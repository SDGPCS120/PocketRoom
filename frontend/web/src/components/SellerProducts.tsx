import React, { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import { CATEGORIES } from '../constants/categories';
import AppShell from './AppShell';
import ConfirmDialog from './ConfirmDialog';
import EmptyState from './EmptyState';
import { useToast } from './Toast';
import './SellerProducts.css';

function WarningIcon() {
  return (
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ color: '#e53e3e' }}>
      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
      <line x1="12" y1="9" x2="12" y2="13" />
      <line x1="12" y1="17" x2="12.01" y2="17" />
    </svg>
  );
}

function BoxEmptyIcon() {
  return (
    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ color: '#9aada0' }}>
      <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z" />
      <polyline points="3.27 6.96 12 12.01 20.73 6.96" />
      <line x1="12" y1="22.08" x2="12" y2="12" />
    </svg>
  );
}

function SparklesIcon() {
  return (
    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', marginRight: '4px', verticalAlign: 'text-bottom' }}>
      <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
    </svg>
  );
}

interface Product {
  productId: string;
  id?: string;
  name: string;
  description: string;
  price: number;
  furnitureType: string;
  stock: number;
  dimensions?: { length: number; width: number; height: number };
  materials?: string[];
  modelURL?: string;
  imageUrl?: string[];
  createdAt?: string;
}

type SortOption = 'name-asc' | 'price-asc' | 'price-desc' | 'newest';

