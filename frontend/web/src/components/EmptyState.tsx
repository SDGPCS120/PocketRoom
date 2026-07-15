import React from 'react';

export interface EmptyStateProps {
  icon?: React.ReactNode;
  title: string;
  description?: string;
  action?: React.ReactNode;
}

const EmptyState: React.FC<EmptyStateProps> = ({ icon, title, description, action }) => (
  <div className="empty-state">
    {icon && <div className="empty-icon">{icon}</div>}
    <h3>{title}</h3>
    {description && <p>{description}</p>}
    {action}
  </div>
);

export default EmptyState;
