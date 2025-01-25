import {
	Entity,
	PrimaryGeneratedColumn,
	Column,
	OneToMany,
	Index,
	ManyToMany,
	JoinTable,
} from 'typeorm';
import { ProgramEntity } from './program.entity';
import { FollowEntity } from './follow.entity';
import { GroupEntity } from './group.entity';
import { ReactionEntity } from './reaction.entity';
import { CommentEntity } from './comment.entity';
import { UserDataDto } from '../dtos/response/user-data.dto';

@Entity('users')
export class UserEntity {
	@PrimaryGeneratedColumn('uuid')
	userId: string;

	@Column({ nullable: false, length: 60 })
	userName: string;

	@Column({ nullable: false, length: 60 })
	firstName: string;

	@Column({ nullable: false, length: 60 })
	lastName: string;

	@Column({ nullable: false, length: 60, unique: true })
	@Index()
	email: string;

	@Column({ nullable: false, length: 255 })
	password: string;

	@Column({ nullable: true })
	avatarUrl?: string;

	@Column({ nullable: true })
	bio?: string;

	@Column({ nullable: false, default: false })
	isVerified: boolean = false;

	@OneToMany(() => ProgramEntity, (program) => program.user, {
		cascade: ['insert', 'update', 'remove'],
	})
	programs: ProgramEntity[];

	@OneToMany(() => FollowEntity, (follow) => follow.follower)
	followings: FollowEntity[];

	@OneToMany(() => FollowEntity, (follow) => follow.following)
	followers: FollowEntity[];

	@ManyToMany(() => GroupEntity, (group) => group.members)
	@JoinTable({
		name: 'user_groups',
		joinColumn: {
			name: 'userId',
			referencedColumnName: 'userId',
		},
		inverseJoinColumn: {
			name: 'groupId',
			referencedColumnName: 'groupId',
		},
	})
	groups: GroupEntity[];

	@OneToMany(() => GroupEntity, (group) => group.owner)
	ownedGroups: GroupEntity[];

	@OneToMany(() => ReactionEntity, (reaction) => reaction.user, {
		cascade: ['remove'],
	})
	reactions: ReactionEntity[];

	@OneToMany(() => CommentEntity, (comment) => comment.user, {
		cascade: ['remove'],
	})
	comments: CommentEntity[];

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;

	@Column('timestamp', {
		default: () => 'CURRENT_TIMESTAMP',
		onUpdate: 'CURRENT_TIMESTAMP',
	})
	updatedAt: Date;

	@Column({ type: Date, nullable: true })
	connectedAt: Date;

	@Column({ type: Date, nullable: true })
	disconnectedAt: Date;

	toUserDataDto(): UserDataDto {
		return new UserDataDto(
			this.userId,
			this.userName,
			this.firstName,
			this.lastName,
			this.email,
			this.bio,
			this.avatarUrl,
			this.connectedAt,
			this.disconnectedAt,
		);
	}
}
