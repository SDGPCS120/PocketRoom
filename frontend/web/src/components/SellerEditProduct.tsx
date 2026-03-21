import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../lib/firebase';
import api, { getApiBaseURL, toUserFacingApiError } from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import AppShell from './AppShell';
import './SellerEditProduct.css';

function TrashIcon() { return <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>; }

/* ── Icon replacements for emojis ── */
function WarningIcon() { return <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{color: '#e53e3e', marginRight: '8px'}}><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>; }
function CheckIcon() { return <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', marginRight: '4px', verticalAlign: 'text-bottom' }}><polyline points="20 6 9 17 4 12"/></svg>; }
function SparklesIcon() { return <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', marginRight: '4px', verticalAlign: 'text-bottom' }}><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>; }
function CrystalBallIcon() { return <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', marginRight: '6px', verticalAlign: 'text-bottom' }}><circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/></svg>; }

const CATEGORIES = ['Sofa', 'Chair', 'Table', 'Bed', 'Storage', 'Decor'];

interface ProductData {
  productId: string;
  name: string;
  description?: string;
  price: number;
  furnitureType?: string;
  dimensions?: { height?: number; width?: number; length?: number };
  imageUrl?: string[];
  modelURL?: string;
  storeId: string;
}

const SellerEditProduct: React.FC = () => {
  const { productId } = useParams<{ productId: string }>();
  const navigate = useNavigate();
  useSellerSession();

  // ── Product form state ─────────────────────────────────────────────────────
  const [product, setProduct] = useState<ProductData | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    category: 'Sofa',
    price: '',
    width: '',
    height: '',
    depth: '',
  });

  const [existingImages, setExistingImages] = useState<string[]>([]);
  const [imageFiles, setImageFiles] = useState<File[]>([]);

  // ── UI state ───────────────────────────────────────────────────────────────
  const [loadingProduct, setLoadingProduct] = useState(true);
  const [saveStatus, setSaveStatus] = useState<'idle' | 'saving' | 'saved'>('idle');
  const [saveError, setSaveError] = useState('');

  // ── 3D generation state ────────────────────────────────────────────────────
  const [genImage, setGenImage] = useState<File | null>(null);
  const [genStatus, setGenStatus] = useState<'idle' | 'generating' | 'done' | 'error'>('idle');
  const [genError, setGenError] = useState('');

  // ── Fetch product on mount ─────────────────────────────────────────────────
  useEffect(() => {
    if (!productId) return;
    const load = async () => {
      try {
        const res = await api.get<ProductData>(`/products/${productId}`);
        const p = res.data;
        setProduct(p);
        setFormData({
          name: p.name ?? '',
          description: p.description ?? '',
          category: p.furnitureType ?? 'Sofa',
          price: p.price?.toString() ?? '',
          width: p.dimensions?.width?.toString() ?? '',
          height: p.dimensions?.height?.toString() ?? '',
          depth: p.dimensions?.length?.toString() ?? '',
        });
        setExistingImages(p.imageUrl || []);
      } catch (err) {
        setSaveError(toUserFacingApiError(err));
      } finally {
        setLoadingProduct(false);
      }
    };
    load();
  }, [productId]);

  const handleInputChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>,
  ) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // ── Save changes ───────────────────────────────────────────────────────────
  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaveError('');
    setSaveStatus('saving');

    try {
      const dimensions: Record<string, number> = {};
      if (formData.width) dimensions.width = Number(formData.width);
      if (formData.height) dimensions.height = Number(formData.height);
      if (formData.depth) dimensions.length = Number(formData.depth);

      const body: Record<string, unknown> = {
        name: formData.name,
        description: formData.description,
        price: Number(formData.price),
        furnitureType: formData.category,
      };
      if (Object.keys(dimensions).length > 0) body.dimensions = dimensions;

      // Upload new images to Firebase
      const storeId = product?.storeId;
      const uploadedUrls: string[] = [];
      if (storeId) {
        for (const file of imageFiles) {
          const storageRef = ref(storage, `products/${storeId}/${Date.now()}_${file.name}`);
          const snapshot = await uploadBytes(storageRef, file);
          const downloadUrl = await getDownloadURL(snapshot.ref);
          uploadedUrls.push(downloadUrl);
        }
      }

      const finalImageUrls = [...existingImages, ...uploadedUrls];
      body.imageUrl = finalImageUrls;

      await api.put(`/products/${productId}`, body);
      setSaveStatus('saved');
      setExistingImages(finalImageUrls);
      setImageFiles([]);
      setTimeout(() => setSaveStatus('idle'), 3000);
    } catch (err) {
      setSaveError(toUserFacingApiError(err));
      setSaveStatus('idle');
    }
  };

  // ── Generate 3D model ──────────────────────────────────────────────────────
  const handleGenerate = async () => {
    if (!genImage) {
      setGenError('Please select a reference image first.');
      return;
    }
    setGenError('');
    setGenStatus('generating');

    try {
      const multipart = new FormData();
      multipart.append('image', genImage);
      multipart.append('x', formData.width || '10');
      multipart.append('y', formData.height || '10');
      multipart.append('z', formData.depth || '10');

      const baseUrl = getApiBaseURL();
      const res = await fetch(`${baseUrl}/model-generation/${productId}/generate`, {
        method: 'POST',
        body: multipart,
      });

      if (!res.ok) {
        throw new Error(await res.text());
      }

      setGenStatus('done');
      // Refresh product so AR badge shows
      const refreshed = await api.get<ProductData>(`/products/${productId}`);
      setProduct(refreshed.data);
    } catch (err) {
      setGenError(err instanceof Error ? err.message : 'Generation failed.');
      setGenStatus('error');
    }
  };

  // ── Render ─────────────────────────────────────────────────────────────────
  if (loadingProduct) {
    return (
      <AppShell pageTitle="Edit Product">
        <div className="edit-product-container">
          <div className="edit-loading">
            <span className="spinner-lg" />
            <p>Loading product…</p>
          </div>
        </div>
      </AppShell>
    );
  }

  if (!product && !loadingProduct) {
    return (
      <AppShell pageTitle="Edit Product">
        <div className="edit-product-container">
          <div className="edit-error-state">
            <div className="edit-error-icon"><WarningIcon /></div>
            <h2>Product not found</h2>
            <p>{saveError || 'This product could not be loaded.'}</p>
            <button className="btn-secondary" onClick={() => navigate('/products')}>
              ← Back to Catalog
            </button>
          </div>
        </div>
      </AppShell>
    );
  }

  // Using CheckIcon indirectly here as string doesn't take elements in label mapping
  // We'll render it custom in button
  
  return (
    <AppShell pageTitle="Edit Product">
      <div className="edit-product-container">
        {/* ── Page header ─────────────────────────────────────────────────── */}
        <div className="edit-product-header">
          <div className="edit-header-row">
            <div>
              <p className="product-id-label">ID: <code>{productId}</code></p>
            </div>
            {product?.modelURL && (
              <div className="ar-ready-badge"><SparklesIcon /> AR Ready</div>
            )}
          </div>
        </div>

        {/* ── Edit form card ───────────────────────────────────────────────── */}
        <div className="form-card">
          {saveError && <div className="form-error">{saveError}</div>}

          <form onSubmit={handleSave} className="product-form">
            <section className="form-section">
              <h2>Basic Information</h2>
              <div className="form-group">
                <label htmlFor="name">Product Name *</label>
                <input
                  type="text" id="name" name="name" required
                  value={formData.name} onChange={handleInputChange}
                  placeholder="e.g., Modern Velvet Sofa"
                />
              </div>

              <div className="form-group">
                <label htmlFor="description">Description</label>
                <textarea
                  id="description" name="description" rows={4}
                  value={formData.description} onChange={handleInputChange}
                  placeholder="Describe the item…"
                />
              </div>

              <div className="form-row">
                <div className="form-group half">
                  <label htmlFor="category">Category *</label>
                  <select id="category" name="category" value={formData.category} onChange={handleInputChange}>
                    {CATEGORIES.map((c) => <option key={c} value={c}>{c}</option>)}
                  </select>
                </div>
                <div className="form-group half">
                  <label htmlFor="price">Price (LKR) *</label>
                  <input
                    type="number" id="price" name="price" min="0" step="0.01" required
                    value={formData.price} onChange={handleInputChange} placeholder="29999"
                  />
                </div>
              </div>
            </section>

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

            <section className="form-section media-section">
              <h2>Media</h2>
              <div className="file-upload-group">
                <label className="file-label">
                  <span className="file-title">Add Images</span>
                  <span className="file-desc">High quality images for the catalog (JPG, PNG).</span>
                  <input
                    type="file" multiple
                    accept="image/jpeg,image/jpg,image/png"
                    onChange={(e) => {
                      if (e.target.files && e.target.files.length > 0) {
                        setImageFiles((prev) => [...prev, ...Array.from(e.target.files!)]);
                      }
                    }}
                    className="file-input"
                  />
                </label>

                {(existingImages.length > 0 || imageFiles.length > 0) && (
                  <div className="image-previews">
                    {existingImages.map((url, idx) => (
                      <div key={`exist-${idx}`} className="image-preview-item">
                        <img src={url} alt={`Existing ${idx + 1}`} />
                        <button type="button" className="btn-remove-img" onClick={() => setExistingImages(imgs => imgs.filter((_, i) => i !== idx))}>
                          <TrashIcon />
                        </button>
                      </div>
                    ))}
                    {imageFiles.map((file, idx) => (
                      <div key={`new-${idx}`} className="image-preview-item">
                        <img src={URL.createObjectURL(file)} alt={`New ${idx + 1}`} />
                        <button type="button" className="btn-remove-img" onClick={() => setImageFiles(files => files.filter((_, i) => i !== idx))}>
                          <TrashIcon />
                        </button>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </section>

            <div className="form-actions">
              <button type="button" className="btn-secondary" onClick={() => navigate('/products')} disabled={saveStatus === 'saving'}>
                Cancel
              </button>
              <button
                type="submit"
                className={`btn-primary ${saveStatus === 'saved' ? 'btn-success' : ''}`}
                disabled={saveStatus === 'saving'}
              >
                {saveStatus === 'saving' ? (
                  <><span className="btn-spinner" /> Saving…</>
                ) : saveStatus === 'saved' ? (
                  <><CheckIcon /> Saved!</>
                ) : (
                  'Save Changes'
                )}
              </button>
            </div>
          </form>
        </div>

        {/* ── 3D Model Generation card ────────────────────────────────────── */}
        <div className="form-card generation-card">
          <div className="generation-header">
            <div>
              <h2>3D Model &amp; AR</h2>
              <p>
                {product?.modelURL
                  ? 'A 3D model already exists for this product. You can regenerate it below.'
                  : 'No 3D model yet. Upload a reference image and generate one.'}
              </p>
            </div>
            {product?.modelURL && <div className="ar-mini-badge"><SparklesIcon /> AR Ready</div>}
          </div>

          <div className="generation-body">
            <div className="file-upload-group gen-upload">
              <label className="file-label">
                <span className="file-title">Reference Image *</span>
                <span className="file-desc">A clear photo of the furniture item (JPG, PNG)</span>
                <input
                  type="file"
                  accept="image/jpeg,image/jpg,image/png"
                  onChange={(e) => {
                    if (e.target.files && e.target.files.length > 0) {
                      setGenImage(e.target.files[0]);
                      setGenStatus('idle');
                      setGenError('');
                    }
                  }}
                  className="file-input"
                  disabled={genStatus === 'generating'}
                />
              </label>
              {genImage && <p className="file-selected"><CheckIcon /> {genImage.name}</p>}
            </div>

            {genError && <div className="form-error gen-error">{genError}</div>}

            {genStatus === 'done' && (
              <div className="gen-success">
                <CheckIcon /> 3D model generation started successfully! It may take a few minutes to process.
              </div>
            )}

            <button
              type="button"
              className="btn-generate"
              onClick={handleGenerate}
              disabled={genStatus === 'generating' || !genImage}
            >
              {genStatus === 'generating' ? (
                <><span className="btn-spinner btn-spinner-dark" />Generating 3D Model…</>
              ) : (
                <><CrystalBallIcon /> {product?.modelURL ? 'Regenerate 3D Model' : 'Generate 3D Model'}</>
              )}
            </button>
          </div>
        </div>
      </div>
    </AppShell>
  );
};

export default SellerEditProduct;
