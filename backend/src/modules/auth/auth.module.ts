import { forwardRef, Module } from '@nestjs/common';
import { AuthController } from './controllers/auth.controller';
import { AuthService } from './services/auth/auth.service';
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './strategies/jwt.strategy';
import { SocialMediaModule } from '../social-media/social-media.module';
import { JwtConfigService } from './services/jwt-config/jwt-config.service';
import { ConfigModule, ConfigService } from '@nestjs/config';

@Module({
	controllers: [AuthController],
	imports: [
		forwardRef(() => SocialMediaModule),
		JwtModule.registerAsync({
			global: true,
			imports: [ConfigModule],
			inject: [ConfigService],
			useClass: JwtConfigService,
		}),
	],
	exports: [AuthService],
	providers: [AuthService, JwtStrategy, JwtConfigService],
})
export class AuthModule {}
