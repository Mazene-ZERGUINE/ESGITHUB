import { ChangeDetectionStrategy, Component, OnDestroy, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { Observable, Subject, combineLatest, interval } from 'rxjs';
import {
  distinctUntilChanged,
  map,
  shareReplay,
  startWith,
  switchMap,
  takeUntil,
  tap,
} from 'rxjs/operators';
import { NavigationService } from 'src/app/core/Auth/service/navigation.service';
import { AuthService } from '../../core/Auth/service/auth.service';
import { ProgramModel } from '../../core/models/program.model';
import { UserDataModel } from '../../core/models/user-data.model';
import { ModalService } from '../../core/services/modal.service';
import { ReactionsEnum } from '../../shared/enums/reactions.enum';
import { SocketService } from '../socket.service';
import { HomeService } from './home.service';
import { FileTypesEnum } from 'src/app/shared/enums/FileTypesEnum';

export enum AvailableLangages {
  JAVASCRIPT = 'javascript',
  CPLUSPLUS = 'c++',
  PHP = 'php',
  PYTHON = 'python',
}

export const INTERVAL_REFRESH_TIME = 5000;

export const availableLangagesQueryParamKey = 'availablelangages';

export const inputFileTypeQueryParamKey = 'inputfile';

export const outputFileTypeQueryParamKey = 'outputfile';
@Component({
  selector: 'app-home-page',
  templateUrl: './home-page.component.html',
  styleUrls: ['./home-page.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class HomePageComponent implements OnInit, OnDestroy {
  readonly userData$: Observable<UserDataModel> = this.authService
    .getUserData()
    .pipe(shareReplay({ refCount: true, bufferSize: 1 }));

  readonly filtersOptionsForm = new FormGroup({
    searchQuery: new FormControl<string>('', { nonNullable: true }),
    availableLangages: new FormControl<AvailableLangages[]>([]),
    inputFiles: new FormControl<FileTypesEnum[] | null>([]),
    outputFiles: new FormControl<FileTypesEnum[] | null>([]),
  });

  readonly availableLangagesQueryParam$: Observable<AvailableLangages[] | null> =
    this.navigationService
      .createQueryParamStream<AvailableLangages>(
        availableLangagesQueryParamKey,
        AvailableLangages,
      )
      .pipe(
        tap((selectedLangages) => {
          this.filtersOptionsForm.controls.availableLangages.setValue(selectedLangages);
        }),
      );

  readonly inputFileTypeQueryParam$: Observable<FileTypesEnum[] | null> =
    this.navigationService
      .createQueryParamStream<FileTypesEnum>(inputFileTypeQueryParamKey, FileTypesEnum)
      .pipe(
        tap((selectedInputFiles) => {
          this.filtersOptionsForm.controls.inputFiles.setValue(selectedInputFiles);
        }),
      );

  readonly outputFileTypeQueryParam$: Observable<FileTypesEnum[] | null> =
    this.navigationService
      .createQueryParamStream<FileTypesEnum>(outputFileTypeQueryParamKey, FileTypesEnum)
      .pipe(
        tap((selectedOutputFiles) => {
          this.filtersOptionsForm.controls.outputFiles.setValue(selectedOutputFiles);
        }),
      );

  readonly refreshPrograms$ = new Subject<void>();

  readonly componentDestroy$ = new Subject<void>();

  readonly programsList$: Observable<ProgramModel[]> = combineLatest([
    interval(INTERVAL_REFRESH_TIME).pipe(startWith(0)),
    this.userData$,
    this.refreshPrograms$.pipe(startWith(undefined)),
    this.availableLangagesQueryParam$,
    this.inputFileTypeQueryParam$,
    this.outputFileTypeQueryParam$,
    this.filtersOptionsForm.controls.searchQuery.valueChanges.pipe(startWith('')),
  ]).pipe(
    switchMap(
      ([
        ,
        userData,
        ,
        availableLangagesQueryParam,
        inputFileTypeQueryParam,
        outputFileTypeQueryParam,
        searchQuery,
      ]) =>
        this.homeService.getProgramsList$('public').pipe(
          map((programList) =>
            programList.filter((program) => {
              const matchesUser = program.userId !== userData.userId;
              const matchesSearch = program.description
                ?.toLowerCase()
                .includes(searchQuery.toLowerCase());

              const matchesLanguage =
                availableLangagesQueryParam === null ||
                availableLangagesQueryParam.includes(program.programmingLanguage);

              const matchesInputFiles =
                inputFileTypeQueryParam === null ||
                program.inputTypes.some((inputType) =>
                  inputFileTypeQueryParam.includes(inputType),
                );

              const matchesOuputFiles =
                outputFileTypeQueryParam === null ||
                program.outputTypes.some((inputType) =>
                  outputFileTypeQueryParam.includes(inputType),
                );

              return (
                matchesUser &&
                matchesLanguage &&
                matchesSearch &&
                matchesInputFiles &&
                matchesOuputFiles
              );
            }),
          ),
        ),
    ),
    distinctUntilChanged(),
    shareReplay({ refCount: true, bufferSize: 1 }),
  );

  readonly currentUserProgramCount$: Observable<number> = combineLatest([
    this.userData$,
    this.programsList$,
  ]).pipe(
    map(
      ([userData, programList]) =>
        programList.filter((program) => program.user.userId === userData.userId).length,
    ),
  );

  constructor(
    private readonly homeService: HomeService,
    private readonly authService: AuthService,
    private navigationService: NavigationService,
    private readonly modalService: ModalService,
    private socketService: SocketService,
  ) {}

  ngOnInit(): void {
    this.socketService.on(ReactionsEnum.DISLIKE, () => {
      this.refreshPrograms$.next();
    });
  }

  ngOnDestroy(): void {
    this.componentDestroy$.next();
    this.componentDestroy$.complete();
  }

  likeProgram(event: { programId: string; userId: string }): void {
    this.userData$
      .pipe(
        takeUntil(this.componentDestroy$),
        switchMap((user) =>
          this.homeService.likeOrDislikeProgram(
            ReactionsEnum.LIKE,
            event.programId,
            user.userId,
          ),
        ),
        tap(() => {
          this.refreshPrograms$.next();
        }),
      )
      .subscribe();
  }

  async deleteProgram(event: string): Promise<void> {
    const result = await this.modalService.getConfirmationModelResults(
      'delete program',
      'are you sur you want to delete this program?',
    );
    if (result) {
      this.homeService
        .deleteProgram(event)
        .pipe(
          takeUntil(this.componentDestroy$),
          tap(() => {
            this.refreshPrograms$.next();
          }),
        )
        .subscribe();
    }
  }
}
