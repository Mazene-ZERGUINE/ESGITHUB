import { ChangeDetectionStrategy, Component, Input, OnInit } from '@angular/core';
import { UserUtils } from 'src/app/core/Auth/utils/user.utils';
import { Follower } from 'src/app/core/models/user-followers.model';

@Component({
  selector: 'app-follower',
  templateUrl: './follower.component.html',
  styleUrls: ['./follower.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class FollowerFollowingComponent implements OnInit {
  @Input() follower!: Follower;
  @Input() customBgcolor: string = '333333';
  readonly anonymousImageUrl =
    'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  isUserConnected: boolean | undefined;

  timeElapsed: string | undefined;

  ngOnInit(): void {
    if (this.follower) {
      this.isUserConnected = UserUtils.setIsUserConnected(
        this.follower.follower.disconnectedAt,
        this.follower.follower.connectedAt,
      );

      this.timeElapsed = UserUtils.calculateElapsed(
        this.follower.follower.disconnectedAt,
      );
    }
  }
}
