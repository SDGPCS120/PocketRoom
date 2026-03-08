import { IsInt, IsOptional, Min } from 'class-validator';

export class UpdateCartItemDto {
  @IsInt()
  @IsOptional()
  @Min(1)
  quantity?: number;
}
