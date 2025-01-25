import { Injectable } from '@nestjs/common';
import { CodeProcessorService } from './code-processor.service';
import { Express } from 'express';
import { GetProgramDto } from '../../social-media/dtos/response/get-program.dto';
import { ProcessFileRequestDto } from '../dtos/request/process-file-request.dto';
import { ProgrammingLanguage } from '../enums/ProgrammingLanguage';
import * as fs from 'fs';
import * as path from 'path';
import { join } from 'path';
import { HttpService } from './http.service';

@Injectable()
export class PipelineService {
	private readonly inputDirPath = join(__dirname, '../../../..');
	private readonly outputDirPath = join(__dirname, '../../../..');

	constructor(
		private readonly runCodeService: CodeProcessorService,
		private readonly httpService: HttpService,
	) {}

	async runPipelineWithFiles(
		startingFile: Express.Multer.File[],
		programsData: { programs: GetProgramDto[] },
	): Promise<any> {
		const outputFiles = [];
		let error: string = '';
		let success: boolean = true;
		let currentInputFile = startingFile;

		const programs: GetProgramDto[] = programsData.programs;

		for (const program of programs) {
			const processFileRequestDto = new ProcessFileRequestDto(
				program.programmingLanguage as unknown as ProgrammingLanguage,
				program.sourceCode,
				program.outputTypes,
			);

			try {
				const result = await this.runCodeService.runCodeWithFiles(
					currentInputFile,
					processFileRequestDto,
				);
				if (result.result.output_file_paths.length > 0) {
					for (const outputFilePath of result.result.output_file_paths) {
						const localFilePath = await this.httpService.downloadFile(outputFilePath);
						outputFiles.push(localFilePath);
					}
					await this.copyFilesToInputDirectory(outputFiles, 'uploads/code/input');
					currentInputFile = outputFiles.map((filePath) =>
						this.createFileObject(
							path.join('uploads/code/input', path.basename(filePath)),
						),
					);
				} else {
					success = false;
					error = result.result.stderr;
					break;
				}
			} catch (err) {
				success = false;
				error = err.message;
				break;
			}
		}

		if (success) {
			const outputLinks = outputFiles.map((file) =>
				file.replace('/var/www/4AL2_PA_backend/', ''),
			);

			//console.log(outputLinks)
			return { success, outputLinks };
		} else {
			return { success, error };
		}
	}

	private createFileObject(filePath: string): Express.Multer.File {
		const file = {
			fieldname: 'file',
			originalname: filePath.split('/').pop() || '',
			encoding: '7bit',
			mimetype: 'application/octet-stream',
			destination: filePath,
			filename: filePath.split('/').pop() || '',
			path: filePath,
			size: 0,
		} as Express.Multer.File;
		return file;
	}

	private async copyFilesToInputDirectory(
		filePaths: string[],
		targetDirectory: string,
	): Promise<void> {
		return new Promise((resolve, reject) => {
			filePaths.forEach((filePath, index) => {
				const fileName = path.basename(filePath);
				const targetPath = path.join(this.inputDirPath, targetDirectory, fileName);
				fs.copyFile(filePath, targetPath, (err) => {
					if (err) {
						reject(err);
					}
					if (index === filePaths.length - 1) {
						resolve();
					}
				});
			});
		});
	}
}
