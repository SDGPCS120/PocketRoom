import React, { useState, useEffect } from 'react';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import AppShell from './AppShell';
import './SellerAnalytics.css';

interface Order {
  orderId: string;
  totalAmount: number;
  createdAt: string;
  items?: { productName: string; itemTotal?: number; quantity: number }[];
}

interface Product {
  productId: string;
  name: string;
  materials?: string[];
  modelURL?: string;
}

const SellerAnalytics: React.FC = () => {
  const { session } = useSellerSession();
  
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);

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
          const [productsRes, ordersRes] = await Promise.all([
            api.get(`/products/store/${storeId}`).catch(() => ({ data: [] })),
            api.get(`/orders/store/${storeId}`).catch(() => ({ data: [] }))
          ]);
          setProducts(productsRes.data || []);
          setOrders(ordersRes.data || []);
        }
      } catch (err) {
        console.error('Failed to load analytics data', err);
      } finally {
        setIsLoading(false);
      }
    };
    
    fetchData();
  }, [session]);

  const totalRevenue = orders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);
  const totalOrders = orders.length;

  const arProducts = products.filter(p => !!p.modelURL).length;

  // Simple day-of-week revenue aggregation for the chart
  const daysOfWeek = [0, 1, 2, 3, 4, 5, 6];
  const revByDay = daysOfWeek.map(() => 0);
  
  orders.forEach(o => {
    const d = new Date(o.createdAt);
    if (!isNaN(d.getTime())) {
      const dow = d.getDay(); // 0 is Sunday
      // Convert 0=Sun to 0=Mon, 6=Sun
      const adjustedDow = dow === 0 ? 6 : dow - 1;
      revByDay[adjustedDow] += (o.totalAmount || 0);
    }
  });

  const maxDailyRevenue = Math.max(...revByDay, 1); // fallback to 1 to avoid div by zero
  
  // Aggregate revenue by product
  const revByProduct: Record<string, number> = {};
  orders.forEach(o => {
    if (o.items) {
      o.items.forEach(item => {
        const itemRevenue = item.itemTotal || 0;
        revByProduct[item.productName] = (revByProduct[item.productName] || 0) + itemRevenue;
      });
    } else {
      // fallback if no items array exists, just attribute to "Unknown"
      revByProduct['Miscellaneous'] = (revByProduct['Miscellaneous'] || 0) + (o.totalAmount || 0);
    }
  });

  const topProductsList = Object.entries(revByProduct)
    .map(([name, rev]) => ({ name, rev }))
    .sort((a, b) => b.rev - a.rev)
    .slice(0, 3);

  return (
    <AppShell pageTitle="Analytics">
      <div className="analytics-page">
        <header className="analytics-header">
          <div>
            <p>
              Understand how your PocketRoom store performs — from visits and conversions
              to top performing items.
            </p>
          </div>
          <div className="analytics-filters">
            <select defaultValue="all">
              <option value="all">All time</option>
            </select>
          </div>
        </header>

        {isLoading ? (
          <div className="loading-state">
            <span className="spinner"></span>
            <p>Loading your store analytics...</p>
          </div>
        ) : (
          <main className="analytics-main">
            <section className="analytics-kpis">
              <div className="analytics-card kpi">
                <span className="kpi-label">Revenue</span>
                <span className="kpi-value">${totalRevenue.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</span>
                <span className="kpi-trend neutral">All time total</span>
              </div>
              <div className="analytics-card kpi">
                <span className="kpi-label">Orders</span>
                <span className="kpi-value">{totalOrders}</span>
                <span className="kpi-trend neutral">All time total</span>
              </div>
              <div className="analytics-card kpi">
                <span className="kpi-label">Conversion rate</span>
                <span className="kpi-value">-- %</span>
                <span className="kpi-trend neutral">Coming soon</span>
              </div>
              <div className="analytics-card kpi">
                <span className="kpi-label">AR Ready Products</span>
                <span className="kpi-value">{arProducts}</span>
                <span className="kpi-trend up">{products.length ? Math.round((arProducts / products.length) * 100) : 0}% of catalog</span>
              </div>
            </section>

            <section className="analytics-grid">
              <div className="analytics-card chart">
                <div className="chart-header">
                  <h2>Revenue by Day of Week</h2>
                  <span>All time sales breakdown</span>
                </div>
                <div className="chart-body">
                  <div className="chart-area">
                    <div className="chart-bars">
                      {revByDay.map((rev, i) => (
                        <span key={i} style={{ height: `${Math.max(5, (rev / maxDailyRevenue) * 100)}%` }} title={`$${rev.toFixed(2)}`} />
                      ))}
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
                  <h2>Top Products by Revenue</h2>
                </div>
                {topProductsList.length === 0 ? (
                  <div style={{ textAlign: 'center', color: '#757575', padding: '30px', fontStyle: 'italic', fontSize: '13px' }}>
                    No product revenue data yet.
                  </div>
                ) : (
                  <ul className="products-list">
                    {topProductsList.map((p, i) => (
                      <li key={i}>
                        <div>
                          <strong>{p.name}</strong>
                          <p>Popular choice</p>
                        </div>
                        <span className="product-metric">${p.rev.toLocaleString()}</span>
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            </section>
          </main>
        )}
      </div>
    </AppShell>
  );
};

export default SellerAnalytics;

