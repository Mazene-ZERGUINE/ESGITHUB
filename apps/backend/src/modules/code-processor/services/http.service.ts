import { Injectable } from '@nestjs/common';
import axios, { AxiosResponse } from 'axios';
import { ConfigService } from '@nestjs/config';
import * as path from 'node:path';
import * as fs from 'node:fs';
import { join } from 'path';

@Injectable()
export class HttpService {
	private readonly axiosInstance;
	private readonly outputDir = join(
		__dirname,
		'../../../../',
		'uploads',
		'code',
		'output',
	);

	constructor(private configService: ConfigService) {
		this.axiosInstance = axios.create({
			baseURL: this.configService.get(
				'CODE_RUNNER_SERVICE_API',
				'http://cdr.esgithub.org/',
			),
			headers: {
				'Content-Type': 'application/json',
			},
		});
	}

	async get<T>(url: string): Promise<T> {
		try {
			const response = (await this.axiosInstance.get(url)) as AxiosResponse<T>;
			return response.data;
		} catch (error) {
			console.error(error);
		}
	}

	async post<T, D>(url: string, data?: D): Promise<T> {
		const response = (await this.axiosInstance.post(url, data)) as AxiosResponse<T>;
		return response.data;
	}

	async downloadFile(fileUrl: string): Promise<string> {
		const outputFilePath = path.join(this.outputDir, path.basename(fileUrl));
		const writer = fs.createWriteStream(outputFilePath);
		try {
			const response = await this.axiosInstance.get(fileUrl, {
				responseType: 'stream',
			});
			response.data.pipe(writer);
			return new Promise((resolve, reject) => {
				writer.on('finish', () => resolve(outputFilePath));
				writer.on('error', reject);
			});
		} catch (error) {
			writer.close();
			throw error;
		}
	}
}
