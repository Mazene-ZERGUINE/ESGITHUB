import { Component, EventEmitter, Input, Output } from '@angular/core';
import { UserUtils } from 'src/app/core/Auth/utils/user.utils';
import { Following } from 'src/app/core/models/user-followers.model';

@Component({
  selector: 'app-following',
  templateUrl: './following.component.html',
  styleUrls: ['./following.component.scss'],
})
export class FollowingComponent {
  @Input() following!: Following;

  @Input() customBgcolor = '333333';

  @Input() isOwner!: boolean;

  @Output() removeFollowerEvent = new EventEmitter<string>();

  readonly anonymousImageUrl =
    'https://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  isUserConnected: boolean | undefined;

  timeElapsed: string | undefined;

  ngOnInit(): void {
    if (this.following) {
      this.isUserConnected = UserUtils.setIsUserConnected(
        this.following.following.disconnectedAt,
        this.following.following.connectedAt,
      );

      this.timeElapsed = UserUtils.calculateElapsed(
        this.following.following.disconnectedAt,
      );
    }
  }

  onRemoveClick(event: MouseEvent, relationId: string): void {
    event.preventDefault();
    event.stopPropagation();
    this.removeFollowerEvent.emit(relationId);
  }
}
