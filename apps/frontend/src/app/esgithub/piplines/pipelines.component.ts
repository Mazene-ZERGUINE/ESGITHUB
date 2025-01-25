import { animate, state, style, transition, trigger } from '@angular/animations';
import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  ElementRef,
  OnDestroy,
  OnInit,
  ViewChild,
} from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import { BehaviorSubject, Observable, Subject, combineLatest, finalize, tap } from 'rxjs';
import { map, shareReplay, startWith, switchMap, takeUntil } from 'rxjs/operators';
import { NavigationService } from 'src/app/core/Auth/service/navigation.service';
import { environment } from '../../../environment/environment';
import { ProgramModel } from '../../core/models/program.model';
import { NotifierService } from '../../core/services/notifier.service';
import { CodingProcessorService } from '../coding-page/coding-processor.service';
import { AvailableLangages } from '../home-page/home-page.component';
import { PipelinesService } from './pipelines.service';
import { CategorizedFiles, CodingPageUtils } from '../coding-page/coding-page-utils';
import { HttpClient } from '@angular/common/http';

export const availableLangagesQueryParamKey = 'availablelangages';

@Component({
  selector: 'app-piplines',
  templateUrl: './pipelines.component.html',
  styleUrls: ['./pipelines.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
  animations: [
    trigger('fadeIn', [
      state('void', style({ opacity: 0 })),
      transition(':enter', [animate('1s ease-in', style({ opacity: 1 }))]),
    ]),
  ],
})
export class PipelinesComponent implements OnInit, OnDestroy {
  @ViewChild('fileSelector', { static: false })
  inputSelect!: ElementRef<HTMLInputElement>;
  @ViewChild('dropZone', { static: false }) dropZone!: ElementRef<HTMLElement>;

  readonly pipelineFormFilter = new FormGroup({
    availableLangages: new FormControl<AvailableLangages[]>([]),
    searchQuery: new FormControl<string>('', { nonNullable: true }),
  });

  private componentDestroyer$ = new Subject<void>();
  private refreshPrograms$ = new Subject<void>();
  private selectedLanguages$ = new BehaviorSubject<string[]>([]);
  private searchQuery$ = new BehaviorSubject<string>('');
  private inputFilesFormats$ = new BehaviorSubject<string[]>([]);
  private latestOutputFilesFormats$ = new BehaviorSubject<string[]>([]);

  protected selectedInputFiles: File[] = [];
  protected droppedPrograms: ProgramModel[] = [];
  protected isLoading: boolean = false;
  protected generatedFiles!: CategorizedFiles;
  protected isRefreshing: boolean = false;
  protected outputError?: string;

  isOutputOpen = false;

  fileContents: { [key: string]: string } = {};

  private readonly fileIconMapping: { [key: string]: string } = {
    pdf: 'https://upload.wikimedia.org/wikipedia/commons/8/87/PDF_file_icon.svg',
    png: 'https://images.freeimages.com/fic/images/icons/2275/sinem/512/png_file_icon.png',
    jpeg: 'https://images.freeimages.com/fic/images/icons/2275/sinem/512/jpeg_file_icon.png',
    csv: 'https://upload.wikimedia.org/wikipedia/commons/1/18/Text-csv-text.svg',
    yml: 'https://freepngimg.com/icon/download/file/10375-yaml-file-format.png',
    json: 'https://upload.wikimedia.org/wikipedia/commons/5/56/JSON_Formatter.svg',
    xlsx: 'https://upload.wikimedia.org/wikipedia/commons/c/c6/.csv_icon.svg',
    txt: 'https://upload.wikimedia.org/wikipedia/commons/2/23/Text-txt.svg',
  };

  readonly AvailableLangages = Object.values(AvailableLangages);

  readonly availableLangagesQueryParam$: Observable<AvailableLangages[] | null> =
    this.navigationService
      .createQueryParamStream<AvailableLangages>(
        availableLangagesQueryParamKey,
        AvailableLangages,
      )
      .pipe(
        tap((selectedLangages) => {
          this.pipelineFormFilter.controls.availableLangages.setValue(selectedLangages);
        }),
      );

  protected programsList$: Observable<ProgramModel[]> = combineLatest([
    this.refreshPrograms$.pipe(startWith(undefined)),
    this.availableLangagesQueryParam$,
    this.pipelineFormFilter.controls.searchQuery.valueChanges.pipe(startWith('')),
    this.inputFilesFormats$,
    this.latestOutputFilesFormats$,
  ]).pipe(
    switchMap(
      ([, selectedLanguages, searchQuery, inputFilesFormats, latestOutputFilesFormats]) =>
        this.pipelinesService.getFilesPrograms$().pipe(
          map((programList) =>
            programList.filter((program) => {
              const matchesLanguage =
                selectedLanguages === null ||
                selectedLanguages.includes(program.programmingLanguage);

              const matchesSearch = program.description
                ?.toLowerCase()
                .includes(searchQuery.toLowerCase());
              const matchesInputFormat =
                inputFilesFormats.length === 0 ||
                inputFilesFormats.every((format) =>
                  program.inputTypes.some(
                    (inputType) => inputType.toLowerCase() === format,
                  ),
                );
              const matchesLatestOutputFormat =
                latestOutputFilesFormats.length === 0 ||
                latestOutputFilesFormats.some((format) =>
                  program.inputTypes.some(
                    (inputType) => inputType.toLowerCase() === format,
                  ),
                );
              return (
                matchesLanguage &&
                matchesSearch &&
                matchesInputFormat &&
                matchesLatestOutputFormat
              );
            }),
          ),
          tap(() => {
            this.isRefreshing = true;
            // eslint-disable-next-line angular/timeout-service
            setTimeout(() => {
              this.isRefreshing = false;
              this.cdr.markForCheck();
            }, 1500);
          }),
        ),
    ),
    shareReplay({ refCount: true, bufferSize: 1 }),
  );

  constructor(
    private readonly pipelinesService: PipelinesService,
    private readonly notifierService: NotifierService,
    private readonly cdr: ChangeDetectorRef,
    private readonly codeProcessorService: CodingProcessorService,
    private readonly router: Router,
    readonly http: HttpClient,
    readonly navigationService: NavigationService,
  ) {}

  ngOnInit(): void {
    // eslint-disable-next-line angular/timeout-service
    this.isRefreshing = true;
    // eslint-disable-next-line angular/timeout-service
    setTimeout(() => {
      this.isRefreshing = false;
      this.cdr.markForCheck();
    }, 2000);
    this.refreshPrograms$.next();
  }

  ngOnDestroy(): void {
    this.componentDestroyer$.next();
    this.componentDestroyer$.complete();
  }

  onHanleOpenOutput(): void {
    this.isOutputOpen = !this.isOutputOpen;
    console.log(this.isOutputOpen);
  }

  onSelectStartFiles(event: any): void {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      Array.from(input.files).forEach((file) => {
        this.selectedInputFiles.push(file);
        console.log(file);
        const fileFormat = file.name.split('.').pop()?.toLowerCase() || '';
        if (fileFormat && !this.inputFilesFormats$.value.includes(fileFormat)) {
          this.inputFilesFormats$.next([...this.inputFilesFormats$.value, fileFormat]);
        }
      });
      this.inputSelect.nativeElement.value = '';
      this.refreshPrograms$.next();
    }
  }

  handleAvailableLangage(selectedLangage: AvailableLangages): void {
    const currentLangages =
      this.pipelineFormFilter.controls.availableLangages.value || [];
    const updatedLangages = currentLangages.includes(selectedLangage)
      ? currentLangages.filter((lang) => lang !== selectedLangage)
      : [...currentLangages, selectedLangage];

    if (updatedLangages.length > 0) {
      this.navigationService.addQueriesToCurrentUrl({
        [availableLangagesQueryParamKey]: updatedLangages.join(','),
      });
    } else {
      this.navigationService.removeQueryParam(availableLangagesQueryParamKey);
    }
  }

  onLanguageChange(event: any): void {
    const checkbox = event.target as HTMLInputElement;
    const value = checkbox.value.toLowerCase();
    const selectedLanguages = this.selectedLanguages$.value;

    if (checkbox.checked) {
      this.selectedLanguages$.next([...selectedLanguages, value]);
    } else {
      this.selectedLanguages$.next(selectedLanguages.filter((lang) => lang !== value));
    }
    this.refreshPrograms$.next();
  }

  onDragStart(event: DragEvent, program: ProgramModel): void {
    event.dataTransfer?.setData('application/json', JSON.stringify(program));
  }

  loadFileContent(filePath: string): void {
    this.http
      .get(filePath, { responseType: 'text' })
      .pipe(
        takeUntil(this.componentDestroyer$),
        map((content) => {
          this.fileContents[filePath] = content;
          this.cdr.markForCheck();
        }),
      )
      .subscribe();
  }

  onDrop(event: DragEvent): void {
    event.preventDefault();
    const data = event.dataTransfer?.getData('application/json');
    if (data) {
      const program = JSON.parse(data) as ProgramModel;
      if (
        this.selectedInputFiles.length === 0 &&
        program.inputTypes.length > 0 &&
        this.droppedPrograms.length === 0
      ) {
        this.notifierService.showWarning(
          'You must select the start input file first or a program that does not have input files',
        );
        return;
      }
      this.inputFilesFormats$.next([]);
      this.droppedPrograms.push(program);
      this.latestOutputFilesFormats$.next(
        program.outputTypes.map((type) => type.toLowerCase()),
      );
      this.programsList$ = this.programsList$.pipe(
        map((programs) => programs.filter((p) => p.programId !== program.programId)),
      );
      this.refreshPrograms$.next();
      this.cdr.markForCheck();
    }
  }

  onDragOver(event: DragEvent): void {
    event.preventDefault();
  }

  onRunPipeLineClick(): void {
    this.isLoading = true;
    if (this.selectedInputFiles.length === 0) {
      this.notifierService.showError(
        'No input file provided. Select a file and try again.',
      );
      this.isLoading = false;
      return;
    } else {
      const formData = new FormData();
      this.selectedInputFiles.forEach((file) => formData.append('files', file));
      const programsJson = JSON.stringify(this.droppedPrograms);
      formData.append('programs', programsJson);

      this.pipelinesService
        .runPipeLinesWithFiles(formData)
        .pipe(
          takeUntil(this.componentDestroyer$),
          tap((response: { success: boolean; outputLinks: string[]; error?: string }) => {
            if (response.success) {
              const transformedLinks = response.outputLinks.map((link) =>
                this.onGeneratedFile(link),
              );
              this.isOutputOpen = true;
              this.generatedFiles = CodingPageUtils.categorizeFiles(transformedLinks);
              this.notifierService.showSuccess('Pipeline executed successfully.');
            } else {
              this.outputError = response.error;
              this.notifierService.showError('error occurred while running pipelines.');
            }
            this.droppedPrograms = [];
            this.selectedInputFiles = [];
            this.selectedLanguages$.next([]);
            this.searchQuery$.next(''), this.inputFilesFormats$.next([]);
            this.latestOutputFilesFormats$.next([]);
            this.refreshPrograms$.next();
          }),
          finalize(() => {
            this.isLoading = false;
            this.cdr.markForCheck();
          }),
        )
        .subscribe();
    }
  }

  protected onGeneratedFile(filePath: string): string {
    const segments = filePath.split('/');
    const startIndex = segments.indexOf('uploads');
    const url =
      environment.baseUrl.replace('/api/v1', '/') + segments.slice(startIndex).join('/');

    return url;
  }

  protected getFileIcon(fileName: string): string {
    const extension = fileName.split('.').pop()?.toLowerCase() as string;
    return this.fileIconMapping[extension];
  }

  protected onViewProgramClick(programId: string): void {
    const url = this.router.createUrlTree(['/program', programId]).toString();
    // eslint-disable-next-line angular/window-service
    window.open(url, '_blank');
  }
}
