import React from 'react';
import FormField from '../FormField';
import type { AddProductFormData, FormErrors } from './useAddProductForm';

interface StepDetailsProps {
  form: AddProductFormData;
  errors: FormErrors;
  onChange: (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void;
}

const StepDetails: React.FC<StepDetailsProps> = ({ form, errors, onChange }) => (
  <div className="form-step">
    <h2>Details</h2>
    <p className="form-subtitle">Dimensions and tags help buyers find and visualize your product. All fields are optional.</p>

    {errors.dimensions && <div className="form-error">{errors.dimensions}</div>}

    <h3 className="form-section-title">Dimensions (cm)</h3>
    <div className="form-row three-col">
      <FormField id="width" label="Width" error={errors.width}>
        <input
          type="number"
          id="width"
          name="width"
          min="0"
          value={form.width}
          onChange={onChange}
          placeholder="W"
          className={errors.width ? 'input-error' : ''}
        />
      </FormField>
      <FormField id="height" label="Height" error={errors.height}>
        <input
          type="number"
          id="height"
          name="height"
          min="0"
          value={form.height}
          onChange={onChange}
          placeholder="H"
          className={errors.height ? 'input-error' : ''}
        />
      </FormField>
      <FormField id="depth" label="Depth" error={errors.depth}>
        <input
          type="number"
          id="depth"
          name="depth"
          min="0"
          value={form.depth}
          onChange={onChange}
          placeholder="D"
          className={errors.depth ? 'input-error' : ''}
        />
      </FormField>
    </div>

    <FormField id="materials" label="Materials (comma separated)" error={errors.materials}>
      <input
        type="text"
        id="materials"
        name="materials"
        value={form.materials}
        onChange={onChange}
        placeholder="e.g., Wood, Fabric, Metal"
      />
    </FormField>

    <FormField id="styleTags" label="Style Tags (comma separated)" error={errors.styleTags}>
      <input
        type="text"
        id="styleTags"
        name="styleTags"
        value={form.styleTags}
        onChange={onChange}
        placeholder="e.g., Modern, Minimalist, Luxurious"
      />
    </FormField>
  </div>
);

export default StepDetails;
