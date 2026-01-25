import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { ProductsService } from '../src/products/products.service';
import { Logger } from '@nestjs/common';

async function bootstrap() {
    const logger = new Logger('TestRegeneration');
    const app = await NestFactory.createApplicationContext(AppModule);
    const productsService = app.get(ProductsService);

    const productId = 'chair-104';

    logger.log(`Triggering regeneration for ${productId}...`);

    try {
        await productsService.regenerateModel(productId, { x: 1, y: 1, z: 1 });
        logger.log('✅ Regeneration triggered successfully!');
        logger.log('Check the running server logs for progress.');
    } catch (error) {
        logger.error(`❌ Failed: ${error.message}`);
    }

    await app.close();
}

bootstrap();
