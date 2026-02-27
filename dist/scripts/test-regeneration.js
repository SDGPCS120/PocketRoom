"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../src/app.module");
const products_service_1 = require("../src/products/products.service");
const common_1 = require("@nestjs/common");
async function bootstrap() {
    const logger = new common_1.Logger('TestRegeneration');
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    const productsService = app.get(products_service_1.ProductsService);
    const productId = 'chair-104';
    logger.log(`Triggering regeneration for ${productId}...`);
    try {
        await productsService.regenerateModel(productId, { x: 1, y: 1, z: 1 });
        logger.log('✅ Regeneration triggered successfully!');
        logger.log('Check the running server logs for progress.');
    }
    catch (error) {
        logger.error(`❌ Failed: ${error.message}`);
    }
    await app.close();
}
bootstrap();
//# sourceMappingURL=test-regeneration.js.map