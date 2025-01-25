import { Injectable } from '@angular/core';
import { ApiService } from '../../core/services/api.service';
import { HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { ProgramModel } from '../../core/models/program.model';
import { ReactionsEnum } from '../../shared/enums/reactions.enum';

@Injectable({
  providedIn: 'root',
})
export class HomeService {
  constructor(private readonly apiService: ApiService) {}

  getProgramsList$(
    type: 'private' | 'public' | 'only_followers',
  ): Observable<ProgramModel[]> {
    const params = new HttpParams().append('type', type);
    return this.apiService.getRequest('programs', params);
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

  deleteProgram(programId: string): Observable<void> {
    return this.apiService.deleteRequest('programs/' + programId);
  }
}
