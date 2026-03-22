import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../lib/firebase';
import api, { getApiBaseURL } from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import AppShell from './AppShell';
import './SellerAddProduct.css';

function TrashIcon() { return <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6" /><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" /></svg>; }
function CheckIcon() { return <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', margin: 0 }}><polyline points="20 6 9 17 4 12" /></svg>; }

const CATEGORIES = ['Sofa', 'Chair', 'Table', 'Bed', 'Storage', 'Decor'];

const SellerAddProduct: React.FC = () => {
  const navigate = useNavigate();
  const { session } = useSellerSession();

  const [formData, setFormData] = useState({
    name: '',
    description: '',
    furnitureType: 'Sofa',
    price: '',
    width: '',
    height: '',
    depth: '',
    materials: '',
    styleTags: '',
  });

  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [generate3D, setGenerate3D] = useState(false);
  const [selectedGenIndex, setSelectedGenIndex] = useState(0);
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

    // ── Resolve storeId — try session first, then call /stores/me directly ──────
    let storeId = session?.storeId;
    if (!storeId) {
      try {
        const storeRes = await api.get('/stores/me');
        storeId = storeRes.data?.storeId as string | undefined;
        if (storeId) {
          const storeName = storeRes.data?.storeName as string | undefined;
          const cached = JSON.parse(localStorage.getItem('currentUser') ?? '{}');
          localStorage.setItem('currentUser', JSON.stringify({ ...cached, storeId, storeName }));
        }
      } catch {
        // store truly doesn't exist; error reported below
      }
    }

    if (!storeId) {
      setError(
        'No store is linked to your account. Please complete your store setup before adding products.',
      );
      return;
    }

    if (generate3D && imageFiles.length === 0) {
      setError('Please upload at least one display image to generate the 3D model, or uncheck "Generate 3D Model now".');
      return;
    }

    setLoadingStep('saving');
    let productId: string;

    try {
      // ── Step 1: Create the product without images first ──────────────────────────
      const dimensions: Record<string, number> = {};
      if (formData.width) dimensions.width = Number(formData.width);
      if (formData.height) dimensions.height = Number(formData.height);
      if (formData.depth) dimensions.length = Number(formData.depth); // DTO uses "length" for depth

      const body: Record<string, unknown> = {
        name: formData.name,
        description: formData.description,
        price: Number(formData.price),
        furnitureType: formData.furnitureType,
      };

      if (formData.materials) {
        body.materials = formData.materials.split(',').map((m: string) => m.trim()).filter((m: string) => m !== '');
      }

      if (formData.styleTags) {
        body.styleTags = formData.styleTags.split(',').map((t: string) => t.trim()).filter((t: string) => t !== '');
      }

      if (Object.keys(dimensions).length > 0) {
        body.dimensions = dimensions;
      }

      const response = await api.post(`/products/store/${storeId}`, body);
      productId = response.data.productId as string;

      // ── Step 2: Upload images to Firebase Storage ──────────────────────────
      if (imageFiles.length > 0) {
        const uploadedUrls: string[] = [];
        for (const file of imageFiles) {
          // Upload to product-specific folder instead of store folder
          const storageRef = ref(storage, `products/${productId}/${Date.now()}_${file.name}`);
          const snapshot = await uploadBytes(storageRef, file);
          const downloadUrl = await getDownloadURL(snapshot.ref);
          uploadedUrls.push(downloadUrl);
        }

        // ── Step 3: Update the product with the uploaded image URLs ────────────────
        await api.put(`/products/${productId}`, { imageUrl: uploadedUrls });
      }

    } catch (err: unknown) {
      const msg =
        err instanceof Error ? err.message : 'Failed to save product. Please try again.';
      // If product was created but image upload failed, we might have an orphaned product. 
      // For now, just show the error.
      setError(msg);
      setLoadingStep('idle');
      return;
    }

    // ── Step 3 (optional): Trigger 3D generation ───────────────────────────────
    if (generate3D && imageFiles.length > 0) {
      setLoadingStep('generating');
      try {
        const multipart = new FormData();
        multipart.append('image', imageFiles[selectedGenIndex] || imageFiles[0]); // Use selected image
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

    // ── Navigate to catalog page ──────────────────────────────────────────────────
    navigate('/products');
  };

  const stepLabel =
    loadingStep === 'saving'
      ? 'Saving product…'
      : loadingStep === 'generating'
        ? 'Generating 3D model…'
        : 'Publish Product';

  const primaryImage = imageFiles.length > 0 ? URL.createObjectURL(imageFiles[0]) : null;

  return (
    <AppShell pageTitle="Add New Product">
      <div className="add-product-container">
        {/* ── Banner Image Background ─────────────────────────────────────── */}
        <div className="add-product-banner" style={{ backgroundImage: primaryImage ? `url(${primaryImage})` : 'none' }}>
          {!primaryImage && <div className="no-image-banner">Upload an image to see it here</div>}
        </div>

        <div className="form-card overlap-card">
          <div className="add-product-header-content">
            <h1 className="add-product-title">{formData.name || 'New Product Name'}</h1>
            <p className="product-id-label">Brand: <span className="brand-text">POCKETROOM</span></p>
          </div>
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
                  <label htmlFor="furnitureType">Category *</label>
                  <select
                    id="furnitureType"
                    name="furnitureType"
                    value={formData.furnitureType}
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

              <div className="form-group">
                <label htmlFor="materials">Materials (comma separated)</label>
                <input
                  type="text"
                  id="materials"
                  name="materials"
                  value={formData.materials}
                  onChange={handleInputChange}
                  placeholder="e.g., Wood, Fabric, Metal"
                />
              </div>

              <div className="form-group">
                <label htmlFor="styleTags">Style Tags (comma separated)</label>
                <input
                  type="text"
                  id="styleTags"
                  name="styleTags"
                  value={formData.styleTags}
                  onChange={handleInputChange}
                  placeholder="e.g., Modern, Minimalist, Luxurious"
                />
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
                  <span className="file-title">Display Images {generate3D && '*'}</span>
                  <span className="file-desc">High quality images for the catalog (JPG, PNG). The first image will be used for AR generation.</span>
                  <input
                    type="file"
                    multiple
                    accept="image/jpeg,image/jpg,image/png"
                    onChange={(e) => {
                      if (e.target.files && e.target.files.length > 0) {
                        setImageFiles((prev) => [...prev, ...Array.from(e.target.files!)]);
                      }
                    }}
                    className="file-input"
                  />
                </label>

                {imageFiles.length > 0 && (
                  <div className="image-previews gen-selectors">
                    {imageFiles.map((file, idx) => {
                      const isSelected = generate3D && selectedGenIndex === idx;
                      return (
                        <div
                          key={idx}
                          className={`image-preview-item ${generate3D ? 'gen-select-item' : ''} ${isSelected ? 'selected' : ''}`}
                          onClick={() => generate3D && setSelectedGenIndex(idx)}
                        >
                          <img src={URL.createObjectURL(file)} alt={`Preview ${idx + 1}`} />
                          {isSelected && <div className="sel-check"><CheckIcon /></div>}
                          <button
                            type="button"
                            className="btn-remove-img"
                            onClick={(e) => {
                              e.stopPropagation();
                              setImageFiles(files => files.filter((_, i) => i !== idx));
                              if (selectedGenIndex === idx) setSelectedGenIndex(0);
                              else if (selectedGenIndex > idx) setSelectedGenIndex(prev => prev - 1);
                            }}
                          >
                            <TrashIcon />
                          </button>
                        </div>
                      );
                    })}
                  </div>
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
                      {imageFiles.length > 1
                        ? 'Click on one of the uploaded images above to choose which one to use for the 3D model.'
                        : 'Uses the image above to create an AR-ready 3D model.'} You can also do this later from the product's edit page.
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
    </AppShell>
  );
};

export default SellerAddProduct;
