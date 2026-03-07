export type AuthUser = {
  uid: string;
  email?: string | null;
  claims?: Record<string, unknown>;
  isAnonymous?: boolean;
};
