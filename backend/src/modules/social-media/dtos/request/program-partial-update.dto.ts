import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsEnum, IsOptional, IsString } from 'class-validator';
import { ProgramVisibilityEnum } from '../../enums/program-visibility.enum';
import { FileTypesEnum } from '../../enums/file-types.enum';

export class ProgramPartialUpdateDto {
	@ApiProperty({
		description: 'program description text max 500 character',
	})
	@IsString()
	@IsOptional()
	description?: string;

	@ApiProperty({
		description: 'program source code',
		example: "console.log('hello wolrd')",
	})
	@IsString()
	@IsOptional()
	sourceCode?: string;

	@ApiProperty({
		description: 'program visibility to others (public | private | only_followers)',
		enum: ProgramVisibilityEnum,
	})
	@IsOptional()
	@IsEnum(ProgramVisibilityEnum, {
		message: 'Not a valid visibility type',
	})
	visibility?: ProgramVisibilityEnum;

	@ApiProperty({
		description: 'files types that the program takes as an input',
		example: "['txt', 'json']",
	})
	@IsArray()
	@IsOptional()
	@IsEnum(FileTypesEnum, {
		each: true,
		message: 'Invalid input file type',
	})
	inputTypes?: FileTypesEnum[];

	@ApiProperty({
		description: 'files types that the program returns as output',
		example: "['xlsx']",
	})
	@IsArray()
	@IsOptional()
	@IsEnum(FileTypesEnum, {
		each: true,
		message: 'Invalid output file type',
	})
	outputTypes?: FileTypesEnum[];
}
