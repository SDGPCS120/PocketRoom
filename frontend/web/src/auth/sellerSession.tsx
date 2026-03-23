import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { onAuthStateChanged, signOut, type User } from 'firebase/auth';
import api from '../lib/api';
import { auth } from '../lib/firebase';

/* eslint-disable react-refresh/only-export-components */
export type SellerSession = {
  firebaseUser: User;
  email: string | null;
  uid: string;
  storeId?: string;
  storeName?: string;
};

type SellerSessionState = {
  status: 'loading' | 'authed' | 'unauthed';
  session: SellerSession | null;
  refreshStore: () => Promise<void>;
  logout: () => Promise<void>;
};

const Ctx = createContext<SellerSessionState | null>(null);

function readCachedSession(): Partial<SellerSession> | null {
  const raw = localStorage.getItem('currentUser');
  if (!raw) return null;
  try {
    return JSON.parse(raw) as Partial<SellerSession>;
  } catch {
    return null;
  }
}

function writeCachedSession(patch: Partial<SellerSession>) {
  const prev = readCachedSession() ?? {};
  localStorage.setItem('currentUser', JSON.stringify({ ...prev, ...patch }));
}

export function SellerSessionProvider({ children }: { children: React.ReactNode }) {
  const [status, setStatus] = useState<SellerSessionState['status']>('loading');
  const [session, setSession] = useState<SellerSession | null>(null);

  const refreshStore = async () => {
    if (!auth.currentUser) return;
    const token = await auth.currentUser.getIdToken(true); // force-refresh token
    const me = await api.get('/stores/me', {
      headers: { Authorization: `Bearer ${token}` },
    });
    const storeId = me.data?.storeId as string | undefined;
    const storeName = me.data?.storeName as string | undefined;
    if (storeId || storeName) {
      writeCachedSession({ storeId, storeName });
      setSession((prev) => (prev ? { ...prev, storeId, storeName } : prev));
    }
  };

  const logout = async () => {
    localStorage.removeItem('currentUser');
    await signOut(auth);
    setSession(null);
    setStatus('unauthed');
  };

  useEffect(() => {
    const unsub = onAuthStateChanged(auth, async (u) => {
      if (!u) {
        setSession(null);
        setStatus('unauthed');
        return;
      }

      const cached = readCachedSession();
      const next: SellerSession = {
        firebaseUser: u,
        uid: u.uid,
        email: u.email,
        storeId: cached?.storeId,
        storeName: cached?.storeName,
      };

      setSession(next);
      setStatus('authed');

      // Best-effort: hydrate store details.
      try {
        if (!next.storeId) await refreshStore();
      } catch {
        // ignore; route-level pages can surface errors
      }
    });

    return () => unsub();
  }, []);

  const value = useMemo<SellerSessionState>(
    () => ({ status, session, refreshStore, logout }),
    [status, session],
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useSellerSession() {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useSellerSession must be used within SellerSessionProvider');
  return ctx;
}

