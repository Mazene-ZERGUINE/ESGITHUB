import { AfterViewInit, Component, ElementRef, Input, ViewChild } from '@angular/core';
import * as ace from 'ace-builds';
import { Ace } from 'ace-builds';
import { ProgramModel } from 'src/app/core/models/program.model';
import { AvailableLangages } from '../../home-page.component';

import './ace-editor-custom-theme.js';

@Component({
  selector: 'app-program-code',
  templateUrl: './program-code.component.html',
  styleUrls: ['./program-code.component.scss'],
})
export class ProgramCodeComponent implements AfterViewInit {
  @ViewChild('editor') private editor!: ElementRef<HTMLElement>;
  @Input() userProgram!: ProgramModel;

  aceEditor!: Ace.Editor;

  ngAfterViewInit(): void {
    this.setAceEditor();
  }

  private setAceEditorMode(programmingLanguage: string): string {
    if (programmingLanguage === AvailableLangages.CPLUSPLUS) return 'c_cpp';

    return programmingLanguage;
  }

  private setAceEditor(): void {
    this.aceEditor = ace.edit(this.editor.nativeElement);
    this.aceEditor.setValue(this.userProgram.sourceCode);
    this.aceEditor.setTheme('ace/theme/custom_theme');
    this.aceEditor.session.setMode(
      'ace/mode/' + this.setAceEditorMode(this.userProgram.programmingLanguage),
    );
    this.aceEditor.setOptions({
      fontSize: '15px',
      showLineNumbers: false,
      showGutter: false,
      highlightActiveLine: false,
      readOnly: true,
    });

    this.aceEditor.clearSelection();
  }
}
