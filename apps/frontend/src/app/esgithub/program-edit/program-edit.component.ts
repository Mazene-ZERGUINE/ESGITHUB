import { animate, state, style, transition, trigger } from '@angular/animations';
import { HttpClient } from '@angular/common/http';
import {
  AfterViewInit,
  Component,
  ElementRef,
  OnDestroy,
  OnInit,
  ViewChild,
} from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import * as ace from 'ace-builds';
import { Ace } from 'ace-builds';
import {
  Observable,
  Subject,
  Subscription,
  filter,
  forkJoin,
  switchMap,
  tap,
} from 'rxjs';
import { map, shareReplay, takeUntil } from 'rxjs/operators';
import { UserUtils } from 'src/app/core/Auth/utils/user.utils';
import { AuthService } from '../../core/Auth/service/auth.service';
import { LineCommentsModalComponent } from '../../core/modals/line-comments-modal/line-comments-modal.component';
import {
  ProgramVersionModel,
  VersionModel,
} from '../../core/models/program-version.model';
import { ProgramModel } from '../../core/models/program.model';
import { UserDataModel } from '../../core/models/user-data.model';
import { ModalService } from '../../core/services/modal.service';
import { NotifierService } from '../../core/services/notifier.service';
import { ReactionsEnum } from '../../shared/enums/reactions.enum';
import { CategorizedFiles, CodingPageUtils } from '../coding-page/coding-page-utils';
import { CodingProcessorService } from '../coding-page/coding-processor.service';
import { RunCodeRequestDto } from '../coding-page/models/RunCodeRequestDto';
import { RunCodeResponseDto } from '../coding-page/models/RunCodeResponseDto';
import { AvailableLangages } from '../home-page/home-page.component';
import { EditProgramService } from './edit-program.service';

@Component({
  selector: 'app-program-edit',
  templateUrl: './program-edit.component.html',
  styleUrls: ['./program-edit.component.scss'],
  animations: [
    trigger('slideInOut', [
      state(
        'in',
        style({
          transform: 'translateX(0)',
          opacity: 1,
          display: 'block',
        }),
      ),
      state(
        'out',
        style({
          transform: 'translateX(-100%)',
          opacity: 0,
          display: 'none',
        }),
      ),
      transition('in => out', [animate('600ms ease-in-out')]),
      transition('out => in', [animate('600ms ease-in-out')]),
    ]),
  ],
})
export class ProgramEditComponent implements OnInit, AfterViewInit, OnDestroy {
  @ViewChild('editor') private editor!: ElementRef<HTMLElement>;

  readonly userData$: Observable<UserDataModel> = this.authService.getUserData();
  private getProgramDetailsSubscription: Subscription = new Subscription();
  private likeOrDislikeSubscription: Subscription = new Subscription();
  private loadCommentsSubscription: Subscription = new Subscription();
  private dialogSubscription: Subscription = new Subscription();
  private commentsSubscription: Subscription = new Subscription();

  codeOutput!: {
    output: string;
    status: number;
    output_file_paths?: string[];
    stderr?: string;
  };

  categorizedFiles!: CategorizedFiles;

  fileContents: { [key: string]: string } = {};

  isCommentsOpen = false;

  programComments!: any[];
  aceEditor!: Ace.Editor;
  program!: ProgramModel;
  userReaction: ReactionsEnum | undefined = undefined;
  likes!: number;
  dislikes!: number;
  commentFieldText!: string;
  replyingToCommentId: string | null = null;
  commentReplyFieldText!: string;
  highlightedLines: number[] = [];
  isDescriptionVisible: boolean = false;
  protected selectedInputFiles: File[] = [];
  hideButtonText: string = 'Show description';
  @ViewChild('inputSelect', { static: false }) inputSelect!: ElementRef<HTMLInputElement>;
  // @ViewChild('descriptionButton') descriptionButton!: ElementRef<HTMLButtonElement>;

  readonly anonymousImageUrl =
    'http://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  componentDestroyes$ = new Subject<void>();
  isLoading: boolean = false;
  private readonly programId = this.route.snapshot.params['programId'];

