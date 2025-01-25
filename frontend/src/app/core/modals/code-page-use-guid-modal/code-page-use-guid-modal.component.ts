import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';

@Component({
  selector: 'app-code-page-use-guid-modal',
  templateUrl: './code-page-use-guid-modal.component.html',
  styleUrls: ['./code-page-use-guid-modal.component.scss'],
})
export class CodePageUseGuidModalComponent {
  constructor(
    public dialogRef: MatDialogRef<CodePageUseGuidModalComponent>,
    @Inject(MAT_DIALOG_DATA) public data: any,
  ) {}
}
