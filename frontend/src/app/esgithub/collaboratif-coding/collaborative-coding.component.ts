import {
  Component,
  ViewChild,
  ElementRef,
  AfterViewInit,
  OnDestroy,
  OnInit,
  ChangeDetectorRef,
} from '@angular/core';
import * as ace from 'ace-builds';
import 'ace-builds/src-noconflict/theme-nord_dark';
import 'ace-builds/src-noconflict/mode-javascript';
import 'ace-builds/src-noconflict/mode-python';
import 'ace-builds/src-noconflict/mode-c_cpp';
import 'ace-builds/src-noconflict/mode-php';
import { Ace } from 'ace-builds';
import { RunCodeRequestDto } from '../coding-page/models/RunCodeRequestDto';
import { CodingProcessorService } from '../coding-page/coding-processor.service';
import { RunCodeResponseDto } from '../coding-page/models/RunCodeResponseDto';
import { NotifierService } from '../../core/services/notifier.service';
import { ActivatedRoute, Router } from '@angular/router';
import { io, Socket } from 'socket.io-client';
import { BehaviorSubject, debounceTime, Observable, Subject } from 'rxjs';
import { AuthService } from '../../core/Auth/service/auth.service';
import { first, map } from 'rxjs/operators';
import { ModalService } from '../../core/services/modal.service';
import { ConfirmationModalComponent } from '../../core/modals/conifrmatio-modal/confirmation-modal.component';
import { UserDataModel } from '../../core/models/user-data.model';
import { environment } from '../../../environment/environment';
import { AvailableLangages } from '../home-page/home-page.component';
import { FileTypesEnum } from 'src/app/shared/enums/FileTypesEnum';
import { CategorizedFiles, CodingPageUtils } from '../coding-page/coding-page-utils';
import { HttpClient } from '@angular/common/http';

interface CodeChangePayload {
  code: string;
}

interface CursorChangePayload {
  cursor: Ace.Point;
}

@Component({
  selector: 'app-collaboratif-coding',
  templateUrl: './collaborative-coding.component.html',
  styleUrls: ['./collaborative-coding.component.scss'],
})
export class CollaborativeCodingComponent implements AfterViewInit, OnDestroy, OnInit {
  @ViewChild('editor') private editor!: ElementRef<HTMLElement>;
  @ViewChild('inputSelect', { static: false }) inputSelect!: ElementRef<HTMLInputElement>;

  aceEditor!: Ace.Editor;
  selectedLanguage = AvailableLangages.JAVASCRIPT;

  isLoading = false;

  codeOutput!: {
    output: string;
    status: number;
    output_file_paths?: string[];
    stderr?: string;
  };

  fileTypes = Object.values(FileTypesEnum);

  protected selectedInputFiles: File[] = [];

  private selectedOutputFormats: string[] = [];

  protected sessionUrl!: string;

  private socket!: Socket;

  private codeChange$ = new Subject<CodeChangePayload>();

  private cursorChange$ = new Subject<CursorChangePayload>();

  private isInternalChange: boolean = false;

  private ownerId!: string;

  private sessionId!: string;
  protected userAccess!: string;

  protected isWaitingForApproval: boolean = false;

  protected userTmpName: string = '';

  private userDataSubject = new BehaviorSubject<UserDataModel | null>(null);
  userData$: Observable<UserDataModel | null> = this.userDataSubject.asObservable();

  fileContents: { [key: string]: string } = {};

  categorizedFiles!: CategorizedFiles;

  constructor(
    private readonly codeProcessorService: CodingProcessorService,
    private readonly notifier: NotifierService,
    private readonly activatedRoute: ActivatedRoute,
    private readonly route: ActivatedRoute,
    private readonly cdr: ChangeDetectorRef,
    private readonly router: Router,
    private readonly authService: AuthService,
    private readonly modalService: ModalService,
    private readonly http: HttpClient,
  ) {}

  ngOnInit(): void {
    this.ownerId = this.activatedRoute.snapshot.params['ownerId'];
    this.sessionId = this.activatedRoute.snapshot.params['sessionId'];
    const apiUrl = environment.baseUrl.replace('/api/v1', '');
    this.sessionUrl = `${apiUrl}/collaborate/${this.sessionId}/${this.ownerId}`;
    this.checkUserRole();
    this.userAccess = this.activatedRoute.snapshot.queryParams['access'];
    this.initializeWebSocketConnection();
    this.setupDebouncedCodeChange();
    this.setupDebouncedCursorChange();
    this.cdr.detectChanges();
  }

