import { ApiBadRequestResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { Body, Controller, HttpCode, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { LikeRequestDto } from '../dtos/request/like-request.dto';
import { ReactionsService } from '../services/reactions.service';

@ApiTags('reactions')
@Controller('reactions')
export class ReactionsController {
	constructor(private readonly reactionsService: ReactionsService) {}

	@UseGuards(JwtAuthGuard)
	@Post('/like')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns http 200 code whene liked',
	})
	@ApiBadRequestResponse()
	async like(@Body() payload: LikeRequestDto): Promise<void> {
		await this.reactionsService.likeProgram(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Post('/dislike')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns http 200 code when reaction is dislike',
	})
	@ApiBadRequestResponse()
	async dislike(@Body() payload: LikeRequestDto): Promise<void> {
		await this.reactionsService.dislikeProgram(payload);
	}
}
