import {
	Entity,
	PrimaryGeneratedColumn,
	Column,
	ManyToOne,
	JoinColumn,
	Unique,
} from 'typeorm';
import { ReactionTypeEnum } from '../enums/reaction-type.enum';
import { UserEntity } from './user.entity';
import { ProgramEntity } from './program.entity';

@Entity()
@Unique(['program', 'user'])
export class ReactionEntity {
	@PrimaryGeneratedColumn('uuid')
	reactionId: string;

	@Column({ type: 'enum', enum: ReactionTypeEnum })
	type: ReactionTypeEnum;

	@ManyToOne(() => UserEntity, (user) => user.reactions)
	@JoinColumn({ name: 'userId' })
	user: UserEntity;

	@ManyToOne(() => ProgramEntity, (program) => program.reactions, {
		onDelete: 'CASCADE',
	})
	@JoinColumn({ name: 'programId' })
	program: ProgramEntity;

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;
}
