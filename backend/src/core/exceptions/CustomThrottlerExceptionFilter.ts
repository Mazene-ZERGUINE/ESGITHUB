import { ExceptionFilter, Catch, ArgumentsHost, HttpStatus } from '@nestjs/common';
import { ThrottlerException } from '@nestjs/throttler';
import { Request, Response } from 'express';

@Catch(ThrottlerException)
export class CustomThrottlerExceptionFilter implements ExceptionFilter {
	catch(exception: ThrottlerException, host: ArgumentsHost): void {
		const ctx = host.switchToHttp();
		const response = ctx.getResponse<Response>();
		const request = ctx.getRequest<Request>();

		response.status(HttpStatus.TOO_MANY_REQUESTS).json({
			statusCode: HttpStatus.TOO_MANY_REQUESTS,
			message: 'Custom rate limit exceeded message',
			timestamp: new Date().toISOString(),
			path: request.url,
		});
	}
}
