import React, { useMemo } from 'react';
import type { AddProductFormData } from './useAddProductForm';

interface StepReviewProps {
  form: AddProductFormData;
  imageFiles: File[];
  generate3D: boolean;
  selectedGenIndex: number;
  onGoToStep: (step: 1 | 2 | 3) => void;
}

const StepReview: React.FC<StepReviewProps> = ({
  form,
  imageFiles,
  generate3D,
  selectedGenIndex,
  onGoToStep,
}) => {
  const previewUrl = useMemo(
    () => (imageFiles.length > 0 ? URL.createObjectURL(imageFiles[0]) : null),
    [imageFiles],
  );

  const materials = form.materials
    .split(',')
    .map((m) => m.trim())
    .filter(Boolean);
  const styleTags = form.styleTags
    .split(',')
    .map((t) => t.trim())
    .filter(Boolean);

  const hasDims = form.width || form.height || form.depth;

  return (
    <div className="form-step">
      <h2>Review &amp; Publish</h2>
      <p className="form-subtitle">
        Double-check how your listing will appear in the catalog before publishing.
      </p>

      <div className="review-layout">
        <div className="review-preview-card product-card">
          <div className="product-image-wrapper">
            {previewUrl ? (
              <img src={previewUrl} alt={form.name || 'Preview'} className="product-image" />
            ) : (
              <div className="product-placeholder">No Image Available</div>
            )}
            <div className="product-badges">
              {imageFiles.length === 0 && (
                <span className="status-badge badge-warning">No image</span>
              )}
              {imageFiles.length > 0 && (
                <span className="status-badge badge-info">
                  {imageFiles.length} photo{imageFiles.length === 1 ? '' : 's'}
                </span>
              )}
              {generate3D && (
                <span className="ar-badge">AR pending</span>
              )}
            </div>
          </div>
          <div className="product-info">
            <div className="product-header-row">
              <span className="product-category">{form.furnitureType || '—'}</span>
              <span className="product-price">
                LKR {form.price ? Number(form.price).toFixed(2) : '0.00'}
              </span>
            </div>
            <h3 className="product-name">{form.name || 'Untitled product'}</h3>
            <p className="product-description">
              {form.description
                ? `${form.description.substring(0, 60)}${form.description.length > 60 ? '...' : ''}`
                : 'No description'}
            </p>
            {hasDims && (
              <div className="product-dimensions">
                {form.width || '—'}x{form.height || '—'}x{form.depth || '—'} cm
              </div>
            )}
          </div>
        </div>

        <div className="review-summary">
          <section className="review-block">
            <div className="review-block-header">
              <h3>Basics</h3>
              <button type="button" className="btn-link" onClick={() => onGoToStep(1)}>
                Edit
              </button>
            </div>
            <dl className="review-dl">
              <div>
                <dt>Name</dt>
                <dd>{form.name || '—'}</dd>
              </div>
              <div>
                <dt>Category</dt>
                <dd>{form.furnitureType || '—'}</dd>
              </div>
              <div>
                <dt>Price</dt>
                <dd>LKR {form.price ? Number(form.price).toFixed(2) : '—'}</dd>
              </div>
              <div>
                <dt>Description</dt>
                <dd className="review-desc">{form.description || '—'}</dd>
              </div>
            </dl>
          </section>

          <section className="review-block">
            <div className="review-block-header">
              <h3>Details</h3>
              <button type="button" className="btn-link" onClick={() => onGoToStep(2)}>
                Edit
              </button>
            </div>
            <dl className="review-dl">
              <div>
                <dt>Dimensions</dt>
                <dd>
                  {hasDims
                    ? `${form.width || '—'} × ${form.height || '—'} × ${form.depth || '—'} cm`
                    : 'Not set'}
                </dd>
              </div>
              <div>
                <dt>Materials</dt>
                <dd>{materials.length ? materials.join(', ') : '—'}</dd>
              </div>
              <div>
                <dt>Style tags</dt>
                <dd>{styleTags.length ? styleTags.join(', ') : '—'}</dd>
              </div>
            </dl>
          </section>

          <section className="review-block">
            <div className="review-block-header">
              <h3>Media &amp; AR</h3>
              <button type="button" className="btn-link" onClick={() => onGoToStep(3)}>
                Edit
              </button>
            </div>
            <dl className="review-dl">
              <div>
                <dt>Images</dt>
                <dd>
                  {imageFiles.length === 0
                    ? 'None uploaded'
                    : `${imageFiles.length} file${imageFiles.length === 1 ? '' : 's'}`}
                </dd>
              </div>
              <div>
                <dt>3D generation</dt>
                <dd>
                  {generate3D
                    ? `Yes (image ${selectedGenIndex + 1})`
                    : 'No — can generate later'}
                </dd>
              </div>
            </dl>
          </section>
        </div>
      </div>
    </div>
  );
};

export default StepReview;
