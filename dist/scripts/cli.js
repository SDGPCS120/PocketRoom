"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("../src/app.module");
const products_service_1 = require("../src/products/products.service");
const inquirer_1 = __importDefault(require("inquirer"));
const ora_1 = __importDefault(require("ora"));
const chalk_1 = __importDefault(require("chalk"));
const fs = __importStar(require("fs"));
const path = __importStar(require("path"));
const mime = __importStar(require("mime-types"));
async function bootstrap() {
    const app = await core_1.NestFactory.createApplicationContext(app_module_1.AppModule);
    const productsService = app.get(products_service_1.ProductsService);
    console.log(chalk_1.default.blue.bold('\n🚀 3D Generation Pipeline CLI 🚀\n'));
    while (true) {
        const { action } = await inquirer_1.default.prompt([
            {
                type: 'list',
                name: 'action',
                message: 'What would you like to do?',
                choices: [
                    { name: '📋 View All Products', value: 'view' },
                    { name: '➕ Add New Product', value: 'add' },
                    { name: '🔄 Generate 3D Model', value: 'regenerate' },
                    { name: '❌ Exit', value: 'exit' },
                ],
            },
        ]);
        if (action === 'exit') {
            console.log(chalk_1.default.yellow('Goodbye! 👋'));
            await app.close();
            process.exit(0);
        }
        if (action === 'view') {
            const spinner = (0, ora_1.default)('Fetching products...').start();
            const products = await productsService.findAll();
            spinner.stop();
            const failed = products.filter(p => p.modelStatus === 'failed');
            if (failed.length > 0) {
                console.log(chalk_1.default.red('\nFailed Products Errors:'));
                failed.forEach(p => {
                    console.log(chalk_1.default.red(`- ${p.name} (${p.id}): ${p.modelError}`));
                });
                console.log('\n');
            }
            console.table(products.map(p => ({
                ID: p.id,
                Name: p.name,
                Status: p.modelStatus || 'pending',
                Image: p.imageUrl ? '✅' : '❌',
                Model: p.modelURL ? '✅' : '❌',
                Error: p.modelError ? p.modelError.substring(0, 50) : ''
            })));
        }
        if (action === 'regenerate') {
            const spinner = (0, ora_1.default)('Fetching products...').start();
            const products = await productsService.findAll();
            spinner.stop();
            const { productId } = await inquirer_1.default.prompt([
                {
                    type: 'list',
                    name: 'productId',
                    message: 'Select a product to regenerate:',
                    choices: products.map(p => ({
                        name: `${p.name} (${p.modelStatus || 'pending'}) - ID: ${p.id}`,
                        value: p.id
                    }))
                }
            ]);
            const { confirm } = await inquirer_1.default.prompt([
                {
                    type: 'confirm',
                    name: 'confirm',
                    message: `Are you sure you want to regenerate the model for ${productId}?`,
                    default: true
                }
            ]);
            if (confirm) {
                const genSpinner = (0, ora_1.default)('Triggering generation...').start();
                try {
                    await productsService.regenerateModel(productId, { x: 1, y: 1, z: 1 });
                    genSpinner.succeed(chalk_1.default.green('Generation triggered successfully!'));
                    console.log(chalk_1.default.gray('Check your backend logs or Firebase to see progress.'));
                }
                catch (error) {
                    genSpinner.fail(chalk_1.default.red('Failed to trigger generation.'));
                    console.error(error.message);
                }
            }
        }
        if (action === 'add') {
            console.log(chalk_1.default.cyan('\n📝 Enter Product Details\n'));
            const answers = await inquirer_1.default.prompt([
                {
                    type: 'input',
                    name: 'productID',
                    message: 'Product ID (leave empty to auto-generate):',
                },
                {
                    type: 'input',
                    name: 'name',
                    message: 'Product Name:',
                    validate: (input) => input ? true : 'Name is required'
                },
                {
                    type: 'number',
                    name: 'price',
                    message: 'Price ($):',
                    validate: (input) => !isNaN(input) && input >= 0 ? true : 'Please enter a valid price'
                },
                {
                    type: 'input',
                    name: 'material',
                    message: 'Material:',
                    validate: (input) => input ? true : 'Material is required'
                },
                {
                    type: 'input',
                    name: 'primaryColor',
                    message: 'Primary Color:',
                    validate: (input) => input ? true : 'Color is required'
                },
                {
                    type: 'confirm',
                    name: 'stockStatus',
                    message: 'In Stock?',
                    default: true
                },
                {
                    type: 'input',
                    name: 'styleTags',
                    message: 'Style Tags (comma separated):',
                    filter: (input) => input.split(',').map(t => t.trim()).filter(t => t.length > 0)
                },
                {
                    type: 'number',
                    name: 'height',
                    message: 'Height (cm):',
                    validate: (input) => !isNaN(input) && input > 0 ? true : 'Valid height required'
                },
                {
                    type: 'number',
                    name: 'length',
                    message: 'Length (cm):',
                    validate: (input) => !isNaN(input) && input > 0 ? true : 'Valid length required'
                },
                {
                    type: 'number',
                    name: 'width',
                    message: 'Width (cm):',
                    validate: (input) => !isNaN(input) && input > 0 ? true : 'Valid width required'
                },
                {
                    type: 'input',
                    name: 'imagePath',
                    message: 'Path to Product Image (absolute or relative):',
                    validate: async (input) => {
                        try {
                            if (fs.existsSync(input))
                                return true;
                            return 'File does not exist';
                        }
                        catch (e) {
                            return 'Invalid path';
                        }
                    }
                }
            ]);
            const spinner = (0, ora_1.default)('Creating product...').start();
            try {
                const productData = {
                    productID: answers.productID || undefined,
                    name: answers.name,
                    price: answers.price,
                    material: answers.material,
                    primaryColor: answers.primaryColor,
                    stockStatus: answers.stockStatus,
                    styleTags: answers.styleTags,
                    dimensions: {
                        height: answers.height,
                        length: answers.length,
                        width: answers.width
                    }
                };
                const createResult = await productsService.create(productData);
                const newProductId = createResult.id;
                spinner.text = 'Uploading image...';
                const imagePath = path.resolve(answers.imagePath);
                const fileBuffer = fs.readFileSync(imagePath);
                const mimeType = mime.lookup(imagePath) || 'image/jpeg';
                const uploadResult = await productsService.uploadProductImage(newProductId, fileBuffer, mimeType);
                await productsService.update(newProductId, {
                    imageUrl: uploadResult.imageUrl,
                    imagePath: uploadResult.imagePath,
                    modelStatus: 'pending'
                });
                spinner.succeed(chalk_1.default.green(`Product created successfully! ID: ${newProductId}`));
                console.log(chalk_1.default.gray(`Image uploaded to: ${uploadResult.imagePath}`));
            }
            catch (error) {
                spinner.fail(chalk_1.default.red('Failed to add product.'));
                console.error(error.message);
            }
        }
    }
}
bootstrap();
//# sourceMappingURL=cli.js.map