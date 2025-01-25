import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { GroupEntity } from '../entities/group.entity';
import { EntityNotFoundError, Repository } from 'typeorm';
import { ProgramEntity } from '../entities/program.entity';
import { CreateGroupRequestDto } from '../dtos/request/create-group-request.dto';
import { GroupDataDto } from '../dtos/response/group-data.dto';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import JoinGroupDto from '../dtos/request/join-group.dto';
import { UserEntity } from '../entities/user.entity';
import { CreateGroupProgramDto } from '../dtos/request/create-group-program.dto';
import { ProgramVisibilityEnum } from '../enums/program-visibility.enum';

@Injectable()
export class GroupsService {
	constructor(
		@InjectRepository(GroupEntity)
		private readonly groupsRepository: Repository<GroupEntity>,
		@InjectRepository(UserEntity)
		private readonly userRepository: Repository<UserEntity>,
		@InjectRepository(ProgramEntity)
		private readonly programRepository: Repository<ProgramEntity>,
	) {}

	async createGroup(
		createGroupRequestDto: CreateGroupRequestDto,
		imageUrl: string,
	): Promise<GroupDataDto> {
		const existingGroup = await this.groupsRepository.findOne({
			where: { name: createGroupRequestDto.name },
		});
		if (existingGroup) {
			throw new InternalServerErrorException('Group with this name already exists');
		}
		const entity: GroupEntity = this.groupsRepository.create({
			...createGroupRequestDto,
			owner: { userId: createGroupRequestDto.ownerId },
			imageUrl: imageUrl,
		});
		const created = await this.groupsRepository.save(entity);
		return created.toDto();
	}

	async getAllGroups(): Promise<GroupDataDto[]> {
		const groups = await this.groupsRepository.find({ relations: ['owner', 'members'] });
		return groups.map((group) => group.toDto());
	}

	async getTopGroupsByMembers(): Promise<GroupDataDto[]> {
		const groups = await this.groupsRepository.find({ relations: ['owner', 'members'] });
		groups.sort((a, b) => b.members.length - a.members.length);
		const popularGroups = groups.slice(0, 10);
		return popularGroups.map((group) => group.toDto());
	}

	async getGroupData(groupId: string): Promise<GroupDataDto> {
		try {
			const groupEntity = await this.groupsRepository.findOneOrFail({
				where: { groupId: groupId },
				relations: [
					'owner',
					'members',
					'programs',
					'programs.user',
					'programs.reactions',
					'programs.reactions.user',
				],
			});
			return groupEntity.toDto();
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException(error.message);
			else throw new InternalServerErrorException(error);
		}
	}

	async joinGroup(joinGroupDto: JoinGroupDto): Promise<void> {
		try {
			const groupEntity = await this.groupsRepository.findOneOrFail({
				where: { groupId: joinGroupDto.groupId },
				relations: ['members'],
			});
			const userEntity = await this.userRepository.findOneOrFail({
				where: { userId: joinGroupDto.userId },
			});
			groupEntity.members.push(userEntity);
			await this.groupsRepository.save(groupEntity);
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException(error.message);
			else throw new InternalServerErrorException(error);
		}
	}

	async leaveGroup(joinGroupDto: JoinGroupDto): Promise<void> {
		try {
			const groupEntity = await this.groupsRepository.findOneOrFail({
				where: { groupId: joinGroupDto.groupId },
				relations: ['members'],
			});
			const index = groupEntity.members.findIndex(
				(member) => member.userId === joinGroupDto.userId,
			);
			if (index === -1) {
				throw new HttpNotFoundException('user not memeber of group');
			}
			groupEntity.members.splice(index, 1);
			await this.groupsRepository.save(groupEntity);
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException(error.message);
			else throw new InternalServerErrorException(error);
		}
	}

	async deleteGroup(groupId: string): Promise<void> {
		await this.groupsRepository.delete(groupId);
	}

	async publishProgram(payload: CreateGroupProgramDto): Promise<void> {
		try {
			const user = await this.userRepository.findOneOrFail({
				where: { userId: payload.userId },
			});
			const program = new ProgramEntity(
				payload.description,
				payload.programmingLanguage,
				payload.sourceCode,
				ProgramVisibilityEnum.PRIVATE,
				payload.inputTypes,
				user,
				payload.outputTypes,
			);
			program.isProgramGroup = true;

			const group = await this.groupsRepository.findOneOrFail({
				where: { groupId: payload.groupId },
				relations: ['members', 'owner', 'programs'],
			});
			group.programs.push(program);
			await this.programRepository.save(program);
			await this.groupsRepository.save(group);
		} catch (error: unknown) {
			if (error instanceof EntityNotFoundError)
				throw new HttpNotFoundException(error.message);
			else throw new InternalServerErrorException(error);
		}
	}

	async updateGroupVisibility(groupId: string): Promise<{ visibility: string }> {
		const group = await this.groupsRepository.findOneOrFail({
			where: { groupId: groupId },
		});
		if (group.visibility === ProgramVisibilityEnum.PRIVATE) {
			group.visibility = ProgramVisibilityEnum.PUBLIC;
		} else {
			group.visibility = ProgramVisibilityEnum.PRIVATE;
		}
		await this.groupsRepository.save(group);
		return { visibility: group.visibility };
	}
}
