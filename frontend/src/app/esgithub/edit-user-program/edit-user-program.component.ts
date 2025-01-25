import {
  Component,
  ElementRef,
  OnDestroy,
  ViewChild,
  AfterViewChecked,
  OnInit,
} from '@angular/core';
import { filter, Observable, of, Subject, switchMap, tap } from 'rxjs';
import { ActivatedRoute, Router } from '@angular/router';
import { AuthService } from '../../core/Auth/service/auth.service';
import { EditProgramService } from '../program-edit/edit-program.service';
import { map, shareReplay, takeUntil } from 'rxjs/operators';
import { Ace } from 'ace-builds';
import { CodingProcessorService } from '../coding-page/coding-processor.service';
import { NotifierService } from '../../core/services/notifier.service';
import { ModalService } from '../../core/services/modal.service';
import { ProgramModel } from '../../core/models/program.model';
import * as ace from 'ace-builds';
import { CodePageUseGuidModalComponent } from '../../core/modals/code-page-use-guid-modal/code-page-use-guid-modal.component';
import { RunCodeResponseDto } from '../coding-page/models/RunCodeResponseDto';
import { RunCodeRequestDto } from '../coding-page/models/RunCodeRequestDto';
import { ShareCodeModalComponent } from '../../core/modals/share-code-modal/share-code-modal.component';
import { CreateProgramDto } from '../coding-page/models/CreateProgramDto';
import { VersionModalComponent } from '../../core/modals/version-modal/version-modal.component';
import {
  ProgramVersionModel,
  VersionModel,
} from '../../core/models/program-version.model';
import { AvailableLangages } from '../home-page/home-page.component';
import { FileTypesEnum } from 'src/app/shared/enums/FileTypesEnum';
import { UserDataModel } from 'src/app/core/models/user-data.model';
import { CategorizedFiles, CodingPageUtils } from '../coding-page/coding-page-utils';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-edit-user-program',
  templateUrl: './edit-user-program.component.html',
  styleUrls: ['./edit-user-program.component.scss'],
})
export class EditUserProgramComponent implements OnInit, OnDestroy, AfterViewChecked {
  readonly componentDestroyer$ = new Subject<void>();

  @ViewChild('editor') private editor!: ElementRef<HTMLElement>;
  @ViewChild('inputSelect', { static: false }) inputSelect!: ElementRef<HTMLInputElement>;

  aceEditor!: Ace.Editor;

  isLoading = false;

  codeOutput!: {
    output: string;
    status: number;
    output_file_paths?: string[];
    stderr?: string;
  };

  readonly fileTypes = Object.values(FileTypesEnum);

  readonly AvailableLangages = AvailableLangages;

  categorizedFiles!: CategorizedFiles;

  fileContents: { [key: string]: string } = {};

  protected selectedInputFiles: File[] = [];

  private selectedOutputFormats: string[] = [];

  private programmingLanguage!: string;

  private isProgramVersion: boolean = false;

  private programVersionId?: string;

  private program!: ProgramModel;

  protected programId: string = this.route.snapshot.params['programId'];

  readonly userData$: Observable<UserDataModel> = this.authService.getUserData().pipe(
    shareReplay({
      refCount: true,
      bufferSize: 1,
    }),
  );

  programData$: Observable<ProgramModel> = this.programEditService
    .getProgram(this.programId)
    .pipe(
      shareReplay({
        refCount: true,
        bufferSize: 1,
      }),
      map((program: ProgramModel) => program),
    );

  protected selectedVersion: VersionModel | ProgramModel | null = null;

  programVersions$: Observable<ProgramVersionModel> = this.programEditService
    .getProgramVersion(this.programId)
    .pipe(
      shareReplay({
        refCount: true,
        bufferSize: 1,
      }),
    );

  private aceEditorInitialized = false;

  constructor(
    private readonly route: ActivatedRoute,
    private readonly authService: AuthService,
    private readonly programEditService: EditProgramService,
    private readonly codeProcessor: CodingProcessorService,
    private readonly notifier: NotifierService,
    private readonly modalService: ModalService,
    private readonly router: Router,
    private readonly http: HttpClient,
  ) {}

  ngOnInit(): void {
    this.programData$
      .pipe(
        takeUntil(this.componentDestroyer$),
        map((program) => {
          this.program = program;
          this.selectedVersion = program;
          this.initializeAceEditor();
        }),
      )
      .subscribe();
  }

