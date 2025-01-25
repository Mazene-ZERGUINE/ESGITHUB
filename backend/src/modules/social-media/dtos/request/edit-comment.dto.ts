import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, Length } from 'class-validator';

export class EditCommentDto {
	@ApiProperty({
		description: 'comment content',
		type: String,
	})
	@IsString()
	@Length(0, 255)
	@IsNotEmpty()
	content: string;
}
