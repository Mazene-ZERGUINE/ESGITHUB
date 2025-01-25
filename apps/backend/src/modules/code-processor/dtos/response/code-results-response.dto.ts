import { ApiProperty } from '@nestjs/swagger';

export class CodeResultsResponseDto {
	@ApiProperty({ description: 'The status of the code processing' })
	status: string;

	@ApiProperty({
		description: 'The output result of the code processing',
		example: {
			stdout: 'Hello, World!\n',
			stderr: '',
			returncode: 0,
		},
	})
	result: {
		stdout: string;
		stderr: string;
		returncode: number;
	};
}
