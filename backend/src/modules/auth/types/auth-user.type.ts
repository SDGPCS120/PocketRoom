export type AuthUser = {
  uid: string;
  email?: string | null;
  claims?: Record<string, any>;
  roles?: string[];
};
