import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './contexts/AuthContext';
import { SocketProvider } from './contexts/SocketContext';
import { ThemeProvider } from './contexts/ThemeContext';
import ProtectedRoute from './components/common/ProtectedRoute';
import Layout from './components/common/Layout';

// Pages
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Orders from './pages/Orders';
import OrderDetail from './pages/OrderDetail';
import Drivers from './pages/Drivers';
import DriverDetail from './pages/DriverDetail';
import Partners from './pages/Partners';
import HubPoints from './pages/HubPoints';
import Campaigns from './pages/Campaigns';
import EmailAnalytics from './pages/EmailAnalytics';
import Settings from './pages/Settings';
import AIDashboard from './pages/AIDashboard';
import NotFound from './pages/NotFound';

function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <SocketProvider>
          <Router>
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/register" element={<Register />} />
              
              <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
                <Route index element={<Dashboard />} />
                <Route path="orders" element={<Orders />} />
                <Route path="orders/:id" element={<OrderDetail />} />
                <Route path="drivers" element={<Drivers />} />
                <Route path="drivers/:id" element={<DriverDetail />} />
                <Route path="partners" element={<Partners />} />
                <Route path="hub-points" element={<HubPoints />} />
                <Route path="campaigns" element={<Campaigns />} />
                <Route path="email-analytics" element={<EmailAnalytics />} />
                <Route path="ai-dashboard" element={<AIDashboard />} />
                <Route path="settings" element={<Settings />} />
              </Route>
              
              <Route path="*" element={<NotFound />} />
            </Routes>
          </Router>
        </SocketProvider>
      </AuthProvider>
    </ThemeProvider>
  );
}

export default App;