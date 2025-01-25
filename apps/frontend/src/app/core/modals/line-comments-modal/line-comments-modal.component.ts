import { Component, Inject, OnDestroy, OnInit } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { EditProgramService } from '../../../esgithub/program-edit/edit-program.service';
import { Subscription, switchMap } from 'rxjs';
import { AuthService } from '../../Auth/service/auth.service';
import { map } from 'rxjs/operators';
import { UserUtils } from '../../Auth/utils/user.utils';

@Component({
  selector: 'app-line-comments-modal',
  templateUrl: './line-comments-modal.component.html',
  styleUrls: ['./line-comments-modal.component.scss'],
})
export class LineCommentsModalComponent implements OnInit, OnDestroy {
  getLinesCommentsSubscription!: Subscription;
  onCommentSubscribe!: Subscription;
  loadCommentsSubscription!: Subscription;

  lineNumber: number;
  programId: string;

  commentFieldText!: string;
  replyingToCommentId: string | null = null;
  commentReplyFieldText!: string;
  programComments!: any[];
  readonly anonymousImageUrl =
    'http://thumbs.dreamstime.com/b/default-profile-picture-avatar-photo-placeholder-vector-illustration-default-profile-picture-avatar-photo-placeholder-vector-189495158.jpg';

  constructor(
    @Inject(MAT_DIALOG_DATA) public data: any,
    private readonly editProgramService: EditProgramService,
    private readonly authService: AuthService,
    public dialogRef: MatDialogRef<LineCommentsModalComponent>,
  ) {
    this.lineNumber = data.lineNumber;
    this.programId = data.programId;
  }

  ngOnInit(): void {
    this.loadComments();
  }

  ngOnDestroy(): void {
    if (this.getLinesCommentsSubscription) {
      this.getLinesCommentsSubscription.unsubscribe();
    }
    if (this.onCommentSubscribe) {
      this.onCommentSubscribe.unsubscribe();
    }
    if (this.loadCommentsSubscription) {
      this.loadCommentsSubscription.unsubscribe();
    }
  }

  private loadComments(): void {
    this.loadCommentsSubscription = this.editProgramService
      .getLinesComments(this.lineNumber, this.programId)
      .subscribe((comments) => {
        this.programComments = this.filterComments(comments);
      });
  }

  private filterComments(comments: any[]): any[] {
    const replyCommentIds = this.getReplyCommentIds(comments);
    return comments.filter((comment) => !replyCommentIds.has(comment.commentId));
  }

  private getReplyCommentIds(comments: any[]): Set<string> {
    const replyCommentIds = new Set<string>();

    const collectReplyCommentIds = (commentArray: any[]) => {
      for (const comment of commentArray) {
        if (comment.replies && comment.replies.length > 0) {
          for (const reply of comment.replies) {
            replyCommentIds.add(reply.commentId);
          }
          collectReplyCommentIds(comment.replies);
        }
      }
    };
    collectReplyCommentIds(comments);
    return replyCommentIds;
  }

  onReplyClick(commentId: string): void {
    this.replyingToCommentId = this.replyingToCommentId === commentId ? null : commentId;
  }

  onSubmitReply(commentId: string): void {
    this.onCommentSubscribe = this.authService
      .getUserData()
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.replyToComment(
            commentId,
            userId,
            this.programId,
            this.commentReplyFieldText,
            this.lineNumber,
          ),
        ),
      )
      .subscribe(() => this.loadComments());
  }

  onFormatCommentAt(comment: string): string {
    return UserUtils.calculateElapsed(comment);
  }

  onCommentClick(): void {
    this.onCommentSubscribe = this.authService
      .getUserData()
      .pipe(
        map((userData) => userData.userId),
        switchMap((userId) =>
          this.editProgramService.submitComment(
            this.programId,
            userId,
            this.commentFieldText,
            this.lineNumber,
          ),
        ),
      )
      .subscribe(() => this.loadComments());
  }

  onCloseBtnClick(): void {
    this.dialogRef.close();
  }
}
