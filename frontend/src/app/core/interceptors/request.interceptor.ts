import { Injectable } from '@angular/core';
import {
  HttpEvent,
  HttpInterceptor,
  HttpHandler,
  HttpRequest,
  HttpErrorResponse,
} from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { NotifierService } from '../services/notifier.service';

@Injectable()
export class RequestInterceptor implements HttpInterceptor {
  constructor(private notifierService: NotifierService) {}
  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {
    return next.handle(req).pipe(
      catchError((error: HttpErrorResponse) => {
        const errorMessage = error.error.error.message;
        this.notifierService.showError(errorMessage);
        return throwError(() => new Error(errorMessage));
      }),
    );
  }
}
