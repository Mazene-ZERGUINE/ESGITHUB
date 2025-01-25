import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { FormGroup } from '@angular/forms';
import { Observable } from 'rxjs';
import { AuthFormType } from '../auth.component';
import { AuthStepperService } from '../service/auth-stepper.service';
import { AuthStepperType } from '../utils/auh-stepper.enum';

@Component({
  selector: 'app-join',
  templateUrl: 'join.component.html',
  styleUrls: ['./join.component.scss'],
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class JoinComponent {
  @Input() isLogin!: boolean;

  @Input() authForm!: FormGroup<AuthFormType>;

  readonly authStep$: Observable<AuthStepperType> =
    this.authStepperService.getAuthStep$();

  readonly AuthStepperType = AuthStepperType;

  constructor(private authStepperService: AuthStepperService) {}

  nextStep(): void {
    const { password: passwordFormControl, confirmPassword: confirmPasswordControl } =
      this.authForm.controls;

    if (passwordFormControl.value !== confirmPasswordControl.value) {
      confirmPasswordControl.setErrors({ passwordsNotEqual: true });
      return;
    }

    if (this.isStepOneValid()) {
      this.authStepperService.setAuthStep(AuthStepperType.SECOND_STEP);
    }
  }

  private isStepOneValid(): boolean {
    const { email, password, confirmPassword } = this.authForm.controls;

    return email.valid && password.valid && confirmPassword.valid;
  }
}
