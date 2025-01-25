import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  standalone: true,
  name: 'userDisplayName',
})
export class UserDisplayNamePipe implements PipeTransform {
  transform(user: any): string {
    if (!user) {
      return '';
    }
    const lastName = user.lastName ? user.lastName.toUpperCase() : '';
    const firstName = user.firstName ? user.firstName : '';

    return `${lastName} ${firstName}`.trim();
  }
}
