import {
  Component,
  EventEmitter,
  Input,
  OnChanges,
  OnDestroy,
  Output,
  SimpleChanges,
} from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Subject, takeUntil, tap } from 'rxjs';
import { AuthService } from '../../../core/Auth/service/auth.service';
import { UserDataModel } from '../../../core/models/user-data.model';
import { NotifierService } from '../../../core/services/notifier.service';
import { ProfileService } from '../profile.service';

export type UpdatePasswordDto = {
  currentPassword: string;
  newPassword: string;
};

@Component({
  selector: 'app-edit-profile',
  templateUrl: './edit-profile.component.html',
  styleUrls: ['./edit-profile.component.scss'],
})
export class EditProfileComponent implements OnChanges, OnDestroy {
  @Input() currentUserInfo: UserDataModel | undefined;

  @Output() profileUpdated = new EventEmitter<void>();

  readonly componentDestroyed$ = new Subject<void>();

  private readonly _editProfileForm = new FormGroup({
    email: new FormControl<string>('', [Validators.email]),
    firstName: new FormControl<string>(''),
    lastName: new FormControl<string>(''),
    userName: new FormControl<string>(''),
    bio: new FormControl<string>(''),
  });

  get editProfileForm(): FormGroup {
    return this._editProfileForm;
  }

  private readonly _editPasswordForm: FormGroup = new FormGroup({
    currentPassword: new FormControl<string>('', [Validators.required]),
    newPassword: new FormControl<string>('', [Validators.required, Validators.min(8)]),
  });

  get editPasswordForm(): FormGroup {
    return this._editPasswordForm as FormGroup;
  }

  onEditAccountClick(): void {
    if (this.editPasswordForm.value && this.currentUserInfo) {
      const payload: UserDataModel = this.editProfileForm.value;

      this.profileService
        .editAccount(payload, this.currentUserInfo.userId)
        .pipe(
          takeUntil(this.componentDestroyed$),
          tap(() => {
            this.notifierService.showSuccess('account updated');
            this.profileUpdated.emit();
          }),
        )
        .subscribe();
    }
  }

  onEditPasswordClick(): void {
    if (this.editPasswordForm.valid && this.currentUserInfo) {
      const payload: UpdatePasswordDto = this.editPasswordForm.value;
      this.profileService
        .updatePassword(payload, this.currentUserInfo.userId)
        .pipe(
          takeUntil(this.componentDestroyed$),
          tap(() => {
            this.notifierService.showSuccess('password updated');
            this.profileUpdated.emit();
          }),
        )
        .subscribe();
    }
  }

  constructor(
    private readonly profileService: ProfileService,
    private readonly authService: AuthService,
    private readonly notifierService: NotifierService,
  ) {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['currentUserInfo'] && this.currentUserInfo) {
      this.editProfileForm.patchValue(this.currentUserInfo);
    }
  }

  ngOnDestroy(): void {
    this.componentDestroyed$.next();
    this.componentDestroyed$.complete();
  }
}
