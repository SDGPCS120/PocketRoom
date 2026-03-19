import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { createUserWithEmailAndPassword } from 'firebase/auth';
import { auth } from '../lib/firebase';
import api, { toUserFacingApiError } from '../lib/api';
import './SellerRegister.css';

interface FormData {
  firstName: string;
  lastName: string;
  email: string;
  password: string;
  confirmPassword: string;
  phone: string;
  storeName: string;
  storeSlug: string;
  storeDescription: string;
  businessRegistrationNumber: string;
}

interface FormErrors {
  [key: string]: string;
}

const generateSlug = (name: string) =>
  name
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-');

const SellerRegister: React.FC = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState<1 | 2>(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);

  const [form, setForm] = useState<FormData>({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
    confirmPassword: '',
    phone: '',
    storeName: '',
    storeSlug: '',
    storeDescription: '',
    businessRegistrationNumber: '',
  });

  const [errors, setErrors] = useState<FormErrors>({});

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>
  ) => {
    const { name, value } = e.target;
    setForm((prev) => {
      const updated = { ...prev, [name]: value };
      // Auto-generate slug from store name
      if (name === 'storeName') {
        updated.storeSlug = generateSlug(value);
      }
      return updated;
    });
    // Clear error on change
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const validateStep1 = (): boolean => {
    const newErrors: FormErrors = {};
    if (!form.firstName.trim()) newErrors.firstName = 'First name is required.';
    if (!form.lastName.trim()) newErrors.lastName = 'Last name is required.';
    if (!form.email.trim()) {
      newErrors.email = 'Email is required.';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) {
      newErrors.email = 'Please enter a valid email address.';
    }
    if (!form.password) {
      newErrors.password = 'Password is required.';
    } else if (form.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters.';
    }
    if (!form.confirmPassword) {
      newErrors.confirmPassword = 'Please confirm your password.';
    } else if (form.password !== form.confirmPassword) {
      newErrors.confirmPassword = 'Passwords do not match.';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const validateStep2 = (): boolean => {
    const newErrors: FormErrors = {};
    if (!form.storeName.trim()) newErrors.storeName = 'Store name is required.';
    if (!form.storeSlug.trim()) {
      newErrors.storeSlug = 'Store URL is required.';
    } else if (!/^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(form.storeSlug)) {
      newErrors.storeSlug =
        'URL can only contain lowercase letters, numbers, and hyphens.';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleNext = () => {
    if (validateStep1()) setStep(2);
  };

  const handleBack = () => setStep(1);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateStep2()) return;

    setIsSubmitting(true);

    try {
      // 1. Create Firebase User
      const userCredential = await createUserWithEmailAndPassword(auth, form.email, form.password);
      const user = userCredential.user;

      // 2. Sync user to Backend database with vendor role
      await api.get('/auth/sync?role=vendor');

      // 3. Create the Store in the Backend
      const storeRes = await api.post('/stores', {
        sellerId: user.uid,
        storeName: form.storeName,
        storeSlug: form.storeSlug,
        storeDescription: form.storeDescription || undefined,
        isActive: true,
      });

      // Maintain a simplified local cache for immediate UI renders if necessary
      const sellerData = {
        uid: user.uid,
        email: user.email,
        username: `${form.firstName} ${form.lastName}`,
        storeName: form.storeName,
        storeId: storeRes.data?.storeId,
      };
      
      localStorage.setItem('currentUser', JSON.stringify(sellerData));
      
      setSuccess(true);
      setTimeout(() => navigate('/dashboard'), 2000);
    } catch (error: unknown) {
      console.error('Registration error:', error);
      setErrors((prev) => ({ ...prev, general: toUserFacingApiError(error) }));
    } finally {
      setIsSubmitting(false);
    }
  };

  if (success) {
    return (
      <div className="register-page">
        <div className="register-card success-card">
          <div className="success-icon">✓</div>
          <h2>Registration Successful!</h2>
          <p>Your seller account has been created. Redirecting to dashboard…</p>
        </div>
      </div>
    );
  }

  return (
    <div className="register-page">
      {/* Left Panel */}
      <div className="register-left">
        <div className="register-brand">
          <div className="brand-logo">PR</div>
          <h1>PocketRoom</h1>
          <p>Seller Portal</p>
        </div>
        <div className="register-features">
          <div className="feature-item">
            <span className="feature-icon">🛍️</span>
            <div>
              <strong>List Your Products</strong>
              <p>Reach thousands of customers looking for unique room decor.</p>
            </div>
          </div>
          <div className="feature-item">
            <span className="feature-icon">📊</span>
            <div>
              <strong>Track Analytics</strong>
              <p>Monitor your sales, views, and revenue in real time.</p>
            </div>
          </div>
          <div className="feature-item">
            <span className="feature-icon">🚀</span>
            <div>
              <strong>Grow Your Business</strong>
              <p>Use AR-powered previews to boost buyer confidence.</p>
            </div>
          </div>
        </div>
      </div>

      {/* Right Panel — Form */}
      <div className="register-right">
        <div className="register-card">
          {/* Step Indicator */}
          <div className="step-indicator">
            <div className={`step-dot ${step >= 1 ? 'active' : ''}`}>
              <span>1</span>
            </div>
            <div className={`step-line ${step === 2 ? 'active' : ''}`} />
            <div className={`step-dot ${step === 2 ? 'active' : ''}`}>
              <span>2</span>
            </div>
          </div>
          <div className="step-labels">
            <span className={step === 1 ? 'label-active' : ''}>
              Personal Info
            </span>
            <span className={step === 2 ? 'label-active' : ''}>
              Store Details
            </span>
          </div>

          <form
            onSubmit={step === 1 ? (e) => { e.preventDefault(); handleNext(); } : handleSubmit}
            noValidate
          >
            {errors.general && (
              <div className="alert-error" role="alert">
                {errors.general}
              </div>
            )}
            {/* ── STEP 1: Personal Info ── */}
            {step === 1 && (
              <div className="form-step">
                <h2>Create Your Account</h2>
                <p className="form-subtitle">
                  Start by entering your personal details.
                </p>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="firstName">
                      First Name <span className="required">*</span>
                    </label>
                    <input
                      type="text"
                      id="firstName"
                      name="firstName"
                      value={form.firstName}
                      onChange={handleChange}
                      placeholder="John"
                      className={errors.firstName ? 'input-error' : ''}
                    />
                    {errors.firstName && (
                      <span className="error-msg">{errors.firstName}</span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="lastName">
                      Last Name <span className="required">*</span>
                    </label>
                    <input
                      type="text"
                      id="lastName"
                      name="lastName"
                      value={form.lastName}
                      onChange={handleChange}
                      placeholder="Doe"
                      className={errors.lastName ? 'input-error' : ''}
                    />
                    {errors.lastName && (
                      <span className="error-msg">{errors.lastName}</span>
                    )}
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="email">
                    Email Address <span className="required">*</span>
                  </label>
                  <input
                    type="email"
                    id="email"
                    name="email"
                    value={form.email}
                    onChange={handleChange}
                    placeholder="john@example.com"
                    className={errors.email ? 'input-error' : ''}
                  />
                  {errors.email && (
                    <span className="error-msg">{errors.email}</span>
                  )}
                </div>

                <div className="form-group">
                  <label htmlFor="phone">Phone Number</label>
                  <input
                    type="tel"
                    id="phone"
                    name="phone"
                    value={form.phone}
                    onChange={handleChange}
                    placeholder="+1 555 000 0000"
                  />
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="password">
                      Password <span className="required">*</span>
                    </label>
                    <input
                      type="password"
                      id="password"
                      name="password"
                      value={form.password}
                      onChange={handleChange}
                      placeholder="Min. 6 characters"
                      className={errors.password ? 'input-error' : ''}
                    />
                    {errors.password && (
                      <span className="error-msg">{errors.password}</span>
                    )}
                  </div>
                  <div className="form-group">
                    <label htmlFor="confirmPassword">
                      Confirm Password <span className="required">*</span>
                    </label>
                    <input
                      type="password"
                      id="confirmPassword"
                      name="confirmPassword"
                      value={form.confirmPassword}
                      onChange={handleChange}
                      placeholder="Repeat password"
                      className={errors.confirmPassword ? 'input-error' : ''}
                    />
                    {errors.confirmPassword && (
                      <span className="error-msg">
                        {errors.confirmPassword}
                      </span>
                    )}
                  </div>
                </div>

                <button type="submit" className="btn-primary btn-full">
                  Continue to Store Details →
                </button>

                <p className="login-link">
                  Already have an account? <Link to="/login">Sign in</Link>
                </p>
              </div>
            )}

            {/* ── STEP 2: Store Details ── */}
            {step === 2 && (
              <div className="form-step">
                <h2>Set Up Your Store</h2>
                <p className="form-subtitle">
                  Tell customers a bit about your store.
                </p>

                <div className="form-group">
                  <label htmlFor="storeName">
                    Store Name <span className="required">*</span>
                  </label>
                  <input
                    type="text"
                    id="storeName"
                    name="storeName"
                    value={form.storeName}
                    onChange={handleChange}
                    placeholder="e.g. Modern Living Co."
                    className={errors.storeName ? 'input-error' : ''}
                  />
                  {errors.storeName && (
                    <span className="error-msg">{errors.storeName}</span>
                  )}
                </div>

                <div className="form-group">
                  <label htmlFor="storeSlug">
                    Store URL <span className="required">*</span>
                  </label>
                  <div className="slug-input-wrapper">
                    <span className="slug-prefix">pocketroom.com/</span>
                    <input
                      type="text"
                      id="storeSlug"
                      name="storeSlug"
                      value={form.storeSlug}
                      onChange={handleChange}
                      placeholder="my-store"
                      className={errors.storeSlug ? 'input-error' : ''}
                    />
                  </div>
                  {errors.storeSlug ? (
                    <span className="error-msg">{errors.storeSlug}</span>
                  ) : (
                    <span className="field-hint">
                      Auto-generated from store name. Lowercase letters, numbers
                      and hyphens only.
                    </span>
                  )}
                </div>

                <div className="form-group">
                  <label htmlFor="storeDescription">
                    Store Description{' '}
                    <span className="optional">(optional)</span>
                  </label>
                  <textarea
                    id="storeDescription"
                    name="storeDescription"
                    value={form.storeDescription}
                    onChange={handleChange}
                    placeholder="Describe your store — what you sell, your style, etc."
                    rows={3}
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="businessRegistrationNumber">
                    Business Registration Number{' '}
                    <span className="optional">(optional)</span>
                  </label>
                  <input
                    type="text"
                    id="businessRegistrationNumber"
                    name="businessRegistrationNumber"
                    value={form.businessRegistrationNumber}
                    onChange={handleChange}
                    placeholder="e.g. BRN-12345678"
                  />
                </div>

                <div className="form-actions">
                  <button
                    type="button"
                    className="btn-secondary"
                    onClick={handleBack}
                  >
                    ← Back
                  </button>
                  <button
                    type="submit"
                    className="btn-primary"
                    disabled={isSubmitting}
                  >
                    {isSubmitting ? (
                      <span className="spinner" />
                    ) : (
                      'Create Seller Account'
                    )}
                  </button>
                </div>
              </div>
            )}
          </form>
        </div>
      </div>
    </div>
  );
};

export default SellerRegister;
