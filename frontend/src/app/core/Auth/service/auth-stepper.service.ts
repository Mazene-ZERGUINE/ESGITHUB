import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged } from 'rxjs';
import { AuthStepperType } from '../utils/auh-stepper.enum';

const DEFAULT_AUTH_STEP = AuthStepperType.FIRST_STEP;

@Injectable({
  providedIn: 'root',
})
export class AuthStepperService {
  private authStep$ = new BehaviorSubject<AuthStepperType>(DEFAULT_AUTH_STEP);

  setAuthStep(nextStep: AuthStepperType): void {
    this.authStep$.next(nextStep);
  }

  getAuthStep$(): Observable<AuthStepperType> {
    return this.authStep$.pipe(distinctUntilChanged());
  }
}
