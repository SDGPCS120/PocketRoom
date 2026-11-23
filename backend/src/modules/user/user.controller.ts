import { Body, Controller, Delete, Get, Param, Patch, Post, Query, Req, UseGuards } from '@nestjs/common';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import type { AuthenticatedRequest } from '../auth/types/authenticated-request';
import { UserService } from './user.service';
import { CreateUserDto, UserRole } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@UseGuards(FirebaseAuthGuard)
@Controller('users')
export class UserController {
  constructor(private readonly service: UserService) {}

  @Post()
  create(@Req() req: AuthenticatedRequest, @Body() dto: CreateUserDto) {
    return this.service.create(req.user, dto);
  }

  @Get()
  findAll(
    @Req() req: AuthenticatedRequest,
    @Query('role') role?: UserRole,
    @Query('isActive') isActive?: string,
  ) {
    const activeBool = typeof isActive === 'string' ? isActive === 'true' : undefined;
    return this.service.findAll(req.user, role, activeBool);
  }

  @Get(':id')
  findOne(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.service.findOne(req.user, id);
  }

  @Patch(':id')
  update(@Req() req: AuthenticatedRequest, @Param('id') id: string, @Body() dto: UpdateUserDto) {
    return this.service.update(req.user, id, dto);
  }

  @Delete(':id')
  remove(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.service.remove(req.user, id);
  }
}
