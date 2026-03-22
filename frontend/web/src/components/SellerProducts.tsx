import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import AppShell from './AppShell';
import './SellerProducts.css';

function WarningIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{color: '#e53e3e'}}><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>; }
function BoxEmptyIcon() { return <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{color: '#9aada0'}}><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/><polyline points="3.27 6.96 12 12.01 20.73 6.96"/><line x1="12" y1="22.08" x2="12" y2="12"/></svg>; }
function SparklesIcon() { return <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', marginRight: '4px', verticalAlign: 'text-bottom' }}><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>; }

interface Product {
  productId: string;
  name: string;
  description: string;
  price: number;
  category: string;
  stock: number;
  dimensions?: { length: number; width: number; height: number };
  modelURL?: string;
  imageUrl?: string[];
}

const SellerProducts: React.FC = () => {
  const navigate = useNavigate();
  const { session } = useSellerSession();
  
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProducts = async () => {
      if (!session) return;

      try {
        let storeId = session.storeId;
        
        // Fallback: If session doesn't have storeId, try fetching it
        if (!storeId) {
          try {
            const storeRes = await api.get('/stores/me');
            storeId = storeRes.data?.storeId;
          } catch (e: unknown) {
            console.error('Could not resolve store:', e);
          }
        }

        if (!storeId) {
          setError('No store is associated with this account. If you just registered, please wait a moment and refresh the page.');
          setIsLoading(false);
          return;
        }

        const response = await api.get(`/products/store/${storeId}`);
        setProducts(response.data);
      } catch (err: unknown) {
        console.error('Failed to load products:', err);
        setError('Failed to load your catalog. Please try again later.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchProducts();
  }, [session?.storeId, session]);

  return (
    <AppShell pageTitle="Store Catalog">
      <div className="seller-products-page">
        <div className="products-actions-bar" style={{ display: 'flex', justifyContent: 'flex-end', marginBottom: '20px' }}>
          <button className="btn-primary" onClick={() => navigate('/add-product')}>
            + Add New Product
          </button>
        </div>

        <div className="products-content">
          {isLoading ? (
            <div className="loading-state">
              <span className="spinner"></span>
              <p>Loading your products...</p>
            </div>
          ) : error ? (
            <div className="empty-state">
               <div className="empty-icon"><WarningIcon /></div>
               <h3>Oops, something went wrong</h3>
               <p>{error}</p>
            </div>
          ) : products.length === 0 ? (
            <div className="empty-state">
              <div className="empty-icon"><BoxEmptyIcon /></div>
              <h3>Your catalog is empty</h3>
              <p>You haven't added any products yet. Start by creating your first listing!</p>
              <button className="btn-primary mt-4" onClick={() => navigate('/add-product')}>
                + Add New Product
              </button>
            </div>
          ) : (
            <div className="products-grid">
              {products.map((product) => (
                <div key={product.productId} className="product-card">
                  <div className="product-image-wrapper">
                    {(product.imageUrl?.[0] || product.modelURL) ? (
                       <img src={product.imageUrl?.[0] || product.modelURL} alt={product.name} className="product-image" 
                            onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }} />
                    ) : (
                      <div className="product-placeholder">No Image Available</div>
                    )}
                    {product.modelURL && <span className="ar-badge"><SparklesIcon /> AR Ready</span>}
                  </div>
                  <div className="product-info">
                    <div className="product-header-row">
                      <span className="product-category">{product.category}</span>
                      <span className="product-price">LKR {Number(product.price).toFixed(2)}</span>
                    </div>
                    <h3 className="product-name">{product.name}</h3>
                    <p className="product-description">{product.description?.substring(0, 60)}{product.description && product.description.length > 60 ? '...' : ''}</p>
                    {product.dimensions && (
                      <div className="product-dimensions">
                        {product.dimensions.width}x{product.dimensions.height}x{product.dimensions.length} cm
                      </div>
                    )}
                  </div>
                  <div className="product-actions">
                    <button 
                      className="btn-sm btn-secondary" 
                      onClick={() => {
                        const targetId = product.productId || (product as any).id;
                        if (targetId) navigate(`/products/${targetId}`);
                        else alert('Error: Product ID not found.');
                      }}
                    >
                      Edit
                    </button>
                    <button className="btn-sm btn-danger" onClick={() => alert('Delete functionality not implemented yet')}>
                      Delete
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
};

export default SellerProducts;
