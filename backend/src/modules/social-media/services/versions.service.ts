import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { ProgramVersionEntity } from '../entities/program-version.entity';
import { Repository } from 'typeorm';
import { CreateVersionDto } from '../dtos/request/create-version.dto';
import { ProgramEntity } from '../entities/program.entity';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import {
	ProgramVersionResponseDto,
	VersionsDto,
} from '../dtos/response/program-version-response.dto';

@Injectable()
export class VersionsService {
	constructor(
		@InjectRepository(ProgramVersionEntity)
		private readonly versionsRepository: Repository<ProgramVersionEntity>,
		@InjectRepository(ProgramEntity)
		private readonly programRepository: Repository<ProgramEntity>,
	) {}

	async addNewVersion(createVersionDto: CreateVersionDto): Promise<void> {
		const originalProgram = await this.programRepository.findOne({
			where: { programId: createVersionDto.programId },
			relations: ['versions'],
		});
		if (!originalProgram) {
			throw new HttpNotFoundException(
				"Can't create new version. Original program not found.",
			);
		}

		const tagExists = originalProgram.versions?.some(
			(programVersion) => programVersion.version === createVersionDto.version,
		);
		if (tagExists) {
			throw new BadRequestException('This version tag already exists.');
		}

		const programVersionEntity = new ProgramVersionEntity(
			originalProgram,
			createVersionDto.programmingLanguage,
			createVersionDto.sourceCode,
			createVersionDto.version,
		);
		await this.versionsRepository.save(programVersionEntity);
	}

	async getProgramVersion(programId: string): Promise<ProgramVersionResponseDto> {
		const program = await this.programRepository.findOne({
			where: { programId: programId },
			relations: ['versions', 'comments'],
		});
		if (!program) {
			throw new HttpNotFoundException('program not found');
		}
		const versions = program.versions.map((versions) => versions.toProgramVersions());
		return new ProgramVersionResponseDto(program.toGetProgramDto(), versions);
	}

	async getVersion(programVersion: string): Promise<VersionsDto | undefined> {
		try {
			const version = await this.versionsRepository.findOneOrFail({
				where: { programVersionId: programVersion },
				relations: ['comments'],
			});
			return version.toProgramVersions();
		} catch (error: unknown) {
			throw new HttpNotFoundException('version not found');
		}
	}

	async deleteVersion(versionId: string): Promise<void> {
		try {
			await this.versionsRepository.delete(versionId);
		} catch (error: unknown) {
			throw new HttpNotFoundException('version not found');
		}
	}

	async versionPartialUpdate(
		versionId: string,
		payload: {
			sourceCode: string;
		},
	): Promise<void> {
		try {
			const entity = await this.versionsRepository.findOneOrFail({
				where: { programVersionId: versionId },
			});
			entity.sourceCode = payload.sourceCode;
			await this.versionsRepository.save(entity);
		} catch (error: unknown) {
			throw new HttpNotFoundException('version not found');
		}
	}
}
