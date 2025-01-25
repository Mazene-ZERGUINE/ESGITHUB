import { HttpException, HttpStatus } from '@nestjs/common';

export class HttpExistsException extends HttpException {
	constructor(message: string, public readonly customCode?: string) {
		super(
			{
				status: HttpStatus.BAD_REQUEST,
				error: message,
				code: customCode || 'BAD_REQUEST',
			},
			HttpStatus.BAD_REQUEST,
		);
	}
}
