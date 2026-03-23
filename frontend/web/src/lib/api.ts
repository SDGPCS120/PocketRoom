import axios, { type AxiosError, type InternalAxiosRequestConfig } from 'axios';
import { auth } from './firebase';

const baseURL =
  import.meta.env.VITE_API_URL || 'https://pocketroom-backend-nm5z3yxdra-el.a.run.app';

export function getApiBaseURL() {
  return baseURL;
}

export function toUserFacingApiError(error: unknown): string {
  if (axios.isAxiosError(error)) {
    const e = error as AxiosError;

    // No response => network/DNS/CORS/proxy/mixed-content, etc.
    if (!e.response) {
      return `Network error: could not reach API at ${baseURL}. Is the backend running and reachable?`;
    }

    const status = e.response.status;
    const data = e.response.data as unknown;
    const msg =
      typeof data === 'object' &&
      data !== null &&
      'message' in data &&
      typeof (data as { message?: unknown }).message === 'string'
        ? (data as { message: string }).message
        : null;
    return msg ? `API error (${status}): ${msg}` : `API error (${status})`;
  }

  if (error instanceof Error) return error.message;
  return 'Unexpected error';
}

const api = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  async (config: InternalAxiosRequestConfig) => {
    const user = auth.currentUser;
    if (user) {
      const token = await user.getIdToken();
      config.headers.set('Authorization', `Bearer ${token}`);
    }
    return config;
  },
  (error: unknown) => {
    return Promise.reject(error);
  }
);

api.interceptors.response.use(
  (response) => {
    // Unwrap NestJS ResponseTransformInterceptor payloads globally
    if (
      response.data &&
      typeof response.data === 'object' &&
      'success' in response.data &&
      'data' in response.data
    ) {
      response.data = response.data.data;
    }
    return response;
  },
  (error) => Promise.reject(error)
);

export default api;
