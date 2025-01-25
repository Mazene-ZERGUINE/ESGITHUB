import { IsEmail, IsOptional, IsString, Length } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateUserDto {
	@ApiProperty({
		description: 'user name',
		example: 'bouraz',
	})
	@IsString()
	@Length(1, 60)
	userName: string;

	@ApiProperty({
		description: 'user first name',
		example: 'john',
	})
	@IsString()
	@Length(1, 60)
	firstName: string;

	@ApiProperty({
		description: 'user last name',
		example: 'doe',
	})
	@IsString()
	@Length(1, 60)
	lastName: string;

	@ApiProperty({
		description: 'user email',
		example: 'john.doe@email.fr',
	})
	@IsEmail()
	@Length(1, 60)
	email: string;

	@ApiProperty({
		description: 'user password min 8 characters max 255',
		example: 'azerty1234',
	})
	@IsString()
	@Length(8, 255)
	password: string;

	@ApiProperty({
		description: 'user profile image url',
	})
	@IsOptional()
	@IsString()
	avatarUrl?: string;

	@ApiProperty({
		description: 'user bio description',
		example: 'just a random person',
	})
	@IsOptional()
	@IsString()
	bio?: string;
}
