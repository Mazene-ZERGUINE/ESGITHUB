import { group } from '@angular/animations';
import { Component, OnDestroy } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import {
  EMPTY,
  Observable,
  Subject,
  catchError,
  combineLatest,
  filter,
  interval,
  map,
  of,
  shareReplay,
  startWith,
  switchMap,
  take,
  takeUntil,
  tap,
} from 'rxjs';
import { NavigationService } from 'src/app/core/Auth/service/navigation.service';
import { UserUtils } from 'src/app/core/Auth/utils/user.utils';
import { GroupMembersModalComponent } from 'src/app/core/modals/group-members-modal/group-members-modal.component';
import { GroupPublishModalComponent } from 'src/app/core/modals/group-publish-modal/group-publish-modal.component';
import { ShareCodeModalComponent } from 'src/app/core/modals/share-code-modal/share-code-modal.component';
import { AuthService } from '../../../core/Auth/service/auth.service';
import { ConfirmationModalComponent } from '../../../core/modals/conifrmatio-modal/confirmation-modal.component';
import { GroupModel } from '../../../core/models/group.model';
import { ProgramModel } from '../../../core/models/program.model';
import { UserDataModel } from '../../../core/models/user-data.model';
import { ModalService } from '../../../core/services/modal.service';
import { NotifierService } from '../../../core/services/notifier.service';
import { VisibilityEnum } from '../../../shared/enums/visibility.enum';
import { INTERVAL_REFRESH_TIME } from '../../home-page/home-page.component';
import { HomeService } from '../../home-page/home.service';
import { GroupsService } from '../groups.service';
import { FormControl, FormGroup } from '@angular/forms';

@Component({
  selector: 'app-groupe-home',
  templateUrl: './groupe-details.component.html',
  styleUrls: ['./groupe-details.component.scss'],
})
export class GroupeDetailsComponent implements OnDestroy {
  readonly componentDestroy$ = new Subject<void>();

  readonly GroupVisibility = VisibilityEnum;

  readonly shouldRefreshGroupDetails$ = new Subject<void>();

  readonly shouldReloadGroupProgram$ = new Subject<void>();

  readonly filtersOptionsForm = new FormGroup({
    searchQuery: new FormControl<string>('', { nonNullable: true }),
  });

  readonly userData$ = this.authService
    .getUserData()
    .pipe(shareReplay({ refCount: true, bufferSize: 1 }));

  readonly groupIdParam$: Observable<string> = this.navigationService
    .getParamValueFromActivatedRoute$(this.route, 'groupId')
    .pipe(filter((groupId): groupId is string => !!groupId));

  readonly groupDetails$: Observable<GroupModel> = combineLatest([
    this.groupIdParam$,
    this.shouldRefreshGroupDetails$.pipe(startWith(undefined)),
    interval(INTERVAL_REFRESH_TIME).pipe(startWith(0)),
  ]).pipe(
    switchMap(([groupId]) =>
      this.groupService.getGroupDetails(groupId).pipe(
        catchError(() => {
          this.router.navigate(['/groups']);
          return EMPTY;
        }),
      ),
    ),
    shareReplay({ refCount: true, bufferSize: 1 }),
  );

  readonly groupPrograms$: Observable<ProgramModel[] | undefined> = combineLatest([
    this.groupIdParam$,
    this.filtersOptionsForm.controls.searchQuery.valueChanges.pipe(startWith('')),
    this.shouldReloadGroupProgram$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([groupId, searchFilter]) =>
      this.groupService
        .getGroupDetails(groupId)
        .pipe(
          map((group) =>
            group.programs?.filter((groupProgram) =>
              groupProgram.description?.includes(searchFilter),
            ),
          ),
        ),
    ),
  );

  readonly isGroupOwner$: Observable<boolean> = combineLatest([
    this.userData$,
    this.groupDetails$,
  ]).pipe(map(([user, groupDetails]) => user.userId === groupDetails.owner.userId));

  readonly isUserTheOwnerOrMember$: Observable<boolean> = combineLatest([
    this.userData$,
    this.groupDetails$,
    this.isGroupOwner$,
  ]).pipe(
    map(([user, groupDetails, isGroupOwner]) => {
      if (groupDetails.visibility === VisibilityEnum.PUBLIC || isGroupOwner) {
        return true;
      } else {
        const isGroupMember = groupDetails.members?.find(
          (member: UserDataModel) => member.userId === user.userId,
        );
        return !!isGroupMember;
      }
    }),
  );

  readonly userId$: Observable<string> = this.userData$.pipe(map((user) => user.userId));

  readonly groupMembersCount$: Observable<number> = this.groupDetails$.pipe(
    map((group) => group.members.length),
  );

  readonly groupPublicationCount$: Observable<number | undefined> =
    this.groupDetails$.pipe(map((group) => group.programs?.length));

  readonly anonymousGroupImage =
    'https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3AtMjAwLWV5ZS0wMzQyNzAyLmpwZw.jpg';

  readonly userProgramCount$ = combineLatest([
    this.homeService.getProgramsList$('public'),
    this.userData$,
  ]).pipe(
    map(
      ([programList, currentUser]) =>
        programList.filter((program) => program.user.userId === currentUser.userId)
          .length,
    ),
  );

  readonly isOwnerConnected$: Observable<boolean> = this.groupDetails$.pipe(
    map((groupDetails) =>
      UserUtils.setIsUserConnected(
        groupDetails.owner.disconnectedAt,
        groupDetails.owner.connectedAt,
      ),
    ),
  );

  readonly currentGroupId$ = this.navigationService
    .getParamValueFromActivatedRoute$(this.route, 'groupId')
    .pipe(filter((groupId): groupId is string => !!groupId));

