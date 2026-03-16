import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../lib/firebase';
import api from '../lib/api';
import './SellerAddProduct.css';

const SellerAddProduct: React.FC = () => {
  const navigate = useNavigate();
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
  const [modelFile, setModelFile] = useState<File | null>(null);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, type: 'image' | 'model') => {
    if (e.target.files && e.target.files.length > 0) {
      if (type === 'image') setImageFile(e.target.files[0]);
      if (type === 'model') setModelFile(e.target.files[0]);
    }
  };

  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!imageFile) {
      alert('Display image is required.');
      return;
    }

    setIsSubmitting(true);
    try {
      const userStr = localStorage.getItem('currentUser');
      const storeId = userStr ? JSON.parse(userStr).storeId : null;

      if (!storeId) {
        alert('Could not find your store ID. Please log in again.');
        setIsSubmitting(false);
        return;
      }

      // 1. Upload Image
      const imageRef = ref(storage, `products/images/${Date.now()}_${imageFile.name}`);
      await uploadBytes(imageRef, imageFile);
      const imageUrl = await getDownloadURL(imageRef);

      // 2. Upload Model (Optional)
      let modelUrl = '';
      if (modelFile) {
        const modelRef = ref(storage, `products/models/${Date.now()}_${modelFile.name}`);
        await uploadBytes(modelRef, modelFile);
        modelUrl = await getDownloadURL(modelRef);
      }

      // 3. Save Product to Backend
      const payload = {
        name: formData.name,
        description: formData.description,
        price: parseFloat(formData.price),
        furnitureType: formData.category,
        dimensions: `${formData.width}x${formData.height}x${formData.depth}`,
        images: [imageUrl],
        modelUrl: modelUrl || undefined,
      };

      await api.post(`/products/store/${storeId}`, payload);

      alert('Product published successfully!');
      navigate('/dashboard');
    } catch (err) {
      console.error('Failed to add product:', err);
      alert('Failed to add product. Please check console.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleGenerateModel = () => {
    alert('AI 3D Model Generation Pipeline coming soon!');
  };

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
        <form onSubmit={handleSubmit} className="product-form">
          
          <section className="form-section">
            <h2>Basic Information</h2>
            <div className="form-group">
              <label htmlFor="name">Product Name *</label>
              <input type="text" id="name" name="name" required value={formData.name} onChange={handleInputChange} placeholder="e.g., Modern Velvet Sofa" />
            </div>

            <div className="form-group">
              <label htmlFor="description">Description *</label>
              <textarea id="description" name="description" required rows={4} value={formData.description} onChange={handleInputChange} placeholder="Describe the item..."></textarea>
            </div>

            <div className="form-row">
              <div className="form-group half">
                <label htmlFor="category">Category *</label>
                <select id="category" name="category" value={formData.category} onChange={handleInputChange}>
                  <option value="Sofa">Sofa</option>
                  <option value="Chair">Chair</option>
                  <option value="Table">Table</option>
                  <option value="Bed">Bed</option>
                  <option value="Storage">Storage</option>
                  <option value="Decor">Decor</option>
                </select>
              </div>
              <div className="form-group half">
                <label htmlFor="price">Price ($) *</label>
                <input type="number" id="price" name="price" min="0" step="0.01" required value={formData.price} onChange={handleInputChange} placeholder="299.99" />
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
            <h2>Media & AR Assets</h2>
            
            <div className="file-upload-group">
              <label className="file-label">
                <span className="file-title">Display Image *</span>
                <span className="file-desc">High quality image for the catalog (JPG, PNG)</span>
                <input type="file" accept="image/*" required onChange={(e) => handleFileChange(e, 'image')} className="file-input" />
              </label>
            </div>

            <div className="file-upload-group">
              <label className="file-label file-label-ar">
                <span className="file-title">3D AR Model (Optional)</span>
                <span className="file-desc">Upload a .glb or .gltf file for AR placement</span>
                <input type="file" accept=".glb,.gltf" onChange={(e) => handleFileChange(e, 'model')} className="file-input" />
              </label>
              
              <div className="generate-model-box" style={{ marginTop: '1rem', textAlign: 'center' }}>
                <p style={{ fontSize: '0.9rem', color: '#757575', marginBottom: '0.5rem' }}>Don't have a 3D model?</p>
                <button type="button" className="btn-secondary" onClick={handleGenerateModel}>
                  ✨ Generate 3D Model from Image
                </button>
              </div>
            </div>
          </section>

          <div className="form-actions">
            <button type="button" className="btn-secondary" onClick={() => navigate('/dashboard')} disabled={isSubmitting}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={isSubmitting}>
              {isSubmitting ? 'Publishing...' : 'Publish Product'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SellerAddProduct;
