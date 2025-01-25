import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterModule } from '@angular/router';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';

import { SharedModule } from '../shared/shared.module';
import { RequestInterceptor } from './interceptors/request.interceptor';
import { CustomSnackbarComponent } from './components/custom-snackbar/custom-snackbar.component';
import { SideNavbarComponent } from './components/side-navbar/side-navbar.component';
import { AuthModule } from './Auth/auth.module';
import { AuthInterceptor } from './interceptors/auth.interceptor';
import { MaterialModule } from '../shared/material.module';
import { CodePageUseGuidModalComponent } from './modals/code-page-use-guid-modal/code-page-use-guid-modal.component';
import { LineCommentsModalComponent } from './modals/line-comments-modal/line-comments-modal.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { CreateGroupModalComponent } from './modals/create-group-modal/create-group-modal.component';
import { ConfirmationModalComponent } from './modals/conifrmatio-modal/confirmation-modal.component';
import { GroupPublishModalComponent } from './modals/group-publish-modal/group-publish-modal.component';
import { GroupMembersModalComponent } from './modals/group-members-modal/group-members-modal.component';
import { UserDisplayNamePipe } from '../shared/pipes/user-display-name.pipe';
import { ShowCodeExecutionResultModalComponent } from './modals/show-code-execution-result-modal/show-code-execution-result-modal.component';
import { VersionModalComponent } from './modals/version-modal/version-modal.component';
import { DisplayIconsNavbarComponent } from './components/side-navbar/display-icons-navbar/display-icons-navbar.component';

@NgModule({
  declarations: [
    CustomSnackbarComponent,
    SideNavbarComponent,
    CodePageUseGuidModalComponent,
    LineCommentsModalComponent,
    CreateGroupModalComponent,
    ConfirmationModalComponent,
    GroupPublishModalComponent,
    GroupMembersModalComponent,
    ShowCodeExecutionResultModalComponent,
    VersionModalComponent,
    DisplayIconsNavbarComponent,
  ],
  imports: [
    CommonModule,
    SharedModule,
    RouterModule,
    HttpClientModule,
    AuthModule,
    MaterialModule,
    ReactiveFormsModule,
    FormsModule,
    UserDisplayNamePipe,
  ],
  providers: [
    {
      provide: HTTP_INTERCEPTORS,
      useClass: RequestInterceptor,
      multi: true,
    },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true,
    },
  ],
  exports: [SideNavbarComponent],
})
export class CoreModule {}
