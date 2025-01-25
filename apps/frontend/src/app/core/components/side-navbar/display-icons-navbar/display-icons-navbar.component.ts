import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-display-icons-navbar',
  templateUrl: './display-icons-navbar.component.html',
  styleUrls: ['./display-icons-navbar.component.scss'],
})
export class DisplayIconsNavbarComponent {
  @Input() iconName!: string;
  @Input() isCurrentNav!: boolean;
}
