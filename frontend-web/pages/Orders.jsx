import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

export default function Orders() {
  const { token, user } = useAuth();
  const [orders, setOrders] = useState([]);

  useEffect(() => {
    const endpoint = user.role === 'ADMIN' 
      ? 'http://localhost:3000/api/admin/orders'
      : 'http://localhost:3000/api/orders/my-orders';
    axios.get(endpoint, { headers: { Authorization: `Bearer ${token}` } })
      .then(res => setOrders(res.data));
  }, []);

  const updateStatus = async (orderId, status) => {
    await axios.put(`http://localhost:3000/api/admin/orders/${orderId}/status`, { status }, {
      headers: { Authorization: `Bearer ${token}` }
    });
    window.location.reload();
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Orders</h1>
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Order ID</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">File</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Total</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Status</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Payment</th>
              {user.role === 'ADMIN' && <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Action</th>}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {orders.map(order => (
              <tr key={order.id}>
                <td className="px-6 py-4 text-sm">{order.id.slice(0,8)}</td>
                <td className="px-6 py-4 text-sm">{order.fileName}</td>
                <td className="px-6 py-4 text-sm">Rp {order.totalPrice?.toLocaleString()}</td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    order.deliveryStatus === 'DELIVERED' ? 'bg-green-100 text-green-800' :
                    order.deliveryStatus === 'IN_TRANSIT' ? 'bg-blue-100 text-blue-800' : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {order.deliveryStatus}
                  </span>
                </td>
                <td className="px-6 py-4 text-sm">{order.paymentMethod}</td>
                {user.role === 'ADMIN' && (
                  <td className="px-6 py-4">
                    <select onChange={(e) => updateStatus(order.id, e.target.value)} className="text-sm border rounded p-1">
                      <option value="PENDING">Pending</option>
                      <option value="PROCESSING">Processing</option>
                      <option value="PICKED_UP">Picked Up</option>
                      <option value="IN_TRANSIT">In Transit</option>
                      <option value="DELIVERED">Delivered</option>
                    </select>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}