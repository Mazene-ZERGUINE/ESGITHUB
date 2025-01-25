import { IsEmail, IsNotEmpty, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDTO {
	@ApiProperty({
		description: 'login email',
		example: 'john.doe@email.fr',
	})
	@IsEmail()
	@IsNotEmpty()
	email: string;

	@ApiProperty({
		description: 'login password',
		example: 'azerty1234',
	})
	@IsString()
	@IsNotEmpty()
	password: string;
}
