import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LikeRequestDto } from '../dtos/request/like-request.dto';
import { ReactionTypeEnum } from '../enums/reaction-type.enum';
import { UserEntity } from '../entities/user.entity';
import { ProgramEntity } from '../entities/program.entity';
import { LikesGateway } from 'src/core/websocket/likes.gateway';
import { ReactionEntity } from '../entities/reaction.entity';

@Injectable()
export class ReactionsService {
	constructor(
		@InjectRepository(ReactionEntity)
		private readonly reactionRepository: Repository<ReactionEntity>,
		private readonly likesGateway: LikesGateway,
	) {}

	async likeProgram(likeRequestDto: LikeRequestDto): Promise<void> {
		const existingReaction = await this.reactionRepository.findOne({
			where: {
				user: { userId: likeRequestDto.userId },
				program: { programId: likeRequestDto.programId },
			},
		});

		if (existingReaction) {
			if (existingReaction.type === ReactionTypeEnum.LIKE) {
				await this.reactionRepository.remove(existingReaction);
			} else if (existingReaction.type === ReactionTypeEnum.DISLIKE) {
				existingReaction.type = ReactionTypeEnum.LIKE;
				await this.reactionRepository.save(existingReaction);
			}
		} else {
			const reactionEntity = this.reactionRepository.create({
				type: ReactionTypeEnum.LIKE,
				user: { userId: likeRequestDto.userId } as UserEntity,
				program: { programId: likeRequestDto.programId } as ProgramEntity,
			});
			await this.reactionRepository.save(reactionEntity);
		}

		this.likesGateway.server.emit(ReactionTypeEnum.LIKE, {
			postId: likeRequestDto.programId,
		});
	}

	async dislikeProgram(likeRequestDto: LikeRequestDto): Promise<void> {
		const existingReaction = await this.reactionRepository.findOne({
			where: {
				user: { userId: likeRequestDto.userId },
				program: { programId: likeRequestDto.programId },
			},
		});

		if (existingReaction) {
			if (existingReaction.type === ReactionTypeEnum.DISLIKE) {
				await this.reactionRepository.remove(existingReaction);
			} else if (existingReaction.type === ReactionTypeEnum.LIKE) {
				existingReaction.type = ReactionTypeEnum.DISLIKE;
				await this.reactionRepository.save(existingReaction);
			}
		} else {
			const reactionEntity = this.reactionRepository.create({
				type: ReactionTypeEnum.DISLIKE,
				user: { userId: likeRequestDto.userId } as UserEntity,
				program: { programId: likeRequestDto.programId } as ProgramEntity,
			});
			await this.reactionRepository.save(reactionEntity);
		}

		this.likesGateway.server.emit(ReactionTypeEnum.DISLIKE, {
			postId: likeRequestDto.programId,
		});
	}
}
