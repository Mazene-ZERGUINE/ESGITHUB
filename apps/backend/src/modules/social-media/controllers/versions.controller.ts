import {
	Body,
	Controller,
	Delete,
	Get,
	HttpCode,
	Param,
	Patch,
	Post,
	UseGuards,
} from '@nestjs/common';
import {
	ApiBadRequestResponse,
	ApiCreatedResponse,
	ApiNoContentResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { VersionsService } from '../services/versions.service';
import { CreateVersionDto } from '../dtos/request/create-version.dto';
import {
	ProgramVersionResponseDto,
	VersionsDto,
} from '../dtos/response/program-version-response.dto';

@ApiTags('versions')
@Controller('versions')
export class VersionsController {
	constructor(private readonly versionsService: VersionsService) {}

	@UseGuards(JwtAuthGuard)
	@Post('')
	@HttpCode(201)
	@ApiCreatedResponse({
		description: 'returns 2O1 code when new code version is created',
	})
	@ApiBadRequestResponse({
		description: 'returns 400 code when a param is messing from request body',
	})
	async create(@Body() payload: CreateVersionDto): Promise<void> {
		await this.versionsService.addNewVersion(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/all/:programId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns a list of all program versions',
		type: ProgramVersionResponseDto,
		isArray: true,
	})
	@ApiNotFoundResponse({
		description: 'returns 400 code when program does not exists',
	})
	async getAllByProgram(
		@Param('programId') programId: string,
	): Promise<ProgramVersionResponseDto> {
		return await this.versionsService.getProgramVersion(programId);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/version/:versionId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'return the version details with code 200',
		type: VersionsDto,
		isArray: false,
	})
	@ApiNotFoundResponse({
		description: 'returns 404 error when version not found',
	})
	async getOneByVersion(@Param('versionId') versionId: string): Promise<VersionsDto> {
		return await this.versionsService.getVersion(versionId);
	}

	@UseGuards(JwtAuthGuard)
	@Delete('/:versionId')
	@HttpCode(204)
	@ApiNoContentResponse({
		description: 'returns 204 code when version is deleted',
	})
	@ApiNotFoundResponse({
		description: 'returns 404 code when not found',
	})
	async delete(@Param('versionId') versionId: string): Promise<void> {
		await this.versionsService.deleteVersion(versionId);
	}

	@UseGuards(JwtAuthGuard)
	@Patch('/:versionId')
	@HttpCode(204)
	@ApiOkResponse()
	@ApiNotFoundResponse()
	async updateVersionSourceCode(
		@Param('versionId') versionId: string,
		@Body()
		payload: {
			sourceCode: string;
		},
	): Promise<void> {
		await this.versionsService.versionPartialUpdate(versionId, payload);
	}
}
