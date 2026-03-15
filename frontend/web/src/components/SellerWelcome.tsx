import React from 'react';
import { Link } from 'react-router-dom';
import './SellerWelcome.css';

const SellerWelcome: React.FC = () => {
  return (
    <div className="welcome-page">
      <div className="welcome-gradient" />

      <header className="welcome-header">
        <div className="welcome-logo">
          <span className="welcome-logo-mark">PR</span>
          <div className="welcome-logo-text">
            <span className="welcome-logo-title">PocketRoom</span>
            <span className="welcome-logo-subtitle">Seller Portal</span>
          </div>
        </div>
        <nav className="welcome-nav">
          <Link to="/login" className="welcome-nav-link">
            Sign in
          </Link>
          <Link to="/register" className="welcome-nav-cta">
            Become a seller
          </Link>
        </nav>
      </header>

      <main className="welcome-main">
        <section className="welcome-hero">
          <div className="welcome-hero-text">
            <h1>
              Welcome to
              <span> PocketRoom Sellers</span>
            </h1>
            <p>
              Turn your rooms, decor and furniture into a thriving online business.
              PocketRoom gives you a modern dashboard, AR-powered previews and
              tools that make selling beautifully simple.
            </p>

            <div className="welcome-actions">
              <Link to="/register" className="welcome-btn welcome-btn-primary">
                Start selling in minutes
              </Link>
              <Link to="/login" className="welcome-btn welcome-btn-ghost">
                I already have an account
              </Link>
            </div>

            <div className="welcome-meta">
              <span>⚡ No setup fees</span>
              <span>•</span>
              <span>Real-time analytics</span>
              <span>•</span>
              <span>Designed for modern sellers</span>
            </div>
          </div>

          <div className="welcome-hero-card">
            <div className="welcome-card-header">
              <span className="welcome-pill">Live preview</span>
              <span className="welcome-dot-group">
                <span />
                <span />
                <span />
              </span>
            </div>

            <div className="welcome-stats-grid">
              <div className="welcome-stat">
                <span className="welcome-stat-label">Today&apos;s revenue</span>
                <span className="welcome-stat-value">$2,430</span>
                <span className="welcome-stat-trend up">+18.4% vs yesterday</span>
              </div>
              <div className="welcome-stat">
                <span className="welcome-stat-label">Active listings</span>
                <span className="welcome-stat-value">48</span>
                <span className="welcome-stat-trend neutral">2 drafts pending</span>
              </div>
            </div>

            <div className="welcome-chart">
              <div className="welcome-chart-bars">
                <span style={{ height: '35%' }} />
                <span style={{ height: '60%' }} />
                <span style={{ height: '50%' }} />
                <span style={{ height: '80%' }} />
                <span style={{ height: '65%' }} />
                <span style={{ height: '90%' }} />
              </div>
              <div className="welcome-chart-footer">
                <span>This week</span>
                <span className="welcome-chip">+32% orders</span>
              </div>
            </div>
          </div>
        </section>

        <section className="welcome-highlights">
          <div className="welcome-highlight">
            <h3>Beautiful product experiences</h3>
            <p>
              Showcase your pieces with high-impact visuals and immersive previews
              that help buyers imagine your products in their own spaces.
            </p>
          </div>
          <div className="welcome-highlight">
            <h3>Built-in insights</h3>
            <p>
              See what&apos;s trending, which rooms convert best, and where your
              buyers are coming from — all from your dashboard.
            </p>
          </div>
          <div className="welcome-highlight">
            <h3>Seller-first tooling</h3>
            <p>
              From bulk uploads to inventory alerts, PocketRoom is designed to
              keep you focused on creating, not juggling spreadsheets.
            </p>
          </div>
        </section>
      </main>
    </div>
  );
};

export default SellerWelcome;

