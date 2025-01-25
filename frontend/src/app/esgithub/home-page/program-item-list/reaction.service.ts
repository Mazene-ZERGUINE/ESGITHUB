import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable, distinctUntilChanged } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class ReactionService {
  private likes$: { [programId: string]: BehaviorSubject<number> } = {};
  private dislikes$: { [programId: string]: BehaviorSubject<number> } = {};

  getLikes$(programId: string): Observable<number> {
    return this.likes$[programId].pipe(distinctUntilChanged());
  }

  getDislikes$(programId: string): Observable<number> {
    return this.dislikes$[programId].pipe(distinctUntilChanged());
  }

  updateLikes(programId: string, likes: number): void {
    if (!this.likes$[programId]) {
      this.likes$[programId] = new BehaviorSubject<number>(0);
    }
    this.likes$[programId].next(likes);
  }

  updateDislikes(programId: string, dislikes: number): void {
    if (!this.dislikes$[programId]) {
      this.dislikes$[programId] = new BehaviorSubject<number>(0);
    }
    this.dislikes$[programId].next(dislikes);
  }
}
