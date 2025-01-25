import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { FormControl } from '@angular/forms';
import { NavigationService } from 'src/app/core/Auth/service/navigation.service';
import {
  AvailableLangages,
  availableLangagesQueryParamKey,
  inputFileTypeQueryParamKey,
  outputFileTypeQueryParamKey,
} from '../home-page.component';
import { FileTypesEnum } from 'src/app/shared/enums/FileTypesEnum';

@Component({
  selector: 'app-program-filter-pop-over',
  templateUrl: './program-filter-pop-over.component.html',
  styleUrls: ['./program-filter-pop-over.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class ProgramFilterPopOverComponent {
  @Input() availableLangagesControl!: FormControl<AvailableLangages[] | null>;
  @Input() inputFilesControl!: FormControl<FileTypesEnum[] | null>;
  @Input() outputFilesControl!: FormControl<FileTypesEnum[] | null>;

  isFilterOpen = false;

  readonly AvailableLangages = Object.values(AvailableLangages);

  readonly FileTypes = Object.values(FileTypesEnum);

  handleAvailableLangage(selectedLangage: AvailableLangages): void {
    const currentLangages = this.availableLangagesControl.value || [];
    const updatedLangages = currentLangages.includes(selectedLangage)
      ? currentLangages.filter((lang) => lang !== selectedLangage)
      : [...currentLangages, selectedLangage];

    if (updatedLangages.length > 0) {
      this.navigationService.addQueriesToCurrentUrl({
        [availableLangagesQueryParamKey]: updatedLangages.join(','),
      });
    } else {
      this.navigationService.removeQueryParam(availableLangagesQueryParamKey);
    }
  }

  handleInputFile(selectedInputFile: FileTypesEnum): void {
    const currentInputFile = this.inputFilesControl.value || [];
    const updatedInputFiles = currentInputFile.includes(selectedInputFile)
      ? currentInputFile.filter((inputFile) => inputFile !== selectedInputFile)
      : [...currentInputFile, selectedInputFile];

    if (updatedInputFiles.length > 0) {
      this.navigationService.addQueriesToCurrentUrl({
        [inputFileTypeQueryParamKey]: updatedInputFiles.join(','),
      });
    } else {
      this.navigationService.removeQueryParam(inputFileTypeQueryParamKey);
    }
  }

  handleOutputFile(selectedOutputFile: FileTypesEnum): void {
    const currentOutputFile = this.outputFilesControl.value || [];
    const updatedOutputFiles = currentOutputFile.includes(selectedOutputFile)
      ? currentOutputFile.filter((outputFile) => outputFile !== selectedOutputFile)
      : [...currentOutputFile, selectedOutputFile];

    if (updatedOutputFiles.length > 0) {
      this.navigationService.addQueriesToCurrentUrl({
        [outputFileTypeQueryParamKey]: updatedOutputFiles.join(','),
      });
    } else {
      this.navigationService.removeQueryParam(outputFileTypeQueryParamKey);
    }
  }

  handleClickOpenMoreOptionsOverlay(): void {
    this.isFilterOpen = true;
  }

  handleClickCloseMoreOptionsOverlay(): void {
    this.isFilterOpen = false;
  }

  handleResetFilters(): void {
    this.availableLangagesControl.reset();
    this.inputFilesControl.reset();
    this.outputFilesControl.reset();

    this.navigationService.removeAllQueryParams();
  }

  constructor(private navigationService: NavigationService) {}
}
