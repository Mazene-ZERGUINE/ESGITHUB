import { GroupEntity } from '../../entities/group.entity';
import { UserDataDto } from './user-data.dto';
import { GetProgramDto } from './get-program.dto';

export class GroupDataDto {
	groupId: string;
	name: string;
	description?: string;
	owner: UserDataDto;
	members: UserDataDto[];
	created_at: Date;
	imageUrl?: string;
	visibility: string;
	programs?: GetProgramDto[];

	constructor(entity: GroupEntity) {
		this.groupId = entity.groupId;
		this.name = entity.name;
		this.description = entity.description;
		this.owner = entity.owner.toUserDataDto();
		if (entity.members) this.members = entity.members.map((user) => user.toUserDataDto());
		if (entity.programs)
			this.programs = entity.programs.map((program) => program.toGetProgramDto());
		this.created_at = entity.createdAt;
		this.imageUrl = entity.imageUrl;
		this.visibility = entity.visibility;
	}
}
