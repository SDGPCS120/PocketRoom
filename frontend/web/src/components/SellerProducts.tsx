import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import './SellerProducts.css';

interface Product {
  productId: string;
  name: string;
  description: string;
  price: number;
  furnitureType: string;
  imageUrl?: string[];
  images?: string[];
  modelURL?: string;
  storeId: string;
}

const SellerProducts: React.FC = () => {
  const navigate = useNavigate();
  const { session } = useSellerSession();
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        // Always try to resolve storeId — first from session cache, then from the API directly.
        // The session may not have storeId yet due to async hydration timing after login.
        let storeId = session?.storeId;

        if (!storeId) {
          try {
            // Call /stores/me directly (refreshStore also updates session + cache)
            const storeRes = await api.get('/stores/me');
            storeId = storeRes.data?.storeId as string | undefined;
            if (storeId) {
              const storeName = storeRes.data?.storeName as string | undefined;
              const cached = JSON.parse(localStorage.getItem('currentUser') ?? '{}');
              localStorage.setItem('currentUser', JSON.stringify({ ...cached, storeId, storeName }));
            }
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
    // Re-run whenever session.storeId becomes available (e.g., after async hydration)
  }, [session?.storeId]);

  return (
    <div className="seller-products-page">
      <div className="products-header">
        <div className="header-left">
          <button className="back-btn" onClick={() => navigate('/dashboard')}>
            ← Back to Dashboard
          </button>
          <h1>Store Catalog</h1>
          <p>Manage and view all the products listed in your store.</p>
        </div>
        <div className="header-right">
          <button className="btn-primary" onClick={() => navigate('/add-product')}>
            + Add New Product
          </button>
        </div>
      </div>

      <div className="products-content">
        {isLoading ? (
          <div className="loading-state">
            <span className="spinner"></span>
            <p>Loading your products...</p>
          </div>
        ) : error ? (
          <div className="empty-state">
             <div className="empty-icon">⚠</div>
             <h3>Oops, something went wrong</h3>
             <p>{error}</p>
          </div>
        ) : products.length === 0 ? (
          <div className="empty-state">
            <div className="empty-icon">🛋️</div>
            <h3>Your catalog is empty</h3>
            <p>You haven't added any products yet. Start by creating your first listing!</p>
            <button className="btn-primary mt-4" onClick={() => navigate('/add-product')}>
              Add Product
            </button>
          </div>
        ) : (
          <div className="products-grid">
            {products.map((product) => (
              <div key={product.productId} className="product-card">
                <div className="product-image-wrapper">
                  {(product.imageUrl ?? product.images ?? []).length > 0 ? (
                    <img src={(product.imageUrl ?? product.images ?? [])[0]} alt={product.name} className="product-image" />
                  ) : (
                    <div className="product-placeholder">No Image</div>
                  )}
                  {product.modelURL && (
                    <div className="ar-badge">✨ AR Ready</div>
                  )}
                </div>
                <div className="product-info">
                  <span className="product-category">{product.furnitureType}</span>
                  <h3 className="product-name">{product.name}</h3>
                  <p className="product-price">LKR {product.price?.toFixed(2)}</p>
                </div>
                <div className="product-actions">
                  <button
                    className="btn-secondary btn-sm"
                    onClick={() => navigate(`/products/${product.productId}`)}
                  >
                    Edit
                  </button>
                  <button className="btn-danger btn-sm" onClick={() => alert('Delete feature coming soon!')}>Delete</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default SellerProducts;
