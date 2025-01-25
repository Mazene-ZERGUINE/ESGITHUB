import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  OnInit,
} from '@angular/core';
import { FormControl, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { omit } from 'lodash';
import { NotifierService } from '../services/notifier.service';
import { CreateUserDto } from './models/create-user.dto';
import { LoginDto } from './models/login.dto';
import { AuthService } from './service/auth.service';

export type AuthFormType = {
  firstName: FormControl<string | null>;
  lastName: FormControl<string | null>;
  userName: FormControl<string | null>;
  email: FormControl<string>;
  password: FormControl<string>;
  confirmPassword: FormControl<string | null>;
};

@Component({
  selector: 'app-auth',
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class AuthComponent implements OnInit {
  isLogin = true;

  readonly authForm: FormGroup<AuthFormType> = new FormGroup({
    firstName: new FormControl<string | null>(null),
    lastName: new FormControl<string | null>(null),
    userName: new FormControl<string | null>(null),
    email: new FormControl<string>('', {
      nonNullable: true,
      validators: [Validators.required, Validators.email],
    }),
    password: new FormControl<string>('', {
      nonNullable: true,
      validators: [Validators.required, Validators.minLength(8)],
    }),
    confirmPassword: new FormControl<string | null>(null, {
      nonNullable: true,
    }),
  });

  constructor(
    private readonly authService: AuthService,
    private readonly notifierService: NotifierService,
    private readonly router: Router,
    private readonly cdRef: ChangeDetectorRef,
  ) {}

  ngOnInit(): void {
    this.updateValidators();
  }

  onToggleSubmissionType(): void {
    this.isLogin = !this.isLogin;
    this.updateValidators();
  }

  updateValidators(): void {
    if (this.isLogin) {
      this.authForm.controls.firstName.clearValidators();
      this.authForm.controls.lastName.clearValidators();
      this.authForm.controls.userName.clearValidators();
      this.authForm.controls.confirmPassword.clearValidators();

      this.authForm.controls.firstName.setValue(null);
      this.authForm.controls.lastName.setValue(null);
      this.authForm.controls.userName.setValue(null);
      this.authForm.controls.confirmPassword.setValue(null);
    } else {
      this.authForm.controls.firstName.setValidators([Validators.required]);
      this.authForm.controls.lastName.setValidators([Validators.required]);
      this.authForm.controls.userName.setValidators([Validators.required]);
      this.authForm.controls.confirmPassword.setValidators([Validators.required]);
    }
    this.authForm.controls.firstName.updateValueAndValidity();
    this.authForm.controls.lastName.updateValueAndValidity();
    this.authForm.controls.userName.updateValueAndValidity();
    this.authForm.controls.confirmPassword.updateValueAndValidity();
  }

  onSubmit(): void {
    if (this.authForm.valid) {
      const formValues = this.authForm.value;

      if (!this.isLogin) {
        const payload: CreateUserDto = omit(formValues, [
          'confirmPassword',
        ]) as CreateUserDto;
        this.authService.register(payload).subscribe(() => {
          this.notifierService.showSuccess('Your account has been created successfully');
          this.isLogin = !this.isLogin;
          this.updateValidators();
          this.cdRef.markForCheck();
        });
      } else {
        const payload: LoginDto = omit(formValues, [
          'confirmPassword',
          'firstName',
          'lastName',
          'userName',
        ]) as LoginDto;
        this.authService.login(payload).subscribe((response) => {
          localStorage.setItem('token', response.accessToken);
          this.notifierService.showSuccess(`welcome 💩`);
          this.router.navigate(['home']);
        });
      }
    } else {
      this.authForm.markAllAsTouched();
    }
  }
}
