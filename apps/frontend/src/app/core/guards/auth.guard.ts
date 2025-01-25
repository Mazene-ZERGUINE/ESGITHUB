import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { AuthService } from '../Auth/service/auth.service';
import { NotifierService } from '../services/notifier.service';

@Injectable({
  providedIn: 'root',
})
export class AuthGuard implements CanActivate {
  constructor(
    private readonly authService: AuthService,
    private readonly router: Router,
    private readonly notifier: NotifierService,
  ) {}

  canActivate(): boolean {
    if (this.authService.isAuthenticated()) {
      return true;
    } else {
      this.notifier.showError('you are unauthorized to access this resource');
      this.router.navigate(['auth']);
      return false;
    }
  }
}
