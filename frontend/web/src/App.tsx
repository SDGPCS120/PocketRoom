import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import SellerLogin from './components/SellerLogin';
import SellerRegister from './components/SellerRegister';
import SellerDashboard from './components/SellerDashboard';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <Routes>
          <Route path="/register" element={<SellerRegister />} />
          <Route path="/login" element={<SellerLogin />} />
          <Route path="/dashboard" element={<SellerDashboard />} />
          {/* Default to register page */}
          <Route path="/" element={<Navigate to="/register" replace />} />
          {/* Catch all - redirect to register */}
          <Route path="*" element={<Navigate to="/register" replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
