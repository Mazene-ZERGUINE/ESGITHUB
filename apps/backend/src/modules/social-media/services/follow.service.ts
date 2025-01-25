import { BadRequestException, Injectable } from '@nestjs/common';
import { FollowEntity } from '../entities/follow.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { UserEntity } from '../entities/user.entity';
import { Repository } from 'typeorm';
import { FollowUserRequestDto } from '../dtos/request/follow-user-request.dto';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import { UserWithFollowersDto } from '../dtos/response/user-with-followers.dto';

@Injectable()
export class FollowService {
	constructor(
		@InjectRepository(FollowEntity)
		private followRepository: Repository<FollowEntity>,
		@InjectRepository(UserEntity)
		private userRepository: Repository<UserEntity>,
	) {}

	async addToFollowers(payload: FollowUserRequestDto): Promise<void> {
		const follower = await this.userRepository.findOne({
			where: { userId: payload.followerId },
		});
		const following = await this.userRepository.findOne({
			where: { userId: payload.followingId },
		});
		if (!follower || !following) {
			throw new HttpNotFoundException('user not found');
		}
		const followEntity = new FollowEntity(follower, following);
		await this.followRepository.save(followEntity);
	}
	async getFollowersAndFollowings(userId: string): Promise<UserWithFollowersDto> {
		const user = await this.userRepository.findOne({
			where: { userId: userId },
			relations: [
				'followers',
				'followers.follower',
				'followings',
				'followings.following',
			],
		});
		if (!user) {
			throw new Error('User not found');
		}
		const followers = user.followers.map((follow) => {
			return { follower: follow.follower.toUserDataDto(), relationId: follow.relationId };
		});
		const followings = user.followings.map((follow) => {
			return {
				following: follow.following.toUserDataDto(),
				relationId: follow.relationId,
			};
		});
		return new UserWithFollowersDto(userId, followers, followings);
	}
	async unfollow(relationId: string): Promise<void> {
		const relation = await this.followRepository.findOne({
			where: { relationId: relationId },
		});
		if (!relation) {
			throw new BadRequestException('relation not found');
		}
		await this.followRepository.remove(relation);
	}
}
