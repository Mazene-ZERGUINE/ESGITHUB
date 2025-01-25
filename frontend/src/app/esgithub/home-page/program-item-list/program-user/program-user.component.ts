import { Component, Input } from '@angular/core';
import { ProgramModel } from 'src/app/core/models/program.model';

@Component({
  selector: 'app-program-user',
  templateUrl: './program-user.component.html',
  styleUrls: ['./program-user.component.scss'],
})
export class ProgramUserComponent {
  @Input() userProgram!: ProgramModel;
  @Input() isUserConnected!: boolean | null;

  readonly anonymousImageUrl =
    'http://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';
}
