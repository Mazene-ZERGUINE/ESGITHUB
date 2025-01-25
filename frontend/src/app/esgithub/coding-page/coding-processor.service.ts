import { Injectable } from '@angular/core';
import { ApiService } from '../../core/services/api.service';
import { Observable } from 'rxjs';
import { RunCodeResponseDto } from './models/RunCodeResponseDto';
import { RunCodeRequestDto } from './models/RunCodeRequestDto';
import { CreateProgramDto } from './models/CreateProgramDto';
import { saveAs } from 'file-saver';
import * as JSZip from 'jszip';

@Injectable({
  providedIn: 'root',
})
export class CodingProcessorService {
  constructor(private readonly apiService: ApiService) {}

  sendCodeToProcess(payload: RunCodeRequestDto): Observable<RunCodeResponseDto> {
    return this.apiService.postRequest('code-processor/run-code', payload);
  }

  shareProgram(payload: CreateProgramDto): Observable<void> {
    return this.apiService.postRequest('programs', payload);
  }

  sendCodeWithFilesToProcess(payload: FormData): Observable<RunCodeResponseDto> {
    return this.apiService.postRequest('code-processor/files/run-code', payload);
  }

  downloadOutputFile(filePath: string): void {
    this.apiService.downloadFile(filePath).subscribe((blob) => {
      const fileName = filePath.split('/').pop();
      saveAs(blob, fileName);
    });
  }

  downloadFilesAsZip(filePaths: string[]): void {
    const zip = new JSZip();
    const downloadPromises = filePaths.map((filePath) =>
      this.apiService
        .downloadFile(filePath)
        .toPromise()
        .then((blob) => {
          const fileName = this.getFileNameFromPath(filePath);
          zip.file(fileName, blob as Blob);
        }),
    );
    Promise.all(downloadPromises).then(() => {
      zip.generateAsync({ type: 'blob' }).then((content) => {
        saveAs(content, 'output_files.zip');
      });
    });
  }

  generateCodingSession(): Observable<{ sessionId: string }> {
    return this.apiService.getRequest('collaboratif-coding/generate-session');
  }

  private getFileNameFromPath(filePath: string): string {
    const fileName = filePath.split('/').pop();
    return fileName ? fileName : 'unknown';
  }
}
