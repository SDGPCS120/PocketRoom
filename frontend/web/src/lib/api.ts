import axios from 'axios';
import { auth } from './firebase';

const baseURL = import.meta.env.VITE_API_URL || 'https://pocketroom-backend-nm5z3yxdra-el.a.run.app';

const api = axios.create({
  baseURL,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use(
  async (config) => {
    const user = auth.currentUser;
    if (user) {
      const token = await user.getIdToken();
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

export default api;
