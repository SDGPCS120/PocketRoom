import {
  Body, Controller, Delete, ForbiddenException, Get, Param, Patch, Post, Query,
  Req, UnauthorizedException, UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { AuthUser } from '../auth/types/auth-user.type';
import { AddressService } from './address.service';
import { CreateAddressDto } from './dto/create-address.dto';
import { UpdateAddressDto } from './dto/update-address.dto';

type AuthenticatedRequest = Request & { user?: AuthUser };

@UseGuards(FirebaseAuthGuard)
@Controller('addresses')
export class AddressController {
  constructor(private readonly addressService: AddressService) {}

  private ownerId(req: AuthenticatedRequest, requestedId?: string) {
    // Existing address records use the Firebase UID, not the mapped profile ID.
    const authUid = req.user?.authUid;
    if (!authUid) throw new UnauthorizedException();
    if (requestedId !== undefined && requestedId !== authUid) {
      throw new ForbiddenException('Address owner does not match authenticated user');
    }
    return authUid;
  }

  @Post()
  create(@Req() req: AuthenticatedRequest, @Body() dto: CreateAddressDto) {
    return this.addressService.create(this.ownerId(req, dto.userId), dto);
  }

  @Get()
  findAll(
    @Req() req: AuthenticatedRequest,
    @Query('userId') userId?: string,
    @Query('isDefault') isDefault?: string,
  ) {
    const defaultBool =
      typeof isDefault === 'string' ? isDefault === 'true' : undefined;

    return this.addressService.findAll(this.ownerId(req, userId), defaultBool);
  }

  @Get(':id')
  findOne(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.addressService.findOne(this.ownerId(req), id);
  }

  @Patch(':id')
  update(
    @Req() req: AuthenticatedRequest,
    @Param('id') id: string,
    @Body() dto: UpdateAddressDto,
  ) {
    return this.addressService.update(this.ownerId(req, dto.userId), id, dto);
  }

  @Delete(':id')
  remove(@Req() req: AuthenticatedRequest, @Param('id') id: string) {
    return this.addressService.remove(this.ownerId(req), id);
  }
}