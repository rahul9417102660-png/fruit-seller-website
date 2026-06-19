import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { toast, ToastContainer } from 'react-toastify';
import './AdminOrders.css';

const AdminOrders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedOrder, setSelectedOrder] = useState(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/orders');
      if (response.data.success) {
        setOrders(response.data.data);
      }
    } catch (error) {
      toast.error('Error fetching orders');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusChange = async (orderId, newStatus) => {
    try {
      const response = await axios.put(`http://localhost:5000/api/orders/${orderId}/status`, {
        status: newStatus,
      });

      if (response.data.success) {
        setOrders(orders.map(o => o._id === orderId ? response.data.data : o));
        toast.success('Order status updated!');
      }
    } catch (error) {
      toast.error('Error updating order');
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      'Pending': '#f59e0b',
      'Confirmed': '#3b82f6',
      'Processing': '#8b5cf6',
      'Shipped': '#06b6d4',
      'Delivered': '#10b981',
      'Cancelled': '#ef4444',
    };
    return colors[status] || '#666';
  };

  if (loading) return <div className="loading">Loading orders...</div>;

  return (
    <div className="admin-orders">
      <ToastContainer />
      <h1>Order Management</h1>

      <div className="orders-grid">
        {orders.map(order => (
          <div key={order._id} className="order-card">
            <div className="order-header">
              <div>
                <h3>{order.orderNumber}</h3>
                <p className="order-date">{new Date(order.createdAt).toLocaleDateString()}</p>
              </div>
              <div
                className="order-status"
                style={{ backgroundColor: getStatusColor(order.status) }}
              >
                {order.status}
              </div>
            </div>

            <div className="order-details">
              <div className="detail-row">
                <span className="label">Customer:</span>
                <span className="value">{order.customer?.name}</span>
              </div>
              <div className="detail-row">
                <span className="label">Phone:</span>
                <span className="value">{order.customer?.phone}</span>
              </div>
              <div className="detail-row">
                <span className="label">Address:</span>
                <span className="value">{order.customer?.address}, {order.customer?.city}</span>
              </div>
              <div className="detail-row">
                <span className="label">Total Amount:</span>
                <span className="value price">₹{order.totalAmount}</span>
              </div>
              <div className="detail-row">
                <span className="label">Quantity:</span>
                <span className="value">{order.quantity} kg</span>
              </div>
            </div>

            <div className="order-actions">
              <select
                value={order.status}
                onChange={(e) => handleStatusChange(order._id, e.target.value)}
                className="status-select"
              >
                <option>Pending</option>
                <option>Confirmed</option>
                <option>Processing</option>
                <option>Shipped</option>
                <option>Delivered</option>
                <option>Cancelled</option>
              </select>
              <button className="view-btn" onClick={() => setSelectedOrder(order)}>View Details</button>
            </div>
          </div>
        ))}
      </div>

      {selectedOrder && (
        <div className="modal-overlay" onClick={() => setSelectedOrder(null)}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <h2>Order Details: {selectedOrder.orderNumber}</h2>
            <div className="modal-body">
              <h3>Customer Information</h3>
              <p><strong>Name:</strong> {selectedOrder.customer?.name}</p>
              <p><strong>Email:</strong> {selectedOrder.customer?.email}</p>
              <p><strong>Phone:</strong> {selectedOrder.customer?.phone}</p>
              <p><strong>Address:</strong> {selectedOrder.customer?.address}</p>
              <p><strong>City:</strong> {selectedOrder.customer?.city}, {selectedOrder.customer?.state}</p>
              <p><strong>Pincode:</strong> {selectedOrder.customer?.pincode}</p>

              <h3>Order Items</h3>
              <table className="items-table">
                <thead>
                  <tr>
                    <th>Product</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Total</th>
                  </tr>
                </thead>
                <tbody>
                  {selectedOrder.items?.map((item, idx) => (
                    <tr key={idx}>
                      <td>{item.productName}</td>
                      <td>{item.quantity}</td>
                      <td>₹{item.price}</td>
                      <td>₹{item.totalPrice}</td>
                    </tr>
                  ))}
                </tbody>
              </table>

              <div className="order-summary">
                <p><strong>Total Amount:</strong> ₹{selectedOrder.totalAmount}</p>
                <p><strong>Payment Method:</strong> {selectedOrder.paymentMethod}</p>
                <p><strong>Payment Status:</strong> {selectedOrder.paymentStatus}</p>
              </div>
            </div>
            <button className="close-btn" onClick={() => setSelectedOrder(null)}>Close</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default AdminOrders;