  ngAfterViewInit(): void {
    this.aceEditor = ace.edit(this.editor.nativeElement);
    this.aceEditor.setTheme('ace/theme/nord_dark');
    this.aceEditor.session.setMode('ace/mode/javascript');
    this.aceEditor.setOptions({
      fontSize: '15px',
      showLineNumbers: true,
      highlightActiveLine: true,
      readOnly: false,
      useWrapMode: true,
    });

    this.isInternalChange = false;

    this.aceEditor.on('change', () => {
      if (!this.isInternalChange) {
        const code = this.aceEditor.getValue();
        this.codeChange$.next({ code });
      }
    });

    this.aceEditor.getSession().selection.on('changeCursor', () => {
      if (!this.isInternalChange) {
        const cursor = this.aceEditor.getCursorPosition();
        this.cursorChange$.next({ cursor });
      }
    });

    this.cdr.detectChanges();

    if (this.socket) {
      this.socket.on('loadCode', (payload: CodeChangePayload) => {
        this.updateEditorContent(payload);
      });

      this.socket.on('codeUpdate', (payload: CodeChangePayload) => {
        this.updateEditorContent(payload);
      });

      this.socket.on('cursorUpdate', (payload: CursorChangePayload) => {
        this.updateCursor(payload);
      });
    }
  }

  private initializeWebSocketConnection(): void {
    this.socket = io('http://localhost:3000/collaboratif-coding', {
      withCredentials: true,
    });

    this.socket.on('connect', () => {
      this.checkUserAccess();
    });

    this.socket.on('disconnect', () => {
      console.log('Disconnected from WebSocket server');
    });

    this.socket.on('connect_error', (error) => {
      console.error('WebSocket connection error:', error);
    });

    this.socket.on('requestAuthorization', () => {
      this.showAuthorizationDialog();
    });

    this.socket.on('authorizationGranted', () => {
      this.isWaitingForApproval = false;
      this.socket.emit('joinSession', this.sessionId);
    });

    this.socket.on('authorizationDenied', () => {
      this.isWaitingForApproval = false;
      this.notifier.showError('your request has been denied by the owner');
      this.router.navigate(['/auth']);
    });
  }

  private checkUserAccess(): void {
    console.log(this.userAccess);
    if (this.userAccess === 'owner') {
      this.isWaitingForApproval = false;
      this.socket.emit('joinSession', this.sessionId);
    } else {
      this.isWaitingForApproval = true;
      this.socket.emit('requestAccess', this.sessionId);
    }
  }

  private showAuthorizationDialog(): void {
    const randomUserName = `user_${Math.floor(10000 + Math.random() * 90000)}`;
    this.userTmpName = randomUserName;
    const dialogRef = this.modalService.openDialog(ConfirmationModalComponent, 700, {
      title: 'join request',
      message: `${randomUserName} is asking to join the coding session authorize ?'`,
    });

    dialogRef.subscribe((result: any) => {
      if (result) {
        this.socket.emit('grantAccess', this.sessionId);
      } else {
        this.socket.emit('denyAccess', this.sessionId);
      }
    });
  }

  ngOnDestroy(): void {
    this.socket.disconnect();
    this.codeChange$.unsubscribe();
    this.cursorChange$.unsubscribe();
  }

  onSelectedLanguageUpdate(language: AvailableLangages): void {
    this.selectedLanguage = language;
    this.setDefaultCode(this.selectedLanguage);
    this.aceEditor.session.setMode('ace/mode/' + this.getAceMode(this.selectedLanguage));
  }

