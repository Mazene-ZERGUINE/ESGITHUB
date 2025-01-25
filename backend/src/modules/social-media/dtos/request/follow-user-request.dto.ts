import { IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class FollowUserRequestDto {
	@ApiProperty({
		description: 'the follower user id (uuid)',
		example: 'ca01d&-dacv5Gcqxm%',
	})
	@IsString()
	@IsNotEmpty()
	followerId: string;

	@ApiProperty({
		description: 'the followed user id (uuid)',
		example: 'ca01d&-dacv5Gcqxm%',
	})
	@IsString()
	@IsNotEmpty()
	followingId: string;
}
