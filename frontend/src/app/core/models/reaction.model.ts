import { ReactionsEnum } from '../../shared/enums/reactions.enum';
import { UserDataModel } from './user-data.model';

export class ReactionModel {
  reactionId!: string;
  type?: ReactionsEnum;
  createdAt?: Date;
  user!: UserDataModel;
}
