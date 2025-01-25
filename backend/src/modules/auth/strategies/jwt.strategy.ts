import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../../social-media/services/users.service';
import { LoginDTO } from '../dtos/request/login.dto';

export class JwtStrategy extends PassportStrategy(Strategy) {
	constructor(private readonly usersService: UsersService) {
		super({
			jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
			ignoreExpiration: false,
			secretOrKey: process.env.JWT_SECRET,
		});
	}

	async validate(
		payload: unknown,
	): Promise<{ userId: string; email: string; username: string }> {
		if (!this.isLoginDto(payload)) {
			throw new UnauthorizedException();
		}

		const foundUser = await this.usersService.findByEmail(payload.email);
		if (!foundUser) {
			throw new UnauthorizedException();
		}

		return {
			email: foundUser.email,
			userId: foundUser.userId,
			username: foundUser.userName,
		};
	}

	private isLoginDto(payload: unknown): payload is LoginDTO {
		const dto = payload as Partial<LoginDTO>;

		return typeof dto.email === 'string' && typeof dto.password === 'string';
	}
}
