export type UserDataModel = {
  userId: string;
  userName: string;
  firstName: string;
  lastName: string;
  email: string;
  bio?: string;
  avatarUrl?: string;
  connectedAt: string | null;
  disconnectedAt: string | null;
};
