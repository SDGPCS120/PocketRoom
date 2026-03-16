import React, { useEffect, useState } from 'react';
import { useNavigate, Link, useLocation } from 'react-router-dom';
import './SellerDashboard.css';

/* ─── Types ─── */
interface Order {
  id: string;
  customer: string;
  product: string;
  date: string;
  amount: number;
  status: 'Delivered' | 'Processing' | 'Shipped' | 'Cancelled';
}

interface Notification {
  id: number;
  text: string;
  time: string;
  read: boolean;
}

/* ─── Mock data ─── */
const ORDERS: Order[] = [
  { id: '#ORD-4821', customer: 'Sarah Johnson', product: 'Modern Lounge Chair', date: 'Mar 11, 2026', amount: 349.00, status: 'Delivered' },
  { id: '#ORD-4820', customer: 'David Lee',     product: 'Scandinavian Shelf Unit', date: 'Mar 10, 2026', amount: 189.50, status: 'Shipped' },
  { id: '#ORD-4819', customer: 'Priya Mehta',   product: 'Velvet Accent Chair',     date: 'Mar 10, 2026', amount: 420.00, status: 'Processing' },
  { id: '#ORD-4818', customer: 'Tom Walker',    product: 'Oak Dining Table',        date: 'Mar 9, 2026',  amount: 899.99, status: 'Delivered' },
  { id: '#ORD-4817', customer: 'Aisha Kamara',  product: 'Marble Coffee Table',     date: 'Mar 9, 2026',  amount: 560.00, status: 'Cancelled' },
  { id: '#ORD-4816', customer: 'James Patel',   product: 'Wicker Floor Lamp',       date: 'Mar 8, 2026',  amount: 135.00, status: 'Shipped' },
];

const NOTIFICATIONS: Notification[] = [
  { id: 1, text: 'New order #ORD-4821 received', time: '2 min ago', read: false },
  { id: 2, text: 'Product "Velvet Chair" is low on stock', time: '1 hr ago', read: false },
  { id: 3, text: 'Your payout of $1,240 was processed', time: '3 hrs ago', read: true },
  { id: 4, text: 'New 5★ review on "Oak Dining Table"', time: 'Yesterday', read: true },
];

const TOP_PRODUCTS = [
  { name: 'Oak Dining Table',       sales: 38, revenue: 34199 },
  { name: 'Modern Lounge Chair',    sales: 54, revenue: 18846 },
  { name: 'Scandinavian Shelf Unit',sales: 29, revenue: 5496  },
  { name: 'Marble Coffee Table',    sales: 21, revenue: 11760 },
];

const statusColor: Record<Order['status'], string> = {
  Delivered:  'status--delivered',
  Processing: 'status--processing',
  Shipped:    'status--shipped',
  Cancelled:  'status--cancelled',
};

/* ─── Sidebar links ─── */
const NAV_LINKS = [
  { path: '/dashboard',        label: 'Dashboard',       icon: <GridIcon /> },
  { path: '/products',         label: 'Store Catalog',   icon: <BoxIcon /> },
  { path: '/analytics',        label: 'Analytics',       icon: <ChartIcon /> },
  { path: '/add-product',      label: 'Upload Product',  icon: <UploadIcon /> },
];

/* ─── Icon components ─── */
function GridIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
      <rect x="3" y="14" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/>
    </svg>
  );
}
function ChartIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/>
      <line x1="6" y1="20" x2="6" y2="14"/><line x1="2" y1="20" x2="22" y2="20"/>
    </svg>
  );
}
function UploadIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
      <polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/>
    </svg>
  );
}
function BoxIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/>
      <polyline points="3.27 6.96 12 12.01 20.73 6.96"/>
      <line x1="12" y1="22.08" x2="12" y2="12"/>
    </svg>
  );
}
function BellIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
      <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
    </svg>
  );
}

