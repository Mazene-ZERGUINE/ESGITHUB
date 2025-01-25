import {
	Entity,
	PrimaryGeneratedColumn,
	Column,
	ManyToOne,
	JoinColumn,
	OneToMany,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { ProgramEntity } from './program.entity';
import { GetCommentsDto } from '../dtos/response/get-comments.dto';

@Entity('comment')
export class CommentEntity {
	@PrimaryGeneratedColumn('uuid')
	commentId: string;

	@Column({ nullable: false, type: 'text' })
	content: string;

	@ManyToOne(() => UserEntity, (user) => user.comments)
	@JoinColumn({ name: 'userId' })
	user: UserEntity;

	@ManyToOne(() => ProgramEntity, (program) => program.comments, {
		onDelete: 'CASCADE',
	})
	@JoinColumn({ name: 'programId' })
	program: ProgramEntity;

	@Column({ nullable: true, type: 'integer' })
	codeLineNumber?: number;

	@ManyToOne(() => CommentEntity, (comment) => comment.replies, {
		nullable: true,
		onDelete: 'CASCADE',
	})
	@JoinColumn({ name: 'parentCommentId' })
	parentComment: CommentEntity;

	@OneToMany(() => CommentEntity, (comment) => comment.parentComment, {
		cascade: ['insert', 'update', 'remove'],
	})
	replies?: CommentEntity[];

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;

	@Column('timestamp', {
		default: () => 'CURRENT_TIMESTAMP',
		onUpdate: 'CURRENT_TIMESTAMP',
	})
	updatedAt: Date;

	toGetCommentDto(): GetCommentsDto {
		return new GetCommentsDto(this);
	}
}
