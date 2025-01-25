import { UserDataModel } from './user-data.model';

export type ProgramComment = {
  commentId: string;
  content: string;
  replies: Comment[];
  user: UserDataModel;
  createdAt: string;
  updatedAt: string;
  codeLineNumber: number | null;
};
