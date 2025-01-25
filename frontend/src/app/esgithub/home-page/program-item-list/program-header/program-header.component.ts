import { Component, Input } from '@angular/core';
import { AvailableLangages } from '../../home-page.component';

@Component({
  selector: 'app-program-header',
  templateUrl: './program-header.component.html',
  styleUrls: ['./program-header.component.scss'],
})
export class ProgramHeaderComponent {
  @Input() programIcon!: AvailableLangages;

  readonly AvailableLangages = AvailableLangages;
}
