import { Component } from '@angular/core';
import { MatDialogRef } from '@angular/material/dialog';
import { AvailableLangages } from 'src/app/esgithub/home-page/home-page.component';

@Component({
  selector: 'app-select-file-language-modal',
  templateUrl: './group-publish-modal.component.html',
  styleUrls: ['./group-publish-modal.component.scss'],
})
export class GroupPublishModalComponent {
  selectedFile?: File;
  fileContent: string = '';
  selectedLanguage: string = '';

  readonly languages = Object.values(AvailableLangages);

  constructor(public dialogRef: MatDialogRef<GroupPublishModalComponent>) {}

  onFileChange(event: any): void {
    const file = event.target.files[0];
    if (file) {
      this.selectedFile = file;
      this.readFileContent(file);
    }
  }

  readFileContent(file: File): void {
    const reader = new FileReader();
    reader.onload = (e: any) => {
      this.fileContent = e.target.result;
    };
    reader.readAsText(file);
  }

  onSubmit(): void {
    if (this.selectedFile && this.selectedLanguage) {
      this.dialogRef.close({
        fileContent: this.fileContent,
        language: this.selectedLanguage,
      });
    } else {
      alert('Please select a file and a language');
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }
}
