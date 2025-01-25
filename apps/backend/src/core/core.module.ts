import { Module } from '@nestjs/common';
import { ScheduleModule } from '@nestjs/schedule';
import { CronService } from './utils/cron.service';
import { PopulateDatabaseService } from './database/populate-database.service';
import { CollaborativeCodingGateway } from './websocket/collaborative-coding.gateway';
import { LikesGateway } from './websocket/likes.gateway';

@Module({
	imports: [ScheduleModule.forRoot()],
	providers: [
		CronService,
		PopulateDatabaseService,
		CollaborativeCodingGateway,
		LikesGateway,
	],
})
export class CoreModule {}
