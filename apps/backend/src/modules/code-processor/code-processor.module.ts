import { Module } from '@nestjs/common';
import { CodeProcessingControllerController } from './controllers/code-prossessing-controller.controller';
import { CodeProcessorService } from './services/code-processor.service';
import { HttpService } from './services/http.service';
import { FilesHandlerUtils } from './utils/files-handler.utils';
import { CollaboratifCodingController } from './controllers/collaboratif-coding.controller';
import { PipelinesController } from './controllers/pipelines.controller';
import { PipelineService } from './services/pipeline.service';

@Module({
	controllers: [
		CodeProcessingControllerController,
		CollaboratifCodingController,
		PipelinesController,
	],
	providers: [CodeProcessorService, HttpService, FilesHandlerUtils, PipelineService],
})
export class CodeProcessorModule {}
