import { ApiProperty } from '@nestjs/swagger';
import { IsString } from 'class-validator';

export class UpdateAccountDto {
	@ApiProperty({
		description: 'account user name',
	})
	@IsString()
	userName?: string;

	@ApiProperty({
		description: 'account first name',
	})
	@IsString()
	firstName?: string;

	@ApiProperty({
		description: 'account last name',
	})
	@IsString()
	lastName?: string;

	@ApiProperty({
		description: 'account email',
	})
	@IsString()
	email?: string;

	@ApiProperty({
		description: 'account bio',
	})
	@IsString()
	bio?: string;
}
