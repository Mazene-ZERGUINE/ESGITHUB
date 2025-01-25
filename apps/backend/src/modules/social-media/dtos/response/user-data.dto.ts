export class UserDataDto {
	userId: string;
	userName: string;
	firstName: string;
	lastName: string;
	email: string;
	bio?: string;
	avatarUrl?: string;
	connectedAt: Date;
	disconnectedAt: Date;

	constructor(
		userId: string,
		userName: string,
		firstName: string,
		lastName: string,
		email: string,
		bio: string,
		avatarUrl: string,
		connectedAt: Date,
		disconnectedAt: Date,
	) {
		this.userId = userId;
		this.userName = userName;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.bio = bio;
		this.avatarUrl = avatarUrl;
		this.connectedAt = connectedAt;
		this.disconnectedAt = disconnectedAt;
	}
}
