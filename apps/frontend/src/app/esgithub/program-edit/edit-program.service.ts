import { Injectable } from '@angular/core';
import { ApiService } from '../../core/services/api.service';
import { Observable } from 'rxjs';
import { ProgramModel } from '../../core/models/program.model';
import { ReactionsEnum } from '../../shared/enums/reactions.enum';
import { HttpParams } from '@angular/common/http';

@Injectable({
  providedIn: 'root',
})
export class EditProgramService {
  constructor(private readonly apiService: ApiService) {}

  getProgram(programId: string): Observable<ProgramModel> {
    return this.apiService.getRequest('programs/details/' + programId);
  }

  getProgramComments(programId: string): Observable<any> {
    return this.apiService.getRequest('comment/' + programId);
  }

  likeOrDislikeProgram(
    type: ReactionsEnum,
    programId: string,
    userId: string,
  ): Observable<void> {
    const payload = {
      userId: userId,
      programId: programId,
    };
    if (type === ReactionsEnum.LIKE)
      return this.apiService.postRequest('reactions/like', payload);
    else return this.apiService.postRequest('reactions/dislike', payload);
  }

  submitComment(
    programId: string,
    userId: string,
    content: string,
    lineNumber?: number,
  ): Observable<void> {
    let payload: any = {
      userId: userId,
      programId: programId,
      content: content,
    };
    if (lineNumber) {
      payload = { ...payload, codeLineNumber: lineNumber };
    }
    return this.apiService.postRequest('comment', payload);
  }

  replyToComment(
    commentId: string,
    userId: string,
    programId: string,
    content: string,
    lineNumber?: number,
  ): Observable<void> {
    let payload: any = {
      userId: userId,
      programId: programId,
      content: content,
    };
    if (lineNumber) {
      payload = { ...payload, codeLineNumber: lineNumber };
    }
    return this.apiService.postRequest('comment/respond/' + commentId, payload);
  }

  getLinesComments(lineNumber: number, programId: string): Observable<any> {
    const params = new HttpParams()
      .set('lineNumber', String(lineNumber))
      .set('programId', programId);
    return this.apiService.getRequest('comment/line/' + programId, params);
  }

  updateProgram(programId: string, payload: any): Observable<void> {
    return this.apiService.patchRequest('programs/edit/' + programId, payload);
  }

  saveNewVersion(payload: any): Observable<void> {
    return this.apiService.postRequest('versions/', payload);
  }

  getProgramVersion(programId: string): Observable<any> {
    return this.apiService.getRequest('versions/all/' + programId);
  }

  updateProgramVersion(
    versionId: string,
    payload: {
      sourceCode: string;
    },
  ): Observable<void> {
    return this.apiService.patchRequest('versions/' + versionId, payload);
  }

  deleteProgramOrVersion(type: string, id: string): Observable<void> {
    if (type === 'version') {
      return this.apiService.deleteRequest('versions/' + id);
    } else {
      return this.apiService.deleteRequest('programs/' + id);
    }
  }
}