/* ─── Component ─── */
const SellerDashboard: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [user, setUser] = useState<{ email: string; username: string } | null>(null);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const unreadCount = NOTIFICATIONS.filter((n) => !n.read).length;

  useEffect(() => {
    const session = localStorage.getItem('currentUser');
    if (!session) { navigate('/login'); return; }
    setUser(JSON.parse(session));
  }, [navigate]);

  const handleLogout = () => {
    localStorage.removeItem('currentUser');
    navigate('/login');
  };

  if (!user) return null;

  const initials = user.username
    ? user.username.slice(0, 2).toUpperCase()
    : user.email.slice(0, 2).toUpperCase();

  return (
    <div className={`db-layout ${sidebarOpen ? 'sidebar-open' : ''}`}>
      {/* ── Sidebar ── */}
      <aside className="db-sidebar">
        <div className="sb-brand">
          <div className="sb-logo">PR</div>
          <div>
            <span className="sb-name">PocketRoom</span>
            <span className="sb-role">Seller Portal</span>
          </div>
        </div>

        <nav className="sb-nav">
          <p className="sb-section-label">Main Menu</p>
          {NAV_LINKS.map((link) => (
            <Link
              key={link.path}
              to={link.path}
              className={`sb-link ${location.pathname === link.path ? 'sb-link--active' : ''}`}
              onClick={() => setSidebarOpen(false)}
            >
              <span className="sb-link-icon">{link.icon}</span>
              {link.label}
            </Link>
          ))}
        </nav>

        <div className="sb-bottom">
          <div className="sb-user-card">
            <div className="sb-avatar">{initials}</div>
            <div className="sb-user-info">
              <span className="sb-user-name">{user.username}</span>
              <span className="sb-user-email">{user.email}</span>
            </div>
          </div>
          <button className="sb-logout" onClick={handleLogout}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
            Sign Out
          </button>
        </div>
      </aside>

      {sidebarOpen && <div className="sb-overlay" onClick={() => setSidebarOpen(false)} />}

      {/* ── Main ── */}
      <div className="db-main">
        {/* Top bar */}
        <header className="db-topbar">
          <div className="topbar-left">
            <button className="hamburger" onClick={() => setSidebarOpen((v) => !v)} aria-label="Toggle sidebar">
              <span /><span /><span />
            </button>
            <div className="topbar-title">
              <h1>Dashboard</h1>
              <p>Tuesday, March 11, 2026</p>
            </div>
          </div>
          <div className="topbar-right">
            <div className="notif-wrapper">
              <button className="icon-btn" onClick={() => setNotifOpen((v) => !v)} aria-label="Notifications">
                <BellIcon />
                {unreadCount > 0 && <span className="notif-badge">{unreadCount}</span>}
              </button>
              {notifOpen && (
                <div className="notif-dropdown">
                  <div className="notif-header">
                    <strong>Notifications</strong>
                    <span className="notif-count">{unreadCount} new</span>
                  </div>
                  {NOTIFICATIONS.map((n) => (
                    <div key={n.id} className={`notif-item ${!n.read ? 'notif-item--unread' : ''}`}>
                      {!n.read && <span className="notif-dot" />}
                      <div>
                        <p>{n.text}</p>
                        <span>{n.time}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
            <div className="topbar-avatar">{initials}</div>
          </div>
        </header>

        <div className="db-content">
          {/* Welcome banner */}
          <div className="welcome-banner">
            <div>
              <h2>Welcome back, {user.username}! 👋</h2>
              <p>Here's what's happening with your store today.</p>
            </div>
            <Link to="/add-product" className="btn-add-product">
              + Add New Product
            </Link>
          </div>

          {/* KPI Cards */}
          <div className="kpi-grid">
            <div className="kpi-card">
              <div className="kpi-icon kpi-icon--revenue">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><line x1="12" y1="1" x2="12" y2="23"/><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/></svg>
              </div>
              <div className="kpi-body">
                <span className="kpi-label">Total Revenue</span>
                <span className="kpi-value">$24,390</span>
                <span className="kpi-change kpi-change--up">↑ 12.5% this month</span>
              </div>
            </div>

            <div className="kpi-card">
              <div className="kpi-icon kpi-icon--orders">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
              </div>
              <div className="kpi-body">
                <span className="kpi-label">Total Orders</span>
                <span className="kpi-value">142</span>
                <span className="kpi-change kpi-change--up">↑ 8.1% this month</span>
              </div>
            </div>

            <div className="kpi-card">
              <div className="kpi-icon kpi-icon--products">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
              </div>
              <div className="kpi-body">
                <span className="kpi-label">Active Products</span>
                <span className="kpi-value">36</span>
                <span className="kpi-change kpi-change--neutral">→ 2 added this week</span>
              </div>
            </div>

            <div className="kpi-card">
              <div className="kpi-icon kpi-icon--rating">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
              </div>
              <div className="kpi-body">
                <span className="kpi-label">Store Rating</span>
                <span className="kpi-value">4.8 ★</span>
                <span className="kpi-change kpi-change--up">↑ from 4.6 last month</span>
              </div>
            </div>
          </div>

          {/* Orders + Top Products row */}
          <div className="db-row">
            {/* Recent Orders */}
            <div className="db-card db-card--wide">
              <div className="card-header">
                <h3>Recent Orders</h3>
                <button className="btn-text">View all →</button>
              </div>
              <div className="table-scroll">
                <table className="orders-table">
                  <thead>
                    <tr>
                      <th>Order ID</th>
                      <th>Customer</th>
                      <th>Product</th>
                      <th>Date</th>
                      <th>Amount</th>
                      <th>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    {ORDERS.map((o) => (
                      <tr key={o.id}>
                        <td className="order-id">{o.id}</td>
                        <td>{o.customer}</td>
                        <td className="order-product">{o.product}</td>
                        <td className="order-date">{o.date}</td>
                        <td className="order-amount">${o.amount.toFixed(2)}</td>
                        <td>
                          <span className={`status-badge ${statusColor[o.status]}`}>
                            {o.status}
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            {/* Top Products */}
            <div className="db-card db-card--narrow">
              <div className="card-header">
                <h3>Top Products</h3>
                <button className="btn-text">See all →</button>
              </div>
              <div className="top-products">
                {TOP_PRODUCTS.map((p, i) => {
                  const maxRevenue = Math.max(...TOP_PRODUCTS.map((x) => x.revenue));
                  const pct = Math.round((p.revenue / maxRevenue) * 100);
                  return (
                    <div className="tp-item" key={p.name}>
                      <span className="tp-rank">#{i + 1}</span>
                      <div className="tp-info">
                        <span className="tp-name">{p.name}</span>
                        <div className="tp-bar-track">
                          <div className="tp-bar-fill" style={{ width: `${pct}%` }} />
                        </div>
                        <div className="tp-meta">
                          <span>{p.sales} sold</span>
                          <span>${p.revenue.toLocaleString()}</span>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="db-card">
            <div className="card-header">
              <h3>Quick Actions</h3>
            </div>
            <div className="quick-actions">
              <Link to="/add-product" className="qa-btn">
                <span className="qa-icon">📦</span>
                <span>Add Product</span>
              </Link>
              <Link to="/analytics" className="qa-btn">
                <span className="qa-icon">📊</span>
                <span>View Analytics</span>
              </Link>
              <button className="qa-btn">
                <span className="qa-icon">🏷️</span>
                <span>Manage Pricing</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon">🚚</span>
                <span>Track Shipments</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon">💬</span>
                <span>Customer Messages</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon">⚙️</span>
                <span>Store Settings</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SellerDashboard;
