import { Component, OnDestroy, OnInit } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import {
  BehaviorSubject,
  Observable,
  Subject,
  combineLatest,
  distinctUntilChanged,
  exhaustMap,
  filter,
  first,
  interval,
  map,
  scan,
  shareReplay,
  startWith,
  switchMap,
  takeUntil,
  tap,
} from 'rxjs';
import { AuthService } from 'src/app/core/Auth/service/auth.service';
import { NavigationService } from 'src/app/core/Auth/service/navigation.service';
import { ProgramModel } from 'src/app/core/models/program.model';
import { UserDataModel } from 'src/app/core/models/user-data.model';
import { Follower, UserFollowersModel } from 'src/app/core/models/user-followers.model';
import { NotifierService } from 'src/app/core/services/notifier.service';
import { INTERVAL_REFRESH_TIME } from '../home-page/home-page.component';
import { ProfileService } from './profile.service';
import { HomeService } from '../home-page/home.service';

export enum ProfileTabFragment {
  PUBLICATIONS = 'publications',
  FOLLOWERS = 'followers',
  FOLLOWINGS = 'followings',
}

type ActivatedTabs = Set<ProfileTabFragment>;

@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss'],
})
export class ProfileComponent implements OnInit, OnDestroy {
  activeTab$: Observable<ProfileTabFragment> | undefined;

  activatedTabs$: Observable<ActivatedTabs> | undefined;

  readonly shouldReloadPersonalInfo$ = new Subject<void>();

  readonly editProfilView$ = new BehaviorSubject<boolean>(false);

  readonly programVisibility$ = new BehaviorSubject<'public' | 'only_followers'>(
    'public',
  );

  readonly userIdQueryParam$: Observable<string | null> =
    this.navigationService.getParamValueFromActivatedRoute$(this.activedRoute, 'userId');

  readonly currentUser$ = this.shouldReloadPersonalInfo$.pipe(
    startWith(undefined),
    switchMap(() => this.authService.getUserData()),
  );

  readonly componentDestroyed$ = new Subject<void>();

  readonly ProfileTabFragment = ProfileTabFragment;

  readonly isItMyProfil$ = new BehaviorSubject<boolean>(false);

  readonly defaultProfileTab = ProfileTabFragment.PUBLICATIONS;

  readonly shouldReloadUserFollowersAndFollowings$ = new Subject<void>();

  readonly shoulRealoadUserPrograms$ = new Subject<void>();

  readonly userData$: Observable<UserDataModel> = this.userIdQueryParam$.pipe(
    switchMap((userIdQueryParam) => {
      if (userIdQueryParam) {
        return this.profileService.getUserInfo(userIdQueryParam);
      }
      this.isItMyProfil$.next(true);

      return this.currentUser$;
    }),
    shareReplay({ refCount: true, bufferSize: 1 }),
  );

  readonly userFollowersAndFollowing$: Observable<UserFollowersModel> = combineLatest([
    this.userData$,
    this.shouldReloadUserFollowersAndFollowings$.pipe(startWith(undefined)),
    interval(INTERVAL_REFRESH_TIME).pipe(startWith(0)),
  ]).pipe(
    switchMap(([userData]) =>
      this.profileService.getFollowersAndFollowings(userData.userId),
    ),
    shareReplay({ refCount: true, bufferSize: 1 }),
  );

  readonly combinedProgramsList$: Observable<ProgramModel[]> = combineLatest([
    this.homeService.getProgramsList$('public'),
    this.homeService.getProgramsList$('only_followers'),
  ]).pipe(
    map(([publicPrograms, followerPrograms]) => [...publicPrograms, ...followerPrograms]),
  );

  readonly userProgramList$: Observable<ProgramModel[]> = combineLatest([
    this.currentUser$,
    this.shoulRealoadUserPrograms$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([userData]) => this.profileService.getUserPrograms(userData.userId)),
  );

  readonly spectedUserProgram$: Observable<ProgramModel[]> = combineLatest([
    this.programVisibility$,
  ]).pipe(
    switchMap(([programVisibility]) =>
      this.homeService.getProgramsList$(programVisibility),
    ),
  );

  readonly currentUserFollowingOrFollowerData$: Observable<Follower | undefined> =
    combineLatest([this.userFollowersAndFollowing$, this.currentUser$]).pipe(
      map(([userFollowersAndFollowing, currentUser]) =>
        userFollowersAndFollowing.followers.find(
          (follower) => follower.follower.userId === currentUser.userId,
        ),
      ),
    );

  readonly isCurrentUserFollowingTheUserSpected$: Observable<boolean> =
    this.currentUserFollowingOrFollowerData$.pipe(
      map((currentUserFollowingOrFollowerData) => !!currentUserFollowingOrFollowerData),
    );

