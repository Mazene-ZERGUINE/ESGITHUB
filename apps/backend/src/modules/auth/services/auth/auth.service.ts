import { BadRequestException, Injectable } from '@nestjs/common';
import { compare, genSalt, hash } from 'bcrypt';

import { UsersService } from '../../../social-media/services/users.service';
import { LoginDTO } from '../../dtos/request/login.dto';
import { JwtService } from '@nestjs/jwt';
import { AccessTokenDto } from '../../dtos/response/access-token.dto';
import { ConfigService } from '@nestjs/config';
import { HttpNotFoundException } from '../../../../core/exceptions/HttpNotFoundException';
import { UpdatePasswordDto } from '../../dtos/request/update-password.dto';

@Injectable()
export class AuthService {
	constructor(
		private readonly configService: ConfigService,
		private readonly userService: UsersService,
		private readonly jwtService: JwtService,
	) {}

	async generateJsonWebToken(loginDTO: LoginDTO): Promise<AccessTokenDto> {
		const user = await this.userService.findByEmail(loginDTO.email);

		if (!user) {
			throw new HttpNotFoundException('user not found');
		}
		if (!(await this.isPasswordMatching(loginDTO.password, user.password))) {
			throw new HttpNotFoundException('Bad credentials');
		}

		user.connectedAt = new Date();
		await this.userService.save(user);
		return {
			accessToken: await this.jwtService.signAsync({
				email: user.email,
				sub: user.userId,
				username: user.userName,
			}),
		};
	}

	async updatePassword(payload: UpdatePasswordDto, userId: string): Promise<void> {
		const user = await this.userService.findById(userId);
		if (!user) {
			throw new HttpNotFoundException('user not found');
		}

		if (!(await this.isPasswordMatching(payload.currentPassword, user.password))) {
			throw new BadRequestException("current password don't match");
		}
		user.password = await hash(payload.newPassword, await genSalt());
		await this.userService.save(user);
	}

	async logout(userId: string): Promise<void> {
		const user = await this.userService.findById(userId);
		user.disconnectedAt = new Date();
		user.connectedAt = null;
		await this.userService.save(user);
	}

	private async isPasswordMatching(
		password: string,
		hashedPassword: string,
	): Promise<boolean> {
		return await compare(password, hashedPassword);
	}
}
