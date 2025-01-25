import { HttpException, HttpStatus } from '@nestjs/common';

export class TimeoutException extends HttpException {
	constructor(message: string, public readonly customCode?: string) {
		super(
			{
				status: HttpStatus.REQUEST_TIMEOUT,
				error: message,
				code: customCode || 'REQUEST_TIMEOUT',
			},
			HttpStatus.REQUEST_TIMEOUT,
		);
	}
}
