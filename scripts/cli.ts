import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { ProductsService } from '../src/products/products.service';
import inquirer from 'inquirer';
import ora from 'ora';
import chalk from 'chalk';
import * as fs from 'fs';
import * as path from 'path';
import * as mime from 'mime-types';


async function bootstrap() {
    const app = await NestFactory.createApplicationContext(AppModule);
    const productsService = app.get(ProductsService);

    console.log(chalk.blue.bold('\n🚀 3D Generation Pipeline CLI 🚀\n'));

    while (true) {
        const { action } = await inquirer.prompt([
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
        // const action: any = 'view';
        if (action === 'exit') {
            console.log(chalk.yellow('Goodbye! 👋'));
            await app.close();
            process.exit(0);
        }

        if (action === 'view') {
            const spinner = ora('Fetching products...').start();
            const products = await productsService.findAll() as any[];
            spinner.stop();

            const failed = products.filter(p => p.modelStatus === 'failed');
            if (failed.length > 0) {
                console.log(chalk.red('\nFailed Products Errors:'));
                failed.forEach(p => {
                    console.log(chalk.red(`- ${p.name} (${p.id}): ${p.modelError}`));
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
            const spinner = ora('Fetching products...').start();
            const products = await productsService.findAll() as any[];
            spinner.stop();

            const { productId } = await inquirer.prompt([
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

            const { confirm } = await inquirer.prompt([
                {
                    type: 'confirm',
                    name: 'confirm',
                    message: `Are you sure you want to regenerate the model for ${productId}?`,
                    default: true
                }
            ]);

            if (confirm) {
                const genSpinner = ora('Triggering generation...').start();
                try {
                    // Default dimensions or ask user? For simplicity, using defaults for now
                    await productsService.regenerateModel(productId, { x: 1, y: 1, z: 1 });
                    genSpinner.succeed(chalk.green('Generation triggered successfully!'));
                    console.log(chalk.gray('Check your backend logs or Firebase to see progress.'));
                } catch (error) {
                    genSpinner.fail(chalk.red('Failed to trigger generation.'));
                    console.error(error.message);
                }
            }
        }



        if (action === 'add') {
            console.log(chalk.cyan('\n📝 Enter Product Details\n'));

            const answers = await inquirer.prompt([
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
                        const fs = require('fs');
                        try {
                            if (fs.existsSync(input)) return true;
                            return 'File does not exist';
                        } catch (e) {
                            return 'Invalid path';
                        }
                    }

                }
            ]);

            const spinner = ora('Creating product...').start();


            try {
                // 1. Create initial product document
                const productData = {
                    productID: answers.productID || undefined, // undefined will trigger auto-gen logic if we handled it that way, but passing undefined key is fine as DTO handles it? Actually if undefined, DTO is fine.
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

                const createResult = await productsService.create(productData as any);
                const newProductId = createResult.id;

                spinner.text = 'Uploading image...';

                // 2. Read and upload image
                const imagePath = path.resolve(answers.imagePath);
                const fileBuffer = fs.readFileSync(imagePath);
                const mimeType = mime.lookup(imagePath) || 'image/jpeg';

                const uploadResult = await productsService.uploadProductImage(newProductId, fileBuffer, mimeType);

                // 3. Update product with image URLs
                await productsService.update(newProductId, {
                    imageUrl: uploadResult.imageUrl,
                    imagePath: uploadResult.imagePath,
                    // Ensure modelStatus is pending, but we are NOT triggering generation
                    modelStatus: 'pending'
                });

                spinner.succeed(chalk.green(`Product created successfully! ID: ${newProductId}`));
                console.log(chalk.gray(`Image uploaded to: ${uploadResult.imagePath}`));

            } catch (error) {
                spinner.fail(chalk.red('Failed to add product.'));
                console.error(error.message);
            }
        }
    }
}

bootstrap();
