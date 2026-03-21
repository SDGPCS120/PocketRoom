import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import SellerWelcome from './components/SellerWelcome';
import SellerLogin from './components/SellerLogin';
import SellerRegister from './components/SellerRegister';
import SellerDashboard from './components/SellerDashboard';
import SellerAddProduct from './components/SellerAddProduct';
import SellerProducts from './components/SellerProducts';
import SellerAnalytics from './components/SellerAnalytics';
import { SellerSessionProvider } from './auth/sellerSession';
import ProtectedRoute from './auth/ProtectedRoute';
import './App.css';

function App() {
  return (
    <SellerSessionProvider>
      <Router>
        <div className="app">
          <Routes>
            <Route path="/" element={<SellerWelcome />} />
            <Route path="/register" element={<SellerRegister />} />
            <Route path="/login" element={<SellerLogin />} />
            <Route
              path="/dashboard"
              element={
                <ProtectedRoute>
                  <SellerDashboard />
                </ProtectedRoute>
              }
            />
            <Route
              path="/add-product"
              element={
                <ProtectedRoute>
                  <SellerAddProduct />
                </ProtectedRoute>
              }
            />
            <Route
              path="/products"
              element={
                <ProtectedRoute>
                  <SellerProducts />
                </ProtectedRoute>
              }
            />
            <Route
              path="/analytics"
              element={
                <ProtectedRoute>
                  <SellerAnalytics />
                </ProtectedRoute>
              }
            />
            {/* Catch all - redirect to welcome */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </div>
      </Router>
    </SellerSessionProvider>
  );
}

export default App;
