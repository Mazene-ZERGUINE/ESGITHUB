import { Component, EventEmitter, Input, OnDestroy, OnInit, Output } from '@angular/core';
import { Observable, Subject, map, takeUntil, tap } from 'rxjs';
import { ProgramModel } from '../../../core/models/program.model';
import { ReactionModel } from '../../../core/models/reaction.model';
import { UserDataModel } from '../../../core/models/user-data.model';
import { ReactionsEnum } from '../../../shared/enums/reactions.enum';
import { HomeService } from '../home.service';
import { ProgramListService } from './program-list.service';
import { ReactionService } from './reaction.service';
import { UserUtils } from 'src/app/core/Auth/utils/user.utils';

@Component({
  selector: 'app-program-item-list',
  templateUrl: './program-item-list.component.html',
  styleUrls: ['./program-item-list.component.scss'],
})
export class ProgramItemListComponent implements OnInit, OnDestroy {
  readonly componentDestroyer$: Subject<void> = new Subject();

  @Input() program!: ProgramModel;
  @Input() currentUser!: UserDataModel;
  @Input() homePage!: boolean;
  @Input() isGroupOwner!: boolean;
  @Input() isProfileOwner?: boolean;

  @Output() programHasBeenLiked = new EventEmitter<void>();

  @Output() dislikeClickEvent = new EventEmitter<{ programId: string; userId: string }>();
  @Output() removeClickEvent = new EventEmitter<string>();

  isUserConnected!: boolean | null;
  programCommentsCount$: Observable<number> | undefined;
  isProgramOwner: boolean = false;
  userReaction?: ReactionModel;
  likes$!: Observable<number>;
  dislikes$!: Observable<number>;

  readonly ReactionsEnum = ReactionsEnum;

  constructor(
    private reactionService: ReactionService,
    private homeService: HomeService,
    private programListService: ProgramListService,
  ) {}

  ngOnInit(): void {
    if (this.currentUser && this.program) {
      this.userReaction = this.getUserReaction(this.currentUser);
      this.isProgramOwner = this.checkOwner(this.currentUser);

      this.reactionService.updateLikes(this.program.programId, this.getLikes());
      this.reactionService.updateDislikes(this.program.programId, this.getDislikes());

      this.likes$ = this.reactionService.getLikes$(this.program.programId);
      this.dislikes$ = this.reactionService.getDislikes$(this.program.programId);

      this.programCommentsCount$ = this.setProgramCommentCount(this.program.programId);

      this.isUserConnected = UserUtils.setIsUserConnected(
        this.program.user.disconnectedAt,
        this.program.user.connectedAt,
      );
    }
  }

  ngOnDestroy(): void {
    this.componentDestroyer$.next();
    this.componentDestroyer$.complete();
  }

  private getUserReaction(user: UserDataModel): ReactionModel | undefined {
    return this.program.reactions.find(
      (reaction) => reaction?.user?.userId === user.userId,
    );
  }

  private getLikes(): number {
    return this.program.reactions.filter(
      (reaction) => reaction.type === ReactionsEnum.LIKE,
    ).length;
  }

  private getDislikes(): number {
    return this.program.reactions.filter(
      (reaction) => reaction.type === ReactionsEnum.DISLIKE,
    ).length;
  }

  private checkOwner(user: UserDataModel): boolean {
    return this.program.user.userId === user.userId;
  }

  private setProgramCommentCount(programId: string): Observable<number> | undefined {
    return this.programListService.getProgramComments$(programId).pipe(
      map(
        (comments) =>
          comments.filter((comment) => comment.codeLineNumber !== null).length,
      ),
      takeUntil(this.componentDestroyer$),
    );
  }

  onDislikeBtnClick(): void {
    this.dislikeClickEvent.emit({
      userId: this.currentUser.userId,
      programId: this.program.programId,
    });
  }

  onDeleteBtnClick(): void {
    this.removeClickEvent.emit(this.program.programId);
  }

  onlikeProgram(): void {
    this.homeService
      .likeOrDislikeProgram(
        ReactionsEnum.LIKE,
        this.program.programId,
        this.currentUser.userId,
      )
      .pipe(
        takeUntil(this.componentDestroyer$),
        tap(() => this.programHasBeenLiked.emit()),
      )
      .subscribe();
  }
}
