export type RunCodeResponseDto = {
  status: string;
  result: {
    stdout: string;
    stderr: string;
    returncode: number;
    output_file_paths: string[];
  };
};
