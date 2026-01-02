import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable validation globally
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true, // Strip properties that don't have decorators
    forbidNonWhitelisted: true, // Throw error if extra properties sent
    transform: true, // Auto-transform payloads to DTO instances
  }));

  // Enable CORS for frontend access
  app.enableCors();

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
