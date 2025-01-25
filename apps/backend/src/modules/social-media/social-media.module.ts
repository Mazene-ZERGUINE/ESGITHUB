import { Module } from '@nestjs/common';
import { UsersService } from './services/users.service';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserEntity } from './entities/user.entity';
import { ProgramsService } from './services/programs.service';
import { ProgramEntity } from './entities/program.entity';
import { ProgramController } from './controllers/program.controller';
import { UsersController } from './controllers/users.controller';
import { FollowController } from './controllers/follow.controller';
import { FollowService } from './services/follow.service';
import { FollowEntity } from './entities/follow.entity';
import { CommentsController } from './controllers/comments.controller';
import { CommentEntity } from './entities/comment.entity';
import { CommentsService } from './services/comments.service';
import { ProgramVersionEntity } from './entities/program-version.entity';
import { VersionsController } from './controllers/versions.controller';
import { VersionsService } from './services/versions.service';
import { ReactionsController } from './controllers/reactions.controller';
import { ReactionsService } from './services/reactions.service';
import { ReactionEntity } from './entities/reaction.entity';
import { GroupsController } from './controllers/groups.controller';
import { GroupsService } from './services/groups.service';
import { GroupEntity } from './entities/group.entity';
import { LikesGateway } from 'src/core/websocket/likes.gateway';

@Module({
	imports: [
		TypeOrmModule.forFeature([
			UserEntity,
			ProgramEntity,
			FollowEntity,
			CommentEntity,
			ProgramVersionEntity,
			ReactionEntity,
			GroupEntity,
		]),
	],
	exports: [UsersService, TypeOrmModule, ProgramsService],
	providers: [
		UsersService,
		ProgramsService,
		FollowService,
		CommentsService,
		VersionsService,
		ReactionsService,
		GroupsService,
		LikesGateway,
	],
	controllers: [
		ProgramController,
		UsersController,
		FollowController,
		CommentsController,
		VersionsController,
		ReactionsController,
		GroupsController,
	],
})
export class SocialMediaModule {}
