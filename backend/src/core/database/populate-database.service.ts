import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectConnection } from '@nestjs/typeorm';
import { Connection } from 'typeorm';
import { exec } from 'child_process';
import { join } from 'path';
import { existsSync } from 'fs';
import { UserEntity } from '../../modules/social-media/entities/user.entity';

@Injectable()
export class PopulateDatabaseService implements OnModuleInit {
	private readonly pgFilePath: string;

	constructor(
		private readonly configService: ConfigService,
		@InjectConnection() private readonly connection: Connection,
	) {
		const srcPath = join(__dirname, '..', '..', '..', 'database', 'sql', 'dump.sql');
		const distPath = join(__dirname, '..', 'database', 'sql', 'dump.sql');

		// Determine the correct path based on existence
		this.pgFilePath = existsSync(srcPath) ? srcPath : distPath;
		console.log(`Using SQL dump file at path: ${this.pgFilePath}`);
	}

	async onModuleInit(): Promise<void> {
		if (this.configService.get('NODE_ENV') === 'development') {
			await this.resetDatabase();
		}
	}

	private async resetDatabase(): Promise<void> {
		try {
			const isEmpty = await this.isEmptyDatabase();
			if (isEmpty) {
				await this.connection.query('DROP SCHEMA public CASCADE;');
				await this.connection.query('CREATE SCHEMA public;');
				await this.executePgDump();
				console.log('Database has been reset successfully.');
			} else {
				console.log('Database is already populated with test data.');
			}
		} catch (error) {
			console.error('Error resetting database:', error);
		}
	}

	private executePgDump(): Promise<void> {
		return new Promise((resolve, reject) => {
			const dbUser = this.configService.get('DATABASE_USER');
			const dbName = this.configService.get('DATABASE_NAME');
			const dbHost = this.configService.get('DATABASE_HOST');
			const dbPort = this.configService.get<number>('DATABASE_PORT', 5432);
			const dbPassword = this.configService.get('DATABASE_PASSWORD');

			const command = `PGPASSWORD=${dbPassword} psql -U ${dbUser} -h ${dbHost} -p ${dbPort} -d ${dbName} -f ${this.pgFilePath}`;
			console.log(`Executing command: ${command}`);

			exec(command, (error, stdout, stderr) => {
				if (error) {
					console.error('Error executing pg_dump:', error);
					console.error('stderr:', stderr);
					reject(error);
				} else {
					console.log('Database populated successfully');
					console.log('stdout:', stdout);
					resolve();
				}
			});
		});
	}

	private async isEmptyDatabase(): Promise<boolean> {
		const userRepository = this.connection.getRepository(UserEntity);
		return (await userRepository.count()) === 0;
	}
}
