import {
	Body,
	Controller,
	Delete,
	Get,
	HttpCode,
	Param,
	Patch,
	Post,
	Put,
	Query,
	UseGuards,
} from '@nestjs/common';
import {
	ApiBadRequestResponse,
	ApiNoContentResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { ProgramsService } from '../services/programs.service';
import { CreateProgramDto } from '../dtos/request/create-program.dto';
import { ProgramVisibilityEnum } from '../enums/program-visibility.enum';
import { GetProgramDto } from '../dtos/response/get-program.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ProgramPartialUpdateDto } from '../dtos/request/program-partial-update.dto';

@Controller('/programs')
@ApiTags('Programs')
export class ProgramController {
	constructor(private readonly programService: ProgramsService) {}

	@UseGuards(JwtAuthGuard)
	@Post()
	@HttpCode(201)
	@ApiOkResponse()
	@ApiBadRequestResponse()
	async create(@Body() payload: CreateProgramDto): Promise<void> {
		await this.programService.saveProgram(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Get()
	@HttpCode(200)
	@ApiOkResponse()
	@ApiBadRequestResponse()
	async findBy(@Query('type') type: ProgramVisibilityEnum): Promise<GetProgramDto[]> {
		return await this.programService.getProgramByVisibility(type);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/files')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiBadRequestResponse()
	async findByFiles(
		@Query('type') type: ProgramVisibilityEnum,
	): Promise<GetProgramDto[]> {
		return await this.programService.getProgramByVisibilityAndFiles(type);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/:userId')
	@HttpCode(200)
	@ApiOkResponse({ description: 'return the list of all user programs' })
	async getByUser(@Param('userId') userId: string): Promise<GetProgramDto[]> {
		return this.programService.getUserPrograms(userId);
	}

	@UseGuards(JwtAuthGuard)
	@Put('/:programId')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiBadRequestResponse()
	@ApiNotFoundResponse()
	async edit(
		@Param('programId') programId: string,
		@Body() payload: CreateProgramDto,
	): Promise<void> {
		await this.programService.editProgram(programId, payload);
	}

	@UseGuards(JwtAuthGuard)
	@Patch('/edit/:programId')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiBadRequestResponse()
	@ApiNotFoundResponse()
	async updateProgram(
		@Param('programId') programId: string,
		@Body() payload: ProgramPartialUpdateDto,
	): Promise<void> {
		await this.programService.programPartialUpdate(payload, programId);
	}

	@UseGuards(JwtAuthGuard)
	@Delete('/:programId')
	@HttpCode(204)
	@ApiNoContentResponse()
	@ApiNotFoundResponse()
	async delete(@Param('programId') programId: string): Promise<void> {
		await this.programService.deleteProgram(programId);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/details/:programId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'return the details for program',
		type: GetProgramDto,
	})
	@ApiNotFoundResponse()
	async getOneById(@Param('programId') programId: string): Promise<GetProgramDto> {
		return this.programService.getProgramDetails(programId);
	}
}
