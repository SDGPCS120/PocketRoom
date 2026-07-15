import React from 'react';

const STEP_LABELS = ['Basics', 'Details', 'Media', 'Review'];

interface StepIndicatorProps {
  step: 1 | 2 | 3 | 4;
}

const StepIndicator: React.FC<StepIndicatorProps> = ({ step }) => (
  <div className="add-product-steps">
    <div className="step-indicator wizard-4">
      {[1, 2, 3, 4].map((n, i) => (
        <React.Fragment key={n}>
          {i > 0 && <div className={`step-line ${step >= n ? 'active' : ''}`} />}
          <div className={`step-dot ${step >= n ? 'active' : ''}`}>
            <span>{n}</span>
          </div>
        </React.Fragment>
      ))}
    </div>
    <div className="step-labels wizard-4-labels">
      {STEP_LABELS.map((label, i) => (
        <span key={label} className={step === i + 1 ? 'label-active' : ''}>
          {label}
        </span>
      ))}
    </div>
  </div>
);

export default StepIndicator;
