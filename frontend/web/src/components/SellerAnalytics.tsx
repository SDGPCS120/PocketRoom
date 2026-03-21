import React from 'react';
import { Link } from 'react-router-dom';
import './SellerAnalytics.css';

const SellerAnalytics: React.FC = () => {
  return (
    <div className="analytics-page">
      <header className="analytics-header">
        <div>
          <button className="analytics-back">
            <Link to="/dashboard">&larr; Back to dashboard</Link>
          </button>
          <h1>Store analytics</h1>
          <p>
            Understand how your PocketRoom store performs — from visits and conversions
            to top performing rooms and products.
          </p>
        </div>
        <div className="analytics-filters">
          <select defaultValue="7d">
            <option value="24h">Last 24 hours</option>
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="90d">Last 90 days</option>
          </select>
        </div>
      </header>

      <main className="analytics-main">
        <section className="analytics-kpis">
          <div className="analytics-card kpi">
            <span className="kpi-label">Revenue</span>
            <span className="kpi-value">$8,420</span>
            <span className="kpi-trend up">+22.3% vs last period</span>
          </div>
          <div className="analytics-card kpi">
            <span className="kpi-label">Orders</span>
            <span className="kpi-value">126</span>
            <span className="kpi-trend up">+14 orders</span>
          </div>
          <div className="analytics-card kpi">
            <span className="kpi-label">Conversion rate</span>
            <span className="kpi-value">3.2%</span>
            <span className="kpi-trend neutral">Stable</span>
          </div>
          <div className="analytics-card kpi">
            <span className="kpi-label">AR views</span>
            <span className="kpi-value">482</span>
            <span className="kpi-trend up">+31% engagement</span>
          </div>
        </section>

        <section className="analytics-grid">
          <div className="analytics-card chart">
            <div className="chart-header">
              <h2>Revenue over time</h2>
              <span>Simulated sample data</span>
            </div>
            <div className="chart-body">
              <div className="chart-area">
                <div className="chart-bars">
                  <span style={{ height: '35%' }} />
                  <span style={{ height: '52%' }} />
                  <span style={{ height: '46%' }} />
                  <span style={{ height: '68%' }} />
                  <span style={{ height: '74%' }} />
                  <span style={{ height: '90%' }} />
                  <span style={{ height: '60%' }} />
                </div>
              </div>
              <div className="chart-footer">
                <span>Mon</span>
                <span>Tue</span>
                <span>Wed</span>
                <span>Thu</span>
                <span>Fri</span>
                <span>Sat</span>
                <span>Sun</span>
              </div>
            </div>
          </div>

          <div className="analytics-card">
            <div className="chart-header">
              <h2>Top rooms by engagement</h2>
            </div>
            <ul className="rooms-list">
              <li>
                <div>
                  <strong>Scandinavian Living Room</strong>
                  <p>High AR interaction and save-to-wishlist rate.</p>
                </div>
                <span className="room-metric">38% of views</span>
              </li>
              <li>
                <div>
                  <strong>Minimalist Bedroom</strong>
                  <p>Strong late-night browsing and add-to-cart.</p>
                </div>
                <span className="room-metric">26% of views</span>
              </li>
              <li>
                <div>
                  <strong>Workspace Essentials</strong>
                  <p>Consistent weekday performance from remote workers.</p>
                </div>
                <span className="room-metric">19% of views</span>
              </li>
            </ul>
          </div>
        </section>
      </main>
    </div>
  );
};

export default SellerAnalytics;

