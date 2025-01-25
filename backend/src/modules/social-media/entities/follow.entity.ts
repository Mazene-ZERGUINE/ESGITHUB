import { Entity, PrimaryGeneratedColumn, ManyToOne } from 'typeorm';
import { UserEntity } from './user.entity';

@Entity('follow')
export class FollowEntity {
	@PrimaryGeneratedColumn('uuid')
	relationId: string;

	@ManyToOne(() => UserEntity, (user: UserEntity) => user.followings)
	follower: UserEntity;

	@ManyToOne(() => UserEntity, (user: UserEntity) => user.followers)
	following: UserEntity;

	constructor(follower: UserEntity, following: UserEntity) {
		this.follower = follower;
		this.following = following;
	}
}
