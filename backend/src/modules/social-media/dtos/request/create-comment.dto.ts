import { ApiProperty } from '@nestjs/swagger';
import {
	IsNotEmpty,
	IsNumber,
	IsOptional,
	IsString,
	IsUUID,
	Length,
} from 'class-validator';
import { UUID } from 'typeorm/driver/mongodb/bson.typings';

export class CreateCommentDto {
	@ApiProperty({
		description: 'comment content text',
		type: String,
		example: 'bouraz aswadoun jidan',
	})
	@IsString()
	@IsNotEmpty()
	@Length(1, 255)
	content: string;

	@ApiProperty({
		description: 'the number of line when for sub comments',
		nullable: true,
		type: Number,
		example: 6,
	})
	@IsOptional()
	@IsNumber({
		allowInfinity: false,
		allowNaN: false,
	})
	codeLineNumber?: number;

	@ApiProperty({
		description: 'the userId ',
		type: UUID,
	})
	@IsUUID()
	@IsNotEmpty()
	userId: string;

	@ApiProperty({
		description: 'programId uuid',
		type: UUID,
	})
	@IsNotEmpty()
	@IsUUID()
	programId: string;
}
