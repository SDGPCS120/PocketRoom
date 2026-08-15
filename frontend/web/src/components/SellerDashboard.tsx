import React, { useState, useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import { getMockOrders, getMockProducts } from '../lib/mockData';
import AppShell from './AppShell';
import './SellerDashboard.css';

/* ─── Types ─── */
interface Order {
  orderId: string;
  customerId: string;
  orderStatus: string;
  totalAmount: number;
  createdAt: string;
  items?: { productName: string }[];
}

interface Product {
  productId: string;
  name: string;
  materials?: string[];
}

/* ─── Icon components (SVGs replacing emojis) ─── */
function BoxIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>; }
function ChartIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/><line x1="2" y1="20" x2="22" y2="20"/></svg>; }
function TagIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"/><line x1="7" y1="7" x2="7.01" y2="7"/></svg>; }
function TruckIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="1" y="3" width="15" height="13"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>; }
function MessageIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>; }
function SettingsIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>; }

const statusColor: Record<string, string> = {
  DELIVERED:  'status--delivered',
  PROCESSING: 'status--processing',
  SHIPPED:    'status--shipped',
  CANCELLED:  'status--cancelled',
  PENDING_PAYMENT: 'status--processing',
};

const SellerDashboard: React.FC = () => {
  const { session } = useSellerSession();
  
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const user = useMemo(() => {
    if (!session) return null;
    const cached = localStorage.getItem('currentUser');
    const username = cached ? (JSON.parse(cached).username as string | undefined) : undefined;
    return {
      email: session.email ?? '',
      username: username ?? session.storeName ?? 'Seller',
    };
  }, [session]);

  useEffect(() => {
    const fetchData = async () => {
      setIsLoading(true);
      try {
        let storeId = session?.storeId;
        if (!storeId) {
          try {
            const storeRes = await api.get('/stores/me');
            storeId = storeRes.data?.storeId;
          } catch (e) {
            console.warn('Could not fetch store', e);
          }
        }

        if (storeId) {
          if (session?.email === 'arpico_vendor@test.com') {
            setProducts(getMockProducts());
            setOrders(getMockOrders());
          } else {
            const [productsRes, ordersRes] = await Promise.all([
              api.get(`/products/store/${storeId}`).catch(() => ({ data: [] })),
              api.get(`/orders/store/${storeId}`).catch(() => ({ data: [] }))
            ]);
            setProducts(productsRes.data || []);
            setOrders(ordersRes.data || []);
          }
        }
      } catch (err) {
        console.error('Failed to load dashboard data', err);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchData();
  }, [session]);

  if (!user) return null;

  // Compute KPIs
  const totalRevenue = orders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);
  const totalOrders = orders.length;
  const activeProducts = products.length;

  if (isLoading) {
    return (
      <AppShell pageTitle="Dashboard">
        <div className="db-content" style={{ display: 'flex', justifyContent: 'center', paddingTop: '4rem' }}>
          <span className="spinner" style={{ width: '40px', height: '40px', borderWidth: '3px', borderColor: 'rgba(210,107,25,0.2)', borderTopColor: '#d26b19' }} />
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell pageTitle="Dashboard">
      <div className="db-content">
        {/* Welcome banner */}
        <div className="welcome-banner">
          <div>
            <h2>Welcome back, {user.username}!</h2>
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
              <span className="kpi-value">${totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
              <span className="kpi-change kpi-change--neutral">Based on all orders</span>
            </div>
          </div>

          <div className="kpi-card">
            <div className="kpi-icon kpi-icon--orders">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
            </div>
            <div className="kpi-body">
              <span className="kpi-label">Total Orders</span>
              <span className="kpi-value">{totalOrders}</span>
              <span className="kpi-change kpi-change--neutral">All time</span>
            </div>
          </div>

          <div className="kpi-card">
            <div className="kpi-icon kpi-icon--products">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
            </div>
            <div className="kpi-body">
              <span className="kpi-label">Active Products</span>
              <span className="kpi-value">{activeProducts}</span>
              <span className="kpi-change kpi-change--neutral">Available in catalog</span>
            </div>
          </div>

          <div className="kpi-card">
            <div className="kpi-icon kpi-icon--rating">
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
            </div>
            <div className="kpi-body">
              <span className="kpi-label">Store Rating</span>
              <span className="kpi-value">-- ★</span>
              <span className="kpi-change kpi-change--neutral">Coming soon</span>
            </div>
          </div>
        </div>

        {/* Orders + Actions row */}
        <div className="db-row">
          {/* Recent Orders */}
          <div className="db-card db-card--wide">
            <div className="card-header">
              <h3>Recent Orders</h3>
              {orders.length > 0 && <button className="btn-text">View all →</button>}
            </div>
            <div className="table-scroll">
              <table className="orders-table">
                <thead>
                  <tr>
                    <th>Order ID</th>
                    <th>Product</th>
                    <th>Date</th>
                    <th>Amount</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {orders.length === 0 ? (
                    <tr>
                      <td colSpan={5} className="empty-message">No orders yet. They will appear here when customers buy your products.</td>
                    </tr>
                  ) : (
                    orders.slice(0, 8).map((o) => (
                      <tr key={o.orderId}>
                        <td className="order-id">#{o.orderId.substring(0, 8).toUpperCase()}</td>
                        <td className="order-product">{o.items?.[0]?.productName || 'Multiple Items'}</td>
                        <td className="order-date">{new Date(o.createdAt).toLocaleDateString()}</td>
                        <td className="order-amount">${(o.totalAmount || 0).toFixed(2)}</td>
                        <td>
                          <span className={`status-badge ${statusColor[o.orderStatus] || 'status--processing'}`}>
                            {o.orderStatus.replace('_', ' ')}
                          </span>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>

          {/* Quick Actions */}
          <div className="db-card db-card--narrow">
            <div className="card-header">
              <h3>Quick Actions</h3>
            </div>
            <div className="quick-actions">
              <Link to="/add-product" className="qa-btn">
                <span className="qa-icon"><BoxIcon /></span>
                <span>Add Product</span>
              </Link>
              <Link to="/analytics" className="qa-btn">
                <span className="qa-icon"><ChartIcon /></span>
                <span>View Analytics</span>
              </Link>
              <button className="qa-btn">
                <span className="qa-icon"><TagIcon /></span>
                <span>Manage Pricing</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon"><TruckIcon /></span>
                <span>Track Shipments</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon"><MessageIcon /></span>
                <span>Customer Messages</span>
              </button>
              <button className="qa-btn">
                <span className="qa-icon"><SettingsIcon /></span>
                <span>Store Settings</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </AppShell>
  );
};

export default SellerDashboard;
