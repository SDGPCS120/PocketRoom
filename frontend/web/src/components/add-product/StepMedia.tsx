import React from 'react';
import {
  MAX_IMAGES,
  MAX_IMAGE_BYTES,
  validateImageFile,
  type FormErrors,
} from './useAddProductForm';

function TrashIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points="3 6 5 6 21 6" />
      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" />
    </svg>
  );
}

function CheckIcon() {
  return (
    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ display: 'inline', margin: 0 }}>
      <polyline points="20 6 9 17 4 12" />
    </svg>
  );
}

interface StepMediaProps {
  imageFiles: File[];
  generate3D: boolean;
  selectedGenIndex: number;
  errors: FormErrors;
  onAddImages: (files: File[]) => void;
  onRemoveImage: (index: number) => void;
  onGenerate3DChange: (checked: boolean) => void;
  onSelectGenIndex: (index: number) => void;
  onImageError: (message: string) => void;
}

const StepMedia: React.FC<StepMediaProps> = ({
  imageFiles,
  generate3D,
  selectedGenIndex,
  errors,
  onAddImages,
  onRemoveImage,
  onGenerate3DChange,
  onSelectGenIndex,
  onImageError,
}) => {
  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files || e.target.files.length === 0) return;
    const incoming = Array.from(e.target.files);
    const accepted: File[] = [];

    for (const file of incoming) {
      const err = validateImageFile(file);
      if (err) {
        onImageError(err);
        e.target.value = '';
        return;
      }
      accepted.push(file);
    }

    if (imageFiles.length + accepted.length > MAX_IMAGES) {
      onImageError(`You can upload at most ${MAX_IMAGES} images.`);
      e.target.value = '';
      return;
    }

    onAddImages(accepted);
    e.target.value = '';
  };

  return (
    <div className="form-step">
      <h2>Media &amp; AR Assets</h2>
      <p className="form-subtitle">
        Add high-quality photos (JPG/PNG, max {MAX_IMAGES} images, {MAX_IMAGE_BYTES / (1024 * 1024)}MB each).
        Optionally generate an AR-ready 3D model.
      </p>

      {errors.images && <div className="form-error">{errors.images}</div>}

      <div className="file-upload-group">
        <label className="file-label">
          <span className="file-title">
            Display Images {generate3D && <span className="required">*</span>}
          </span>
          <span className="file-desc">
            The first image is used as the catalog thumbnail. Click an image to choose it for 3D generation when enabled.
          </span>
          <input
            type="file"
            multiple
            accept="image/jpeg,image/jpg,image/png"
            onChange={handleFileChange}
            className="file-input"
          />
        </label>

        {imageFiles.length > 0 && (
          <div className="image-previews gen-selectors">
            {imageFiles.map((file, idx) => {
              const isSelected = generate3D && selectedGenIndex === idx;
              return (
                <div
                  key={`${file.name}-${idx}`}
                  className={`image-preview-item ${generate3D ? 'gen-select-item' : ''} ${isSelected ? 'selected' : ''}`}
                  onClick={() => generate3D && onSelectGenIndex(idx)}
                  role={generate3D ? 'button' : undefined}
                  tabIndex={generate3D ? 0 : undefined}
                  onKeyDown={(e) => {
                    if (generate3D && (e.key === 'Enter' || e.key === ' ')) {
                      e.preventDefault();
                      onSelectGenIndex(idx);
                    }
                  }}
                >
                  <img src={URL.createObjectURL(file)} alt={`Preview ${idx + 1}`} />
                  {isSelected && (
                    <div className="sel-check">
                      <CheckIcon />
                    </div>
                  )}
                  <button
                    type="button"
                    className="btn-remove-img"
                    onClick={(e) => {
                      e.stopPropagation();
                      onRemoveImage(idx);
                    }}
                    aria-label={`Remove image ${idx + 1}`}
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
            onChange={(e) => onGenerate3DChange(e.target.checked)}
          />
          <span className="toggle-text">
            <strong>Generate 3D Model now</strong>
            <span className="toggle-sub">
              {imageFiles.length > 1
                ? 'Click on one of the uploaded images above to choose which one to use for the 3D model.'
                : 'Uses the image above to create an AR-ready 3D model.'}{' '}
              You can also do this later from the product&apos;s edit page.
            </span>
          </span>
        </label>
      </div>
    </div>
  );
};

export default StepMedia;
