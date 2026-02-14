import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import SellerLogin from './components/SellerLogin';
import SellerDashboard from './components/SellerDashboard';
import './App.css';

function App() {
  return (
    <Router>
      <div className="app">
        <Routes>
          <Route path="/login" element={<SellerLogin />} />
          <Route path="/dashboard" element={<SellerDashboard />} />
          {/* Default to login page */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          {/* Catch all - redirect to login */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </div>
    </Router>
  );
}

export default App;
