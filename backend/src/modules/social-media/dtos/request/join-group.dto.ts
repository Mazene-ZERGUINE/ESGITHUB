import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsUUID } from 'class-validator';

export default class JoinGroupDto {
	@ApiProperty({
		description: 'userID (uuid)',
		example: 'userID',
	})
	@IsNotEmpty()
	@IsUUID()
	userId: string;

	@ApiProperty({
		description: 'groupId (uuid)',
		example: 'groupId',
	})
	@IsNotEmpty()
	@IsUUID()
	groupId: string;
}
