import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { ProgramModel } from '../../core/models/program.model';
import { ApiService } from '../../core/services/api.service';
import { UserDataModel } from '../../core/models/user-data.model';
import { UpdatePasswordDto } from './edit-profile/edit-profile.component';
import { UserFollowersModel } from 'src/app/core/models/user-followers.model';

@Injectable({
  providedIn: 'root',
})
export class ProfileService {
  constructor(private readonly apiService: ApiService) {}

  getUserPrograms(userId: string): Observable<ProgramModel[]> {
    return this.apiService.getRequest('programs/' + userId);
  }

  editAccount(payload: UserDataModel, userId: string): Observable<void> {
    return this.apiService.patchRequest('users/update/' + userId, payload);
  }

  uploadAvatar(file: File): Observable<{ url: string }> {
    const formData = new FormData();
    formData.append('file', file, file.name);
    return this.apiService.postRequest('users/profile-image/', formData);
  }

  updatePassword(payload: UpdatePasswordDto, userId: string): Observable<void> {
    return this.apiService.patchRequest('auth/update-password/' + userId, payload);
  }

  getUserInfo(userId: string): Observable<UserDataModel> {
    return this.apiService.getRequest('users/' + userId);
  }

  getFollowersAndFollowings(userId: string): Observable<UserFollowersModel> {
    return this.apiService.getRequest('follow/' + userId);
  }

  follow(payload: { followerId: string; followingId: string }): Observable<void> {
    return this.apiService.postRequest('follow/follow-user', payload);
  }

  unfollow(relationId: string): Observable<void> {
    return this.apiService.getRequest('follow/unfollow-user/' + relationId);
  }
}
