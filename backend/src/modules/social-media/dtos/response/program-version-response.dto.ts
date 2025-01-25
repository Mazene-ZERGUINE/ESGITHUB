import { ProgrammingLanguageEnum } from '../../enums/programming-language.enum';
import { ProgramVersionEntity } from '../../entities/program-version.entity';
import { GetProgramDto } from './get-program.dto';
import { ApiProperty } from '@nestjs/swagger';
import { ProgramEntity } from '../../entities/program.entity';

export class ProgramVersionResponseDto {
	@ApiProperty({
		description: 'original program',
		type: ProgramEntity,
	})
	program: GetProgramDto;

	@ApiProperty({
		description: 'program versions',
		isArray: true,
		type: 'VersionsDto',
	})
	versions: VersionsDto[];

	constructor(program: GetProgramDto, versions: VersionsDto[]) {
		this.program = program;
		this.versions = versions;
	}
}

export class VersionsDto {
	@ApiProperty({
		description: 'version id',
		type: 'string',
	})
	programVersionId: string;
	@ApiProperty({
		description: 'program version text',
		type: 'number',
	})
	version: string;
	@ApiProperty({
		description: 'programing language',
		enum: ProgrammingLanguageEnum,
	})
	programmingLanguage: ProgrammingLanguageEnum;
	@ApiProperty({
		description: 'soruce code',
		type: 'string',
	})
	sourceCode: string;
	createdAt: Date;
	constructor(programVersion: ProgramVersionEntity) {
		this.programVersionId = programVersion.programVersionId;
		this.version = programVersion.version;
		this.sourceCode = programVersion.sourceCode;
		this.programmingLanguage = programVersion.programmingLanguage;
		this.createdAt = programVersion.createdAt;
	}
}
