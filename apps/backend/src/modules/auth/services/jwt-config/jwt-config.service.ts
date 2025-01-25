import { Injectable } from '@nestjs/common';
import { JwtModuleOptions, JwtOptionsFactory } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class JwtConfigService implements JwtOptionsFactory {
	constructor(private readonly configService: ConfigService) {}

	createJwtOptions(): JwtModuleOptions {
		const ONE_DAY = '1d';
		const secret = this.configService.get<string>('JWT_SECRET');
		if (!secret) {
			throw new Error('JWT_SECRET manquant !');
		}

		return {
			secret,
			signOptions: {
				expiresIn: this.configService.get('JWT_EXPIRATION_TIME', ONE_DAY),
			},
		};
	}
}
