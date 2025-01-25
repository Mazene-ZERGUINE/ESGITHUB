import { FileTypesEnum } from '../../shared/enums/FileTypesEnum';
import { UserDataModel } from './user-data.model';
import { ReactionModel } from './reaction.model';
import { AvailableLangages } from 'src/app/esgithub/home-page/home-page.component';

export class ProgramModel {
  programId!: string;
  description?: string;
  programmingLanguage!: AvailableLangages;
  sourceCode!: string;
  visibility!: string;
  inputTypes!: FileTypesEnum[];
  outputTypes!: FileTypesEnum[];
  user!: UserDataModel;
  userId!: string;
  reactions!: ReactionModel[];
  createdAt!: Date;
  updatedAt!: Date;
}
