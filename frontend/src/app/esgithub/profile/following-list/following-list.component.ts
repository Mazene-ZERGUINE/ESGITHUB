import { Component, EventEmitter, Input, Output } from '@angular/core';
import { UserFollowersModel } from '../../../core/models/user-followers.model';

@Component({
  selector: 'app-following-list',
  templateUrl: './following-list.component.html',
  styleUrls: ['./following-list.component.scss'],
})
export class FollowingListComponent {
  @Input() followingsList: UserFollowersModel | undefined;

  @Input() isOwner!: boolean;

  @Output() removeFollowingEvent: EventEmitter<string> = new EventEmitter();

  readonly customBgColor = '141414';

  onRemoveClick(relationId: string): void {
    this.removeFollowingEvent.emit(relationId);
  }
}
