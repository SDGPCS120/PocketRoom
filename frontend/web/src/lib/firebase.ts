import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getStorage } from 'firebase/storage';

// Use environment variables for flexibility, falling back to discovered values
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "AIzaSyCqpQLCadDl71NTcRRTohJccNLKiYipGSQ",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "pocketroom-80f62.firebaseapp.com",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "pocketroom-80f62",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "pocketroom-80f62.firebasestorage.app",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "93470454666",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "",
};

export const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const storage = getStorage(app);
