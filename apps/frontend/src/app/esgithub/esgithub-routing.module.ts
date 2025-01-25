import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { CodingPageComponent } from './coding-page/coding-page.component';
import { HomePageComponent } from './home-page/home-page.component';
import { ProfileComponent } from './profile/profile.component';
import { AuthGuard } from '../core/guards/auth.guard';
import { ProgramEditComponent } from './program-edit/program-edit.component';
import { GroupsComponent } from './groups/groups.component';
import { GroupeDetailsComponent } from './groups/groupe-details/groupe-details.component';
import { EditUserProgramComponent } from './edit-user-program/edit-user-program.component';
import { CollaborativeCodingComponent } from './collaboratif-coding/collaborative-coding.component';
import { SessionGuard } from '../core/guards/session.guard';
import { PipelinesComponent } from './piplines/pipelines.component';

const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'auth' },
  { path: 'coding', component: CodingPageComponent, canActivate: [AuthGuard] },
  { path: 'home', component: HomePageComponent, canActivate: [AuthGuard] },
  { path: 'profile', component: ProfileComponent, canActivate: [AuthGuard] },
  { path: 'profile/:userId', component: ProfileComponent, canActivate: [AuthGuard] },
  {
    path: 'program/:programId',
    component: ProgramEditComponent,
    canActivate: [AuthGuard],
  },
  { path: 'groups', component: GroupsComponent, canActivate: [AuthGuard] },
  { path: 'group/:groupId', component: GroupeDetailsComponent, canActivate: [AuthGuard] },
  {
    path: 'program/edit/:programId',
    component: EditUserProgramComponent,
    canActivate: [AuthGuard],
  },
  {
    path: 'collaborate/:sessionId/:ownerId',
    component: CollaborativeCodingComponent,
    canActivate: [SessionGuard],
  },
  {
    path: 'pipelines',
    component: PipelinesComponent,
    canActivate: [AuthGuard],
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule],
})
export class EsgithubRoutingModule {}
