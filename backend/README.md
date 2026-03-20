# PocketRoom Backend - NestJS AI Search

<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

## Description

A modular NestJS backend providing intelligent furniture search with NLP capabilities. This project has been migrated from Express.js/FastAPI to a robust NestJS architecture.

## 🎯 AI Search Features

- **AI-powered natural language search:** Understands complex user queries.
- **Smart query parsing:** Entity extraction for product types, colors, and materials.
- **Color similarity matching:** Finds products in similar shade families.
- **ML-based relevance ranking:** Scores products based on multiple semantic signals.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run dev

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test
```

## 📁 Project Structure

Following a modular feature-based structure:
```
backend/
├── src/
│   ├── features/
│   │   ├── search/          # AI Search module
│   │   │   ├── search.service.ts
│   │   │   ├── search.controller.ts
│   │   │   └── ...
│   │   ├── app.module.ts
│   │   └── main.ts
├── data/
│   └── products.json        # Product database
└── ...
```

## Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [NLP-based Search Logic](src/features/search/README.md) (if it exists)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
