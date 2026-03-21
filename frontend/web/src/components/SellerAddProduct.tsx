import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api, { getApiBaseURL } from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import './SellerAddProduct.css';

const CATEGORIES = ['Sofa', 'Chair', 'Table', 'Bed', 'Storage', 'Decor'];

const SellerAddProduct: React.FC = () => {
  const navigate = useNavigate();
  const { session, refreshStore } = useSellerSession();

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    category: 'Sofa',
    price: '',
    width: '',
    height: '',
    depth: '',
  });

  const [imageFile, setImageFile] = useState<File | null>(null);
  const [generate3D, setGenerate3D] = useState(false);
  const [loadingStep, setLoadingStep] = useState<'idle' | 'saving' | 'generating'>('idle');
  const [error, setError] = useState('');

  const isPublishing = loadingStep !== 'idle';

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>,
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    // ── Resolve storeId ────────────────────────────────────────────────────────
    let storeId = session?.storeId;
    if (!storeId) {
      try {
        await refreshStore();
        const cached = localStorage.getItem('currentUser');
        storeId = cached ? (JSON.parse(cached).storeId as string | undefined) : undefined;
      } catch {
        // ignore; error reported below
      }
    }

    if (!storeId) {
      setError(
        'No store is linked to your account. Please complete your store setup before adding products.',
      );
      return;
    }

    if (generate3D && !imageFile) {
      setError('Please upload a display image to generate the 3D model, or uncheck "Generate 3D Model now".');
      return;
    }

    // ── Step 1: Create the product ─────────────────────────────────────────────
    setLoadingStep('saving');
    let productId: string;

    try {
      const dimensions: Record<string, number> = {};
      if (formData.width) dimensions.width = Number(formData.width);
      if (formData.height) dimensions.height = Number(formData.height);
      if (formData.depth) dimensions.length = Number(formData.depth); // DTO uses "length" for depth

      const body: Record<string, unknown> = {
        name: formData.name,
        description: formData.description,
        price: Number(formData.price),
        furnitureType: formData.category,
      };

      if (Object.keys(dimensions).length > 0) {
        body.dimensions = dimensions;
      }

      const response = await api.post(`/products/store/${storeId}`, body);
      productId = response.data.productID as string;
    } catch (err: unknown) {
      const msg =
        err instanceof Error ? err.message : 'Failed to save product. Please try again.';
      setError(msg);
      setLoadingStep('idle');
      return;
    }

    // ── Step 2 (optional): Trigger 3D generation ───────────────────────────────
    if (generate3D && imageFile) {
      setLoadingStep('generating');
      try {
        const multipart = new FormData();
        multipart.append('image', imageFile);
        multipart.append('x', formData.width || '10');
        multipart.append('y', formData.height || '10');
        multipart.append('z', formData.depth || '10');

        const baseUrl = getApiBaseURL();
        const genResponse = await fetch(`${baseUrl}/model-generation/${productId}/generate`, {
          method: 'POST',
          body: multipart,
        });

        if (!genResponse.ok) {
          // Non-fatal: product was created successfully; warn the user
          console.warn('3D generation failed:', await genResponse.text());
          setError(`Product saved, but 3D generation failed. You can retry it from the product's edit page.`);
        }
      } catch (err) {
        console.warn('3D generation error:', err);
        setError(`Product saved, but 3D generation encountered an error. You can retry it from the product's edit page.`);
      }
    }

    setLoadingStep('idle');

    // ── Navigate to edit page ──────────────────────────────────────────────────
    navigate(`/products/${productId}`);
  };

  const stepLabel =
    loadingStep === 'saving'
      ? 'Saving product…'
      : loadingStep === 'generating'
        ? 'Generating 3D model…'
        : 'Publish Product';

  return (
    <div className="add-product-container">
      <div className="add-product-header">
        <button className="back-button" onClick={() => navigate('/dashboard')}>
          &larr; Back to Dashboard
        </button>
        <h1>Add New Product</h1>
        <p>List a new furniture item with AR visualization capabilities.</p>
      </div>

      <div className="form-card">
        {error && <div className="form-error">{error}</div>}

        <form onSubmit={handleSubmit} className="product-form">

          {/* ── Basic Information ─────────────────────────────────────── */}
          <section className="form-section">
            <h2>Basic Information</h2>
            <div className="form-group">
              <label htmlFor="name">Product Name *</label>
              <input
                type="text"
                id="name"
                name="name"
                required
                value={formData.name}
                onChange={handleInputChange}
                placeholder="e.g., Modern Velvet Sofa"
              />
            </div>

            <div className="form-group">
              <label htmlFor="description">Description *</label>
              <textarea
                id="description"
                name="description"
                required
                rows={4}
                value={formData.description}
                onChange={handleInputChange}
                placeholder="Describe the item…"
              />
            </div>

            <div className="form-row">
              <div className="form-group half">
                <label htmlFor="category">Category *</label>
                <select
                  id="category"
                  name="category"
                  value={formData.category}
                  onChange={handleInputChange}
                >
                  {CATEGORIES.map((c) => (
                    <option key={c} value={c}>{c}</option>
                  ))}
                </select>
              </div>
              <div className="form-group half">
                <label htmlFor="price">Price (LKR) *</label>
                <input
                  type="number"
                  id="price"
                  name="price"
                  min="0"
                  step="0.01"
                  required
                  value={formData.price}
                  onChange={handleInputChange}
                  placeholder="29999"
                />
              </div>
            </div>
          </section>

          {/* ── Dimensions ────────────────────────────────────────────── */}
          <section className="form-section">
            <h2>Dimensions (cm)</h2>
            <div className="form-row three-col">
              <div className="form-group">
                <label htmlFor="width">Width</label>
                <input type="number" id="width" name="width" min="0" value={formData.width} onChange={handleInputChange} placeholder="W" />
              </div>
              <div className="form-group">
                <label htmlFor="height">Height</label>
                <input type="number" id="height" name="height" min="0" value={formData.height} onChange={handleInputChange} placeholder="H" />
              </div>
              <div className="form-group">
                <label htmlFor="depth">Depth</label>
                <input type="number" id="depth" name="depth" min="0" value={formData.depth} onChange={handleInputChange} placeholder="D" />
              </div>
            </div>
          </section>

          {/* ── Media & Optional 3D Generation ────────────────────────── */}
          <section className="form-section media-section">
            <h2>Media &amp; AR Assets</h2>

            <div className="file-upload-group">
              <label className="file-label">
                <span className="file-title">Display Image {generate3D && '*'}</span>
                <span className="file-desc">High quality image for the catalog (JPG, PNG)</span>
                <input
                  type="file"
                  accept="image/jpeg,image/jpg,image/png"
                  onChange={(e) => {
                    if (e.target.files && e.target.files.length > 0) {
                      setImageFile(e.target.files[0]);
                    }
                  }}
                  className="file-input"
                />
              </label>
              {imageFile && (
                <p className="file-selected">✓ {imageFile.name}</p>
              )}
            </div>

            <div className="generate-3d-toggle">
              <label className="toggle-label">
                <input
                  type="checkbox"
                  checked={generate3D}
                  onChange={(e) => setGenerate3D(e.target.checked)}
                />
                <span className="toggle-text">
                  <strong>Generate 3D Model now</strong>
                  <span className="toggle-sub">
                    Uses the image above to create an AR-ready 3D model. You can also do this later from the product's edit page.
                  </span>
                </span>
              </label>
            </div>
          </section>

          {/* ── Actions ───────────────────────────────────────────────── */}
          <div className="form-actions">
            <button
              type="button"
              className="btn-secondary"
              onClick={() => navigate('/dashboard')}
              disabled={isPublishing}
            >
              Cancel
            </button>
            <button type="submit" className="btn-primary" disabled={isPublishing}>
              {isPublishing && <span className="btn-spinner" />}
              {stepLabel}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SellerAddProduct;
