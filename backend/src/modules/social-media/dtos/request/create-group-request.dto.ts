import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsOptional, IsString, IsUUID } from 'class-validator';
import { UUID } from 'typeorm/driver/mongodb/bson.typings';

export class CreateGroupRequestDto {
	@ApiProperty({
		description: 'group name',
		type: String,
	})
	@IsNotEmpty()
	@IsString()
	name: string;

	@ApiProperty({
		description: 'ownerId',
		type: UUID,
	})
	@IsNotEmpty()
	@IsUUID()
	ownerId: string;

	@ApiProperty({
		description: 'group description',
		type: String,
	})
	@IsOptional()
	@IsString()
	description?: string;

	@ApiProperty({
		description: 'group visibility',
		type: String,
	})
	@IsString()
	@IsOptional()
	visibility?: string;
}
