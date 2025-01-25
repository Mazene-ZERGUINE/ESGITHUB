// modal.service.ts
import { Injectable } from '@angular/core';
import { MatDialog, MatDialogConfig } from '@angular/material/dialog';
import { filter, lastValueFrom, Observable, take } from 'rxjs';
import { ComponentType } from '@angular/cdk/portal';
import { ConfirmationModalComponent } from '../modals/conifrmatio-modal/confirmation-modal.component';

@Injectable({
  providedIn: 'root',
})
export class ModalService {
  constructor(private dialog: MatDialog) {}

  openDialog<T, R = any>(
    component: ComponentType<T>,
    width: number,
    data?: R,
    config?: MatDialogConfig<R>,
  ): Observable<R> {
    const dialogRef = this.dialog.open(component, {
      width: `${width}px`,
      data: data,
      ...config,
    });

    return dialogRef.afterClosed() as Observable<R>;
  }

  async getConfirmationModelResults(title: string, message: string): Promise<boolean> {
    const dialogRef = this.openDialog(ConfirmationModalComponent, 400, {
      title: title,
      message: message,
    });

    const result = await lastValueFrom(
      dialogRef.pipe(
        take(1),
        filter((result: any) => result === true || result === false), // Ensure that only true or false results are returned
      ),
    );

    return result;
  }
}
