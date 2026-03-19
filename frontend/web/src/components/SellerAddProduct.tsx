import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { storage } from '../lib/firebase';
import api from '../lib/api';
import { useSellerSession } from '../auth/sellerSession';
import './SellerAddProduct.css';

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

  const [isPublishing, setIsPublishing] = useState(false);

  const [imageFile, setImageFile] = useState<File | null>(null);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>, type: 'image') => {
    if (e.target.files && e.target.files.length > 0) {
      if (type === 'image') setImageFile(e.target.files[0]);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!imageFile) {
        alert('Please upload a display image to generate the 3D model.');
        return;
    }

    setIsPublishing(true);
    
    try {
        const productId = 'prod_' + Date.now();
        const payload = new FormData();
        payload.append('image', imageFile);
        payload.append('x', formData.width || '10');
        payload.append('y', formData.height || '10');
        payload.append('z', formData.depth || '10');

        console.log('Initiating 3D generation for product:', productId);
        
        // In a production app, the backend URL should come from an env variable (e.g. import.meta.env.VITE_API_URL)
        const response = await fetch(`http://localhost:3000/model-generation/${productId}/generate`, {
            method: 'POST',
            body: payload,
        });

        if (!response.ok) {
            throw new Error('Failed to generate 3D model: ' + await response.text());
        }

        const data = await response.json();
        console.log('Generation started:', data);
        
        alert('Product added successfully and 3D generation started! Job ID: ' + data.jobId);
        navigate('/dashboard');
    } catch (error: any) {
        console.error(error);
        alert('Error publishing product: ' + error.message);
    } finally {
        setIsPublishing(false);
    }
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
          </section>

          <div className="form-actions">
            <button type="button" className="btn-secondary" onClick={() => navigate('/dashboard')} disabled={isPublishing}>Cancel</button>
            <button type="submit" className="btn-primary" disabled={isPublishing}>
              {isPublishing ? 'Publishing & Generating...' : 'Publish Product'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SellerAddProduct;
