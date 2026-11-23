import {
  Controller,
  Post,
  Body,
  Param,
  Req,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { GenerationsService, type GenerationImage } from './generations.service';
import { GenerateModelDto } from './dto/generate-model.dto';
import { FirebaseAuthGuard } from '../../../modules/auth/guards/firebase-auth.guard';
import type { AuthenticatedRequest } from '../../../modules/auth/types/authenticated-request';

@Controller('model-generation')
export class GenerationsController {
  constructor(private readonly generationsService: GenerationsService) {}

  /**
   * POST /model-generation/:id/generate
   * Accepts an image file and dimensions to generate a 3D model
   */
  @Post(':id/generate')
  @UseGuards(FirebaseAuthGuard)
  @HttpCode(HttpStatus.ACCEPTED)
  @UseInterceptors(
    FileInterceptor('image', {
      limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
      },
      fileFilter: (req, file, callback) => {
        if (!file.mimetype.match(/\/(jpg|jpeg|png)$/)) {
          return callback(
            new BadRequestException('Only image files are allowed!'),
            false,
          );
        }
        callback(null, true);
      },
    }),
  )
  async generateModel(
    @Param('id') id: string,
    @Req() request: AuthenticatedRequest,
    @UploadedFile() file: GenerationImage | undefined,
    @Body() dimensions: GenerateModelDto,
  ) {
    if (!file) {
      throw new BadRequestException('Image file is required');
    }

    // Convert string inputs to numbers if needed
    const parsedDimensions: GenerateModelDto = {
      x: Number(dimensions.x),
      y: Number(dimensions.y),
      z: Number(dimensions.z),
    };

    return this.generationsService.generateModel(id, request.user, file, parsedDimensions);
  }
}
