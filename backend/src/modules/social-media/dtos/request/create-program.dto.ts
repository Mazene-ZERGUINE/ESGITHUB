import { ProgrammingLanguageEnum } from '../../enums/programming-language.enum';
import { ProgramVisibilityEnum } from '../../enums/program-visibility.enum';
import { FileTypesEnum } from '../../enums/file-types.enum';
import { IsEnum, IsNotEmpty, IsString, IsArray, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateProgramDto {
	@ApiProperty({
		description: 'program description text max 500 character',
	})
	@IsString()
	description?: string;

	@ApiProperty({
		description: 'program language',
		enum: ProgrammingLanguageEnum,
		examples: ['javascript', 'python'],
	})
	@IsNotEmpty()
	@IsEnum(ProgrammingLanguageEnum, {
		message: 'This programming language is not supported',
	})
	programmingLanguage: ProgrammingLanguageEnum;

	@ApiProperty({
		description: 'program source code',
		example: "console.log('hello wolrd')",
	})
	@IsString()
	@IsNotEmpty()
	sourceCode: string;

	@ApiProperty({
		description: 'program visibility to others (public | private | only_followers)',
		enum: ProgramVisibilityEnum,
	})
	@IsString()
	@IsEnum(ProgramVisibilityEnum, {
		message: 'Not a valid visibility type',
	})
	visibility: ProgramVisibilityEnum;

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

	@ApiProperty({
		description: 'user id (UUID)',
		example: '12dx-76fzcw',
	})
	@IsString()
	@IsNotEmpty()
	userId: string;
}
