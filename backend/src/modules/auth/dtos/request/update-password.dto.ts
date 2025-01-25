import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class UpdatePasswordDto {
	@ApiProperty({
		description: 'currentPassword',
		example: 'azerty1234',
	})
	@IsString()
	@IsNotEmpty()
	currentPassword: string;

	@ApiProperty({
		description: 'new password',
		example: 'azerty12345',
	})
	@IsString()
	@IsNotEmpty()
	newPassword: string;
}
