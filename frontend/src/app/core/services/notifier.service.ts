import { Injectable } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { CustomSnackbarComponent } from '../components/custom-snackbar/custom-snackbar.component';

@Injectable({
  providedIn: 'root',
})
export class NotifierService {
  constructor(private readonly snackBar: MatSnackBar) {}

  showSuccess(message: string): void {
    this.snackBar.openFromComponent(CustomSnackbarComponent, {
      data: { message: message, icon: 'check_circle' },
      duration: 6000,
      panelClass: ['success-snackbar'],
      verticalPosition: 'top',
      horizontalPosition: 'end',
    });
  }

  showWarning(message: string): void {
    this.snackBar.openFromComponent(CustomSnackbarComponent, {
      data: { message: message, icon: 'warning' },
      duration: 6000,
      panelClass: ['warning-snackbar'],
      verticalPosition: 'top',
      horizontalPosition: 'end',
    });
  }

  showError(message: string): void {
    this.snackBar.openFromComponent(CustomSnackbarComponent, {
      data: { message: message, icon: 'error' },
      duration: 3000,
      panelClass: ['error-snackbar'],
      verticalPosition: 'top',
      horizontalPosition: 'end',
    });
  }
}
