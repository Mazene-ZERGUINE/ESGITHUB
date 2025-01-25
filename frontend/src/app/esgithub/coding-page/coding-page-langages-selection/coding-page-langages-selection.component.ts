import { Component, EventEmitter, Input, Output } from '@angular/core';
import { CodePageUseGuidModalComponent } from 'src/app/core/modals/code-page-use-guid-modal/code-page-use-guid-modal.component';
import { ModalService } from 'src/app/core/services/modal.service';
import { AvailableLangages } from '../../home-page/home-page.component';

@Component({
  selector: 'app-coding-page-langages-selection',
  templateUrl: './coding-page-langages-selection.component.html',
  styleUrls: ['./coding-page-langages-selection.component.scss'],
})
export class CodingPageLangagesSelectionComponent {
  @Output() langageChanged = new EventEmitter<AvailableLangages>();

  @Input() programLangage: AvailableLangages | undefined;

  readonly AvailableLangages = AvailableLangages;

  selectedLangage =
    localStorage.getItem('selectedLanguage') ?? AvailableLangages.JAVASCRIPT;

  updateLanguage(language: AvailableLangages): void {
    this.langageChanged.emit(language);
    this.selectedLangage = language;
    localStorage.setItem('selectedLanguage', language);
  }

  onShowGuideClick(): void {
    this.modalService.openDialog(CodePageUseGuidModalComponent, 700).subscribe();
  }

  constructor(private readonly modalService: ModalService) {}
}