  onRunCodeClick(): void {
    this.isLoading = true;
    if (this.selectedInputFiles.length > 0 || this.selectedOutputFormats.length > 0) {
      const formData = this.buildFormData();
      this.codeProcessorService.sendCodeWithFilesToProcess(formData).subscribe({
        next: (response: any) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    } else {
      const payload = this.buildPayload();
      this.codeProcessorService.sendCodeToProcess(payload).subscribe({
        next: (response: RunCodeResponseDto) => this.handleResponse(response),
        error: () => this.handleError(),
      });
    }
  }

  onClearFilesClick(): void {
    if (this.selectedInputFiles.length === 0) {
      this.notifier.showWarning('no files have been selected');
      return;
    }
    this.selectedInputFiles = [];
    this.notifier.showSuccess('files cleared.');
  }

  onAddFormatClick(format: string): void {
    this.selectedOutputFormats.push(format);
  }

  getSelectedOutputFilesNumbers(value: string): number {
    return this.selectedOutputFormats.filter((format) => format === value).length;
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

  copySessionUrl(): void {
    navigator.clipboard
      .writeText(this.sessionUrl)
      .then(() => {
        this.notifier.showSuccess('URL copied to clipboard!');
      })
      .catch(() => {
        this.notifier.showError('Failed to copy: ');
      });
  }

  loadFileContent(filePath: string): void {
    this.http.get(filePath, { responseType: 'text' }).subscribe(
      (content) => (this.fileContents[filePath] = content),
      (error) => console.error('Error loading file content', error),
    );
  }

  private checkUserRole(): void {
    if (!this.authService.isAuthenticated()) {
      this.router.navigate(['collaborate/', this.sessionId, this.ownerId], {
        queryParams: { access: 'invited', id: 'no-authenticated' },
      });
    } else {
      this.authService
        .getUserData()
        .pipe(
          first(),
          map((user) => {
            if (user.userId === this.ownerId) {
              this.router.navigate(['collaborate/', this.sessionId, this.ownerId], {
                queryParams: { access: 'owner', id: this.ownerId },
              });
              this.userAccess = 'owner';
            } else {
              this.router.navigate(['collaborate/', this.sessionId, this.ownerId], {
                queryParams: { access: 'invited', id: user.userId },
              });
              this.userAccess = 'invited';
            }
            this.userDataSubject.next(user);
            this.cdr.detectChanges();
          }),
        )
        .subscribe();
    }
  }

  private setupDebouncedCodeChange(): void {
    this.codeChange$.pipe(debounceTime(500)).subscribe((payload: CodeChangePayload) => {
      this.socket.emit('codeChange', { sessionId: this.sessionId, ...payload });
    });
  }

  private setupDebouncedCursorChange(): void {
    this.cursorChange$
      .pipe(debounceTime(300))
      .subscribe((payload: CursorChangePayload) => {
        this.socket.emit('cursorChange', { sessionId: this.sessionId, ...payload });
      });
  }

  private updateEditorContent(payload: CodeChangePayload): void {
    const currentCursor = this.aceEditor.getCursorPosition();
    this.isInternalChange = true;
    this.aceEditor.session.setValue(payload.code);
    this.aceEditor.moveCursorToPosition(currentCursor);
    this.isInternalChange = false;
    this.cdr.detectChanges();
  }

  private updateCursor(payload: CursorChangePayload): void {
    if (!payload.cursor) {
      console.error('Cursor is undefined:', payload);
      return;
    }

    this.isInternalChange = true;
    const scrollTop = this.aceEditor.session.getScrollTop();
    const scrollLeft = this.aceEditor.session.getScrollLeft();
    this.aceEditor.moveCursorToPosition(payload.cursor);
    this.aceEditor.session.setScrollTop(scrollTop);
    this.aceEditor.session.setScrollLeft(scrollLeft);
    this.isInternalChange = false;
    this.cdr.detectChanges();
  }

  private buildFormData(): FormData {
    const formData = new FormData();

    this.selectedInputFiles.forEach((file) => formData.append('files', file));
    const outputFormats =
      this.selectedOutputFormats.length === 1
        ? [this.selectedOutputFormats[0]]
        : this.selectedOutputFormats;

    outputFormats.forEach((format) => formData.append('outputFilesFormats', format));
    formData.append('programmingLanguage', this.selectedLanguage);
    formData.append('sourceCode', this.aceEditor.getValue());

    return formData;
  }

  private buildPayload(): RunCodeRequestDto {
    return {
      programmingLanguage: this.selectedLanguage,
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
        this.codeProcessorService.downloadFilesAsZip(files);
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
    this.cleanAll();
  }

  private handleError(): void {
    this.codeOutput = {
      status: 1,
      output: 'Request has reached timeout',
    };
    this.notifier.showWarning('request has reached timeout');
    this.isLoading = false;
  }

  private cleanAll(): void {
    this.selectedOutputFormats = [];
    this.selectedInputFiles = [];
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

  private setDefaultCode(language: string): void {
    if (language === 'python') {
      this.aceEditor.setValue(`def hello():
  print("hello world")
`);
    } else if (language === 'javascript') {
      this.aceEditor.setValue(`function hello() {
  console.log("Hello, world!");
}`);
    } else if (language === 'c++') {
      this.aceEditor.setValue(`#include <iostream>
using namespace std;

int main() {
  cout << "Hello, world!" << endl;
  return 0;
}`);
    } else if (language === 'php') {
      this.aceEditor.setValue(`<?php
echo "Hello, world!";
?>`);
    }
  }
}
