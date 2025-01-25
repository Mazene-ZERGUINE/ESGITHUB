import { ApiProperty } from '@nestjs/swagger';
import { UUID } from 'typeorm/driver/mongodb/bson.typings';
import { IsNotEmpty, IsUUID } from 'class-validator';

export class LikeRequestDto {
	@ApiProperty({
		description: 'user Id',
		type: UUID,
		required: true,
	})
	@IsUUID()
	@IsNotEmpty()
	userId: string;

	@ApiProperty({
		description: 'program Id',
		type: UUID,
		required: true,
	})
	@IsUUID()
	@IsNotEmpty()
	programId: string;
}
