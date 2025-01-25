// src/app.module.ts
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { createTypeOrmConfig } from './core/database/typeorm.config';
import { CoreModule } from './core/core.module';
import { AuthModule } from './modules/auth/auth.module';
import { CodeProcessorModule } from './modules/code-processor/code-processor.module';
import { SocialMediaModule } from './modules/social-media/social-media.module';
import { ThrottlerModule } from '@nestjs/throttler';
import { throttlerConfig } from './core/config/throttler.config';
import { ServeStaticModule, ServeStaticModuleOptions } from '@nestjs/serve-static';
import { join } from 'path';

const serveStaticOptions: ServeStaticModuleOptions[] = [
	{
		rootPath: join(__dirname, '..', 'uploads', 'avatars'),
		serveRoot: '/uploads/avatars',
	},
	{
		rootPath: join(__dirname, '..', 'uploads', 'code', 'input'),
		serveRoot: '/uploads/code/input',
	},
	{
		rootPath: join(__dirname, '..', 'uploads', 'code', 'output'),
		serveRoot: '/uploads/code/output',
	},
];

@Module({
	imports: [
		CoreModule,
		AuthModule,
		SocialMediaModule,
		CodeProcessorModule,
		ConfigModule.forRoot({
			envFilePath: `.env.${process.env.NODE_ENV}`,
			isGlobal: true,
		}),
		TypeOrmModule.forRootAsync({
			imports: [ConfigModule],
			inject: [ConfigService],
			useFactory: createTypeOrmConfig,
		}),
		ServeStaticModule.forRoot(...serveStaticOptions),
		ThrottlerModule.forRootAsync({
			imports: [ConfigModule],
			inject: [ConfigService],
			useFactory: throttlerConfig,
		}),
	],
})
export class AppModule {}
