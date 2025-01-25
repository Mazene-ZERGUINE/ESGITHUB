// http-exception.filter.ts
import {
	ExceptionFilter,
	Catch,
	ArgumentsHost,
	HttpException,
	Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch(HttpException)
export class GlobalExceptionHandler implements ExceptionFilter {
	private readonly logger = new Logger(GlobalExceptionHandler.name);

	catch(exception: HttpException, host: ArgumentsHost): void {
		const ctx = host.switchToHttp();
		const response = ctx.getResponse<Response>();
		const request = ctx.getRequest<Request>();
		const status = exception.getStatus();
		const exceptionResponse = exception.getResponse();

		this.logger.error(
			`HTTP Status: ${status} Error Message: ${JSON.stringify(exceptionResponse)}`,
		);

		response.status(status).json({
			statusCode: status,
			timestamp: new Date().toISOString(),
			path: request.url,
			error: exceptionResponse,
		});
	}
}
