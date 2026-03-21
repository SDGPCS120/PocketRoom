import { Body, Controller, Delete, Get, Param, Patch, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { ReviewService } from './review.service';
import { CreateReviewDto } from './dto/create-review.dto';

type AuthedRequest = Request & { user?: { uid: string } };

@ApiTags('Reviews')
@Controller('reviews')
export class ReviewController {
  constructor(private readonly reviewService: ReviewService) {}

  @Post()
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth('firebase-auth')
  @ApiOperation({ summary: 'Create a new review' })
  @ApiCreatedResponse({ description: 'Review successfully created' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  createReview(@Req() req: AuthedRequest, @Body() dto: CreateReviewDto) {
    return this.reviewService.createReview(req.user!.uid, dto);
  }

  @Get('product/:productId')
  @ApiOperation({ summary: 'Get all reviews for a specific product' })
  @ApiParam({ name: 'productId', description: 'Product ID' })
  @ApiOkResponse({ description: 'List of product reviews' })
  getReviewsByProductId(@Param('productId') productId: string) {
    return this.reviewService.getReviewsByProductId(productId);
  }

  @Patch(':id')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth('firebase-auth')
  @ApiOperation({ summary: 'Update an existing review' })
  @ApiParam({ name: 'id', description: 'Review ID' })
  @ApiOkResponse({ description: 'Review successfully updated' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  updateReview(
    @Param('id') id: string,
    @Req() req: AuthedRequest,
    @Body() dto: Partial<CreateReviewDto>,
  ) {
    return this.reviewService.updateReview(id, req.user!.uid, dto);
  }

  @Delete(':id')
  @UseGuards(FirebaseAuthGuard)
  @ApiBearerAuth('firebase-auth')
  @ApiOperation({ summary: 'Delete a review' })
  @ApiParam({ name: 'id', description: 'Review ID' })
  @ApiOkResponse({ description: 'Review successfully deleted' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid Firebase token' })
  deleteReview(
    @Param('id') id: string,
    @Req() req: AuthedRequest,
  ) {
    return this.reviewService.deleteReview(id, req.user!.uid);
  }
}

