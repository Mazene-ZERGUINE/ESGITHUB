import { Component, EventEmitter, Input, Output } from '@angular/core';
import { UserFollowersModel } from '../../../core/models/user-followers.model';

@Component({
  selector: 'app-followers-list',
  templateUrl: './followers-list.component.html',
  styleUrls: ['./followers-list.component.scss'],
})
export class FollowersListComponent {
  @Input() followersList!: UserFollowersModel;

  @Output() removeFollowerEvent: EventEmitter<string> = new EventEmitter();

  @Input() isOwner!: boolean;

  readonly customBgColor = '141414';

  onRemoveClick(relationId: string): void {
    this.removeFollowerEvent.emit(relationId);
  }
}
