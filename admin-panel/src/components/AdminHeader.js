import React from 'react';
import './AdminHeader.css';

const AdminHeader = ({ adminUser, onLogout }) => {
  return (
    <div className="admin-header">
      <div className="header-content">
        <h1>Welcome back, {adminUser?.name}! 👋</h1>
        <p className="header-time">Last login: {new Date().toLocaleString()}</p>
      </div>
      <div className="header-stats">
        <div className="stat-badge">
          <span className="stat-label">Total Sales</span>
          <span className="stat-value">₹ 45,000</span>
        </div>
        <div className="stat-badge">
          <span className="stat-label">New Orders</span>
          <span className="stat-value">12</span>
        </div>
        <div className="stat-badge">
          <span className="stat-label">Products</span>
          <span className="stat-value">28</span>
        </div>
      </div>
    </div>
  );
};

export default AdminHeader;