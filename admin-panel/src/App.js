import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import axios from 'axios';
import './App.css';

// Admin Pages
import AdminLogin from './pages/AdminLogin';
import AdminDashboard from './pages/AdminDashboard';
import AdminProducts from './pages/AdminProducts';
import AdminOrders from './pages/AdminOrders';
import AdminAnalytics from './pages/AdminAnalytics';

// Admin Components
import AdminSidebar from './components/AdminSidebar';
import AdminHeader from './components/AdminHeader';

const API_BASE_URL = 'http://localhost:5000/api';

function App() {
  const [adminUser, setAdminUser] = useState(null);
  const [isLoggedIn, setIsLoggedIn] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem('adminToken');
    const user = localStorage.getItem('adminUser');

    if (token && user) {
      setAdminUser(JSON.parse(user));
      setIsLoggedIn(true);
    }
  }, []);

  const handleAdminLogout = () => {
    localStorage.removeItem('adminToken');
    localStorage.removeItem('adminUser');
    setAdminUser(null);
    setIsLoggedIn(false);
  };

  if (!isLoggedIn) {
    return (
      <Router>
        <Routes>
          <Route path="*" element={<AdminLogin setAdminUser={setAdminUser} setIsLoggedIn={setIsLoggedIn} />} />
        </Routes>
      </Router>
    );
  }

  return (
    <Router>
      <div className="admin-app">
        <AdminSidebar adminUser={adminUser} onLogout={handleAdminLogout} />
        <div className="admin-main">
          <AdminHeader adminUser={adminUser} onLogout={handleAdminLogout} />
          <div className="admin-content">
            <Routes>
              <Route path="/dashboard" element={<AdminDashboard />} />
              <Route path="/products" element={<AdminProducts />} />
              <Route path="/orders" element={<AdminOrders />} />
              <Route path="/analytics" element={<AdminAnalytics />} />
            </Routes>
          </div>
        </div>
      </div>
    </Router>
  );
}

export default App;
