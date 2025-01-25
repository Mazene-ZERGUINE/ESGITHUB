import {
	WebSocketGateway,
	WebSocketServer,
	OnGatewayConnection,
	OnGatewayDisconnect,
	SubscribeMessage,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({
	namespace: '/collaboratif-coding',
	cors: {
		origin: 'http://localhost:4200',
		methods: ['GET', 'POST'],
		credentials: true,
	},
})
export class CollaborativeCodingGateway
	implements OnGatewayConnection, OnGatewayDisconnect
{
	@WebSocketServer() server: Server;
	private sessions: Map<string, string> = new Map();
	private pendingAuthorizations: Map<string, string[]> = new Map();

	handleConnection(client: Socket): void {
		// eslint-disable-next-line no-console
		console.log(`Client connected: ${client.id}`);
	}

	handleDisconnect(client: Socket): void {
		// eslint-disable-next-line no-console
		console.log(`Client disconnected: ${client.id}`);
	}

	@SubscribeMessage('joinSession')
	handleJoinSession(client: Socket, sessionId: string): void {
		try {
			client.join(sessionId);
			if (this.sessions.has(sessionId)) {
				client.emit('loadCode', { code: this.sessions.get(sessionId) });
			} else {
				this.sessions.set(sessionId, '');
			}
		} catch (error) {
			client.emit('error', 'Failed to join session');
		}
	}

	@SubscribeMessage('requestAccess')
	handleRequestAccess(client: Socket, sessionId: string): void {
		try {
			this.server.to(sessionId).emit('requestAuthorization');
			if (!this.pendingAuthorizations.has(sessionId)) {
				this.pendingAuthorizations.set(sessionId, []);
			}
			this.pendingAuthorizations.get(sessionId)?.push(client.id);
		} catch (error) {
			client.emit('error', 'Failed to request access');
		}
	}

	@SubscribeMessage('grantAccess')
	handleGrantAccess(client: Socket, sessionId: string): void {
		try {
			const pendingClients = this.pendingAuthorizations.get(sessionId);
			if (pendingClients) {
				pendingClients.forEach((clientId) => {
					const clientSocket = this.getSocketById(clientId);
					if (clientSocket) {
						clientSocket.emit('authorizationGranted');
					} else {
						// eslint-disable-next-line no-console
						console.error(`Client socket not found for ID: ${clientId}`);
					}
				});
				this.pendingAuthorizations.delete(sessionId);
			}
		} catch (error) {
			client.emit('error', 'Failed to grant access');
		}
	}

	@SubscribeMessage('denyAccess')
	handleDenyAccess(client: Socket, sessionId: string): void {
		try {
			const pendingClients = this.pendingAuthorizations.get(sessionId);
			if (pendingClients) {
				pendingClients.forEach((clientId) => {
					const clientSocket = this.getSocketById(clientId);
					if (clientSocket) {
						clientSocket.emit('authorizationDenied');
					} else {
						// eslint-disable-next-line no-console
						console.error(`Client socket not found for ID: ${clientId}`);
					}
				});
				this.pendingAuthorizations.delete(sessionId);
			}
		} catch (error) {
			client.emit('error', 'Failed to deny access');
		}
	}

	@SubscribeMessage('codeChange')
	handleCodeChange(
		client: Socket,
		payload: {
			sessionId: string;
			code: string;
		},
	): void {
		try {
			this.sessions.set(payload.sessionId, payload.code);
			client.to(payload.sessionId).emit('codeUpdate', payload);
		} catch (error) {
			client.emit('error', 'Failed to update code');
		}
	}

	@SubscribeMessage('cursorChange')
	handleCursorChange(
		client: Socket,
		payload: {
			sessionId: string;
			cursor: { row: number; column: number };
		},
	): void {
		try {
			client.emit('cursorUpdate', payload);
		} catch (error) {
			client.emit('error', 'Failed to update cursor');
		}
	}

	private getSocketById(clientId: string): Socket | undefined {
		const sockets = this.server.sockets as any;
		return sockets.get(clientId) ?? undefined;
	}
}