  readonly programList$ = combineLatest([
    this.isItMyProfil$,
    this.userIdQueryParam$,
    this.isCurrentUserFollowingTheUserSpected$,
    this.shoulRealoadUserPrograms$.pipe(startWith(undefined)),
  ]).pipe(
    switchMap(([isItMyProfile, userIdParam, isCurrentUserFollowingTheUserSpected]) => {
      if (isItMyProfile) {
        return this.userProgramList$;
      }
      if (isCurrentUserFollowingTheUserSpected) {
        return this.combinedProgramsList$.pipe(
          map((spectedUserPrograms) =>
            spectedUserPrograms.filter(
              (spectedUserPrograms) => spectedUserPrograms.user.userId === userIdParam,
            ),
          ),
        );
      }
      return this.spectedUserProgram$.pipe(
        map((spectedUserPrograms) =>
          spectedUserPrograms.filter(
            (spectedUserPrograms) => spectedUserPrograms.user.userId === userIdParam,
          ),
        ),
      );
    }),
  );

  readonly anonymousGroupImage =
    'https://cdn.discordapp.com/attachments/1057643423546482699/1262421845358022727/64b2ca20d03275743621149c0b69157b.png?ex=66968976&is=669537f6&hm=bf79cefa9971c1614915abe114499d51c7c0ff0c0bf9128955752e05e2872dc0&';

  private getActiveTab(): Observable<ProfileTabFragment> {
    return this.activedRoute.fragment.pipe(
      map((urlFragment) => {
        if (urlFragment) {
          return urlFragment as ProfileTabFragment;
        }
        return ProfileTabFragment.PUBLICATIONS;
      }),
    );
  }

  private getActivatedTabs$(
    activeTab$: Observable<ProfileTabFragment>,
  ): Observable<ActivatedTabs> {
    return activeTab$.pipe(
      scan(
        (activatedTabs, currentActiveTab) => activatedTabs.add(currentActiveTab),
        new Set<ProfileTabFragment>(),
      ),
      distinctUntilChanged((prev, curr) => prev.size === curr.size),
    );
  }

  profileEdited(): void {
    this.editProfilView$.next(false);
    this.shouldReloadPersonalInfo$.next();
  }

  onUnFollowClick(): void {
    this.currentUserFollowingOrFollowerData$
      .pipe(
        first(),
        filter(
          (
            currentUserFollowingOrFollowerData,
          ): currentUserFollowingOrFollowerData is Follower =>
            currentUserFollowingOrFollowerData !== undefined,
        ),
        switchMap((followerOrFollowing) =>
          this.profileService
            .unfollow(followerOrFollowing.relationId)
            .pipe(takeUntil(this.componentDestroyed$)),
        ),
        tap(() => {
          this.shouldReloadUserFollowersAndFollowings$.next();
          this.programVisibility$.next('public');
        }),
      )
      .subscribe();
  }

  onHandleRemoveFollowing(followingId: string): void {
    this.profileService
      .unfollow(followingId)
      .pipe(
        takeUntil(this.componentDestroyed$),
        tap(() => this.shouldReloadUserFollowersAndFollowings$.next()),
      )
      .subscribe();
  }

  onFollowClick(): void {
    combineLatest([this.currentUser$, this.userData$])
      .pipe(
        first(),
        filter(([currentUser, userData]) => currentUser.userId !== userData.userId),
        exhaustMap(([currentUser, userData]) => {
          const payload = {
            followerId: currentUser.userId,
            followingId: userData.userId,
          };
          return this.profileService.follow(payload);
        }),
        tap(() => {
          this.shouldReloadUserFollowersAndFollowings$.next();
          this.programVisibility$.next('only_followers');
        }),
        takeUntil(this.componentDestroyed$),
      )
      .subscribe();
  }

  onPictureSelected(event: Event): void {
    const input = event.target as HTMLInputElement;

    const file = input.files ? input.files[0] : null;

    if (file) {
      this.profileService
        .uploadAvatar(file)
        .pipe(
          takeUntil(this.componentDestroyed$),
          tap(() => {
            this.notifier.showSuccess('Profile image updated');
            this.shouldReloadPersonalInfo$.next();
          }),
        )
        .subscribe();
    }
  }

  private navigateToProfileIfUserIsTheCurrentUser(): void {
    combineLatest([this.currentUser$, this.userIdQueryParam$])
      .pipe(
        map(([currentUser, userIdQueryParam]) => {
          if (userIdQueryParam && currentUser.userId === userIdQueryParam) {
            this.router.navigate(['/profile']);
          }
        }),
        takeUntil(this.componentDestroyed$),
      )
      .subscribe();
  }

  ngOnInit(): void {
    this.navigateToProfileIfUserIsTheCurrentUser();
    this.activeTab$ = this.getActiveTab();
    this.activatedTabs$ = this.getActivatedTabs$(this.activeTab$);
  }

  ngOnDestroy(): void {
    this.componentDestroyed$.next();
    this.componentDestroyed$.complete();
  }

  constructor(
    readonly navigationService: NavigationService,
    readonly authService: AuthService,
    readonly activedRoute: ActivatedRoute,
    readonly homeService: HomeService,
    readonly profileService: ProfileService,
    readonly notifier: NotifierService,
    readonly router: Router,
  ) {}
}
