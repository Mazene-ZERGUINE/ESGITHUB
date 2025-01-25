import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Router } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from '../Auth/service/auth.service';
import { NotifierService } from '../services/notifier.service';

@Injectable({
  providedIn: 'root',
})
export class SessionGuard implements CanActivate {
  constructor(
    private readonly authService: AuthService,
    private readonly router: Router,
    private readonly notifier: NotifierService,
  ) {}

  canActivate(
    next: ActivatedRouteSnapshot,
  ): Observable<boolean> | Promise<boolean> | boolean {
    const access = next.queryParams['access'];
    const userId = next.queryParams['id'];

    if (userId && access) {
      if (access === 'owner' && !this.authService.isAuthenticated()) {
        this.notifier.showError('You are not authorized to access this resource');
        this.router.navigate(['/auth']);
        return false;
      }
      /*
            if (this.authService.user?.userId !== userId) {
              console.log(userId, this.authService.user?.userId);
              this.notifier.showError('You are not authorized to access this resource');
              this.router.navigate(['/auth']);
              return false;
            }*/
    }
    return true;
  }
}
