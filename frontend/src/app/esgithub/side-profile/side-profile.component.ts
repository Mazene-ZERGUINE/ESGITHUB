import { ChangeDetectionStrategy, Component, Input, OnInit } from '@angular/core';
import { Observable, interval, startWith, switchMap } from 'rxjs';
import { ProgramModel } from 'src/app/core/models/program.model';
import { UserDataModel } from 'src/app/core/models/user-data.model';
import { UserFollowersModel } from 'src/app/core/models/user-followers.model';
import { INTERVAL_REFRESH_TIME } from '../home-page/home-page.component';
import { ProfileService } from '../profile/profile.service';

@Component({
  selector: 'app-side-profile',
  templateUrl: './side-profile.component.html',
  styleUrls: ['./side-profile.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class SideProfileComponent implements OnInit {
  @Input() currentUser!: UserDataModel;

  userFollowersAndFollowings$!: Observable<UserFollowersModel>;

  readonly anonymousImageUrl =
    'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  constructor(private readonly profileService: ProfileService) {}

  userProgramList$: Observable<ProgramModel[]> | undefined;

  ngOnInit(): void {
    if (this.currentUser) {
      this.userProgramList$ = this.profileService.getUserPrograms(
        this.currentUser.userId,
      );

      this.userFollowersAndFollowings$ = interval(INTERVAL_REFRESH_TIME).pipe(
        startWith(0),
        switchMap(() =>
          this.profileService.getFollowersAndFollowings(this.currentUser.userId),
        ),
      );
    }
  }
}
