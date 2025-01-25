import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from './http.service';
import { CodeResultsResponseDto } from '../dtos/response/code-results-response.dto';
import { CodeExecutedResponseDto } from '../dtos/response/code-executed-response.dto';
import { ProgrammingLanguage } from '../enums/ProgrammingLanguage';
import { ProcessFileRequestDto } from '../dtos/request/process-file-request.dto';
import { Express } from 'express';
import { CodeWithFileExecutedResponseDto } from '../dtos/response/code-with-file-executed-response.dto';
import { FilesHandlerUtils } from '../utils/files-handler.utils';
import { ExecuteCodeWithFileDto } from '../dtos/request/execute-code-with-file.dto';
import { TimeoutException } from '../../../core/exceptions/TimeoutException';

@Injectable()
export class CodeProcessorService {
	constructor(
		private readonly httpService: HttpService,
		private readonly fileUtils: FilesHandlerUtils,
	) {}

	private delay(ms: number): Promise<void> {
		return new Promise((resolve) => setTimeout(resolve, ms));
	}

	async runCode(
		sourceCode: string,
		programmingLanguage: ProgrammingLanguage,
		maxRetries: number = 3,
		retryDelay: number = 2000,
	): Promise<CodeResultsResponseDto> {
		const data = {
			programming_language: programmingLanguage,
			source_code: sourceCode,
		};
		const response: CodeExecutedResponseDto = await this.httpService.post(
			'execute/',
			data,
		);
		let taskResult: CodeResultsResponseDto;
		for (let attempt = 1; attempt <= maxRetries; attempt++) {
			taskResult = (await this.checkTaskStatus(
				response.task_id,
			)) as CodeResultsResponseDto;

			if (!(taskResult.result as any).error) {
				return taskResult;
			}
			if (attempt < maxRetries) {
				await this.delay(retryDelay);
			}
		}
		throw new TimeoutException(
			'Failed to get successful task result after multiple attempts',
		);
	}

	async runCodeWithFiles(
		files: Express.Multer.File[],
		processCodeDto: ProcessFileRequestDto,
	): Promise<any> {
		let staticOutputFilePaths: string[] = [];
		try {
			const processFilePaths = this.fileUtils.processFilePath(files);
			const executeCodeWithFilesDto = this.createExecuteCodeWithFileDto(
				processCodeDto,
				processFilePaths,
			);
			const taskCreationRequest = await this.createTask(executeCodeWithFilesDto);
			let taskResult = await this.getTaskResult(taskCreationRequest.task_id);
			taskResult = this.validateTaskResult(taskResult);
			staticOutputFilePaths = await this.downloadAndTransformFiles(
				taskResult.result.output_file_paths,
			);
			taskResult.result.output_file_paths = staticOutputFilePaths;
			return taskResult;
		} finally {
			this.cleanupFiles(files);
		}
	}

	private createExecuteCodeWithFileDto(
		processCodeDto: ProcessFileRequestDto,
		processFilePaths: string[],
	): ExecuteCodeWithFileDto {
		return new ExecuteCodeWithFileDto(
			processCodeDto.programmingLanguage,
			processCodeDto.sourceCode,
			processFilePaths,
			processCodeDto.outputFilesFormats,
		);
	}

	private async createTask(
		executeCodeWithFilesDto: ExecuteCodeWithFileDto,
	): Promise<CodeExecutedResponseDto> {
		const taskCreationRequest: CodeExecutedResponseDto = await this.httpService.post(
			'file/execute',
			executeCodeWithFilesDto,
		);

		if (!taskCreationRequest.task_id) {
			throw new InternalServerErrorException(
				'Failed to create new Celery task to execute code',
			);
		}
		return taskCreationRequest;
	}

	private async getTaskResult(taskId: string): Promise<CodeWithFileExecutedResponseDto> {
		const taskResult = await this.checkTaskStatus(taskId);
		return taskResult as CodeWithFileExecutedResponseDto;
	}

	private validateTaskResult(
		taskResult: CodeWithFileExecutedResponseDto,
	): CodeWithFileExecutedResponseDto {
		return taskResult;
	}

	private async downloadAndTransformFiles(outputFilePaths: string[]): Promise<string[]> {
		const staticOutputFilePaths: string[] = [];
		const downloadPromises = outputFilePaths.map(async (filePath) => {
			const newFilePath = await this.httpService.downloadFile(filePath);
			if (!newFilePath) {
				throw new InternalServerErrorException('Failed to download output result file');
			}
			staticOutputFilePaths.push(filePath);
			return filePath;
		});
		await Promise.all(downloadPromises);
		return staticOutputFilePaths;
	}

	private cleanupFiles(files: Express.Multer.File[]): void {
		files.forEach((file) => {
			this.fileUtils.checkFileIfExists(file.path);
			this.fileUtils.removeTmpFiles(file.path);
		});
	}

	private async checkTaskStatus(
		taskId: string,
	): Promise<CodeResultsResponseDto | CodeWithFileExecutedResponseDto> {
		for (let i = 0; i < 5; i++) {
			const taskResult = await this.httpService.get<CodeResultsResponseDto>(
				`result/${taskId}`,
			);
			if (taskResult.status === 'Completed') {
				return taskResult;
			}
			await new Promise((resolve) => setTimeout(resolve, 2000));
		}
	}
}
