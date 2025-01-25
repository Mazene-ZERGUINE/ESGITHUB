import { ApiProperty } from '@nestjs/swagger';

export class AccessTokenDto {
	@ApiProperty({
		example: 'eyJhbGciOi6IkpXVCJ9.eyJlbWFpbnUxQ3NjkwfQ.JrCivdr_-5XBEEwKJWPE3wKJf1Fc',
	})
	accessToken: string;
}
