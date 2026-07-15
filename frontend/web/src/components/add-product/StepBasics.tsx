import React from 'react';
import { CATEGORIES } from '../../constants/categories';
import FormField from '../FormField';
import type { AddProductFormData, FormErrors } from './useAddProductForm';

interface StepBasicsProps {
  form: AddProductFormData;
  errors: FormErrors;
  onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void;
}

const StepBasics: React.FC<StepBasicsProps> = ({ form, errors, onChange }) => (
  <div className="form-step">
    <h2>Basic Information</h2>
    <p className="form-subtitle">Tell buyers what this product is and how much it costs.</p>

    <FormField id="name" label="Product Name" required error={errors.name}>
      <input
        type="text"
        id="name"
        name="name"
        value={form.name}
        onChange={onChange}
        placeholder="e.g., Modern Velvet Sofa"
        className={errors.name ? 'input-error' : ''}
      />
    </FormField>

    <FormField id="description" label="Description" required error={errors.description} hint="At least 20 characters">
      <textarea
        id="description"
        name="description"
        rows={4}
        value={form.description}
        onChange={onChange}
        placeholder="Describe the item, materials, and what makes it special…"
        className={errors.description ? 'input-error' : ''}
      />
    </FormField>

    <div className="form-row">
      <FormField id="furnitureType" label="Category" required error={errors.furnitureType}>
        <select
          id="furnitureType"
          name="furnitureType"
          value={form.furnitureType}
          onChange={onChange}
          className={errors.furnitureType ? 'input-error' : ''}
        >
          {CATEGORIES.map((c) => (
            <option key={c} value={c}>
              {c}
            </option>
          ))}
        </select>
      </FormField>

      <FormField id="price" label="Price (LKR)" required error={errors.price}>
        <input
          type="number"
          id="price"
          name="price"
          min="0"
          step="0.01"
          value={form.price}
          onChange={onChange}
          placeholder="29999"
          className={errors.price ? 'input-error' : ''}
        />
      </FormField>
    </div>
  </div>
);

export default StepBasics;
