import {
	Entity,
	PrimaryGeneratedColumn,
	Column,
	ManyToOne,
	ManyToMany,
	JoinColumn,
	JoinTable,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { GroupDataDto } from '../dtos/response/group-data.dto';
import { ProgramEntity } from './program.entity';

@Entity('group')
export class GroupEntity {
	@PrimaryGeneratedColumn('uuid')
	groupId: string;

	@Column({ nullable: false, length: 60 })
	name: string;

	@Column({ nullable: true, type: 'text', default: null })
	description?: string;

	@Column({ nullable: true, type: 'text', default: null })
	imageUrl?: string;

	@Column({ nullable: true, type: 'text', default: 'public' })
	visibility?: string;

	@ManyToOne(() => UserEntity, (user) => user.ownedGroups, { nullable: false })
	@JoinColumn()
	owner: UserEntity;

	@ManyToMany(() => UserEntity, (user) => user.groups)
	members: UserEntity[];

	@ManyToMany(() => ProgramEntity, (program) => program.groups, {})
	@JoinTable({
		name: 'group_programs',
		joinColumn: {
			name: 'groupId',
			referencedColumnName: 'groupId',
		},
		inverseJoinColumn: {
			name: 'programId',
			referencedColumnName: 'programId',
		},
	})
	programs: ProgramEntity[];

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;

	@Column('timestamp', {
		default: () => 'CURRENT_TIMESTAMP',
		onUpdate: 'CURRENT_TIMESTAMP',
	})
	updatedAt: Date;

	toDto(): GroupDataDto {
		return new GroupDataDto(this);
	}
}
