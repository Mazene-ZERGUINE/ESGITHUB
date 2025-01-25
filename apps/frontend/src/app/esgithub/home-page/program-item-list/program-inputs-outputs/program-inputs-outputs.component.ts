import { Component, Input } from '@angular/core';
import { ProgramModel } from 'src/app/core/models/program.model';

@Component({
  selector: 'app-program-inputs-outputs',
  templateUrl: './program-inputs-outputs.component.html',
  styleUrls: ['./program-inputs-outputs.component.scss'],
})
export class ProgramInputsOutputsComponent {
  @Input() userProgram!: ProgramModel;
}
