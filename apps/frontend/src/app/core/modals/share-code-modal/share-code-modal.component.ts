import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { FileTypesEnum } from '../../../shared/enums/FileTypesEnum';
import { NotifierService } from '../../services/notifier.service';

@Component({
  selector: 'app-share-code-modal',
  templateUrl: './share-code-modal.component.html',
  styleUrls: ['./share-code-modal.component.scss'],
})
export class ShareCodeModalComponent {
  visibility!: string;
  description!: string;
  selectedProgramFile?: File;

  readonly inputFileTypeOptions = Object.values(FileTypesEnum).map((value) => ({
    value,
    checked: false,
  }));

  readonly outputFileTypeOptions = Object.values(FileTypesEnum).map((value) => ({
    value,
    checked: false,
  }));
  visibilityOptions = [
    { label: 'Public', value: 'public' },
    { label: 'Private', value: 'private' },
    { label: 'Follower Only', value: 'only_followers' },
  ];

  constructor(
    public dialogRef: MatDialogRef<ShareCodeModalComponent>,
    private readonly notifier: NotifierService,
  ) {}

  shareCode(): void {
    if (!this.visibility) {
      this.notifier.showWarning('input types, output types and visibility are mandatory');
      return;
    }
    const inputTypes = this.inputFileTypeOptions
      .filter((type) => type.checked)
      .map((type) => type.value);

    const outputTypes = this.outputFileTypeOptions
      .filter((type) => type.checked)
      .map((type) => type.value);

    const data = {
      description: this.description,
      inputTypes: inputTypes,
      outputTypes: outputTypes,
      visibility: this.visibility,
    };
    this.dialogRef.close(data);
  }

  cancel(): void {
    this.dialogRef.close();
  }
}
