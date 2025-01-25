import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { createCorsConfig } from './core/config/cors.config';
import { validationPipeOptions } from './core/config/validation-pipe.config';
import { GlobalExceptionHandler } from './core/middleware/GlobalExceptionHandler';
import { CustomThrottlerExceptionFilter } from './core/exceptions/CustomThrottlerExceptionFilter';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import helmet from 'helmet';

async function bootstrap(): Promise<void> {
	const app = await NestFactory.create(AppModule);
	const configService = app.get(ConfigService);

	app.setGlobalPrefix('api/v1');
	app.enableCors(createCorsConfig(configService));
	app.useGlobalPipes(new ValidationPipe(validationPipeOptions));
	app.useGlobalFilters(
		new GlobalExceptionHandler(),
		new CustomThrottlerExceptionFilter(),
	);
	app.use(
		helmet({
			crossOriginResourcePolicy: { policy: 'cross-origin' },
		}),
	);

	const config = new DocumentBuilder()
		.setTitle('Esgithub')
		.setDescription('Esgithub API')
		.setVersion('1.0')
		.build();
	const document = SwaggerModule.createDocument(app, config);
	SwaggerModule.setup('api', app, document);

	await app.listen(3000);
}

bootstrap()
	// eslint-disable-next-line no-console
	.then(() => console.log('🚀 Server is running'))
	// eslint-disable-next-line no-console
	.catch((error) => console.error('❌ Error starting server', error));
