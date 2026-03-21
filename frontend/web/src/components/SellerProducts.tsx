import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import './SellerProducts.css';

interface Product {
  productID: string;
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
  const { session, refreshStore } = useSellerSession();
  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        let storeId = session?.storeId;

        if (!storeId) {
          try {
            await refreshStore();
            const cached = localStorage.getItem('currentUser');
            storeId = cached ? (JSON.parse(cached).storeId as string | undefined) : undefined;
          } catch (e) {
            console.error(e);
          }
        }
        
        if (!storeId) {
            setError('No store associated with this account. Please verify your registration.');
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
  }, [refreshStore, session?.storeId]);

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
              <div key={product.productID} className="product-card">
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
                    onClick={() => navigate(`/products/${product.productID}`)}
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
