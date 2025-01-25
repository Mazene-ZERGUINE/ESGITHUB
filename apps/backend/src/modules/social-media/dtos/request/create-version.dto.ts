import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, IsUUID } from 'class-validator';
import { ProgrammingLanguageEnum } from '../../enums/programming-language.enum';

export class CreateVersionDto {
	@ApiProperty({
		description: 'program version tag',
		example: '1.0.0',
	})
	@IsString()
	@IsNotEmpty()
	version: string;

	@ApiProperty({
		description: 'programing language',
		enum: ProgrammingLanguageEnum,
		example: 'python',
	})
	@IsEnum(ProgrammingLanguageEnum)
	@IsNotEmpty()
	programmingLanguage: ProgrammingLanguageEnum;

	@ApiProperty({
		description: 'program source code',
		example: 'console.log("hello world")',
	})
	@IsString()
	@IsNotEmpty()
	sourceCode: string;

	@ApiProperty({
		description: 'parent program id (uuid)',
		example: '8ce419bb-3936-4ac8-b67c-f3e39f47466f',
	})
	@IsNotEmpty()
	@IsUUID()
	programId: string;
}
