import { UserDataModel } from './user-data.model';

export type Follower = {
  follower: UserDataModel;
  relationId: string;
};

export type Following = {
  following: UserDataModel;
  relationId: string;
};

export type UserFollowersModel = {
  followers: Follower[];
  followings: Following[];
};
