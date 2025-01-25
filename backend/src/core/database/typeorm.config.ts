import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export function createTypeOrmConfig(configService: ConfigService): TypeOrmModuleOptions {
	console.log('Creating TypeOrm...');
	console.log(`host: ${configService.get('DATABASE_HOST')}`);
	console.log(`port: ${configService.get('DATABASE_PORT')}`);
	console.log(`password: ${configService.get('DATABASE_PASSWORD')}`);
	console.log(`user: ${configService.get('DATABASE_USER')}`);
	console.log(`name ${configService.get('DATABASE_NAME')}`);
	return {
		type: 'postgres',
		host: configService.get<string>('DATABASE_HOST'),
		port: configService.get<number>('DATABASE_PORT', 5432),
		username: configService.get<string>('DATABASE_USER'),
		password: configService.get<string>('DATABASE_PASSWORD'),
		database: configService.get<string>('DATABASE_NAME'),
		entities: [__dirname + '/../../**/*.entity.{js,ts}'],
		synchronize: configService.get<boolean>('TYPEORM_SYNC', true),
	};
}