  protected readonly programVersions$: Observable<ProgramVersionModel> =
    this.editProgramService
      .getProgramVersion(this.programId)
      .pipe(shareReplay({ refCount: true, bufferSize: 1 }));

  readonly componentDestroyer$ = new Subject<void>();

  protected selectedVersion: ProgramModel | VersionModel | null = null;

  programData$: Observable<ProgramModel> = this.editProgramService
    .getProgram(this.programId)
    .pipe(
      shareReplay({
        refCount: true,
        bufferSize: 1,
      }),
      map((program: ProgramModel) => program),
    );

  constructor(
    private readonly authService: AuthService,
    private readonly editProgramService: EditProgramService,
    private readonly route: ActivatedRoute,
    private readonly notifier: NotifierService,
    private readonly modalService: ModalService,
    private readonly codeProccesorService: CodingProcessorService,
    readonly http: HttpClient,
  ) {}

  ngOnInit(): void {
    this.programData$
      .pipe(
        takeUntil(this.componentDestroyer$),
        map((program) => {
          this.program = program;
          this.selectedVersion = program;
        }),
      )
      .subscribe();
  }

  ngAfterViewInit(): void {
    this.loadProgramDetails();
  }

  ngOnDestroy(): void {
    this.getProgramDetailsSubscription.unsubscribe();
    this.getProgramDetailsSubscription.unsubscribe();
    this.loadCommentsSubscription.unsubscribe();
    this.likeOrDislikeSubscription.unsubscribe();
    this.dialogSubscription.unsubscribe();
    this.commentsSubscription.unsubscribe();

    this.componentDestroyes$.next();
    this.componentDestroyes$.complete();
  }

  loadProgramDetails(): void {
    this.getProgramDetailsSubscription = this.route.params
      .pipe(
        map((routeParams) => routeParams['programId']),
        filter((programId) => programId !== undefined),
        switchMap((programId: string) =>
          forkJoin({
            programDetails: this.editProgramService.getProgram(programId),
            programComments: this.editProgramService.getProgramComments(programId),
            userData: this.userData$,
          }),
        ),
        tap(({ programDetails, programComments, userData }) => {
          this.program = programDetails;
          this.userReaction = this.program.reactions.find(
            (reaction) => reaction.user.userId === userData.userId,
          )?.type;
          this.likes = this.program.reactions.filter(
            (reaction) => reaction.type === ReactionsEnum.LIKE,
          ).length;
          this.dislikes = this.program.reactions.filter(
            (reaction) => reaction.type === ReactionsEnum.DISLIKE,
          ).length;
          this.aceEditor = ace.edit(this.editor.nativeElement);
          this.aceEditor.setTheme('ace/theme/nord_dark');

          if (programDetails.programmingLanguage === AvailableLangages.CPLUSPLUS) {
            this.aceEditor.session.setMode('ace/mode/c_cpp');
          } else {
            this.aceEditor.session.setMode(
              'ace/mode/' + this.program.programmingLanguage,
            );
          }
          this.aceEditor.setOptions({
            fontSize: '15px',
            showLineNumbers: true,
            highlightActiveLine: true,
            readOnly: true,
            useWrapMode: true,
          });
          this.aceEditor.setValue(this.program.sourceCode);
          this.aceEditor.on('guttermousedown', (e: any) => this.onGutterClick(e));
          this.programComments = this.filterComments(programComments);
          this.highlightedLines = this.getHighlightedLines(programComments);
          this.addCommentAnnotations(this.highlightedLines);
        }),
      )
      .subscribe();
  }

  onProgramVersionSelect(): void {
    this.aceEditor.setValue(this.selectedVersion?.sourceCode as string);
    if ((this.selectedVersion as ProgramModel).programId === this.programId) {
      this.reloadProgramComments();
    }
  }