  constructor(
    private readonly route: ActivatedRoute,
    private readonly groupService: GroupsService,
    readonly navigationService: NavigationService,
    private readonly notifier: NotifierService,
    private readonly authService: AuthService,
    private readonly router: Router,
    private readonly modalService: ModalService,
    private readonly homeService: HomeService,
  ) {}

  ngOnDestroy(): void {
    this.componentDestroy$.next();
    this.componentDestroy$.complete();
  }

  onPublishProgramClick(): void {
    combineLatest([this.userData$, this.groupIdParam$])
      .pipe(
        takeUntil(this.componentDestroy$),
        switchMap(([userData, groupIdParam]) => {
          const groupPublishModal =
            this.modalService.openDialog<GroupPublishModalComponent>(
              GroupPublishModalComponent,
              700,
            );
          return combineLatest([of({ userData, groupIdParam }), groupPublishModal]);
        }),
        filter(([, modalResult]) => modalResult !== undefined),
        switchMap(([{ userData, groupIdParam }, createGroupResult]) =>
          this.modalService.openDialog(ShareCodeModalComponent, 800).pipe(
            map((shareCodeResult) => ({
              userData,
              groupIdParam,
              createGroupResult,
              shareCodeResult,
            })),
          ),
        ),
        switchMap(({ userData, groupIdParam, createGroupResult, shareCodeResult }) => {
          const payload = {
            ...shareCodeResult,
            sourceCode: createGroupResult.fileContent,
            programmingLanguage: createGroupResult.language,
            userId: userData.userId,
            groupId: groupIdParam,
          };
          return this.groupService.publishGroup(payload);
        }),
        tap(() => {
          this.notifier.showSuccess('Your program has been published');
          this.shouldReloadGroupProgram$.next();
        }),
      )
      .subscribe();
  }

  onJoinGroupClick(): void {
    combineLatest([this.userId$, this.groupIdParam$])
      .pipe(
        takeUntil(this.componentDestroy$),
        switchMap(([userId, groupId]) => {
          return this.groupService.joinGroup(groupId, userId).pipe(
            tap(() => {
              this.notifier.showSuccess(`You have joined this group`);
              this.shouldRefreshGroupDetails$.next();
            }),
          );
        }),
      )
      .subscribe();
  }

  onLeaveGroupClick(): void {
    combineLatest([this.userId$, this.groupIdParam$])
      .pipe(
        takeUntil(this.componentDestroy$),
        switchMap(([userId, groupId]) => {
          return this.groupService.leaveGroup(groupId, userId).pipe(
            tap(() => {
              this.notifier.showSuccess(`You have left this group`);
              this.router.navigate(['/groups']);
              this.shouldRefreshGroupDetails$.next();
            }),
          );
        }),
      )
      .subscribe();
  }

  onDeleteGroupClick(): void {
    const dialog$ = this.modalService.openDialog<
      ConfirmationModalComponent,
      { title: string; message: string }
    >(ConfirmationModalComponent, 600, {
      title: 'Want to delete this group?',
      message: 'Attention this operation is irreversible. Do you want to proceed?',
    });

    combineLatest([dialog$, this.groupDetails$])
      .pipe(
        switchMap(([dialog, groupDetails]) => {
          if (dialog) {
            return this.groupService.deleteGroup(groupDetails.groupId).pipe(
              tap(() => {
                this.notifier.showSuccess('Group deleted');
                this.shouldRefreshGroupDetails$.next();
                this.router.navigate(['/groups']);
              }),
              catchError(() => {
                this.notifier.showError('Failed to delete group');
                return of(null);
              }),
            );
          }
          return of(null);
        }),
        takeUntil(this.componentDestroy$),
      )
      .subscribe();
  }

  onChangeVisibilityClick(): void {
    const dialogRef = this.modalService.openDialog<
      ConfirmationModalComponent,
      { title: string; message: string }
    >(ConfirmationModalComponent, 700, {
      title: 'Change visibility',
      message: 'Want to change this group visibility?',
    });

    combineLatest([this.currentGroupId$, dialogRef])
      .pipe(
        takeUntil(this.componentDestroy$),
        switchMap(([currentGroupId, dialog]) => {
          if (dialog) {
            return this.groupService.updateVisibility(currentGroupId).pipe(
              tap((response: { visibility: string }) => {
                this.notifier.showSuccess(
                  `this group is now a ${response.visibility} group`,
                );
                this.shouldRefreshGroupDetails$.next();
              }),
            );
          } else {
            return of(null);
          }
        }),
      )
      .subscribe();
  }

  onViewMembersClick(): void {
    combineLatest([this.isGroupOwner$.pipe(take(1)), this.groupIdParam$])
      .pipe(
        map(([isGroupOwner, groupIdParam]) => {
          if (isGroupOwner) {
            this.modalService.openDialog(GroupMembersModalComponent, 700, {
              groupId: groupIdParam,
            });
          }
        }),
        takeUntil(this.componentDestroy$),
      )
      .subscribe();
  }

  deleteProgram(event: string): void {
    const dialogRef = this.modalService.openDialog(ConfirmationModalComponent, 700, {
      title: 'Want to delete this program?',
      message: 'This operation is irreversible. Are you sure you want to proceed?',
    });
    dialogRef
      .pipe(
        takeUntil(this.componentDestroy$),
        filter((result: any) => result === true),
        switchMap(() => this.homeService.deleteProgram(event)),
        tap(() => {
          this.notifier.showSuccess('The program has been deleted');
        }),
      )
      .subscribe();
  }

  protected readonly group = group;
}
