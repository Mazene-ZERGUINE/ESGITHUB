import { Component, EventEmitter, Input, Output } from '@angular/core';
import { ReactionsEnum } from 'src/app/shared/enums/reactions.enum';

@Component({
  selector: 'app-program-actions',
  templateUrl: './program-actions.component.html',
  styleUrls: ['./program-actions.component.scss'],
})
export class ProgramActionsComponent {
  @Input() numberOfLikes!: number;
  @Input() userReaction!: ReactionsEnum;
  @Input() programId!: string;
  @Input() programCommentCount!: number;
  @Input() isProgramOwner!: boolean;

  @Output() likeClickEvent = new EventEmitter<void>();

  readonly ReactionEnum = ReactionsEnum;

  onLikeBtnClick(): void {
    this.likeClickEvent.emit();
  }
}
