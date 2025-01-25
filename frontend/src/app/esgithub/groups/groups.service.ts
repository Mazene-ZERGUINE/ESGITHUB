import { Injectable } from '@angular/core';
import { ApiService } from '../../core/services/api.service';
import { Observable } from 'rxjs';
import { GroupModel } from '../../core/models/group.model';
import { ProgramModel } from '../../core/models/program.model';

@Injectable({
  providedIn: 'root',
})
export class GroupsService {
  constructor(private readonly apiService: ApiService) {}

  getGroupsList$(): Observable<GroupModel[]> {
    return this.apiService.getRequest('groups/all');
  }

  createGroup(payload: any): Observable<GroupModel> {
    return this.apiService.postRequest('groups/create', payload);
  }

  getRecentGroups(): Observable<GroupModel[]> {
    return this.apiService.getRequest('groups/recent');
  }

  getGroupDetails(groupId: string): Observable<GroupModel> {
    return this.apiService.getRequest('groups/details/' + groupId);
  }

  getGroupPrograms(groupId: string): Observable<ProgramModel[]> {
    return this.apiService.getRequest('program/group/' + groupId);
  }

  joinGroup(groupId: string, userId: string): Observable<void> {
    const payload = {
      userId: userId,
      groupId: groupId,
    };
    return this.apiService.postRequest('groups/add-member', payload);
  }

  leaveGroup(groupId: string, userId: string): Observable<void> {
    const payload = {
      userId: userId,
      groupId: groupId,
    };
    return this.apiService.postRequest('groups/leave', payload);
  }

  deleteGroup(groupId: string): Observable<void> {
    return this.apiService.deleteRequest('groups/delete/' + groupId);
  }

  // eslint-disable-next-line @typescript-eslint/explicit-module-boundary-types
  publishGroup(payload: any): Observable<void> {
    return this.apiService.postRequest('groups/publish', payload);
  }

  updateVisibility(groupId: string): Observable<{ visibility: string }> {
    return this.apiService.getRequest('groups/update/visibility/' + groupId);
  }
  //todo: impliment all other methods //
}
