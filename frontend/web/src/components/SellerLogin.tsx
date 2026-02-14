import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './SellerLogin.css';

const SellerLogin: React.FC = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const navigate = useNavigate();

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();

        // As requested: take the username and password and save it in a meaningful variable
        const credentials = {
            username: username,
            password: password,
            timestamp: new Date().toISOString()
        };

        console.log('Login attempt with:', credentials);

        // For now, simple validation and redirect
        if (username && password) {
            // Mock saving to variable/state or localStorage if persistent mock needed
            localStorage.setItem('currentUser', JSON.stringify(credentials));
            navigate('/dashboard');
        } else {
            setError('Please enter both username and password.');
        }
    };

    return (
        <div className="login-container">
            <div className="login-card">
                <div className="login-header">
                    <h1>PocketRoom</h1>
                    <p>Seller Portal</p>
                </div>
                <form onSubmit={handleLogin} className="login-form">
                    <div className="form-group">
                        <label htmlFor="username">Username</label>
                        <input
                            type="text"
                            id="username"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            placeholder="Enter your username"
                        />
                    </div>
                    <div className="form-group">
                        <label htmlFor="password">Password</label>
                        <input
                            type="password"
                            id="password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            placeholder="Enter your password"
                        />
                    </div>
                    {error && <p className="error-message">{error}</p>}
                    <button type="submit" className="login-button">
                        Login to Dashboard
                    </button>
                </form>
            </div>
        </div>
    );
};

export default SellerLogin;
