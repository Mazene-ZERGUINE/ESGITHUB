import { Pipe, type PipeTransform } from '@angular/core';

@Pipe({
  name: 'countDisplay',
  standalone: true,
})
export class CountDisplayPipe implements PipeTransform {
  transform(value: number): string {
    return value > 99 ? '99+' : value.toString();
  }
}
