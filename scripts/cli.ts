import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { ProductsService } from '../src/products/products.service';
import inquirer from 'inquirer';
import ora from 'ora';
import chalk from 'chalk';

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
                    { name: '🔄 Regenerate 3D Model', value: 'regenerate' },
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
    }
}

bootstrap();
