import { ApiProperty } from '@nestjs/swagger';
import { ProgrammingLanguage } from '../../enums/ProgrammingLanguage';
import { IsArray, IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { FileTypesEnum } from '../../../social-media/enums/file-types.enum';

export class ExecuteCodeWithFileDto {
	@ApiProperty({
		description: 'programming_language',
		enum: ProgrammingLanguage,
		example: 'python',
	})
	@IsEnum(ProgrammingLanguage)
	@IsNotEmpty()
	programming_language: string;

	@ApiProperty({
		description: 'source_code',
		type: String,
		example: 'print("hello")',
	})
	@IsString()
	@IsNotEmpty()
	source_code: string;
	@ApiProperty({
		description: 'users input file paths',
		type: String,
		isArray: true,
	})
	@IsNotEmpty()
	@IsArray()
	input_files_paths: string[];

	@IsString()
	@IsNotEmpty()
	@IsEnum(FileTypesEnum, { each: true })
	@IsArray()
	output_files_formats: FileTypesEnum[];

	constructor(
		ProgrammingLanguage: string,
		sourceCode: string,
		inputFilesPaths: string[],
		outputFileFormats: FileTypesEnum[],
	) {
		this.programming_language = ProgrammingLanguage;
		this.source_code = sourceCode;
		this.input_files_paths = inputFilesPaths;
		if (typeof outputFileFormats === 'string') {
			outputFileFormats = [outputFileFormats];
		}
		this.output_files_formats = outputFileFormats;
	}
}
