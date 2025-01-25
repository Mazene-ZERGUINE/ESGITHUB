import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { Router } from '@angular/router';
import { ApiService } from '../../services/api.service';

@Injectable({
  providedIn: 'root',
})
export class NavService {
  constructor(
    private readonly router: Router,

    private apiService: ApiService,
  ) {}

  private navBarState$: BehaviorSubject<boolean> = new BehaviorSubject(false);

  get navBarState(): boolean {
    return this.navBarState$.value;
  }

  set navBarState(state: boolean) {
    this.navBarState$.next(state);
  }
}