const SellerProducts: React.FC = () => {
  const navigate = useNavigate();
  const { session } = useSellerSession();
  const { showToast } = useToast();

  const [products, setProducts] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const [search, setSearch] = useState('');
  const [categoryFilter, setCategoryFilter] = useState('all');
  const [sortBy, setSortBy] = useState<SortOption>('name-asc');

  const [deleteTarget, setDeleteTarget] = useState<Product | null>(null);
  const [isDeleting, setIsDeleting] = useState(false);

  useEffect(() => {
    const fetchProducts = async () => {
      if (!session) return;

      try {
        let storeId = session.storeId;

        if (!storeId) {
          try {
            const storeRes = await api.get('/stores/me');
            storeId = storeRes.data?.storeId;
          } catch (e: unknown) {
            console.error('Could not resolve store:', e);
          }
        }

        if (!storeId) {
          setError(
            'No store is associated with this account. If you just registered, please wait a moment and refresh the page.',
          );
          setIsLoading(false);
          return;
        }

        const response = await api.get(`/products/store/${storeId}`);
        setProducts(Array.isArray(response.data) ? response.data : []);
      } catch (err: unknown) {
        console.error('Failed to load products:', err);
        setError('Failed to load your catalog. Please try again later.');
      } finally {
        setIsLoading(false);
      }
    };

    fetchProducts();
  }, [session?.storeId, session]);

  const filteredProducts = useMemo(() => {
    const q = search.trim().toLowerCase();

    let list = products.filter((p) => {
      if (categoryFilter !== 'all' && p.furnitureType !== categoryFilter) return false;
      if (!q) return true;
      const haystack = [
        p.name,
        p.description,
        p.furnitureType,
        ...(p.materials ?? []),
      ]
        .filter(Boolean)
        .join(' ')
        .toLowerCase();
      return haystack.includes(q);
    });

    list = [...list].sort((a, b) => {
      switch (sortBy) {
        case 'price-asc':
          return a.price - b.price;
        case 'price-desc':
          return b.price - a.price;
        case 'newest': {
          const da = a.createdAt ? new Date(a.createdAt).getTime() : 0;
          const db = b.createdAt ? new Date(b.createdAt).getTime() : 0;
          if (da || db) return db - da;
          return a.name.localeCompare(b.name);
        }
        case 'name-asc':
        default:
          return a.name.localeCompare(b.name);
      }
    });

    return list;
  }, [products, search, categoryFilter, sortBy]);

  const productIdOf = (p: Product) => p.productId || p.id || '';

  const handleConfirmDelete = async () => {
    if (!deleteTarget) return;
    const targetId = productIdOf(deleteTarget);
    if (!targetId) {
      showToast('Error: Product ID not found.', 'error');
      setDeleteTarget(null);
      return;
    }

    setIsDeleting(true);
    try {
      await api.delete(`/products/${targetId}`);
      setProducts((prev) =>
        prev.filter((p) => productIdOf(p) !== targetId),
      );
      showToast(`"${deleteTarget.name}" was deleted.`, 'success');
      setDeleteTarget(null);
    } catch (err) {
      console.error('Failed to delete product:', err);
      showToast('Failed to delete product. Please try again.', 'error');
    } finally {
      setIsDeleting(false);
    }
  };

  return (
    <AppShell pageTitle="Store Catalog">
      <div className="seller-products-page">
        {!isLoading && !error && products.length > 0 && (
          <div className="products-toolbar">
            <div className="products-toolbar-left">
              <span className="products-count">
                {filteredProducts.length === products.length
                  ? `${products.length} product${products.length === 1 ? '' : 's'}`
                  : `${filteredProducts.length} of ${products.length} products`}
              </span>
              <input
                type="search"
                className="products-search"
                placeholder="Search products…"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                aria-label="Search products"
              />
              <select
                className="products-filter"
                value={categoryFilter}
                onChange={(e) => setCategoryFilter(e.target.value)}
                aria-label="Filter by category"
              >
                <option value="all">All categories</option>
                {CATEGORIES.map((c) => (
                  <option key={c} value={c}>
                    {c}
                  </option>
                ))}
              </select>
              <select
                className="products-filter"
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as SortOption)}
                aria-label="Sort products"
              >
                <option value="name-asc">Name A→Z</option>
                <option value="price-asc">Price: Low → High</option>
                <option value="price-desc">Price: High → Low</option>
                <option value="newest">Newest first</option>
              </select>
            </div>
            <button className="btn-primary" onClick={() => navigate('/add-product')}>
              + Add New Product
            </button>
          </div>
        )}

        {(!isLoading && !error && products.length === 0) || isLoading || error ? (
          <div className="products-actions-bar">
            {!isLoading && !error && (
              <button className="btn-primary" onClick={() => navigate('/add-product')}>
                + Add New Product
              </button>
            )}
          </div>
        ) : null}

        <div className="products-content">
          {isLoading ? (
            <div className="loading-state">
              <span className="spinner" />
              <p>Loading your products...</p>
            </div>
          ) : error ? (
            <EmptyState
              icon={<WarningIcon />}
              title="Oops, something went wrong"
              description={error}
            />
          ) : products.length === 0 ? (
            <EmptyState
              icon={<BoxEmptyIcon />}
              title="Your catalog is empty"
              description="You haven't added any products yet. Start by creating your first listing!"
              action={
                <button className="btn-primary mt-4" onClick={() => navigate('/add-product')}>
                  + Add New Product
                </button>
              }
            />
          ) : filteredProducts.length === 0 ? (
            <EmptyState
              title="No matching products"
              description="Try adjusting your search or category filter."
              action={
                <button
                  className="btn-secondary mt-4"
                  onClick={() => {
                    setSearch('');
                    setCategoryFilter('all');
                  }}
                >
                  Clear filters
                </button>
              }
            />
          ) : (
            <div className="products-grid">
              {filteredProducts.map((product) => {
                const imageCount = product.imageUrl?.length ?? 0;
                const hasImage = imageCount > 0;
                const targetId = productIdOf(product);

                return (
                  <div key={targetId || product.name} className="product-card">
                    <div className="product-image-wrapper">
                      {hasImage || product.modelURL ? (
                        <img
                          src={product.imageUrl?.[0] || product.modelURL}
                          alt={product.name}
                          className="product-image"
                          onError={(e) => {
                            (e.target as HTMLImageElement).style.display = 'none';
                          }}
                        />
                      ) : (
                        <div className="product-placeholder">No Image Available</div>
                      )}
                      <div className="product-badges">
                        {!hasImage && <span className="status-badge badge-warning">No image</span>}
                        {hasImage && (
                          <span className="status-badge badge-info">
                            {imageCount} photo{imageCount === 1 ? '' : 's'}
                          </span>
                        )}
                        {product.modelURL && (
                          <span className="ar-badge">
                            <SparklesIcon /> AR Ready
                          </span>
                        )}
                      </div>
                    </div>
                    <div className="product-info">
                      <div className="product-header-row">
                        <span className="product-category">{product.furnitureType}</span>
                        <span className="product-price">
                          LKR {Number(product.price).toFixed(2)}
                        </span>
                      </div>
                      <h3 className="product-name">{product.name}</h3>
                      <p className="product-description">
                        {product.description?.substring(0, 60)}
                        {product.description && product.description.length > 60 ? '...' : ''}
                      </p>
                      {product.dimensions && (
                        <div className="product-dimensions">
                          {product.dimensions.width}x{product.dimensions.height}x
                          {product.dimensions.length} cm
                        </div>
                      )}
                    </div>
                    <div className="product-actions">
                      <button
                        className="btn-sm btn-secondary"
                        onClick={() => {
                          if (targetId) navigate(`/products/${targetId}`);
                          else showToast('Error: Product ID not found.', 'error');
                        }}
                      >
                        Edit
                      </button>
                      <button
                        className="btn-sm btn-danger"
                        onClick={() => setDeleteTarget(product)}
                        disabled={isDeleting && deleteTarget?.productId === product.productId}
                      >
                        Delete
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <ConfirmDialog
        open={!!deleteTarget}
        title="Delete product?"
        message={
          deleteTarget
            ? `Are you sure you want to completely delete "${deleteTarget.name}"? This cannot be undone and will remove all associated images and 3D models.`
            : ''
        }
        confirmLabel="Delete"
        cancelLabel="Cancel"
        destructive
        loading={isDeleting}
        onConfirm={handleConfirmDelete}
        onCancel={() => !isDeleting && setDeleteTarget(null)}
      />
    </AppShell>
  );
};

export default SellerProducts;
