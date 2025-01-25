import { ProgramModel } from './program.model';

export type ProgramVersionModel = {
  program: ProgramModel;
  versions: VersionModel[];
};

export type VersionModel = {
  createdAt: Date;
  programVersionId: string;
  programmingLanguage: string;
  sourceCode: string;
  version: string;
};
