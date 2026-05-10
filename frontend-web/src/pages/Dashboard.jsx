import React, { useState, useEffect } from 'react';
import StatCard from '../components/dashboard/StatCard';
import RevenueChart from '../components/dashboard/RevenueChart';
import OrderTimeline from '../components/dashboard/OrderTimeline';
import DriverMap from '../components/dashboard/DriverMap';
import { ordersAPI } from '../services/api';
import { useWebSocket } from '../hooks/useWebSocket';

const Dashboard = () => {
  const [stats, setStats] = useState({
    totalOrders: 0,
    totalRevenue: 0,
    activeDrivers: 0,
    pendingOrders: 0,
  });
  const [recentOrders, setRecentOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const { lastMessage } = useWebSocket('dashboard');

  useEffect(() => {
    fetchDashboardData();
  }, []);

  useEffect(() => {
    if (lastMessage) {
      const data = JSON.parse(lastMessage.data);
      if (data.type === 'NEW_ORDER') {
        setRecentOrders(prev => [data.order, ...prev.slice(0, 9)]);
        setStats(prev => ({
          ...prev,
          totalOrders: prev.totalOrders + 1,
          pendingOrders: prev.pendingOrders + 1,
        }));
      } else if (data.type === 'ORDER_UPDATE') {
        updateOrderStatus(data.orderId, data.status);
      }
    }
  }, [lastMessage]);

  const fetchDashboardData = async () => {
    try {
      const [ordersRes, statsRes] = await Promise.all([
        ordersAPI.getAll({ limit: 10 }),
        ordersAPI.getAll({ analytics: true })
      ]);
      
      setRecentOrders(ordersRes.data);
      setStats(statsRes.data.stats);
    } catch (error) {
      console.error('Failed to fetch dashboard data:', error);
    } finally {
      setLoading(false);
    }
  };

  const updateOrderStatus = (orderId, status) => {
    setRecentOrders(prev =>
      prev.map(order =>
        order.id === orderId ? { ...order, status } : order
      )
    );
  };

  if (loading) {
    return <div className="flex justify-center items-center h-full">Loading...</div>;
  }

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-3xl font-bold text-gray-800">Dashboard</h1>
      
      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Total Orders"
          value={stats.totalOrders}
          icon="📦"
          color="bg-blue-500"
          change="+12%"
        />
        <StatCard
          title="Total Revenue"
          value={`Rp ${stats.totalRevenue.toLocaleString()}`}
          icon="💰"
          color="bg-green-500"
          change="+8%"
        />
        <StatCard
          title="Active Drivers"
          value={stats.activeDrivers}
          icon="🚗"
          color="bg-purple-500"
          change="+2"
        />
        <StatCard
          title="Pending Orders"
          value={stats.pendingOrders}
          icon="⏳"
          color="bg-yellow-500"
          change="-5%"
        />
      </div>
      
      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <RevenueChart />
        <DriverMap />
      </div>
      
      {/* Recent Orders */}
      <OrderTimeline orders={recentOrders} />
    </div>
  );
};

export default Dashboard;