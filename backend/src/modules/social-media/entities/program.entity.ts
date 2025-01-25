import {
	Entity,
	PrimaryGeneratedColumn,
	Column,
	ManyToOne,
	OneToMany,
	ManyToMany,
} from 'typeorm';
import { UserEntity } from './user.entity';
import { ProgrammingLanguageEnum } from '../enums/programming-language.enum';
import { ProgramVisibilityEnum } from '../enums/program-visibility.enum';
import { ProgramVersionEntity } from './program-version.entity';
import { FileTypesEnum } from '../enums/file-types.enum';
import { ReactionEntity } from './reaction.entity';
import { CommentEntity } from './comment.entity';
import { GetProgramDto } from '../dtos/response/get-program.dto';
import { GroupEntity } from './group.entity';

@Entity('program')
export class ProgramEntity {
	@PrimaryGeneratedColumn('uuid')
	programId: string;

	@Column({ nullable: true, length: 255 })
	description?: string;

	@Column({ nullable: false, enum: ProgrammingLanguageEnum })
	programmingLanguage: ProgrammingLanguageEnum;

	@Column({ nullable: false })
	sourceCode: string;

	@Column({ nullable: false, enum: ProgramVisibilityEnum })
	visibility: ProgramVisibilityEnum;

	@Column({ type: 'simple-array', nullable: true, enum: FileTypesEnum })
	inputTypes?: FileTypesEnum[];

	@Column({ type: 'simple-array', nullable: true, enum: FileTypesEnum })
	outputTypes?: FileTypesEnum[];

	@Column({ nullable: true, default: false })
	isProgramGroup?: boolean;

	@ManyToOne(() => UserEntity, (user) => user.programs)
	user: UserEntity;

	@OneToMany(() => ProgramVersionEntity, (version) => version.program, {
		cascade: ['insert', 'update', 'remove', 'soft-remove', 'recover'],
		onDelete: 'CASCADE',
	})
	versions: ProgramVersionEntity[];

	@OneToMany(() => ReactionEntity, (reaction) => reaction.program, {
		cascade: ['remove'],
		onDelete: 'CASCADE',
	})
	reactions: ReactionEntity[];

	@OneToMany(() => CommentEntity, (comment) => comment.program, {
		cascade: ['remove'],
		onDelete: 'CASCADE',
	})
	comments: CommentEntity[];

	@ManyToMany(() => GroupEntity, (group) => group.programs, {
		onDelete: 'CASCADE',
		cascade: ['remove'],
	})
	groups: GroupEntity[];

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;

	@Column('timestamp', {
		default: () => 'CURRENT_TIMESTAMP',
		onUpdate: 'CURRENT_TIMESTAMP',
	})
	updatedAt: Date;

	constructor(
		description: string,
		programmingLanguage: ProgrammingLanguageEnum,
		sourceCode: string,
		visibility: ProgramVisibilityEnum,
		inputTypes: FileTypesEnum[],
		user: UserEntity,
		outputTypes: FileTypesEnum[],
	) {
		this.description = description;
		this.programmingLanguage = programmingLanguage;
		this.sourceCode = sourceCode;
		this.visibility = visibility;
		this.inputTypes = inputTypes;
		this.user = user;
		this.outputTypes = outputTypes;
	}

	toGetProgramDto(): GetProgramDto {
		const dto = new GetProgramDto(this);
		dto.user !== null ? (dto.user = this.user.toUserDataDto()) : null;
		return dto;
	}
}
