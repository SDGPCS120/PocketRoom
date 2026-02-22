import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await NestFactory.create(AppModule);

  const swaggerConfig = new DocumentBuilder()
    .setTitle('PocketRoom Backend API')
    .setDescription('API documentation for PocketRoom backend services')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        description: 'Firebase ID token in format: Bearer <token>',
      },
      'firebase-auth',
    )
    .addTag('System', 'Health and basic system endpoints')
    .addTag('Auth', 'Authentication and user synchronization endpoints')
    .build();

  const swaggerDocument = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, swaggerDocument, {
    swaggerOptions: {
      persistAuthorization: true,
      displayRequestDuration: true,
      docExpansion: 'none',
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
    },
  });

  const port = Number(process.env.PORT ?? 3000);
  const host = process.env.HOST ?? '0.0.0.0';
  await app.listen(port, host);

  const externalHost = host === '0.0.0.0' ? 'localhost' : host;
  const baseUrl = `http://${externalHost}:${port}`;
  logger.log(`Application URL: ${baseUrl}`);
  logger.log(`Swagger UI: ${baseUrl}/docs`);
}
bootstrap();
