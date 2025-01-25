import { NgModule } from '@angular/core';
import { CommonModule, NgOptimizedImage } from '@angular/common';

import { EsgithubRoutingModule } from './esgithub-routing.module';
import { CodingPageComponent } from './coding-page/coding-page.component';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { SharedModule } from '../shared/shared.module';
import { CoreModule } from '../core/core.module';
import { HomePageComponent } from './home-page/home-page.component';
import { ProgramItemListComponent } from './home-page/program-item-list/program-item-list.component';
import { ProfileComponent } from './profile/profile.component';
import { MaterialModule } from '../shared/material.module';
import { UserProgramsComponent } from './profile/user-programs/user-programs.component';
import { EditProfileComponent } from './profile/edit-profile/edit-profile.component';
import { FollowersListComponent } from './profile/followers-list/followers-list.component';
import { FollowingListComponent } from './profile/following-list/following-list.component';
import { SideProfileComponent } from './side-profile/side-profile.component';
import { FollowerFollowingComponent } from './side-profile/follower/follower.component';
import { ProgramEditComponent } from './program-edit/program-edit.component';
import { UserDisplayNamePipe } from '../shared/pipes/user-display-name.pipe';
import { GroupsComponent } from './groups/groups.component';
import { GroupListItemComponent } from './groups/group-list-item/group-list-item.component';
import { GroupeDetailsComponent } from './groups/groupe-details/groupe-details.component';
import { EditUserProgramComponent } from './edit-user-program/edit-user-program.component';
import { CollaborativeCodingComponent } from './collaboratif-coding/collaborative-coding.component';
import { PipelinesComponent } from './piplines/pipelines.component';
import { ProgramHeaderComponent } from './home-page/program-item-list/program-header/program-header.component';
import { ProgramUserComponent } from './home-page/program-item-list/program-user/program-user.component';
import { ProgramCodeComponent } from './home-page/program-item-list/program-code/program-code.component';
import { ProgramInputsOutputsComponent } from './home-page/program-item-list/program-inputs-outputs/program-inputs-outputs.component';
import { SearchProgramInputComponent } from './home-page/search-program-input/search-program-input.component';
import { ProgramActionsComponent } from './home-page/program-item-list/program-actions/program-actions.component';
import { ProgramFilterPopOverComponent } from './home-page/program-filter-pop-over/program-filter-pop-over.component';
import { FollowingComponent } from './side-profile/following/following.component';
import { GroupItemComponent } from './groups/group-item/group-item.component';
import { CodingPageLangagesSelectionComponent } from './coding-page/coding-page-langages-selection/coding-page-langages-selection.component';
import { NgxExtendedPdfViewerModule } from 'ngx-extended-pdf-viewer';
import { CountDisplayPipe } from '../shared/pipes/count-display.pipe';
import { FormatFilenamePipe } from '../shared/pipes/Format-filename.pipe';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

@NgModule({
  declarations: [
    CodingPageComponent,
    HomePageComponent,
    ProgramItemListComponent,
    ProfileComponent,
    UserProgramsComponent,
    EditProfileComponent,
    FollowersListComponent,
    FollowingListComponent,
    SideProfileComponent,
    FollowerFollowingComponent,
    ProgramEditComponent,
    GroupsComponent,
    GroupListItemComponent,
    GroupeDetailsComponent,
    EditUserProgramComponent,
    CollaborativeCodingComponent,
    PipelinesComponent,
    ProgramHeaderComponent,
    ProgramUserComponent,
    ProgramCodeComponent,
    ProgramInputsOutputsComponent,
    SearchProgramInputComponent,
    ProgramActionsComponent,
    ProgramFilterPopOverComponent,
    FollowingComponent,
    GroupItemComponent,
    CodingPageLangagesSelectionComponent,
  ],
  imports: [
    CommonModule,
    EsgithubRoutingModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    FormsModule,
    MatProgressBarModule,
    SharedModule,
    CoreModule,
    MaterialModule,
    ReactiveFormsModule,
    UserDisplayNamePipe,
    NgOptimizedImage,
    NgxExtendedPdfViewerModule,
    CountDisplayPipe,
    MatProgressSpinnerModule,
    FormatFilenamePipe,
  ],
})
export class EsgithubModule {}
