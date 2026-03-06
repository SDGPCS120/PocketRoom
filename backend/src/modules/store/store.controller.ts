import {
    Body,
    Controller,
    Delete,
    Get,
    Param,
    Post,
    Put,
    Req,
    UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseAuthGuard } from '../auth/guards/firebase-auth.guard';
import { CreateStoreDto } from './dto/create-store.dto';
import { UpdateStoreDto } from './dto/update-store.dto';
import { StoreService } from './store.service';

@Controller('stores')
export class StoreController {
    constructor(private readonly storeService: StoreService) { }

    @UseGuards(FirebaseAuthGuard)
    @Post()
    createStore(
        @Req() req: Request & { user?: { uid: string } },
        @Body() dto: CreateStoreDto,
    ) {
        return this.storeService.createStore(req.user!.uid, dto);
    }

    @UseGuards(FirebaseAuthGuard)
    @Get('me')
    getMyStore(@Req() req: Request & { user?: { uid: string } }) {
        return this.storeService.getMyStore(req.user!.uid);
    }

    @Get(':id')
    getStoreById(@Param('id') storeId: string) {
        return this.storeService.getStoreById(storeId);
    }

    @UseGuards(FirebaseAuthGuard)
    @Put(':id')
    updateStore(
        @Param('id') storeId: string,
        @Req() req: Request & { user?: { uid: string } },
        @Body() dto: UpdateStoreDto,
    ) {
        return this.storeService.updateStore(storeId, req.user!.uid, dto);
    }

    @UseGuards(FirebaseAuthGuard)
    @Delete(':id')
    deleteStore(
        @Param('id') storeId: string,
        @Req() req: Request & { user?: { uid: string } },
    ) {
        return this.storeService.deleteStore(storeId, req.user!.uid);
    }
}