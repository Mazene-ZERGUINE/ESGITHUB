import {
	Body,
	Controller,
	HttpCode,
	Post,
	UploadedFiles,
	UseGuards,
	UseInterceptors,
} from '@nestjs/common';
import { ProcessCodeRequestDto } from '../dtos/request/process-code-request.dto';
import { CodeProcessorService } from '../services/code-processor.service';
import { CodeResultsResponseDto } from '../dtos/response/code-results-response.dto';
import {
	ApiBadRequestResponse,
	ApiConsumes,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ThrottlerGuard } from '@nestjs/throttler';
import { codeExecutionsMulterOption } from '../../../core/middleware/multer.config';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ProcessFileRequestDto } from '../dtos/request/process-file-request.dto';
import { Express } from 'express';
import { CodeWithFileExecutedResponseDto } from '../dtos/response/code-with-file-executed-response.dto';

@UseGuards(ThrottlerGuard)
@Controller('/code-processor')
@ApiTags('Code processor')
export class CodeProcessingControllerController {
	constructor(private readonly codeProcessorService: CodeProcessorService) {}

	@UseGuards(JwtAuthGuard, ThrottlerGuard)
	@Post('/run-code')
	@HttpCode(200)
	@ApiOkResponse({
		description: '✅ Code processed successfully',
		type: CodeResultsResponseDto,
	})
	@ApiBadRequestResponse({
		description: '❌ Language/code should be provided/correct',
	})
	async processCode(
		@Body() payload: ProcessCodeRequestDto,
	): Promise<CodeResultsResponseDto> {
		return await this.codeProcessorService.runCode(
			payload.sourceCode,
			payload.programmingLanguage,
		);
	}

	@UseGuards(JwtAuthGuard, ThrottlerGuard)
	@Post('files/run-code')
	@HttpCode(200)
	@ApiOkResponse({
		description: '✅ Code processed successfully',
		type: CodeResultsResponseDto,
	})
	@ApiBadRequestResponse({
		description: '❌ Language/code should be provided/correct',
	})
	@ApiBadRequestResponse({
		description: '❌ no file was provided',
	})
	@UseInterceptors(FilesInterceptor('files', 5, codeExecutionsMulterOption))
	@ApiConsumes('multipart/form-data')
	async processCodeWithFile(
		@Body() payload: ProcessFileRequestDto,
		@UploadedFiles() files: Express.Multer.File[],
	): Promise<CodeWithFileExecutedResponseDto> {
		return await this.codeProcessorService.runCodeWithFiles(files, payload);
	}
}
