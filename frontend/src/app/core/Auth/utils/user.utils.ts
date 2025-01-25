export class UserUtils {
  static setIsUserConnected(
    userDisconnectedAt: string | null,
    userConnectedAt: string | null,
  ): boolean {
    return userConnectedAt !== null;
  }

  static calculateElapsed(disconnectedAt: string | null): string {
    if (!disconnectedAt) return '';
    const disconnectedDate = new Date(disconnectedAt);
    const now = new Date();
    const diff = Math.floor((now.getTime() - disconnectedDate.getTime()) / 60000);

    if (diff >= 60) {
      return 'more than 1h ago';
    } else if (diff > 1) {
      return `${Math.ceil(diff / 5) * 5} min ago`;
    } else {
      return '1 min ago';
    }
  }
}
