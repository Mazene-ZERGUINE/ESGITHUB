import { Component, OnDestroy, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import { Observable, Subject, combineLatest, interval, switchMap, tap } from 'rxjs';
import { map, shareReplay, startWith, takeUntil } from 'rxjs/operators';
import { AuthService } from '../../core/Auth/service/auth.service';
import {
  CreateGroupDto,
  CreateGroupModalComponent,
} from '../../core/modals/create-group-modal/create-group-modal.component';
import { GroupModel } from '../../core/models/group.model';
import { ModalService } from '../../core/services/modal.service';
import { NotifierService } from '../../core/services/notifier.service';
import { HomeService } from '../home-page/home.service';
import { GroupsService } from './groups.service';
import { INTERVAL_REFRESH_TIME } from '../home-page/home-page.component';

export const POPULAR = 20;

export const MODAL_WIDTH = 690;
@Component({
  selector: 'app-groups',
  templateUrl: './groups.component.html',
  styleUrls: ['./groups.component.scss'],
})
export class GroupsComponent implements OnDestroy, OnInit {
  readonly componentDestroyer$ = new Subject<void>();

  readonly filtersOptionsForm = new FormGroup({
    searchQuery: new FormControl<string>('', { nonNullable: true }),
  });

  readonly groupsList$: Observable<GroupModel[]> = combineLatest([
    this.filtersOptionsForm.controls.searchQuery.valueChanges.pipe(startWith('')),
    interval(INTERVAL_REFRESH_TIME).pipe(startWith(0)),
  ]).pipe(
    switchMap(([search]) => {
      return this.groupsService.getGroupsList$().pipe(
        map((groupList) =>
          groupList.filter((group) =>
            group.name.toLocaleLowerCase().includes(search.toLocaleLowerCase()),
          ),
        ),
        shareReplay({ refCount: true, bufferSize: 1 }),
      );
    }),
  );

  // readonly popularGroupsList$: Observable<GroupModel[]> = this.groupsList$.pipe(
  //   map((groupList) => groupList.filter((group) => group.members.length > POPULAR)),
  // );

  readonly userData$ = this.authService.getUserData();

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

  readonly currentUserGroup$: Observable<GroupModel[]> = combineLatest([
    this.groupsList$,
    this.userData$,
  ]).pipe(
    map(([groupsList, userData]) =>
      groupsList.filter((group) => group.owner.userId === userData.userId),
    ),
  );

  constructor(
    private readonly groupsService: GroupsService,
    readonly homeService: HomeService,
    private readonly authService: AuthService,
    private readonly modalService: ModalService,
    private readonly notifier: NotifierService,
    private readonly router: Router,
  ) {}

  ngOnDestroy(): void {
    this.componentDestroyer$.next();
    this.componentDestroyer$.complete();
  }

  ngOnInit(): void {}

  onAddGroupClick(): void {
    const createGroupPayload = this.modalService.openDialog<
      CreateGroupModalComponent,
      CreateGroupDto
    >(CreateGroupModalComponent, MODAL_WIDTH);
    combineLatest([this.userData$, createGroupPayload])
      .pipe(
        map(([user, createGroupPayload]): FormData => {
          const payload = new FormData();
          if (createGroupPayload.image) payload.append('image', createGroupPayload.image);
          payload.append('name', createGroupPayload.groupName);
          payload.append('description', createGroupPayload.description);
          payload.append('ownerId', user.userId);
          payload.append('visibility', createGroupPayload.visibility);
          return payload;
        }),
        switchMap((payload) => this.groupsService.createGroup(payload)),
        tap((result): void => {
          this.notifier.showSuccess(
            `${result.name} has been created successfully. You will be redirected soon.`,
          );
          // eslint-disable-next-line angular/timeout-service
          // const timeoutId = setTimeout(() => {
          //   this.router.navigate(['group/' + result.groupId]);
          //   clearTimeout(timeoutId); // Clear the timeout once executed
          // }, 4000);
        }),
        takeUntil(this.componentDestroyer$),
      )
      .subscribe();
  }
}
