import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // In a real application, you would use FormData to send files to a backend
    console.log('Product Data:', formData);
    console.log('Image File:', imageFile?.name);
    console.log('3D Model File:', modelFile?.name);

    alert('Product added successfully! (Simulation)');
    navigate('/dashboard');
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
                <span className="file-title">3D AR Model *</span>
                <span className="file-desc">Upload a .glb or .gltf file for AR placement</span>
                <input type="file" accept=".glb,.gltf" required onChange={(e) => handleFileChange(e, 'model')} className="file-input" />
              </label>
            </div>
          </section>

          <div className="form-actions">
            <button type="button" className="btn-secondary" onClick={() => navigate('/dashboard')}>Cancel</button>
            <button type="submit" className="btn-primary">Publish Product</button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default SellerAddProduct;
