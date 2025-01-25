import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-show-code-execution-result-modal',
  templateUrl: './show-code-execution-result-modal.component.html',
  styleUrls: ['./show-code-execution-result-modal.component.scss'],
})
export class ShowCodeExecutionResultModalComponent {
  constructor(
    @Inject(MAT_DIALOG_DATA) public data: any,
    private readonly dialogRef: MatDialogRef<ShowCodeExecutionResultModalComponent>,
  ) {}

  onCloseModal() {
    this.data = null;
    this.dialogRef.close(true);
  }

  protected readonly onclose = onclose;
}