  private onGutterClick(e: any): void {
    e.preventDefault();
    console.log('object');
    const target = e.domEvent.target;
    if (target.className.indexOf('ace_gutter-cell') === -1) {
      return;
    }
    const row = e.getDocumentPosition().row;
    if (this.dialogSubscription) {
      this.dialogSubscription.unsubscribe();
    }
    this.modalService
      .openDialog(LineCommentsModalComponent, 900, {
        lineNumber: row,
        programId: this.program.programId,
      })
      .subscribe(() => {
        this.reloadProgramComments();
      });
  }

  private reloadProgramComments(): void {
    this.loadCommentsSubscription = this.editProgramService
      .getProgramComments(this.program.programId)
      .subscribe((comments) => {
        this.programComments = this.filterComments(comments);
        this.highlightedLines = this.getHighlightedLines(comments);
        this.addCommentAnnotations(this.highlightedLines);
      });
  }

  private filterComments(comments: any[]): any[] {
    const replyCommentIds = this.getReplyCommentIds(comments);
    return comments.filter(
      (comment) =>
        !replyCommentIds.has(comment.commentId) && comment.codeLineNumber === null,
    );
  }

  private getReplyCommentIds(comments: any[]): Set<string> {
    const replyCommentIds = new Set<string>();

    const collectReplyCommentIds = (commentArray: any[]): void => {
      for (const comment of commentArray) {
        if (comment.replies && comment.replies.length > 0) {
          for (const reply of comment.replies) {
            replyCommentIds.add(reply.commentId);
          }
          collectReplyCommentIds(comment.replies);
        }
      }
    };

    collectReplyCommentIds(comments);
    return replyCommentIds;
  }

  private getHighlightedLines(comments: any[]): number[] {
    return comments
      .filter((comment) => comment.codeLineNumber !== null)
      .map((comment) => comment.codeLineNumber);
  }

  private addCommentAnnotations(lines: number[]): void {
    const session = this.aceEditor.getSession();
    const annotations = lines.map((line) => ({
      row: line,
      column: 0,
      text: 'Comment',
      type: 'warning',
    }));
    session.setAnnotations(annotations);
  }

  onHanleOpenComment(): void {
    this.isCommentsOpen = !this.isCommentsOpen;
  }

  onFormatCommentAt(comment: string): string {
    return UserUtils.calculateElapsed(comment);
  }

