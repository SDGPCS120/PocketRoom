import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { requireAdministrator, type AuthenticatedRequest } from '../auth/types/authenticated-request';
import { CategoryService } from './category.service';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Controller('categories')
export class CategoryController {
  constructor(private readonly categoryService: CategoryService) {}

  @Post()
  @UseGuards(FirebaseAuthGuard)
  create(@Req() request: AuthenticatedRequest, @Body() dto: CreateCategoryDto) {
    requireAdministrator(request.user);
    return this.categoryService.create(dto);
  }

  @Get()
  findAll(
    @Query('parentCategoryId') parentCategoryId?: string,
    @Query('isActive') isActive?: string,
  ) {
    const activeBool =
      typeof isActive === 'string' ? isActive === 'true' : undefined;

    return this.categoryService.findAll(parentCategoryId, activeBool);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.categoryService.findOne(id);
  }

  @Patch(':id')
  @UseGuards(FirebaseAuthGuard)
  update(@Req() request: AuthenticatedRequest, @Param('id') id: string, @Body() dto: UpdateCategoryDto) {
    requireAdministrator(request.user);
    return this.categoryService.update(id, dto);
  }

  @Delete(':id')
  @UseGuards(FirebaseAuthGuard)
  remove(@Req() request: AuthenticatedRequest, @Param('id') id: string) {
    requireAdministrator(request.user);
    return this.categoryService.remove(id);
  }
}
