import { IsEnum, IsNotEmpty, IsString } from 'class-validator';
import { ProgrammingLanguage } from '../../enums/ProgrammingLanguage';
import { ApiProperty } from '@nestjs/swagger';

export class ProcessCodeRequestDto {
	@ApiProperty({ enum: ProgrammingLanguage, example: ProgrammingLanguage.JAVASCRIPT })
	@IsNotEmpty()
	@IsEnum(ProgrammingLanguage, {
		message: `Supported languages are: ${Object.values(ProgrammingLanguage).join(', ')}`,
	})
	readonly programmingLanguage: ProgrammingLanguage;

	@ApiProperty({ example: "console.log('Hello, World!');" })
	@IsNotEmpty()
	@IsString()
	readonly sourceCode: string;
}
