import {Component, Input, OnInit} from '@angular/core';
import {UserUtils} from 'src/app/core/Auth/utils/user.utils';
import {GroupModel} from 'src/app/core/models/group.model';
import {VisibilityEnum} from 'src/app/shared/enums/visibility.enum';

@Component({
  selector: 'app-group-item',
  templateUrl: './group-item.component.html',
  styleUrls: ['./group-item.component.scss'],
})
export class GroupItemComponent implements OnInit {
  @Input() group!: GroupModel;

  numberOfMembersOnline: number | undefined;

  numberOfMembers: number | undefined;

  readonly anonymousGroupImage =
    'https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIyLTA1L3AtMjAwLWV5ZS0wMzQyNzAyLmpwZw.jpg';

  readonly GroupVisibility = VisibilityEnum;

  ngOnInit(): void {
    if (this.group)
      this.numberOfMembersOnline = this.group.members.filter((member) =>
        UserUtils.setIsUserConnected(member.disconnectedAt, member.connectedAt),
      ).length;

    this.numberOfMembers = this.group.members.length;
    console.log(this.group.imageUrl)
  }

}
