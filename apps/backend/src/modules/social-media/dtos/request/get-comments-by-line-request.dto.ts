import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsUUID } from 'class-validator';
import { Transform } from 'class-transformer';

export class GetCommentsByLineRequestDto {
	@ApiProperty({
		description: 'Line number in the code',
		example: 1,
	})
	@IsNotEmpty()
	@Transform(({ value }) => parseInt(value, 10))
	@IsNumber()
	lineNumber: number;

	@ApiProperty({
		description: 'Program ID uuid',
		example: 'd290f1ee-6c54-4b01-90e6-d701748f0851',
	})
	@IsUUID()
	@IsNotEmpty()
	programId: string;
}
