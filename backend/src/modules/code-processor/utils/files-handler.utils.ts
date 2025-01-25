import { ConfigService } from '@nestjs/config';
import * as fs from 'node:fs';
import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Express } from 'express';

@Injectable()
export class FilesHandlerUtils {
	readonly codeInputPath: string;
	readonly codeOutputPath: string;

	constructor(private readonly configService: ConfigService) {
		this.codeInputPath = this.configService.get<string>('STATIC_INPUT_CODE_URL');
		this.codeOutputPath = this.configService.get<string>('STATIC_OUTPUT_CODE_URL');
	}

	removeTmpFiles(filePath: string): void {
		if (fs.existsSync(filePath)) {
			fs.unlinkSync(filePath);
		} else {
			throw new InternalServerErrorException('Error while removing tmp files');
		}
	}

	processFilePath(inputFiles: Express.Multer.File[]): string[] {
		const inputFilePaths = inputFiles.map((file) => {
			return `${this.codeInputPath}/${file.filename}`;
		});
		return inputFilePaths;
	}

	checkFileIfExists(filePath: string): boolean {
		return fs.existsSync(filePath);
	}

	transformToStaticFile(fileName: string): string {
		return this.codeOutputPath + '/' + fileName;
	}
}
