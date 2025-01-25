// multer.config.ts
import { diskStorage } from 'multer';
import { v4 as uuidv4 } from 'uuid';
import { extname, join } from 'path';
import { Express } from 'express';

export const multerOptions = {
	storage: diskStorage({
		destination: (req, file, cb) => {
			const uploadPath = join(__dirname, '../../../', 'uploads', 'avatars');
			cb(null, uploadPath);
		},
		filename: (req, file, cb) => {
			const fileExtName = extname(file.originalname);
			const randomName = uuidv4();
			cb(null, `${randomName}${fileExtName}`);
		},
	}),
	fileFilter: (
		req: Request,
		file: Express.Multer.File,
		cb: (error: Error | null, acceptFile: boolean) => void,
	): void => {
		if (!file.mimetype.match(/\/(jpg|jpeg|png|gif|svg)$/)) {
			return cb(new Error('Unsupported file type'), false);
		}
		cb(null, true);
	},
};

export const codeExecutionsMulterOption = {
	storage: diskStorage({
		destination: (req, file, cb) => {
			const uploadPath = join(__dirname, '../../../', 'uploads', 'code', 'input');
			cb(null, uploadPath);
		},
		filename: (req, file, cb) => {
			const fileExtName = extname(file.originalname);
			const randomName = uuidv4();
			cb(null, `${randomName}${fileExtName}`);
		},
	}),
};
