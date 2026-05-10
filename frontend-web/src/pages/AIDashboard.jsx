import React, { useState, useEffect } from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts';
import { FaRobot, FaChartLine, FaShieldAlt, FaRoute, FaFileAlt, FaCamera } from 'react-icons/fa';
import api from '../services/api';

const AIDashboard = () => {
  const [forecast, setForecast] = useState(null);
  const [fraudAlerts, setFraudAlerts] = useState([]);
  const [aiStats, setAiStats] = useState({
    totalVerifications: 0,
    avgConfidence: 0,
    routesOptimized: 0,
    timeSaved: 0,
  });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAIData();
    const interval = setInterval(fetchAIData, 30000); // Refresh every 30s
    return () => clearInterval(interval);
  }, []);

  const fetchAIData = async () => {
    try {
      const [forecastRes, fraudRes, statsRes] = await Promise.all([
        api.get('/ai/forecast'),
        api.get('/ai/fraud-alerts'),
        api.get('/ai/stats'),
      ]);
      
      setForecast(forecastRes.data);
      setFraudAlerts(fraudRes.data);
      setAiStats(statsRes.data);
    } catch (error) {
      console.error('Failed to fetch AI data:', error);
    } finally {
      setLoading(false);
    }
  };

  const resolveFraudAlert = async (alertId, action) => {
    try {
      await api.post(`/ai/fraud-alerts/${alertId}/resolve`, { action });
      setFraudAlerts(prev => prev.filter(alert => alert.id !== alertId));
    } catch (error) {
      console.error('Failed to resolve alert:', error);
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-96">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold text-gray-800">AI Dashboard</h1>
        <div className="flex space-x-2">
          <span className="px-3 py-1 bg-green-100 text-green-700 rounded-full text-sm">
            AI Active
          </span>
          <span className="px-3 py-1 bg-blue-100 text-blue-700 rounded-full text-sm">
            Real-time Monitoring
          </span>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="AI Verifications"
          value={aiStats.totalVerifications.toLocaleString()}
          icon={<FaFileAlt className="text-blue-500" size={24} />}
          change="+24%"
          color="bg-blue-50"
        />
        <StatCard
          title="Avg Confidence"
          value={`${(aiStats.avgConfidence * 100).toFixed(1)}%`}
          icon={<FaRobot className="text-purple-500" size={24} />}
          change="+5%"
          color="bg-purple-50"
        />
        <StatCard
          title="Routes Optimized"
          value={aiStats.routesOptimized.toLocaleString()}
          icon={<FaRoute className="text-green-500" size={24} />}
          change={`${aiStats.timeSaved} min saved`}
          color="bg-green-50"
        />
        <StatCard
          title="Fraud Prevention"
          value={fraudAlerts.length}
          icon={<FaShieldAlt className="text-red-500" size={24} />}
          change="Potential risks"
          color="bg-red-50"
        />
      </div>

      {/* Demand Forecasting Chart */}
      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Demand Forecasting (AI-Powered)</h2>
          <div className="flex space-x-2">
            <button className="px-3 py-1 text-sm bg-blue-500 text-white rounded">7 Days</button>
            <button className="px-3 py-1 text-sm bg-gray-200 rounded">14 Days</button>
            <button className="px-3 py-1 text-sm bg-gray-200 rounded">30 Days</button>
          </div>
        </div>
        <ResponsiveContainer width="100%" height={400}>
          <LineChart data={forecast?.daily || []}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="day" label={{ value: 'Hari', position: 'bottom' }} />
            <YAxis label={{ value: 'Jumlah Pesanan', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="forecastCount" stroke="#8884d8" name="Forecast" strokeWidth={2} />
            <Line type="monotone" dataKey="confidence" stroke="#82ca9d" name="Confidence" />
          </LineChart>
        </ResponsiveContainer>
        {forecast?.recommendation && (
          <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded">
            <p className="text-yellow-800">
              <strong>AI Recommendation:</strong> {forecast.recommendation}
            </p>
          </div>
        )}
      </div>

      {/* Fraud Alerts */}
      <div className="bg-white rounded-lg shadow p-6">
        <h2 className="text-xl font-semibold mb-4">Fraud Detection Alerts</h2>
        {fraudAlerts.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <FaShieldAlt size={48} className="mx-auto mb-2 text-green-500" />
            <p>No fraud alerts detected</p>
          </div>
        ) : (
          <div className="space-y-4">
            {fraudAlerts.map(alert => (
              <div key={alert.id} className="border rounded-lg p-4 bg-red-50">
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <div className="flex items-center space-x-2">
                      <span className="px-2 py-1 bg-red-200 text-red-800 text-xs rounded">
                        {alert.severity}
                      </span>
                      <span className="text-sm text-gray-500">
                        {new Date(alert.createdAt).toLocaleString()}
                      </span>
                    </div>
                    <p className="mt-2 text-gray-800">{alert.message}</p>
                    <div className="mt-2 text-sm text-gray-600">
                      <strong>Order:</strong> #{alert.orderNumber}<br />
                      <strong>Driver:</strong> {alert.driverName}<br />
                      <strong>Flags:</strong> {alert.flags.join(', ')}
                    </div>
                  </div>
                  <div className="flex space-x-2">
                    <button
                      onClick={() => resolveFraudAlert(alert.id, 'approved')}
                      className="px-3 py-1 bg-green-500 text-white rounded text-sm"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => resolveFraudAlert(alert.id, 'investigate')}
                      className="px-3 py-1 bg-yellow-500 text-white rounded text-sm"
                    >
                      Investigate
                    </button>
                    <button
                      onClick={() => resolveFraudAlert(alert.id, 'reject')}
                      className="px-3 py-1 bg-red-500 text-white rounded text-sm"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* AI Performance Metrics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">AI Verification Performance</h2>
          <ResponsiveContainer width="100%" height={300}>
            <BarChart data={aiStats.performance || []}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="type" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="accuracy" fill="#8884d8" name="Accuracy (%)" />
              <Bar dataKey="speed" fill="#82ca9d" name="Speed (ms)" />
            </BarChart>
          </ResponsiveContainer>
        </div>
        
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-semibold mb-4">Route Optimization Impact</h2>
          <ResponsiveContainer width="100%" height={300}>
            <PieChart>
              <Pie
                data={[
                  { name: 'Time Saved', value: aiStats.timeSaved || 0 },
                  { name: 'Normal Time', value: aiStats.normalTime || 100 },
                ]}
                cx="50%"
                cy="50%"
                labelLine={false}
                label={entry => `${entry.name}: ${entry.value}min`}
                outerRadius={80}
                fill="#8884d8"
              >
                <Cell fill="#4CAF50" />
                <Cell fill="#FFC107" />
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  );
};

const StatCard = ({ title, value, icon, change, color }) => (
  <div className={`rounded-lg shadow p-6 ${color}`}>
    <div className="flex justify-between items-start">
      <div>
        <p className="text-gray-600 text-sm">{title}</p>
        <p className="text-2xl font-bold mt-2">{value}</p>
        <p className="text-green-600 text-sm mt-2">{change}</p>
      </div>
      <div className="p-3 bg-white rounded-full shadow">
        {icon}
      </div>
    </div>
  </div>
);

export default AIDashboard;