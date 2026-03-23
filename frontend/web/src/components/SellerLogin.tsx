import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../lib/firebase';
import api, { toUserFacingApiError } from '../lib/api';
import logoUrl from '../assets/logo.png';
import './SellerLogin.css';

const SellerLogin: React.FC = () => {
  const navigate = useNavigate();

  const [email, setEmail] = useState(() => {
    // Pre-fill from registration if present
    const reg = localStorage.getItem('sellerRegistration');
    if (reg) {
      try {
        const data = JSON.parse(reg) as { email?: string };
        if (data.email) return data.email;
      } catch {
        // ignore
      }
    }
    // Restore "remember me" email
    const remembered = localStorage.getItem('sellerRememberedEmail');
    return remembered ?? '';
  });
  const [password, setPassword] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState<{ email?: string; password?: string; general?: string }>({});

  const validate = (): boolean => {
    const newErrors: typeof errors = {};
    if (!email.trim()) {
      newErrors.email = 'Email is required.';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = 'Please enter a valid email address.';
    }
    if (!password) {
      newErrors.password = 'Password is required.';
    } else if (password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters.';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;

    setIsLoading(true);
    setErrors({});

    try {
      // 1. Authenticate with Firebase
      const userCredential = await signInWithEmailAndPassword(auth, email, password);
      const user = userCredential.user;

      // 2. Fetch store information from backend (optional enhancement for UI)
      let storeName = email.split('@')[0];
      let storeId = undefined;
      try {
        const response = await api.get('/stores/me');
        if (response.data) {
           storeName = response.data.storeName || storeName;
           storeId = response.data.storeId;
        }
      } catch (storeError) {
        console.warn('Store profile not found or error fetching:', storeError);
      }

      if (rememberMe) {
        localStorage.setItem('sellerRememberedEmail', email);
      } else {
        localStorage.removeItem('sellerRememberedEmail');
      }

      const session = {
        uid: user.uid,
        email: user.email,
        username: storeName,
        storeId: storeId,
        loggedInAt: new Date().toISOString(),
      };
      
      localStorage.setItem('currentUser', JSON.stringify(session));
      navigate('/dashboard');
    } catch (error: unknown) {
      console.error('Login error:', error);
      // Firebase auth errors are usually credential-related; axios errors are connectivity/CORS/back-end.
      const message = toUserFacingApiError(error);
      setErrors({ general: message.includes('API error') || message.includes('Network error') ? message : 'Invalid email or password. Please try again.' });
    }

    setIsLoading(false);
  };

  return (
    <div className="login-page">
      <div className="login-left">
        <div className="login-brand">
          <img src={logoUrl} alt="PocketRoom" className="login-logo-img" />
          <div>
            <h1>PocketRoom</h1>
            <p>Seller Portal</p>
          </div>
        </div>

        <div className="login-illustration">
          <div className="illu-circle illu-circle--1" />
          <div className="illu-circle illu-circle--2" />
          <div className="illu-circle illu-circle--3" />
          <div className="illu-card">
            <div className="illu-card__row">
              <span className="illu-dot" />
              <span className="illu-bar illu-bar--long" />
            </div>
            <div className="illu-card__row">
              <span className="illu-dot" />
              <span className="illu-bar illu-bar--medium" />
            </div>
            <div className="illu-card__row">
              <span className="illu-dot" />
              <span className="illu-bar illu-bar--short" />
            </div>
            <div className="illu-chart">
              <span className="illu-bar-v" style={{ height: '40%' }} />
              <span className="illu-bar-v" style={{ height: '65%' }} />
              <span className="illu-bar-v" style={{ height: '55%' }} />
              <span className="illu-bar-v" style={{ height: '80%' }} />
              <span className="illu-bar-v" style={{ height: '70%' }} />
            </div>
          </div>
        </div>

        <p className="login-tagline">
          "Manage your products, track your sales,<br />
          and grow your store — all in one place."
        </p>
      </div>

      {/* Right: Login form */}
      <div className="login-right">
        <div className="login-card">
          <div className="login-header">
            <h2>Welcome back</h2>
            <p>Sign in to your seller account to continue.</p>
          </div>

          {errors.general && (
            <div className="alert-error" role="alert">
              <span className="alert-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg></span>
              {errors.general}
            </div>
          )}

          <form onSubmit={handleSubmit} noValidate>
            {/* Email */}
            <div className="form-group">
              <label htmlFor="email">Email Address</label>
              <div className={`input-wrapper ${errors.email ? 'input-wrapper--error' : ''}`}>
                <span className="input-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/>
                    <polyline points="22,6 12,13 2,6"/>
                  </svg>
                </span>
                <input
                  type="email"
                  id="email"
                  value={email}
                  onChange={(e) => { setEmail(e.target.value); if (errors.email) setErrors(p => ({ ...p, email: '' })); }}
                  placeholder="you@example.com"
                  autoComplete="email"
                />
              </div>
              {errors.email && <span className="error-msg">{errors.email}</span>}
            </div>

            {/* Password */}
            <div className="form-group">
              <div className="label-row">
                <label htmlFor="password">Password</label>
                <a href="#" className="forgot-link" onClick={(e) => e.preventDefault()}>
                  Forgot password?
                </a>
              </div>
              <div className={`input-wrapper ${errors.password ? 'input-wrapper--error' : ''}`}>
                <span className="input-icon">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                  </svg>
                </span>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  value={password}
                  onChange={(e) => { setPassword(e.target.value); if (errors.password) setErrors(p => ({ ...p, password: '' })); }}
                  placeholder="Your password"
                  autoComplete="current-password"
                />
                <button
                  type="button"
                  className="toggle-password"
                  onClick={() => setShowPassword((v) => !v)}
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                      <line x1="1" y1="1" x2="23" y2="23"/>
                    </svg>
                  ) : (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                      <circle cx="12" cy="12" r="3"/>
                    </svg>
                  )}
                </button>
              </div>
              {errors.password && <span className="error-msg">{errors.password}</span>}
            </div>

            {/* Remember me */}
            <div className="remember-row">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  id="rememberMe"
                />
                <span className="checkbox-custom" />
                Remember me
              </label>
            </div>

            <button type="submit" className="btn-login" disabled={isLoading} id="loginBtn">
              {isLoading ? <span className="spinner" /> : 'Sign In to Dashboard'}
            </button>
          </form>

          <div className="login-divider">
            <span>New to PocketRoom?</span>
          </div>

          <Link to="/register" className="btn-register">
            Create a Seller Account
          </Link>
        </div>
      </div>
    </div>
  );
};

export default SellerLogin;
