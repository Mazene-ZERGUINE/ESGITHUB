import { UserDataModel } from './user-data.model';
import { ProgramModel } from './program.model';
import { VisibilityEnum } from 'src/app/shared/enums/visibility.enum';

export class GroupModel {
  groupId!: string;
  name!: string;
  description?: string;
  owner!: UserDataModel;
  members!: UserDataModel[];
  created_at!: Date;
  imageUrl?: string;
  visibility?: VisibilityEnum;
  programs?: ProgramModel[];
}
