import { ApiProperty } from '@nestjs/swagger';
import { UUID } from 'typeorm/driver/mongodb/bson.typings';
import { UserDataDto } from './user-data.dto';
import { GetProgramDto } from './get-program.dto';
import { CommentEntity } from '../../entities/comment.entity';

export class GetCommentsDto {
	@ApiProperty({
		description: 'commentId (uuid)',
		type: UUID,
		nullable: false,
	})
	commentId: string;

	@ApiProperty({
		description: 'content',
		type: String,
		nullable: false,
	})
	content: string;

	@ApiProperty({
		description: 'user',
		type: UserDataDto,
		nullable: false,
	})
	user: UserDataDto;

	@ApiProperty({
		description: 'program ',
		type: GetProgramDto,
		nullable: false,
	})
	program: GetProgramDto;

	@ApiProperty({
		description: 'comment responses',
		type: GetCommentsDto,
		nullable: false,
	})
	replies: GetCommentsDto[];

	@ApiProperty({
		description: 'line number if comment for code parts',
	})
	codeLineNumber?: number;

	@ApiProperty()
	createdAt: Date;

	@ApiProperty()
	updatedAt: Date;

	constructor(entity: CommentEntity) {
		this.commentId = entity.commentId;
		this.content = entity.content;
		if (entity.replies)
			this.replies = entity?.replies.map((reply) => reply?.toGetCommentDto());
		this.user = entity.user.toUserDataDto();
		this.createdAt = entity.createdAt;
		this.updatedAt = entity.updatedAt;
		this.codeLineNumber = entity.codeLineNumber;
	}
}
