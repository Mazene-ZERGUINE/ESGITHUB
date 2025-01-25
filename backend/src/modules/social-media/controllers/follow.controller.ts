import { Body, Controller, Get, HttpCode, Param, Post, UseGuards } from '@nestjs/common';
import {
	ApiBadRequestResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { FollowService } from '../services/follow.service';
import { FollowUserRequestDto } from '../dtos/request/follow-user-request.dto';
import { UserWithFollowersDto } from '../dtos/response/user-with-followers.dto';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('follow')
@Controller('follow')
export class FollowController {
	constructor(private readonly followService: FollowService) {}

	@UseGuards(JwtAuthGuard)
	@ApiOkResponse({
		description: 'return 200 http code when user is added to followers',
	})
	@ApiBadRequestResponse({
		description: 'returns 400 code whene a parameter is missing',
	})
	@ApiNotFoundResponse({
		description: 'returns 404 code when user not found',
	})
	@Post('follow-user')
	@HttpCode(200)
	async followUser(@Body() payload: FollowUserRequestDto): Promise<void> {
		await this.followService.addToFollowers(payload);
	}

	@UseGuards(JwtAuthGuard)
	@ApiOkResponse({
		description: 'return the list of user followers and followings',
	})
	@ApiNotFoundResponse({
		description: 'returns 404 error when user not found',
	})
	@Get('/:userId')
	@HttpCode(200)
	async getUserFollow(@Param('userId') userId: string): Promise<UserWithFollowersDto> {
		return await this.followService.getFollowersAndFollowings(userId);
	}

	@UseGuards(JwtAuthGuard)
	@ApiOkResponse({
		description: 'return 200 code when user is unfollowed',
	})
	@ApiBadRequestResponse({
		description: 'returns 400 code whene relation does not exist',
	})
	@Get('unfollow-user/:relationId')
	@HttpCode(200)
	async unfollowUser(@Param('relationId') relationId: string): Promise<void> {
		await this.followService.unfollow(relationId);
	}
}
