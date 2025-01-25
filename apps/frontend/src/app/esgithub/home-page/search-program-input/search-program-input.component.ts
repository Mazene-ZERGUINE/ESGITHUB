import { Component, Input } from '@angular/core';
import { FormControl } from '@angular/forms';

@Component({
  selector: 'app-search-program-input',
  templateUrl: './search-program-input.component.html',
  styleUrls: ['./search-program-input.component.scss'],
})
export class SearchProgramInputComponent {
  @Input() searchControl!: FormControl<string>;
}
