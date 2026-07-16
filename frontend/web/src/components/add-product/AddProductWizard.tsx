import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../../lib/firebase';
import api, { getApiBaseURL, toUserFacingApiError } from '../../lib/api';
import { useSellerSession } from '../../auth/sellerSession';
import { useToast } from '../Toast';
import AppShell from '../AppShell';

import StepIndicator from './StepIndicator';
import StepBasics from './StepBasics';
import StepDetails from './StepDetails';
import StepMedia from './StepMedia';
import StepReview from './StepReview';
import {
  initialFormData,
  validateStep,
  type AddProductFormData,
  type FormErrors,
} from './useAddProductForm';

import './AddProductWizard.css';

type WizardStep = 1 | 2 | 3 | 4;
type LoadingStep = 'idle' | 'saving' | 'uploading' | 'generating';

const SellerAddProductWizard: React.FC = () => {
  const navigate = useNavigate();
  const { session } = useSellerSession();
  const { showToast } = useToast();

  // ── Form state ──────────────────────────────────────────────────────────────
  const [step, setStep] = useState<WizardStep>(1);
  const [form, setForm] = useState<AddProductFormData>(initialFormData);
  const [errors, setErrors] = useState<FormErrors>({});
  const [imageFiles, setImageFiles] = useState<File[]>([]);
  const [generate3D, setGenerate3D] = useState(false);
  const [selectedGenIndex, setSelectedGenIndex] = useState(0);
  const [modelFile, setModelFile] = useState<File | null>(null);

  // ── Publish state ────────────────────────────────────────────────────────────
  const [loadingStep, setLoadingStep] = useState<LoadingStep>('idle');
  const [globalError, setGlobalError] = useState('');

  const isPublishing = loadingStep !== 'idle';

  // ── Handlers ─────────────────────────────────────────────────────────────────
  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>,
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
    // Clear that field's error on change
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: '' }));
  };

  const handleAddImages = (files: File[]) => {
    setImageFiles((prev) => [...prev, ...files]);
    if (errors.images) setErrors((prev) => ({ ...prev, images: '' }));
  };

  const handleRemoveImage = (index: number) => {
    setImageFiles((prev) => prev.filter((_, i) => i !== index));
    if (selectedGenIndex === index) setSelectedGenIndex(0);
    else if (selectedGenIndex > index) setSelectedGenIndex((prev) => prev - 1);
  };

  const handleImageError = (message: string) => {
    setErrors((prev) => ({ ...prev, images: message }));
  };

  // ── Navigation ───────────────────────────────────────────────────────────────
  const handleNext = () => {
    const stepErrors = validateStep(step as 1 | 2 | 3 | 4, form, imageFiles, generate3D, modelFile);
    if (Object.keys(stepErrors).length > 0) {
      setErrors(stepErrors);
      return;
    }
    setErrors({});
    setStep((prev) => Math.min(prev + 1, 4) as WizardStep);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBack = () => {
    setErrors({});
    setStep((prev) => Math.max(prev - 1, 1) as WizardStep);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleGoToStep = (target: 1 | 2 | 3) => {
    setErrors({});
    setStep(target);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // ── Publish pipeline ─────────────────────────────────────────────────────────
  const handlePublish = async () => {
    // Final validation across all steps
    const allErrors = validateStep(4, form, imageFiles, generate3D, modelFile);
    if (Object.keys(allErrors).length > 0) {
      setErrors(allErrors);
      setGlobalError('Please fix the errors below before publishing.');
      return;
    }

    setGlobalError('');

    // Resolve storeId
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
        // handled below
      }
    }

    if (!storeId) {
      setGlobalError(
        'No store is linked to your account. Please complete your store setup before adding products.',
      );
      return;
    }

    setLoadingStep('saving');

    let productId: string;

    try {
      // ── Step 1: Create the product ────────────────────────────────────────────
      const dimensions: Record<string, number> = {};
      if (form.width) dimensions.width = Number(form.width);
      if (form.height) dimensions.height = Number(form.height);
      if (form.depth) dimensions.length = Number(form.depth); // DTO uses "length" for depth

      const body: Record<string, unknown> = {
        name: form.name.trim(),
        description: form.description.trim(),
        price: Number(form.price),
        furnitureType: form.furnitureType,
      };

      if (form.materials) {
        body.materials = form.materials
          .split(',')
          .map((m) => m.trim())
          .filter((m) => m !== '');
      }

      if (form.styleTags) {
        body.styleTags = form.styleTags
          .split(',')
          .map((t) => t.trim())
          .filter((t) => t !== '');
      }

      if (Object.keys(dimensions).length > 0) {
        body.dimensions = dimensions;
      }

      const response = await api.post(`/products/store/${storeId}`, body);
      productId = response.data.productId as string;

      // ── Step 2: Upload images and/or model ─────────────────────────────────────
      const updatePayload: any = {};
      
      if (imageFiles.length > 0) {
        setLoadingStep('uploading');
        const uploadedUrls: string[] = [];
        for (const file of imageFiles) {
          const storageRef = ref(storage, `products/${productId}/${Date.now()}_${file.name}`);
          const snapshot = await uploadBytes(storageRef, file);
          const downloadUrl = await getDownloadURL(snapshot.ref);
          uploadedUrls.push(downloadUrl);
        }
        updatePayload.imageUrl = uploadedUrls;
      }
      
      if (modelFile) {
        setLoadingStep('uploading');
        const storageRef = ref(storage, `products/${productId}/model_${Date.now()}_${modelFile.name}`);
        const snapshot = await uploadBytes(storageRef, modelFile);
        const downloadUrl = await getDownloadURL(snapshot.ref);
        updatePayload.modelURL = downloadUrl;
      }
      
      if (Object.keys(updatePayload).length > 0) {
        await api.put(`/products/${productId}`, updatePayload);
      }
    } catch (err: unknown) {
      setGlobalError(toUserFacingApiError(err));
      setLoadingStep('idle');
      return;
    }

    // ── Step 3 (optional): 3D generation ─────────────────────────────────────
    if (generate3D && imageFiles.length > 0) {
      setLoadingStep('generating');
      try {
        const multipart = new FormData();
        multipart.append('image', imageFiles[selectedGenIndex] || imageFiles[0]);
        multipart.append('x', form.width || '10');
        multipart.append('y', form.height || '10');
        multipart.append('z', form.depth || '10');

        const baseUrl = getApiBaseURL();
        const genResponse = await fetch(`${baseUrl}/model-generation/${productId}/generate`, {
          method: 'POST',
          body: multipart,
        });

        if (!genResponse.ok) {
          console.warn('3D generation failed:', await genResponse.text());
          showToast('Product saved, but 3D generation failed. You can retry from the edit page.', 'error');
        }
      } catch (err) {
        console.warn('3D generation error:', err);
        showToast('Product saved, but 3D generation encountered an error. Retry from the edit page.', 'error');
      }
    }

    setLoadingStep('idle');
    showToast('Product published successfully!', 'success');
    navigate('/products');
  };

  // ── Step label for publish button ────────────────────────────────────────────
  const publishLabel = (() => {
    switch (loadingStep) {
      case 'saving': return 'Saving product…';
      case 'uploading': return 'Uploading images…';
      case 'generating': return 'Generating 3D model…';
      default: return 'Publish Product';
    }
  })();

  const primaryImage = imageFiles.length > 0 ? URL.createObjectURL(imageFiles[0]) : null;

  return (
    <AppShell pageTitle="Add New Product">
      <div className="wizard-container">
        {/* ── Live banner preview ─────────────────────────────────────────── */}
        <div
          className="wizard-banner"
          style={{ backgroundImage: primaryImage ? `url(${primaryImage})` : 'none' }}
        >
          {!primaryImage && (
            <div className="wizard-banner-placeholder">Upload an image to preview it here</div>
          )}
        </div>

        <div className="wizard-card">
          {/* ── Product name live preview ────────────────────────────────── */}
          <div className="wizard-card-header">
            <h1 className="wizard-product-name">{form.name || 'New Product Name'}</h1>
            <p className="wizard-brand-label">
              Brand: <span className="wizard-brand">POCKETROOM</span>
            </p>
          </div>

          {/* ── Step indicator ───────────────────────────────────────────── */}
          <StepIndicator step={step} />

          {/* ── Global error ─────────────────────────────────────────────── */}
          {globalError && <div className="form-error wizard-global-error">{globalError}</div>}

          {/* ── Step content ─────────────────────────────────────────────── */}
          <div className="wizard-step-body">
            {step === 1 && (
              <StepBasics form={form} errors={errors} onChange={handleChange} />
            )}
            {step === 2 && (
              <StepDetails form={form} errors={errors} onChange={handleChange} />
            )}
            {step === 3 && (
              <StepMedia
                imageFiles={imageFiles}
                generate3D={generate3D}
                selectedGenIndex={selectedGenIndex}
                modelFile={modelFile}
                errors={errors}
                onAddImages={handleAddImages}
                onRemoveImage={handleRemoveImage}
                onGenerate3DChange={setGenerate3D}
                onSelectGenIndex={setSelectedGenIndex}
                onModelFileChange={setModelFile}
                onImageError={handleImageError}
              />
            )}
            {step === 4 && (
              <StepReview
                form={form}
                imageFiles={imageFiles}
                generate3D={generate3D}
                selectedGenIndex={selectedGenIndex}
                modelFile={modelFile}
                onGoToStep={handleGoToStep}
              />
            )}
          </div>

          {/* ── Navigation actions ───────────────────────────────────────── */}
          <div className="wizard-actions">
            {step === 1 ? (
              <button
                type="button"
                className="btn-secondary"
                onClick={() => navigate('/products')}
              >
                Cancel
              </button>
            ) : (
              <button
                type="button"
                className="btn-secondary"
                onClick={handleBack}
                disabled={isPublishing}
              >
                ← Back
              </button>
            )}

            {step < 4 ? (
              <button type="button" className="btn-primary" onClick={handleNext}>
                Continue →
              </button>
            ) : (
              <button
                type="button"
                className="btn-primary"
                onClick={handlePublish}
                disabled={isPublishing}
              >
                {isPublishing && <span className="btn-spinner" />}
                {publishLabel}
              </button>
            )}
          </div>
        </div>
      </div>
    </AppShell>
  );
};

export default SellerAddProductWizard;
