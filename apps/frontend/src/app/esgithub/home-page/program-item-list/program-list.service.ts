import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ProgramComment } from 'src/app/core/models/program-comment';
import { ApiService } from 'src/app/core/services/api.service';

@Injectable({
  providedIn: 'root',
})
export class ProgramListService {
  constructor(private readonly apiService: ApiService) {}

  getProgramComments$(programId: string): Observable<ProgramComment[]> {
    return this.apiService.getRequest('comment/' + programId);
  }
}
