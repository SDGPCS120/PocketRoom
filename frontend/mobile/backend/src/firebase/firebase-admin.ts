import * as admin from 'firebase-admin';

let initialized = false;

export function firebaseAdmin() {
  if (!initialized) {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
    });
    initialized = true;
  }
  return admin;
}