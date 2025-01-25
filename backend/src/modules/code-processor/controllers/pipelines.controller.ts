import {
	ApiBadRequestResponse,
	ApiConsumes,
	ApiInternalServerErrorResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import {
	Body,
	Controller,
	HttpCode,
	Post,
	UploadedFiles,
	UseGuards,
	UseInterceptors,
} from '@nestjs/common';
import { ThrottlerGuard } from '@nestjs/throttler';
import { FilesInterceptor } from '@nestjs/platform-express';
import { codeExecutionsMulterOption } from '../../../core/middleware/multer.config';
import { PipelineService } from '../services/pipeline.service';
import { Express } from 'express';

@ApiTags('Pipeline')
@Controller('pipelines')
export class PipelinesController {
	constructor(private readonly pipelineService: PipelineService) {}

	@UseGuards(ThrottlerGuard)
	@Post('/file')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiInternalServerErrorResponse()
	@ApiBadRequestResponse()
	@UseInterceptors(FilesInterceptor('files', 5, codeExecutionsMulterOption))
	@ApiConsumes('multipart/form-data')
	async processPipelineWithFiles(
		@Body('programs') programsJson: string,
		@UploadedFiles() files: Express.Multer.File[],
	): Promise<any> {
		const programs = JSON.parse(programsJson);
		return await this.pipelineService.runPipelineWithFiles(files, { programs });
	}
}
