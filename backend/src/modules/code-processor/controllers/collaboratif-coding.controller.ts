import { Controller, Get, HttpCode, UseGuards } from '@nestjs/common';
import { ApiInternalServerErrorResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ThrottlerGuard } from '@nestjs/throttler';
import { v4 as uuidv4 } from 'uuid';

@ApiTags('collaboratif-coding')
@Controller('collaboratif-coding')
export class CollaboratifCodingController {
	@UseGuards(JwtAuthGuard, ThrottlerGuard)
	@Get('/generate-session')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiInternalServerErrorResponse()
	async createSession(): Promise<{ sessionId: string }> {
		const sessionId = uuidv4();
		return { sessionId: sessionId };
	}
}
