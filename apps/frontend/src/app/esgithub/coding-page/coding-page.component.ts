import {
  AfterViewInit,
  Component,
  ElementRef,
  OnDestroy,
  ViewChild,
} from '@angular/core';
import { Router } from '@angular/router';
import * as ace from 'ace-builds';
import { Ace } from 'ace-builds';
import 'ace-builds/src-noconflict/mode-c_cpp';
import 'ace-builds/src-noconflict/mode-javascript';
import 'ace-builds/src-noconflict/mode-php';
import 'ace-builds/src-noconflict/mode-python';
import 'ace-builds/src-noconflict/theme-nord_dark';
import {
  BehaviorSubject,
  Observable,
  Subscription,
  filter,
  switchMap,
  take,
  tap,
} from 'rxjs';
import { FileTypesEnum } from 'src/app/shared/enums/FileTypesEnum';
import { AuthService } from '../../core/Auth/service/auth.service';
import { ShareCodeModalComponent } from '../../core/modals/share-code-modal/share-code-modal.component';
import { UserDataModel } from '../../core/models/user-data.model';
import { ModalService } from '../../core/services/modal.service';
import { NotifierService } from '../../core/services/notifier.service';
import { AvailableLangages } from '../home-page/home-page.component';
import { CodingProcessorService } from './coding-processor.service';
import { CreateProgramDto } from './models/CreateProgramDto';
import { RunCodeRequestDto } from './models/RunCodeRequestDto';
import { RunCodeResponseDto } from './models/RunCodeResponseDto';
import { CategorizedFiles, CodingPageUtils } from './coding-page-utils';
import { DomSanitizer } from '@angular/platform-browser';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-coding-page',
  templateUrl: './coding-page.component.html',
  styleUrls: ['./coding-page.component.scss'],
})
export class CodingPageComponent implements AfterViewInit, OnDestroy {
  @ViewChild('editor') private editor!: ElementRef<HTMLElement>;
  @ViewChild('inputSelect', { static: false }) inputSelect!: ElementRef<HTMLInputElement>;

  aceEditor!: Ace.Editor;

  selectedLanguage =
    localStorage.getItem('selectedLanguage') ?? AvailableLangages.JAVASCRIPT;

  isLoading = false;

  codeOutput!: {
    output: string;
    status: number;
    output_file_paths?: string[];
    stderr?: string;
  };

  fileContents: { [key: string]: string } = {};

  categorizedFiles!: CategorizedFiles;

  readonly isPageLoading$ = new BehaviorSubject<boolean>(false);

  readonly AvailableLangages = AvailableLangages;

  private userId!: string;

  image =
    'https://code-runner-service-bucket.s3.eu-west-1.amazonaws.com/bd47de4f-73e6-4ea1-beba-26a900dafb9a/out/output_file_bd47de4f-73e6-4ea1-beba-26a900dafb9a_0.jpg';

  readonly fileTypes = Object.values(FileTypesEnum);

  protected selectedInputFiles: File[] = [];

  private selectedOutputFormats: string[] = [];

  readonly userData$: Observable<UserDataModel> = this.authService.getUserData();

  private runCodeSubscription = new Subscription();

  private getUserDataSubscription = new Subscription();

  constructor(
    private readonly codeProcessorService: CodingProcessorService,
    private readonly notifier: NotifierService,
    private readonly modalService: ModalService,
    private readonly router: Router,
    private readonly authService: AuthService,
    private readonly sanitizer: DomSanitizer,
    private http: HttpClient,
  ) {}

  ngAfterViewInit(): void {
    this.getUserDataSubscription = this.authService
      .getUserData()
      .subscribe((user: UserDataModel) => {
        this.userId = user.userId;
      });
    this.aceEditor = ace.edit(this.editor.nativeElement);
    this.aceEditor.setTheme('ace/theme/nord_dark');
    this.aceEditor.session.setMode('ace/mode/' + this.getAceMode(this.selectedLanguage));
    this.aceEditor.setOptions({
      fontSize: '15px',
      showLineNumbers: true,
      highlightActiveLine: true,
      readOnly: false,
      useWrapMode: true,
    });
    this.loadCodeFromLocalStorage();
  }

  ngOnDestroy(): void {
    this.runCodeSubscription.unsubscribe();
    this.getUserDataSubscription.unsubscribe();
  }