  ngAfterViewChecked(): void {
    if (!this.aceEditorInitialized && this.editor) {
      this.initializeAceEditor();
      this.aceEditorInitialized = true;
    }
  }

  ngOnDestroy(): void {
    this.componentDestroyer$.next();
    this.componentDestroyer$.complete();
  }

  private initializeAceEditor(): void {
    this.programData$
      .pipe(
        takeUntil(this.componentDestroyer$),
        tap((program: ProgramModel) => {
          this.program = program;
          this.programmingLanguage = program.programmingLanguage;
          this.aceEditor = ace.edit(this.editor.nativeElement);
          this.aceEditor.setTheme('ace/theme/nord_dark');
          this.aceEditor.session.setMode(
            'ace/mode/' + this.getAceMode(program.programmingLanguage),
          );
          this.aceEditor.setOptions({
            fontSize: '15px',
            showLineNumbers: true,
            highlightActiveLine: true,
            readOnly: false,
            useWrapMode: true,
          });
          this.aceEditor.setValue(program.sourceCode);
        }),
      )
      .subscribe();
  }

  onRunCodeClick(): void {
    this.isLoading = true;
    if (this.selectedInputFiles.length > 0 || this.selectedOutputFormats.length > 0) {
      const formData = this.buildFormData();
      this.codeProcessor.sendCodeWithFilesToProcess(formData).subscribe({
        next: (response: any) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    } else {
      const payload = this.buildPayload();
      this.codeProcessor.sendCodeToProcess(payload).subscribe({
        next: (response: RunCodeResponseDto) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    }
  }

  onShowGuidClick(): void {
    this.modalService
      .openDialog(CodePageUseGuidModalComponent, 700)
      .pipe(takeUntil(this.componentDestroyer$))
      .subscribe();
  }

  onClearSelectedFilesClick(): void {
    this.clearAll();
  }

  onAddFormatClick(format: string): void {
    this.selectedOutputFormats.push(format);
  }

  getSelectedOutputFilesNumbers(value: string): number {
    return this.selectedOutputFormats.filter((format) => format === value).length;
  }

  async onSaveChangesClick(): Promise<void> {
    if (!this.isProgramVersion) {
      const result = await this.modalService.getConfirmationModelResults(
        'update program',
        'do you want to also update the program visibility, files or description ?',
      );
      if (result) {
        const dialog = this.modalService.openDialog(ShareCodeModalComponent, 700, {
          isGroupProgram: false,
        });
        dialog
          .pipe(
            takeUntil(this.componentDestroyer$),
            filter((result: any) => result !== undefined),
            switchMap((result) => {
              const programDto: CreateProgramDto = {
                ...result,
                sourceCode: this.aceEditor.getValue(),
              };
              return this.programEditService.updateProgram(this.programId, programDto);
            }),
            tap(() => this.notifier.showSuccess('Your program has been updated')),
          )
          .subscribe();
      } else {
        const payload = {
          sourceCode: this.aceEditor.getValue(),
        };
        this.programEditService
          .updateProgram(this.programId, payload)
          .pipe(
            takeUntil(this.componentDestroyer$),
            tap(() => this.notifier.showSuccess('your program has been updated')),
          )
          .subscribe();
      }
    } else {
      const result = await this.modalService.getConfirmationModelResults(
        `update program version ${(this.selectedVersion as VersionModel).version}`,
        'do you want modify the current source code of this program version ?',
      );
      if (result) {
        this.programEditService
          .updateProgramVersion(this.programVersionId as string, {
            sourceCode: this.aceEditor.getValue(),
          })
          .pipe(
            takeUntil(this.componentDestroyer$),
            tap(() => {
              this.notifier.showSuccess('Your program version has been updated');
              this.programVersions$ = this.programEditService.getProgramVersion(
                this.programId,
              );
            }),
          )
          .subscribe();
      }
    }
  }

  loadFileContent(filePath: string): void {
    this.http.get(filePath, { responseType: 'text' }).subscribe(
      (content) => (this.fileContents[filePath] = content),
      (error) => console.error('Error loading file content', error),
    );
  }

  async onSaveNewVersionClick(): Promise<void> {
    if (this.isProgramVersion) {
      this.notifier.showWarning(
        'you can not save a new program version from another version',
      );
      this.selectedVersion = this.program;
      this.programData$ = of(this.program);
      this.initializeAceEditor();
      this.isProgramVersion = false;
      return;
    }

    const result = await this.modalService.getConfirmationModelResults(
      'save this updates as new version',
      'do you want to create a new version for this update',
    );

    if (result) {
      this.modalService
        .openDialog(VersionModalComponent, 400)
        .pipe(
          takeUntil(this.componentDestroyer$),
          filter((result: string) => result !== undefined),
          switchMap((result: string) => {
            const payload = {
              version: result,
              programmingLanguage: this.programmingLanguage,
              sourceCode: this.aceEditor.getValue(),
              programId: this.programId,
            };
            return this.programEditService.saveNewVersion(payload);
          }),
          tap(() => {
            this.notifier.showSuccess(`program version has been created`);
            this.programVersions$ = this.programEditService.getProgramVersion(
              this.programId,
            );
          }),
        )
        .subscribe();
    }
  }

  onProgramVersionSelect(): void {
    if ((this.selectedVersion as ProgramModel).programId === this.programId) {
      this.isProgramVersion = false;
      this.programVersionId = undefined;
      this.programData$ = of(this.selectedVersion as ProgramModel);
      this.initializeAceEditor();
    } else {
      this.afterVersionSelect(this.selectedVersion as VersionModel);
      this.isProgramVersion = true;
    }
  }

  async onDeleteProgramOrVersionClick(): Promise<void> {
    let id = this.programId;
    let message = 'are you sur you want to delete this program ?';
    let type = 'program';
    if (this.isProgramVersion) {
      id = this.programVersionId as string;
      type = 'version';
      message = `are you sur you want to delete version ${(this.selectedVersion as VersionModel).version} ?`;
    }

    const result = await this.modalService.getConfirmationModelResults(
      'delete program',
      message,
    );
    if (result) {
      this.programEditService
        .deleteProgramOrVersion(type, id)
        .pipe(
          takeUntil(this.componentDestroyer$),
          tap(() => {
            if (type === 'version') {
              this.notifier.showSuccess('Your program version has been deleted');
              this.programVersions$ = this.programEditService.getProgramVersion(
                this.programId,
              );
              this.programData$ = of(this.program);
              this.initializeAceEditor();
              this.isProgramVersion = false;
            } else {
              this.notifier.showSuccess('Your program has been deleted');
              this.router.navigate(['/profile']);
            }
          }),
        )
        .subscribe();
    }
  }

  private afterVersionSelect(selectedVersion: VersionModel | null): void {
    this.aceEditor.setValue(selectedVersion?.sourceCode as string);
    this.programVersionId = selectedVersion?.programVersionId;
  }

  private buildFormData(): FormData {
    const formData = new FormData();

    this.selectedInputFiles.forEach((file) => formData.append('files', file));
    const outputFormats =
      this.selectedOutputFormats.length === 1
        ? [this.selectedOutputFormats[0]]
        : this.selectedOutputFormats;

    outputFormats.forEach((format) => formData.append('outputFilesFormats', format));
    formData.append('programmingLanguage', this.programmingLanguage); // Use the property here
    formData.append('sourceCode', this.aceEditor.getValue());

    return formData;
  }

  private buildPayload(): RunCodeRequestDto {
    return {
      programmingLanguage: this.programmingLanguage,
      sourceCode: this.aceEditor.getValue(),
    };
  }

  private handleResponse(response: RunCodeResponseDto): void {
    if (response.result.returncode === 0) {
      this.codeOutput = {
        output: response.result.stdout,
        status: response.result.returncode,
        output_file_paths: response.result.output_file_paths,
      };
      const files = response.result.output_file_paths;
      this.categorizedFiles = CodingPageUtils.categorizeFiles(files);

      if (files && files.length > 1) {
        this.codeProcessor.downloadFilesAsZip(files);
      }
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
    this.clearAll();
  }

  private handleError(): void {
    this.codeOutput = {
      status: 1,
      output: 'Request has reached timeout',
    };
    this.notifier.showWarning('request has reached timeout');
    this.isLoading = false;
  }

  private clearAll(): void {
    this.selectedInputFiles = [];
    this.selectedOutputFormats = [];
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

  private getAceMode(language: string): string {
    const modes: { [key: string]: string } = {
      javascript: 'javascript',
      python: 'python',
      'c++': 'c_cpp',
      php: 'php',
    };
    return modes[language] || 'text';
  }
}
