export interface EnvironmentVariables {
    PORT: number;
    NODE_ENV: string;
    FIREBASE_SERVICE_ACCOUNT_PATH: string;
}

export function validate(
    config: Record<string, unknown>,
): EnvironmentVariables {
    const errors: string[] = [];

    if (!config.FIREBASE_SERVICE_ACCOUNT_PATH) {
        errors.push('FIREBASE_SERVICE_ACCOUNT_PATH is required');
    }

    if (errors.length > 0) {
        throw new Error(
            `Environment validation failed:\n${errors.map((e) => `  - ${e}`).join('\n')}`,
        );
    }

    return {
        PORT: parseInt(config.PORT as string, 10) || 3000,
        NODE_ENV: (config.NODE_ENV as string) || 'development',
        FIREBASE_SERVICE_ACCOUNT_PATH:
            config.FIREBASE_SERVICE_ACCOUNT_PATH as string,
    };
}
