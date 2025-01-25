import { ApiProperty } from '@nestjs/swagger';

export class CodeExecutionResult {
	@ApiProperty({
		description: 'code executed with success result',
		example: 'hello world',
		type: String,
	})
	stdout: string;

	@ApiProperty({
		description: 'code executed with failure result',
		type: String,
	})
	stderr: string;

	@ApiProperty({
		description: 'code execution returncode result',
		type: Number,
		example: '0 or 1',
	})
	return_code: number;

	@ApiProperty({
		description: 'output file statuc url',
		type: [String],
		isArray: true,
	})
	output_file_paths: string[];
}

export class CodeWithFileExecutedResponseDto {
	@ApiProperty({
		description: 'status',
		example: 'pending or finished',
		type: String,
	})
	status: string;
	@ApiProperty({
		description: 'execution result details',
		type: CodeExecutionResult,
	})
	result: CodeExecutionResult;
}
