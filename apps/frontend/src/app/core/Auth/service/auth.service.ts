import { Injectable } from '@angular/core';
import { ApiService } from '../../services/api.service';
import { BehaviorSubject, Observable, map } from 'rxjs';
import { CreateUserDto } from '../models/create-user.dto';
import { LoginDto } from '../models/login.dto';
import { AccessTokenDto } from '../models/access-token.dto';
import { UserDataModel } from '../../models/user-data.model';
import { NotifierService } from '../../services/notifier.service';
import { Router } from '@angular/router';
import * as confetti from 'canvas-confetti';

@Injectable({
  providedIn: 'root',
})
export class AuthService {
  private userDataSubject = new BehaviorSubject<UserDataModel | null>(null);
  public userData$ = this.userDataSubject.asObservable();

  get user() {
    return this.userDataSubject.value;
  }

  constructor(
    private readonly apiService: ApiService,
    private readonly notifier: NotifierService,
    private router: Router,
  ) {}

  register(payload: CreateUserDto): Observable<void> {
    return this.apiService.postRequest('auth/sign-up', payload);
  }

  login(payload: LoginDto): Observable<AccessTokenDto> {
    return this.apiService.postRequest('auth/login', payload);
  }

  getUserData(): Observable<UserDataModel> {
    return this.apiService.getRequest('auth/get_info');
  }

  isAuthenticated(): boolean {
    return localStorage.getItem('token') !== null;
  }

  logout(userId: string): Observable<void> {
    return this.apiService.getRequest('auth/logout/' + userId).pipe(
      map(() => {
        localStorage.clear();
        this.notifier.showSuccess('you logged out');
        this.router.navigate(['auth']).then(this.launchConfetti);
      }),
    );
  }

  private launchConfetti(): void {
    const durationInMilliseconds = 6 * 1000;
    const end = Date.now() + durationInMilliseconds;
    const colors = ['#f93963', '#ffffff'];

    const myConfetti = confetti.create(undefined, { resize: true });

    (function frame(): void {
      myConfetti({
        particleCount: 2,
        angle: 60,
        spread: 55,
        origin: { x: 0 },
        colors,
      });
      myConfetti({
        particleCount: 2,
        angle: 120,
        spread: 55,
        origin: { x: 1 },
        colors,
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    })();
  }
}
