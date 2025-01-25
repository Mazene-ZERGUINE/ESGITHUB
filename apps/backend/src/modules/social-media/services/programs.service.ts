import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { CreateProgramDto } from '../dtos/request/create-program.dto';
import { InjectRepository } from '@nestjs/typeorm';
import { ProgramEntity } from '../entities/program.entity';
import { EntityNotFoundError, Repository } from 'typeorm';
import { ProgramVisibilityEnum } from '../enums/program-visibility.enum';
import { GetProgramDto } from '../dtos/response/get-program.dto';
import { UsersService } from './users.service';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import { ProgramPartialUpdateDto } from '../dtos/request/program-partial-update.dto';
import { merge } from 'lodash';
import { GroupEntity } from '../entities/group.entity';

@Injectable()
export class ProgramsService {
	constructor(
		@InjectRepository(ProgramEntity)
		private readonly programRepository: Repository<ProgramEntity>,
		@InjectRepository(GroupEntity)
		private readonly groupRepository: Repository<GroupEntity>,
		private readonly userService: UsersService,
	) {}

	async saveProgram(payload: CreateProgramDto): Promise<void> {
		try {
			const user = await this.userService.findById(payload.userId);
			if (!user) {
				throw new HttpNotFoundException('user not found');
			}
			const program = new ProgramEntity(
				payload.description,
				payload.programmingLanguage,
				payload.sourceCode,
				payload.visibility,
				payload.inputTypes,
				user,
				payload.outputTypes,
			);
			await this.programRepository.save(program);
		} catch (error) {
			throw new InternalServerErrorException('Failed to save the program.');
		}
	}

	async getProgramByVisibility(
		visibility: ProgramVisibilityEnum,
	): Promise<GetProgramDto[]> {
		const visiblePrograms: ProgramEntity[] = await this.programRepository.find({
			where: { visibility: visibility, isProgramGroup: false },
			relations: ['user', 'reactions', 'reactions.user'],
		});
		return visiblePrograms.map((entity) => entity.toGetProgramDto());
	}

	async getUserPrograms(userId: string): Promise<GetProgramDto[]> {
		const userPrograms: ProgramEntity[] = await this.programRepository.find({
			where: { user: { userId: userId }, isProgramGroup: false },
			relations: ['user', 'reactions', 'reactions.user'],
		});
		return userPrograms.map((program) => program.toGetProgramDto());
	}

	async editProgram(programId: string, editDto: CreateProgramDto): Promise<void> {
		const program = await this.programRepository.findOneBy({ programId: programId });
		if (!program) {
			throw new HttpNotFoundException('program not found');
		}
		Object.assign(program, editDto);
		await this.programRepository.save(program);
	}

	async programPartialUpdate(
		updateDto: ProgramPartialUpdateDto,
		programId: string,
	): Promise<void> {
		const program = await this.programRepository.findOneBy({ programId: programId });
		if (!program) {
			throw new HttpNotFoundException('programNot found');
		}
		merge(program, updateDto);
		program.inputTypes = updateDto.inputTypes;
		program.outputTypes = updateDto.outputTypes;
		await this.programRepository.save(program);
	}

	async deleteProgram(programId: string): Promise<void> {
		await this.programRepository.delete(programId);
	}

	async getProgramDetails(programId: string): Promise<GetProgramDto> {
		try {
			const entity = await this.programRepository.findOneOrFail({
				where: { programId: programId },
				relations: ['user', 'reactions', 'reactions.user'],
			});
			return entity.toGetProgramDto();
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException('program not found');
			else throw new InternalServerErrorException(error);
		}
	}

	async getProgramByVisibilityAndFiles(
		visibility: ProgramVisibilityEnum,
	): Promise<GetProgramDto[]> {
		const visiblePrograms: ProgramEntity[] = await this.programRepository.find({
			where: { visibility: visibility, isProgramGroup: false },
			relations: ['user', 'reactions', 'reactions.user'],
		});
		const filtredPrograms = visiblePrograms.filter(
			(program: ProgramEntity) =>
				program.inputTypes.length > 0 && program.outputTypes.length > 0,
		);
		return filtredPrograms.map((entity) => entity.toGetProgramDto());
	}
}
