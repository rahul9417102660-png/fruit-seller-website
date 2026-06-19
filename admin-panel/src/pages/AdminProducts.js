import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { FiEdit, FiTrash2, FiPlus } from 'react-icons/fi';
import { toast, ToastContainer } from 'react-toastify';
import './AdminProducts.css';

const AdminProducts = () => {
  const [products, setProducts] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    price: '',
    weight: '',
    category: 'Fruits',
    stock: '',
    image: null,
  });

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const response = await axios.get('http://localhost:5000/api/products');
      if (response.data.success) {
        setProducts(response.data.data);
      }
    } catch (error) {
      toast.error('Error fetching products');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    const { name, value, files } = e.target;
    if (name === 'image') {
      setFormData({ ...formData, image: files[0] });
    } else {
      setFormData({ ...formData, [name]: value });
    }
  };

  const handleAddProduct = async (e) => {
    e.preventDefault();
    
    const form = new FormData();
    form.append('name', formData.name);
    form.append('description', formData.description);
    form.append('price', formData.price);
    form.append('weight', formData.weight);
    form.append('category', formData.category);
    form.append('stock', formData.stock);
    if (formData.image) {
      form.append('image', formData.image);
    }

    try {
      const response = await axios.post('http://localhost:5000/api/products', form, {
        headers: { 'Content-Type': 'multipart/form-data' },
      });

      if (response.data.success) {
        toast.success('Product added successfully!');
        setProducts([...products, response.data.data]);
        setFormData({
          name: '',
          description: '',
          price: '',
          weight: '',
          category: 'Fruits',
          stock: '',
          image: null,
        });
        setShowForm(false);
      }
    } catch (error) {
      toast.error(error.response?.data?.error || 'Error adding product');
    }
  };

  const handleDeleteProduct = async (id) => {
    if (window.confirm('Are you sure?')) {
      try {
        await axios.delete(`http://localhost:5000/api/products/${id}`);
        setProducts(products.filter(p => p._id !== id));
        toast.success('Product deleted!');
      } catch (error) {
        toast.error('Error deleting product');
      }
    }
  };

  if (loading) return <div className="loading">Loading products...</div>;

  return (
    <div className="admin-products">
      <ToastContainer />
      <div className="products-header">
        <h1>Product Management</h1>
        <button className="add-btn" onClick={() => setShowForm(!showForm)}>
          <FiPlus /> Add New Product
        </button>
      </div>

      {showForm && (
        <form className="product-form" onSubmit={handleAddProduct}>
          <div className="form-row">
            <input
              type="text"
              name="name"
              placeholder="Product Name"
              value={formData.name}
              onChange={handleInputChange}
              required
            />
            <input
              type="number"
              name="price"
              placeholder="Price (₹)"
              value={formData.price}
              onChange={handleInputChange}
              required
            />
          </div>
          <div className="form-row">
            <input
              type="number"
              name="weight"
              placeholder="Weight (kg)"
              value={formData.weight}
              onChange={handleInputChange}
              required
            />
            <input
              type="number"
              name="stock"
              placeholder="Stock Quantity"
              value={formData.stock}
              onChange={handleInputChange}
              required
            />
          </div>
          <textarea
            name="description"
            placeholder="Description"
            value={formData.description}
            onChange={handleInputChange}
            rows="3"
            required
          />
          <div className="form-row">
            <select name="category" value={formData.category} onChange={handleInputChange}>
              <option>Fruits</option>
              <option>Vegetables</option>
              <option>Organic</option>
              <option>Premium</option>
            </select>
            <input type="file" name="image" onChange={handleInputChange} required />
          </div>
          <div className="form-buttons">
            <button type="submit" className="submit-btn">Add Product</button>
            <button type="button" className="cancel-btn" onClick={() => setShowForm(false)}>Cancel</button>
          </div>
        </form>
      )}

      <div className="products-table">
        <table>
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Price</th>
              <th>Weight</th>
              <th>Stock</th>
              <th>Category</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {products.map(product => (
              <tr key={product._id}>
                <td>{product.name}</td>
                <td>₹{product.price}</td>
                <td>{product.weight} {product.weightUnit}</td>
                <td>{product.stock}</td>
                <td><span className="category-badge">{product.category}</span></td>
                <td>
                  <button className="edit-btn" title="Edit">
                    <FiEdit />
                  </button>
                  <button className="delete-btn" onClick={() => handleDeleteProduct(product._id)} title="Delete">
                    <FiTrash2 />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default AdminProducts;