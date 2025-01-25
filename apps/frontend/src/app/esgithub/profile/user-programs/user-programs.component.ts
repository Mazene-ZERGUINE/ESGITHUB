import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ReactionsEnum } from 'src/app/shared/enums/reactions.enum';
import { ProgramModel } from '../../../core/models/program.model';
import { UserDataModel } from 'src/app/core/models/user-data.model';

@Component({
  selector: 'app-user-programs',
  templateUrl: './user-programs.component.html',
  styleUrls: ['./user-programs.component.scss'],
})
export class UserProgramsComponent {
  @Input() programsList: ProgramModel[] | undefined;

  @Input() currentUser: UserDataModel | undefined;

  @Input() profileOwner: boolean | undefined;

  @Output() userProgramHasBeenLiked = new EventEmitter<void>();

  readonly ReactionsEnum = ReactionsEnum;
}
