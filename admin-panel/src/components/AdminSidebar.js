import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { FiHome, FiShoppingCart, FiPackage, FiBarChart2, FiLogOut } from 'react-icons/fi';
import './AdminSidebar.css';

const AdminSidebar = ({ adminUser, onLogout }) => {
  const navigate = useNavigate();

  const handleLogout = () => {
    onLogout();
    navigate('/login');
  };

  return (
    <div className="admin-sidebar">
      <div className="sidebar-header">
        <h2>🍎 FruitHub Admin</h2>
      </div>
      
      <nav className="sidebar-nav">
        <Link to="/dashboard" className="nav-item">
          <FiHome /> Dashboard
        </Link>
        <Link to="/products" className="nav-item">
          <FiPackage /> Products
        </Link>
        <Link to="/orders" className="nav-item">
          <FiShoppingCart /> Orders
        </Link>
        <Link to="/analytics" className="nav-item">
          <FiBarChart2 /> Analytics
        </Link>
      </nav>

      <div className="sidebar-footer">
        <div className="user-info">
          <p>{adminUser?.name}</p>
          <small>{adminUser?.email}</small>
        </div>
        <button className="logout-btn" onClick={handleLogout}>
          <FiLogOut /> Logout
        </button>
      </div>
    </div>
  );
};

export default AdminSidebar;