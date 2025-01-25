import { Component, Inject, OnDestroy } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Router } from '@angular/router';
import { UserDataModel } from '../../models/user-data.model';
import { GroupsService } from '../../../esgithub/groups/groups.service';
import { Observable, Subject, combineLatest, interval, tap } from 'rxjs';
import { map, startWith, switchMap, takeUntil } from 'rxjs/operators';
import { NotifierService } from '../../services/notifier.service';
import { ChangeDetectorRef } from '@angular/core';
import { NavigationService } from '../../Auth/service/navigation.service';
import { INTERVAL_REFRESH_TIME } from 'src/app/esgithub/home-page/home-page.component';

export const isMemberRemovedQueryParamKey = 'ismemberremoved';

@Component({
  selector: 'app-group-members-modal',
  templateUrl: './group-members-modal.component.html',
  styleUrls: ['./group-members-modal.component.scss'],
})
export class GroupMembersModalComponent implements OnDestroy {
  readonly anonymousImageUrl =
    'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  readonly componentDestroyer$ = new Subject<void>();

  readonly shouldReloadGroupMembers$ = new Subject<void>();

  constructor(
    public dialogRef: MatDialogRef<GroupMembersModalComponent>,
    @Inject(MAT_DIALOG_DATA)
    public data: { groupId: string },
    private readonly router: Router,
    private readonly groupService: GroupsService,
    private readonly notifier: NotifierService,
    readonly navigationService: NavigationService,
    private cdr: ChangeDetectorRef,
  ) {}

  readonly groupMembers$: Observable<UserDataModel[]> = combineLatest([
    interval(INTERVAL_REFRESH_TIME).pipe(startWith(0)),
    this.shouldReloadGroupMembers$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(() =>
      this.groupService
        .getGroupDetails(this.data.groupId)
        .pipe(map((groupDetails) => groupDetails.members)),
    ),
  );

  ngOnDestroy(): void {
    this.componentDestroyer$.next();
    this.componentDestroyer$.complete();
  }

  onViewMemberClick(userId: string): void {
    this.router.navigate(['/profile', userId]);
    this.dialogRef.close(true);
  }

  onRemoveMemberClick(userId: string): void {
    this.groupService
      .leaveGroup(this.data.groupId, userId)
      .pipe(
        takeUntil(this.componentDestroyer$),
        tap(() => {
          this.notifier.showSuccess('User removed from the group');
          this.shouldReloadGroupMembers$.next();
        }),
      )
      .subscribe();
  }
}
