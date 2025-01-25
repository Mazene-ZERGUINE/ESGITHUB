import { ValidationPipeOptions } from '@nestjs/common';

export const validationPipeOptions: ValidationPipeOptions = {
	whitelist: true,
	forbidNonWhitelisted: true,
	transform: true,
	disableErrorMessages: false,
	validationError: { target: false },
};
