import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { ProgramEntity } from './program.entity';
import { ProgrammingLanguageEnum } from '../enums/programming-language.enum';
import { VersionsDto } from '../dtos/response/program-version-response.dto';

@Entity('program-version')
export class ProgramVersionEntity {
	@PrimaryGeneratedColumn('uuid')
	programVersionId: string;

	@Column({ nullable: false, default: '1.0.0' })
	version: string;

	@Column({ nullable: false, enum: ProgrammingLanguageEnum })
	programmingLanguage: ProgrammingLanguageEnum;

	@Column({ nullable: false })
	sourceCode: string;

	@ManyToOne(() => ProgramEntity, (program: ProgramEntity) => program.versions, {
		onDelete: 'CASCADE',
	})
	program: ProgramEntity;

	@Column('timestamp', { default: () => 'CURRENT_TIMESTAMP' })
	createdAt: Date;

	constructor(
		originalProgram: ProgramEntity,
		programmingLanguage: ProgrammingLanguageEnum,
		sourceCode: string,
		version: string,
	) {
		this.program = originalProgram;
		this.programmingLanguage = programmingLanguage;
		this.sourceCode = sourceCode;
		this.version = version;
	}

	toProgramVersions(): VersionsDto {
		return new VersionsDto(this);
	}
}
