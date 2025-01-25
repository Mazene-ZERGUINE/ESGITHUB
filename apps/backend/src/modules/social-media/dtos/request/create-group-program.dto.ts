import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';
import { ProgrammingLanguageEnum } from '../../enums/programming-language.enum';
import { FileTypesEnum } from '../../enums/file-types.enum';

export class CreateGroupProgramDto {
	@ApiProperty({
		description: 'program description text max 500 character',
	})
	@IsString()
	@IsOptional()
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
		description: 'files types that the program takes as an input',
		example: "['txt', 'json']",
	})
	@IsArray()
	@IsOptional()
	@IsEnum(FileTypesEnum, {
		each: true,
		message: 'Invalid input file type',
	})
	inputTypes: FileTypesEnum[];

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

	@ApiProperty({
		description: 'group id (UUID)',
		example: '12dx-76fzcw',
	})
	@IsString()
	@IsNotEmpty()
	groupId: string;

	@ApiProperty({
		description: 'visibility id (UUID)',
		example: '12dx-76fzcw',
	})
	@IsString()
	@IsOptional()
	visibility?: string;
}