  onSelectedLanguageUpdate(language: AvailableLangages): void {
    this.selectedLanguage = language;
    localStorage.setItem('selectedLanguage', language);
    this.loadCodeFromLocalStorage();
    this.updateAceEditorLanguage();
  }

  updateAceEditorLanguage(): void {
    this.aceEditor.session.setMode('ace/mode/' + this.getAceMode(this.selectedLanguage));
  }

  private loadCodeFromLocalStorage(): void {
    const code = localStorage.getItem('code_' + this.selectedLanguage);
    if (code) {
      this.aceEditor.setValue(code);
    } else {
      this.setDefaultCode(this.selectedLanguage);
    }
  }

  onFileSelected(event: Event): void {
    const target = event.target as HTMLInputElement;
    const file: File | null = target.files ? target.files[0] : null;

    if (file) {
      this.readFile(file);
    }
  }

  private readFile(file: File): void {
    const fileReader = new FileReader();
    fileReader.onload = () => {
      this.aceEditor.setValue(fileReader.result as string);
    };
    fileReader.readAsText(file);
  }

  onRunCodeClick(): void {
    this.isLoading = true;
    if (this.selectedInputFiles.length > 0 || this.selectedOutputFormats.length > 0) {
      const formData = this.buildFormData();
      this.runCodeSubscription = this.codeProcessorService
        .sendCodeWithFilesToProcess(formData)
        .subscribe({
          next: (response: any) => this.handleResponse(response),
          error: () => this.handleError(),
        });
    } else {
      const payload = this.buildPayload();
      this.runCodeSubscription = this.codeProcessorService
        .sendCodeToProcess(payload)
        .subscribe({
          next: (response: RunCodeResponseDto) => this.handleResponse(response),
          error: () => this.handleError(),
        });
    }

    const code = this.aceEditor.getValue();
    localStorage.setItem('code_' + this.selectedLanguage, code);
  }

  onClearFilesClick(): void {
    if (this.selectedInputFiles.length === 0) {
      this.notifier.showWarning('no files have been selected');
      return;
    }
    this.selectedInputFiles = [];
    this.selectedOutputFormats = [];
  }

  onShareClick(): void {
    this.modalService
      .openDialog(ShareCodeModalComponent, 900, { isGroupProgram: false })
      .pipe(
        filter((result: any) => result !== undefined),
        switchMap((result) => {
          const programDto: CreateProgramDto = {
            ...result,
            programmingLanguage: this.selectedLanguage,
            sourceCode: this.aceEditor.getValue(),
            userId: this.userId,
          };
          return this.codeProcessorService.shareProgram(programDto);
        }),
        tap(() => {
          this.notifier.showSuccess('your program has been published');
          this.router.navigate(['home']);
        }),
      )
      .subscribe();
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

  loadFileContent(filePath: string): void {
    this.http.get(filePath, { responseType: 'text' }).subscribe(
      (content) => (this.fileContents[filePath] = content),
      (error) => console.error('Error loading file content', error),
    );
  }

  onInviteUsersClick(): void {
    this.codeProcessorService
      .generateCodingSession()
      .pipe(
        take(1),
        tap((session: { sessionId: string }) => {
          this.notifier.showSuccess(
            'creating the new coding session you will be redirected soon',
          );
          this.isPageLoading$.next(true);
          // eslint-disable-next-line angular/timeout-service
          setTimeout(() => {
            this.isPageLoading$.next(false);

            this.router.navigate(['collaborate', session.sessionId, this.userId]);
          }, 4000);
        }),
      )
      .subscribe();
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
    if (language === AvailableLangages.PYTHON) {
      this.aceEditor.setValue(`def hello():
      print("hello world")
    `);
    } else if (language === AvailableLangages.JAVASCRIPT) {
      this.aceEditor.setValue(`function hello() {
      console.log("Hello, world!");
    }`);
    } else if (language === AvailableLangages.CPLUSPLUS) {
      this.aceEditor.setValue(`#include <iostream>
    using namespace std;
    int main() {
      cout << "Hello, world!" << endl;
      return 0;
    }`);
    } else if (language === AvailableLangages.PHP) {
      this.aceEditor.setValue(`<?php
    echo "Hello, world!";
    ?>`);
    } else {
      this.loadCodeFromLocalStorage();
    }
  }
}
