import React from 'react';

export interface FormFieldProps {
  id: string;
  label: string;
  required?: boolean;
  error?: string;
  hint?: string;
  children: React.ReactNode;
}

const FormField: React.FC<FormFieldProps> = ({
  id,
  label,
  required,
  error,
  hint,
  children,
}) => (
  <div className="form-group">
    <label htmlFor={id}>
      {label}
      {required && <span className="required"> *</span>}
    </label>
    {children}
    {hint && !error && <span className="form-hint">{hint}</span>}
    {error && <span className="error-msg">{error}</span>}
  </div>
);

export default FormField;
