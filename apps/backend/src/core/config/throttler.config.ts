import { ConfigService } from '@nestjs/config';

export const throttlerConfig = (
	configService: ConfigService,
): { limit: number; ttl: number }[] => [
	{
		ttl: configService.get<number>('THROTTLE_TTL', 60000),
		limit: configService.get<number>('THROTTLE_LIMIT', 40),
	},
];
