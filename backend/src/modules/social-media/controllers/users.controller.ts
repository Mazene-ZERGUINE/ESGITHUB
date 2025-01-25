import {
	Body,
	Controller,
	HttpCode,
	Param,
	Post,
	UseInterceptors,
	UploadedFile,
	Request,
	UseGuards,
	Get,
	Patch,
} from '@nestjs/common';
import { UsersService } from '../services/users.service';
import { UpdateAccountDto } from '../dtos/request/update-account.dto';
import { ApiNotFoundResponse, ApiOkResponse, ApiTags } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { multerOptions } from '../../../core/middleware/multer.config';
import { Express } from 'express';
import { ConfigService } from '@nestjs/config';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { UserDataDto } from '../dtos/response/user-data.dto';

@ApiTags('users')
@Controller('users')
export class UsersController {
	constructor(
		private readonly userService: UsersService,
		private configService: ConfigService,
	) {}

	private readonly apiUrl = this.configService.get<string>('STATIC_IMAGES_URL');

	@UseGuards(JwtAuthGuard)
	@Patch('/update/:userId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'user account is updated no values are returned',
	})
	@ApiNotFoundResponse({
		description: 'user not found',
	})
	async updateAccount(
		@Body() body: UpdateAccountDto,
		@Param('userId') userId: string,
	): Promise<void> {
		await this.userService.partialUpdate(body, userId);
	}
	@UseGuards(JwtAuthGuard)
	@Post('/profile-image')
	@HttpCode(200)
	@UseInterceptors(FileInterceptor('file', multerOptions))
	@ApiOkResponse({
		description: 'profile image updated',
	})
	@ApiNotFoundResponse({
		description: 'user not found',
	})
	async uploadProfileImage(
		@UploadedFile() file: Express.Multer.File,
		// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
		@Request() request: any,
	): Promise<{ url: string }> {
		const imageUrl = `${this.apiUrl}/uploads/avatars/${file.filename}`;
		await this.userService.updateProfileImage(request.user.sub, imageUrl);
		return {
			url: imageUrl,
		};
	}
	@UseGuards(JwtAuthGuard)
	@Get('/:userId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'return user info',
	})
	async getUserData(@Param('userId') userId: string): Promise<UserDataDto> {
		return this.userService.findById(userId);
	}
}
