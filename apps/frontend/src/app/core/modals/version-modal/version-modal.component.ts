import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { NotifierService } from '../../services/notifier.service';

@Component({
  selector: 'app-version-modal',
  templateUrl: './version-modal.component.html',
  styleUrls: ['./version-modal.component.scss'],
})
export class VersionModalComponent {
  versionLabel: string = '';

  constructor(
    @Inject(MAT_DIALOG_DATA) public data: any,
    private readonly dialogRef: MatDialogRef<VersionModalComponent>,
    private readonly notifierService: NotifierService,
  ) {}

  submit(): void {
    if (this.versionLabel.trim()) {
      this.dialogRef.close(this.versionLabel.trim());
    } else {
      this.notifierService.showWarning('version tag can not bee empty');
    }
  }
}