  onLikeClick(): void {
    this.likeOrDislikeSubscription = this.userData$
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.likeOrDislikeProgram(
            ReactionsEnum.LIKE,
            this.program.programId,
            userId,
          ),
        ),
        tap(() => this.loadProgramDetails()),
      )
      .subscribe();
  }

  onDislikeClick(): void {
    this.likeOrDislikeSubscription = this.userData$
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.likeOrDislikeProgram(
            ReactionsEnum.DISLIKE,
            this.program.programId,
            userId,
          ),
        ),
        tap(() => this.loadProgramDetails()),
      )
      .subscribe();
  }

  onCommentClick(): void {
    this.commentsSubscription = this.userData$
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.submitComment(
            this.program.programId,
            userId,
            this.commentFieldText,
          ),
        ),
        tap(() => {
          this.reloadProgramComments();
          this.notifier.showSuccess('Comment submitted successfully.');
          this.commentFieldText = '';
        }),
      )
      .subscribe();
  }

  onReplyClick(commentId: string): void {
    this.replyingToCommentId = this.replyingToCommentId === commentId ? null : commentId;
  }

  onSubmitReply(commentId: string): void {
    this.commentsSubscription = this.userData$
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.replyToComment(
            commentId,
            userId,
            this.program.programId,
            this.commentReplyFieldText,
          ),
        ),
      )
      .subscribe(() => {
        this.reloadProgramComments();
        this.notifier.showSuccess('Comment submitted successfully.');
        this.commentReplyFieldText = '';
        this.replyingToCommentId = null;
      });
  }

  onInputFilesSelect(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      Array.from(input.files).forEach((file) => {
        this.selectedInputFiles.push(file);
      });
      this.inputSelect.nativeElement.value = '';
    }
  }

  onRunCodeClick(): void {
    if (this.program.inputTypes.length > 0 || this.program.outputTypes.length > 0) {
      if (this.selectedInputFiles.length <= 0 && this.program.inputTypes.length > 0) {
        this.notifier.showWarning(
          'Input files are required for this program check description for more details',
        );
        // this.descriptionButton.nativeElement.focus();
        return;
      }

      if (this.selectedInputFiles.length !== this.selectedInputFiles.length) {
        this.notifier.showWarning(
          'the number of files you have selected dont match with the required files',
        );
        // this.descriptionButton.nativeElement.focus();
        return;
      }
      this.isLoading = true;
      const formData = this.buildFormData();
      this.codeProccesorService.sendCodeWithFilesToProcess(formData).subscribe({
        next: (response: any) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    } else {
      this.isLoading = true;
      const payload = this.buildPayload();
      this.codeProccesorService.sendCodeToProcess(payload).subscribe({
        next: (response: RunCodeResponseDto) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    }
  }

  private buildPayload(): RunCodeRequestDto {
    return {
      programmingLanguage: this.program.programmingLanguage,
      sourceCode: this.program.sourceCode,
    };
  }

  // private handleResponse(response: RunCodeResponseDto): void {
  //   if (response.result.output_file_paths) {
  //     if (response.result.output_file_paths.length > 0) {
  //       this.codeOutput = {
  //         output: response.result.stdout,
  //         status: response.result.returncode,
  //         output_file_paths: response.result.output_file_paths,
  //       };
  //       this.categorizedFiles = CodingPageUtils.categorizeFiles(
  //         response.result.output_file_paths,
  //       );
  //     }
  //   }
  //   const dialog = this.modalService.openDialog(
  //     ShowCodeExecutionResultModalComponent,
  //     700,
  //     {
  //       code: response.result.returncode,
  //       stdout: response.result.stdout,
  //       stderr: response.result.stderr,
  //     },
  //   );
  //   dialog
  //     .pipe(
  //       takeUntil(this.componentDestroyes$),
  //       tap(() => {
  //         this.notifier.showSuccess('code executed completed successfully.');
  //         this.cleanAll();
  //       }),
  //     )
  //     .subscribe();
  //   this.isLoading = false;
  // }

  private handleResponse(response: RunCodeResponseDto): void {
    if (response.result.returncode === 0) {
      this.codeOutput = {
        output: response.result.stdout,
        status: response.result.returncode,
        output_file_paths: response.result.output_file_paths,
      };
      const files = response.result.output_file_paths;
      this.categorizedFiles = CodingPageUtils.categorizeFiles(files);

      this.notifier.showSuccess('code executed successfully');
    } else {
      this.codeOutput = {
        output: response.result.stderr,
        status: response.result.returncode,
        stderr: response.result.stderr,
      };
      this.notifier.showError('code returned with error');
    }
    this.isLoading = false;
    this.cleanAll();
  }

  cleanAll(): void {
    this.selectedInputFiles = [];
  }

  private handleError(): void {
    this.isLoading = false;
    this.notifier.showError('Something went wrong!');
  }

  private buildFormData(): FormData {
    const formData = new FormData();

    this.selectedInputFiles.forEach((file) => formData.append('files', file));

    this.program.outputTypes.forEach((format) =>
      formData.append('outputFilesFormats', format),
    );
    formData.append('programmingLanguage', this.program.programmingLanguage);
    formData.append('sourceCode', this.aceEditor.getValue());

    return formData;
  }

  loadFileContent(filePath: string): void {
    this.http.get(filePath, { responseType: 'text' }).subscribe(
      (content) => (this.fileContents[filePath] = content),
      (error) => console.error('Error loading file content', error),
    );
  }

  toggleDescription(): void {
    this.isDescriptionVisible = !this.isDescriptionVisible;
  }

  get descriptionState(): string {
    this.isDescriptionVisible
      ? (this.hideButtonText = 'Hide Description')
      : 'Show Description';
    return this.isDescriptionVisible ? 'in' : 'out';
  }

  protected readonly ReactionsEnum = ReactionsEnum;
}
