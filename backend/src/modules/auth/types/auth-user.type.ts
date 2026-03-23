export type AuthUser = {
  uid: string;
  authUid?: string;
  email?: string | null;
  claims?: Record<string, unknown>;
  isAnonymous?: boolean;
};
