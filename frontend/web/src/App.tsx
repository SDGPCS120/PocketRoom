import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import SellerWelcome from './components/SellerWelcome';
import SellerLogin from './components/SellerLogin';
import SellerRegister from './components/SellerRegister';
import SellerDashboard from './components/SellerDashboard';
import SellerAddProduct from './components/SellerAddProduct';
import SellerProducts from './components/SellerProducts';
import SellerAnalytics from './components/SellerAnalytics';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <Routes>
          <Route path="/" element={<SellerWelcome />} />
          <Route path="/register" element={<SellerRegister />} />
          <Route path="/login" element={<SellerLogin />} />
          <Route path="/dashboard" element={<SellerDashboard />} />
          <Route path="/add-product" element={<SellerAddProduct />} />
          <Route path="/products" element={<SellerProducts />} />
          <Route path="/analytics" element={<SellerAnalytics />} />
          {/* Catch all - redirect to welcome */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
