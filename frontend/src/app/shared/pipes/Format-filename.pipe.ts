import { Pipe, type PipeTransform } from '@angular/core';

@Pipe({
  name: 'formatFilename',
  standalone: true,
})
export class FormatFilenamePipe implements PipeTransform {
  transform(fullName: string, length: number = 8): string {
    const dotIndex = fullName.lastIndexOf('.');
    const extension = dotIndex !== -1 ? fullName.substring(dotIndex) : '';
    const namePart = fullName.slice(0, Math.min(length, dotIndex));

    return namePart + extension;
  }
}
