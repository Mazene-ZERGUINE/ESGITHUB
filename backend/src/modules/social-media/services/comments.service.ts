import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { CommentEntity } from '../entities/comment.entity';
import { EntityNotFoundError, Repository } from 'typeorm';
import { ProgramEntity } from '../entities/program.entity';
import { CreateCommentDto } from '../dtos/request/create-comment.dto';
import { UserEntity } from '../entities/user.entity';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import { EditCommentDto } from '../dtos/request/edit-comment.dto';
import { GetCommentsDto } from '../dtos/response/get-comments.dto';

@Injectable()
export class CommentsService {
	constructor(
		@InjectRepository(CommentEntity)
		private readonly commentsRepository: Repository<CommentEntity>,
		@InjectRepository(ProgramEntity)
		private readonly programsRepository: Repository<ProgramEntity>,
		@InjectRepository(UserEntity)
		private readonly userRepository: Repository<UserEntity>,
	) {}

	async saveComment(commentDto: CreateCommentDto): Promise<void> {
		try {
			const commentEntity = await this.createCommentEntity(commentDto);
			await this.commentsRepository.save(commentEntity);
		} catch (error: unknown) {
			throw new InternalServerErrorException(`internal server error ${error}`);
		}
	}

	async deleteComment(commentId: string): Promise<void> {
		try {
			await this.commentsRepository.delete(commentId);
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException('comment ');
			else throw new InternalServerErrorException(`internal server error ${error}`);
		}
	}

	async editComment(commentId: string, editCommentDto: EditCommentDto): Promise<void> {
		try {
			const commentEntity = await this.commentsRepository.findOneByOrFail({
				commentId: commentId,
			});
			commentEntity.content = editCommentDto.content;
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException('comment not found');
			else throw new InternalServerErrorException(`internal server error ${error}`);
		}
	}

	async getAllProgramComments(programId: string): Promise<GetCommentsDto[]> {
		try {
			const comments = await this.commentsRepository.find({
				where: { program: { programId: programId } },
				relations: ['user', 'replies', 'replies.user'],
				order: { createdAt: 'ASC' },
			});
			return comments.map((comment: CommentEntity) => comment?.toGetCommentDto());
		} catch (error: unknown) {
			throw new InternalServerErrorException(`internal server error ${error}`);
		}
	}

	async respondToComment(commentId: string, commentDto: CreateCommentDto): Promise<void> {
		try {
			const commentEntity = await this.commentsRepository.findOneOrFail({
				where: { commentId },
				relations: ['replies'],
			});
			const replyEntity = await this.createCommentEntity(commentDto);
			replyEntity.parentComment = commentEntity;
			commentEntity.replies.push(replyEntity);
			await this.commentsRepository.save(replyEntity);
			await this.commentsRepository.save(commentEntity);
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException('comment not found');
			else throw new InternalServerErrorException(`internal server error ${error}`);
		}
	}

	async getCommentsByLines(
		lineNumber: number,
		programId: string,
	): Promise<GetCommentsDto[]> {
		const comments = await this.commentsRepository.find({
			where: {
				program: { programId: programId },
				codeLineNumber: lineNumber,
			},
			relations: ['user', 'replies', 'replies.user'],
		});
		return comments.map((comment: CommentEntity) => comment.toGetCommentDto());
	}

	private async createCommentEntity(
		commentDto: CreateCommentDto,
	): Promise<CommentEntity> {
		const userRef = await this.userRepository.findOneByOrFail({
			userId: commentDto.userId,
		});
		const programRef = await this.programsRepository.findOneByOrFail({
			programId: commentDto.programId,
		});
		const commentEntity = this.commentsRepository.create({
			...commentDto,
			user: userRef,
			program: programRef,
		});
		return commentEntity;
	}
}
