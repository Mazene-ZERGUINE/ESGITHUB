import {
	Body,
	Controller,
	Get,
	HttpCode,
	Param,
	Patch,
	Post,
	Request,
	UseGuards,
} from '@nestjs/common';
import { AuthService } from '../services/auth/auth.service';
import { UsersService } from '../../social-media/services/users.service';
import { CreateUserDto } from '../dtos/request/create-user.dto';
import { LoginDTO } from '../dtos/request/login.dto';
import { AccessTokenDto } from '../dtos/response/access-token.dto';
import {
	ApiBadRequestResponse,
	ApiCreatedResponse,
	ApiNotFoundResponse,
	ApiOkResponse,
	ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { UserDataDto } from '../../social-media/dtos/response/user-data.dto';
import { UpdatePasswordDto } from '../dtos/request/update-password.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
	constructor(
		private readonly userService: UsersService,
		private readonly authService: AuthService,
	) {}

	@Post('login')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'login',
		type: AccessTokenDto,
	})
	@ApiNotFoundResponse({ description: 'bad credentials (user not found)' })
	async login(@Body() loginDTO: LoginDTO): Promise<AccessTokenDto> {
		return this.authService.generateJsonWebToken(loginDTO);
	}

	@Post('sign-up')
	@HttpCode(201)
	@ApiCreatedResponse({ description: 'no content 201 response' })
	@ApiBadRequestResponse({ description: 'user already exists' })
	async signUp(@Body() userDTO: CreateUserDto): Promise<void> {
		await this.userService.create(userDTO);
	}

	@UseGuards(JwtAuthGuard)
	@ApiOkResponse({
		description: 'returns authenticated user data',
	})
	@ApiNotFoundResponse({
		description: 'user not found',
	})
	@HttpCode(200)
	@Get('get_info')
	// eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
	async getUserInfo(@Request() request: any): Promise<UserDataDto> {
		const userEmail = request.user.email;
		const user = await this.userService.findByEmail(userEmail);
		return user.toUserDataDto();
	}

	@UseGuards(JwtAuthGuard)
	@Patch('/update-password/:userId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'password updated',
	})
	@ApiBadRequestResponse({
		description: 'current password does not mathc',
	})
	async updatePassword(
		@Body() payload: UpdatePasswordDto,
		@Param('userId') userId: string,
	): Promise<void> {
		await this.authService.updatePassword(payload, userId);
	}

	@UseGuards(JwtAuthGuard)
	@Get('/logout/:userId')
	@HttpCode(200)
	@ApiOkResponse({
		description: 'user logout',
	})
	@ApiBadRequestResponse({
		description: 'current password does not mathc',
	})
	async logout(@Param('userId') userId: string): Promise<void> {
		await this.authService.logout(userId);
	}
}
