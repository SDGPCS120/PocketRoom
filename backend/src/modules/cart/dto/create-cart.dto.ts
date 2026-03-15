import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsNotEmpty, IsObject, IsOptional, IsString, Min } from 'class-validator';

export class CreateCartDto {
  @ApiProperty({ example: 'product-123' })
  @IsString()
  @IsNotEmpty()
  id: string;

  @ApiPropertyOptional({ example: 2, default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  quantity?: number;

  @ApiPropertyOptional({
    type: 'object',
    additionalProperties: true,
    example: { id: 'product-123', name: 'Accent Chair', price: 45000 },
  })
  @IsOptional()
  @IsObject()
  furniture?: Record<string, unknown>;
}
