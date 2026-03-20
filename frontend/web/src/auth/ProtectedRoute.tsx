import React from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { useSellerSession } from './sellerSession';

export default function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { status } = useSellerSession();
  const location = useLocation();

  if (status === 'loading') return null;
  if (status === 'unauthed') {
    return <Navigate to="/login" replace state={{ from: location.pathname }} />;
  }

  return <>{children}</>;
}

