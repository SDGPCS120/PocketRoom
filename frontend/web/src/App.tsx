import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import SellerWelcome from './components/SellerWelcome';
import SellerLogin from './components/SellerLogin';
import SellerRegister from './components/SellerRegister';
import SellerDashboard from './components/SellerDashboard';
import AddProductWizard from './components/add-product/AddProductWizard';
import SellerProducts from './components/SellerProducts';
import SellerEditProduct from './components/SellerEditProduct';
import SellerAnalytics from './components/SellerAnalytics';
import { SellerSessionProvider } from './auth/sellerSession';
import ProtectedRoute from './auth/ProtectedRoute';
import { ToastProvider } from './components/Toast';
import './App.css';

function App() {
  return (
    <SellerSessionProvider>
      <ToastProvider>
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
                    <AddProductWizard />
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
                path="/products/:productId"
                element={
                  <ProtectedRoute>
                    <SellerEditProduct />
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
      </ToastProvider>
    </SellerSessionProvider>
  );
}

export default App;
