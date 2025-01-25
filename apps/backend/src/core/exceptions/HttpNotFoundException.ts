import { HttpException, HttpStatus } from '@nestjs/common';

export class HttpNotFoundException extends HttpException {
	constructor(message: string, public readonly customCode?: string) {
		super(
			{
				message: message,
				status: HttpStatus.NOT_FOUND,
				error: message,
				code: customCode || 'NOT_FOUND',
			},
			HttpStatus.NOT_FOUND,
		);
	}
}
