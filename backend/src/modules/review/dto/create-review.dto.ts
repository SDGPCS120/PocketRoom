import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsNumber, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateReviewDto {
  @ApiProperty({ example: 'product-123', description: 'The ID of the product being reviewed' })
  @IsString()
  @IsNotEmpty()
  productId!: string;

  @ApiProperty({ example: 5, description: 'Rating from 1 to 5' })
  @IsNumber()
  @Min(1)
  @Max(5)
  rating!: number;

  @ApiPropertyOptional({ example: 'Great product!', description: 'Text review' })
  @IsOptional()
  @IsString()
  comment?: string;
}
