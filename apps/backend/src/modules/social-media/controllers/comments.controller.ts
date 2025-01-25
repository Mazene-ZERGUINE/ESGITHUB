import {
	BadRequestException,
	Body,
	Controller,
	Delete,
	Get,
	HttpCode,
	Param,
	Patch,
	Post,
	Query,
	UseGuards,
} from '@nestjs/common';
import {
	ApiBadRequestResponse,
	ApiCreatedResponse,
	ApiNoContentResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { CreateCommentDto } from '../dtos/request/create-comment.dto';
import { CommentsService } from '../services/comments.service';
import { GetCommentsDto } from '../dtos/response/get-comments.dto';
import { EditCommentDto } from '../dtos/request/edit-comment.dto';
import { GetCommentsByLineRequestDto } from '../dtos/request/get-comments-by-line-request.dto';

@ApiTags('comments')
@Controller('comment')
export class CommentsController {
	constructor(private readonly commentService: CommentsService) {}
	@UseGuards(JwtAuthGuard)
	@Post('')
	@HttpCode(201)
	@ApiCreatedResponse({
		description: 'returns 201 http code when comments is saved',
		type: null,
	})
	@ApiBadRequestResponse({
		description: 'returns 400 response code when a param is missing',
		type: BadRequestException,
	})
	async create(@Body() payload: CreateCommentDto): Promise<void> {
		await this.commentService.saveComment(payload);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/:programId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'returns a list of program comments and their responses when found',
		isArray: true,
		type: GetCommentsDto,
	})
	@ApiNotFoundResponse({
		description: 'returns http 404 code when comment not found',
	})
	async getAll(@Param('programId') programId: string): Promise<GetCommentsDto[]> {
		return await this.commentService.getAllProgramComments(programId);
	}

	@UseGuards(JwtAuthGuard)
	@Delete('/:commentId')
	@HttpCode(204)
	@ApiNoContentResponse()
	@ApiNotFoundResponse()
	private async delete(@Param('commentId') commentId: string): Promise<void> {
		await this.commentService.deleteComment(commentId);
	}

	@UseGuards(JwtAuthGuard)
	@Patch('/:commentId')
	@HttpCode(200)
	@ApiOkResponse()
	@ApiNotFoundResponse()
	private async partialUpdate(
		@Param('commentId') commentId: string,
		payload: EditCommentDto,
	): Promise<void> {
		await this.commentService.editComment(commentId, payload);
	}

	@UseGuards(JwtAuthGuard)
	@Post('/respond/:commentId')
	@HttpCode(201)
	@ApiCreatedResponse()
	@ApiBadRequestResponse()
	@ApiNotFoundResponse()
	private async replyToComment(
		@Param('commentId') commentId: string,
		@Body() payload: CreateCommentDto,
	): Promise<void> {
		await this.commentService.respondToComment(commentId, payload);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/line/:programId')
	@HttpCode(200)
	@ApiOkResponse({ type: [GetCommentsDto] })
	@ApiBadRequestResponse()
	@ApiNotFoundResponse()
	async getByLines(
		@Query() query: GetCommentsByLineRequestDto,
	): Promise<GetCommentsDto[]> {
		return this.commentService.getCommentsByLines(query.lineNumber, query.programId);
	}
}
