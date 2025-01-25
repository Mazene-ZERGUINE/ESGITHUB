import {
	Injectable,
	CanActivate,
	ExecutionContext,
	UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class JwtAuthGuard implements CanActivate {
	constructor(private jwtService: JwtService) {}

	canActivate(context: ExecutionContext): boolean {
		const request = context.switchToHttp().getRequest<Request>();
		const token = this.extractTokenFromHeader(request);

		if (!token) {
			throw new UnauthorizedException('no token was provided');
		}

		try {
			const payload = this.jwtService.verify(token);
			request.user = payload;
		} catch (e) {
			throw new UnauthorizedException('invalid token');
		}
		return true;
	}

	private extractTokenFromHeader(request: Request): string | null {
		const [type, token] = request.headers.authorization?.split(' ') ?? [];
		return type === 'Bearer' ? token : null;
	}
}
