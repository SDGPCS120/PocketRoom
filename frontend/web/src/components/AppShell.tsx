import React, { useMemo, useState } from 'react';
import { useNavigate, Link, useLocation } from 'react-router-dom';
import { useSellerSession } from '../auth/sellerSession';
import api from '../lib/api';
import logoUrl from '../assets/logo.png';
import './AppShell.css';

interface Notification {
  id: string;
  text: string;
  time: string;
  read: boolean;
}

function timeAgo(dateString: string) {
  const date = new Date(dateString);
  const seconds = Math.floor((new Date().getTime() - date.getTime()) / 1000);
  let interval = seconds / 86400;
  if (interval >= 1) return Math.floor(interval) + (Math.floor(interval) === 1 ? ' day ago' : ' days ago');
  interval = seconds / 3600;
  if (interval >= 1) return Math.floor(interval) + (Math.floor(interval) === 1 ? ' hr ago' : ' hrs ago');
  interval = seconds / 60;
  if (interval >= 1) return Math.floor(interval) + (Math.floor(interval) === 1 ? ' min ago' : ' mins ago');
  return 'Just now';
}

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

interface AppShellProps {
  children: React.ReactNode;
  pageTitle: string;
}

const AppShell: React.FC<AppShellProps> = ({ children, pageTitle }) => {
  const navigate = useNavigate();
  const location = useLocation();
  const { session, logout } = useSellerSession();
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [notifOpen, setNotifOpen] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);

  React.useEffect(() => {
    const fetchNotifications = async () => {
      let storeId = session?.storeId;
      if (!storeId) return;

      try {
        const res = await api.get(`/orders/store/${storeId}`);
        const orders = res.data || [];
        
        // Sort orders by date descending
        orders.sort((a: any, b: any) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime());
        
        // Map top 4 recent orders to notifications
        const recentNotifs = orders.slice(0, 4).map((order: any) => ({
          id: order.id,
          text: `New order #${order.id.slice(0, 6)} received for Rs. ${Math.round(order.totalAmount).toLocaleString('en-US')}`,
          time: timeAgo(order.createdAt),
          read: false, // In a real app, this would be tracked per user
        }));

        if (recentNotifs.length === 0) {
           setNotifications([{ id: 'welcome', text: 'Welcome to PocketRoom Seller Portal!', time: 'Just now', read: true }]);
        } else {
           setNotifications(recentNotifs);
        }

      } catch (err) {
        console.warn('Failed to fetch orders for notifications', err);
      }
    };
    
    fetchNotifications();
  }, [session?.storeId]);

  const unreadCount = notifications.filter((n) => !n.read).length;

  const user = useMemo(() => {
    if (!session) return null;
    const cached = localStorage.getItem('currentUser');
    const username = cached ? (JSON.parse(cached).username as string | undefined) : undefined;
    return {
      email: session.email ?? '',
      username: username ?? session.storeName ?? session.email ?? 'Seller',
    };
  }, [session]);

  const handleLogout = () => {
    void logout().then(() => navigate('/login'));
  };

  if (!user) return null;

  const initials = user.username
    ? user.username.slice(0, 2).toUpperCase()
    : user.email.slice(0, 2).toUpperCase();

  const getPageDate = () => {
    return new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' });
  };

  return (
    <div className={`db-layout ${sidebarOpen ? 'sidebar-open' : ''}`}>
      {/* ── Sidebar ── */}
      <aside className="db-sidebar">
        <div className="sb-brand">
          <div className="sb-logo">
            <img src={logoUrl} alt="PocketRoom" className="sidebar-logo-img" />
          </div>
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
              className={`sb-link ${location.pathname === link.path || location.pathname.startsWith(link.path + '/') ? 'sb-link--active' : ''}`}
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
              <h1>{pageTitle}</h1>
              <p>{getPageDate()}</p>
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
                  {notifications.map((n) => (
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

        <div className="db-content-area">
          {children}
        </div>
      </div>
    </div>
  );
};

export default AppShell;
