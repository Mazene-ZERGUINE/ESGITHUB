import { Injectable } from '@nestjs/common';
import { UserEntity } from '../entities/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateUserDto } from '../../auth/dtos/request/create-user.dto';
import { genSalt, hash } from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { HttpExistsException } from '../../../core/exceptions/HttpExistsException';
import { HttpNotFoundException } from '../../../core/exceptions/HttpNotFoundException';
import { UpdateAccountDto } from '../dtos/request/update-account.dto';
import { merge } from 'lodash';

@Injectable()
export class UsersService {
	constructor(
		private readonly jwtService: JwtService,
		@InjectRepository(UserEntity) private readonly userRepository: Repository<UserEntity>,
	) {}

	async create(userDto: CreateUserDto): Promise<void> {
		const isUserExist = await this.userRepository.findOneBy({ email: userDto.email });
		if (isUserExist) {
			throw new HttpExistsException(` user ${userDto.email} already exists`);
		}
		const newUser = this.userRepository.create(userDto);
		newUser.password = await hash(newUser.password, await genSalt());
		await this.userRepository.save(newUser);
	}
	async findByEmail(email: string): Promise<null | UserEntity> {
		const foundUser = await this.userRepository.findOneBy({ email: email });
		if (!foundUser) {
			throw new HttpNotFoundException(`user ${email} does not exist`);
		}
		return foundUser;
	}
	async findById(userId: string): Promise<UserEntity | null> {
		return await this.userRepository.findOneBy({ userId: userId });
	}

	async partialUpdate(payload: UpdateAccountDto, userId: string): Promise<void> {
		const user = await this.userRepository.findOne({ where: { userId: userId } });
		if (!user) {
			throw new HttpNotFoundException('user not found');
		}
		merge(user, payload);
		await this.userRepository.save(user);
	}

	async updateProfileImage(userId: string, imageUrl: string): Promise<void> {
		const user = await this.userRepository.findOne({ where: { userId: userId } });
		if (!user) {
			throw new HttpNotFoundException('user not found');
		}
		user.avatarUrl = imageUrl;
		await this.userRepository.save(user);
	}

	async save(user: UserEntity): Promise<void> {
		await this.userRepository.save(user);
	}
}
