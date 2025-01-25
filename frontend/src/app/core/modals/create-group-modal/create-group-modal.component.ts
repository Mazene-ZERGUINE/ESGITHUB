import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { NotifierService } from '../../services/notifier.service';

export type CreateGroupDto = {
  groupName: string;
  description: string;
  image: string;
  visibility: 'public' | 'private';
};

@Component({
  selector: 'app-create-group-modal',
  templateUrl: './create-group-modal.component.html',
  styleUrls: ['./create-group-modal.component.scss'],
})
export class CreateGroupModalComponent {
  private readonly _createGroupForm: FormGroup = new FormGroup({
    groupName: new FormControl<string>('', [Validators.required]),
    description: new FormControl<string>('', [Validators.min(6), Validators.max(250)]),
    image: new FormControl<File | null>(null, [Validators.required]),
    visibility: new FormControl<'public' | 'private'>('public'),
  });

  get createGroupForm(): FormGroup {
    return this._createGroupForm as FormGroup;
  }

  selectedImage: File | null | undefined;

  constructor(
    public dialogRef: MatDialogRef<CreateGroupModalComponent>,
    private readonly notifier: NotifierService,
  ) {}

  onCreateButtonClick(): void {
    if (this.createGroupForm.valid) {
      const data = this.createGroupForm.value;
      this.dialogRef.close(data);
      return;
    }
    this.notifier.showWarning(`group name can't be empty`);
  }

  onCloseBtnClick(): void {
    this.dialogRef.close();
  }

  onFileSelected(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      this._createGroupForm.controls['image'].setValue(input.files[0]);
      this.selectedImage = this._createGroupForm.controls['image'].value;
    }
  }
}
