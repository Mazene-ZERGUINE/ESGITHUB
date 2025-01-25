import {
	MessageBody,
	SubscribeMessage,
	WebSocketGateway,
	WebSocketServer,
} from '@nestjs/websockets';
import { Server } from 'socket.io';
import { ReactionTypeEnum } from '../../modules/social-media/enums/reaction-type.enum';

@WebSocketGateway({
	cors: {
		origin: 'http://localhost:4200',
		methods: ['GET', 'POST'],
		credentials: true,
	},
	namespace: '/events',
})
export class LikesGateway {
	@WebSocketServer() server: Server;

	@SubscribeMessage('like')
	handleLike(@MessageBody() data: { postId: string }): void {
		this.server.emit(ReactionTypeEnum.LIKE, data);
	}
}
