import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ShareCodeModalComponent } from '../core/modals/share-code-modal/share-code-modal.component';
import { MatInputModule } from '@angular/material/input';
import { FormsModule } from '@angular/forms';
import { MatDialogModule } from '@angular/material/dialog';

@NgModule({
  declarations: [ShareCodeModalComponent],
  exports: [],
  imports: [CommonModule, MatInputModule, FormsModule, MatDialogModule],
})
export class SharedModule {}
