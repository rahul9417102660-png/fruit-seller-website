import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import './AdminAnalytics.css';

const AdminAnalytics = () => {
  const [chartData, setChartData] = useState([
    { category: 'Fruits', sales: 8000 },
    { category: 'Vegetables', sales: 6000 },
    { category: 'Organic', sales: 5000 },
    { category: 'Premium', sales: 4500 },
  ]);

  return (
    <div className="admin-analytics">
      <h1>Sales Analytics</h1>

      <div className="analytics-grid">
        <div className="analytics-card">
          <h3>Sales by Category</h3>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="category" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Bar dataKey="sales" fill="#667eea" />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="analytics-card">
          <h3>Key Metrics</h3>
          <div className="metrics-list">
            <div className="metric-item">
              <span>Avg Order Value</span>
              <p>₹2,450</p>
            </div>
            <div className="metric-item">
              <span>Customer Satisfaction</span>
              <p>4.8/5.0</p>
            </div>
            <div className="metric-item">
              <span>Delivery Rate</span>
              <p>98.5%</p>
            </div>
            <div className="metric-item">
              <span>Return Rate</span>
              <p>2.3%</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AdminAnalytics;