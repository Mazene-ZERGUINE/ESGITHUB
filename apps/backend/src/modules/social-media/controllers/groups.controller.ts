import {
	Body,
	Controller,
	Delete,
	Get,
	HttpCode,
	Param,
	Post,
	UploadedFile,
	UseGuards,
	UseInterceptors,
} from '@nestjs/common';
import {
	ApiBadRequestResponse,
	ApiCreatedResponse,
	ApiInternalServerErrorResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { GroupsService } from '../services/groups.service';
import { CreateGroupRequestDto } from '../dtos/request/create-group-request.dto';
import { GroupDataDto } from '../dtos/response/group-data.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { multerOptions } from '../../../core/middleware/multer.config';
import { Express } from 'express';
import { ConfigService } from '@nestjs/config';
import JoinGroupDto from '../dtos/request/join-group.dto';
import { CreateGroupProgramDto } from '../dtos/request/create-group-program.dto';

@ApiTags('groups')
@Controller('groups')
export class GroupsController {
	constructor(
		private readonly groupsService: GroupsService,
		private readonly configService: ConfigService,
	) {}

	@Post('/create')
	@UseGuards(JwtAuthGuard)
	@HttpCode(201)
	@UseInterceptors(FileInterceptor('image', multerOptions))
	@ApiCreatedResponse({
		description: 'create a new group',
		isArray: false,
		type: GroupDataDto,
	})
	@ApiBadRequestResponse({
		description: 'returns http 400 error when fields are missing',
	})
	async create(
		@Body() payload: CreateGroupRequestDto,
		@UploadedFile() file: Express.Multer.File,
	): Promise<GroupDataDto> {
		let imageUrl = null;
		if (file) {
			imageUrl = `${this.configService.get('STATIC_IMAGES_URL')}/uploads/avatars/${
				file.filename
			}`;
		}
		return await this.groupsService.createGroup(payload, imageUrl);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/all')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns all groups',
		type: [GroupDataDto],
		isArray: true,
	})
	@ApiInternalServerErrorResponse({
		description: 'returns http 500 if error occured',
	})
	async getAll(): Promise<GroupDataDto[]> {
		return this.groupsService.getAllGroups();
	}

	@UseGuards(JwtAuthGuard)
	@Get('/recent')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns groups created this month',
		type: [GroupDataDto],
		isArray: true,
	})
	@ApiInternalServerErrorResponse({
		description: 'returns http 500 if error occured',
	})
	async getRecentCreatedGroups(): Promise<GroupDataDto[]> {
		return this.groupsService.getTopGroupsByMembers();
	}

	@UseGuards(JwtAuthGuard)
	@Get('details/:groupId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns the group data',
		type: GroupDataDto,
		isArray: false,
	})
	@ApiBadRequestResponse({
		description: 'returns http 400 if error occured',
	})
	@ApiNotFoundResponse({
		description: 'returns http 404 if group not found',
	})
	async getOneById(@Param('groupId') groupId: string): Promise<GroupDataDto> {
		return this.groupsService.getGroupData(groupId);
	}

	@UseGuards(JwtAuthGuard)
	@Post('/add-member')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns 200 whene member is added successfully',
	})
	@ApiBadRequestResponse({
		description: 'returns http 400 if error occured',
	})
	@ApiNotFoundResponse({
		description: 'returns http 404 when user not found or group not found',
	})
	async addNewMember(@Body() payload: JoinGroupDto): Promise<void> {
		await this.groupsService.joinGroup(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Post('/leave')
	@HttpCode(204)
	@ApiOkResponse({
		description: 'returns 204 whene member is removed successfully',
	})
	@ApiBadRequestResponse({
		description: 'returns http 400 if error occured',
	})
	@ApiNotFoundResponse({
		description: 'returns http 404 when user not found or group not found',
	})
	async leaveGroup(@Body() payload: JoinGroupDto): Promise<void> {
		await this.groupsService.leaveGroup(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Delete('/delete/:groupId')
	@HttpCode(204)
	@ApiOkResponse({
		description: 'returns 200 when group is removed successfully',
	})
	@ApiInternalServerErrorResponse({
		description: 'returns http 500 if error occured',
	})
	@ApiNotFoundResponse({
		description: 'returns http 404 if error occured',
	})
	async delete(@Param('groupId') groupId: string): Promise<void> {
		await this.groupsService.deleteGroup(groupId);
	}

	@UseGuards(JwtAuthGuard)
	@Post('/publish')
	@HttpCode(201)
	@ApiOkResponse()
	@ApiNotFoundResponse()
	@ApiInternalServerErrorResponse()
	@ApiBadRequestResponse()
	async publish(@Body() payload: CreateGroupProgramDto): Promise<void> {
		await this.groupsService.publishProgram(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/update/visibility/:groupId')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiNotFoundResponse()
	@ApiInternalServerErrorResponse()
	@ApiBadRequestResponse()
	async updateVisibility(@Param('groupId') groupId: string): Promise<{
		visibility: string;
	}> {
		return await this.groupsService.updateGroupVisibility(groupId);
	}
}
