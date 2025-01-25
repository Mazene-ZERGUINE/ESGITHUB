import { UserDataDto } from './user-data.dto';
import { ApiProperty } from '@nestjs/swagger';

export class UserWithFollowersDto {
	@ApiProperty({
		description: 'user id (uuid)',
	})
	userId: string;
	@ApiProperty({
		description: "list of user's followers",
		type: UserDataDto,
		isArray: true,
	})
	followers: { follower: UserDataDto; relationId: string }[];
	@ApiProperty({
		description: "list of user's followings",
		type: UserDataDto,
		isArray: true,
	})
	followings: { following: UserDataDto; relationId: string }[];
	constructor(
		userId: string,
		followers: { follower: UserDataDto; relationId: string }[],
		followings: { following: UserDataDto; relationId: string }[],
	) {
		this.userId = userId;
		this.followers = followers;
		this.followings = followings;
	}
}
