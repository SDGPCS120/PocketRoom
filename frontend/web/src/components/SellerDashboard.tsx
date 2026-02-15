import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './SellerDashboard.css';

const SellerDashboard: React.FC = () => {
    const [user, setUser] = useState<any>(null);
    const navigate = useNavigate();

    useEffect(() => {
        const session = localStorage.getItem('currentUser');
        if (!session) {
            navigate('/login');
        } else {
            setUser(JSON.parse(session));
        }
    }, [navigate]);

    const handleLogout = () => {
        localStorage.removeItem('currentUser');
        navigate('/login');
    };

    if (!user) return null;

    return (
        <div className="dashboard-container">
            <nav className="dashboard-nav">
                <div className="nav-brand">PocketRoom</div>
                <div className="nav-user">
                    <span>Welcome, <strong>{user.username}</strong></span>
                    <button onClick={handleLogout} className="logout-button">Logout</button>
                </div>
            </nav>

            <main className="dashboard-content">
                <header className="content-header">
                    <h1>Seller Dashboard</h1>
                    <p>Manage your rooms and analytics here.</p>
                </header>

                <div className="stats-grid">
                    <div className="stat-card">
                        <h3>Total Sales</h3>
                        <p className="stat-value">$12,450</p>
                    </div>
                    <div className="stat-card">
                        <h3>Active Rooms</h3>
                        <p className="stat-value">24</p>
                    </div>
                    <div className="stat-card">
                        <h3>New Orders</h3>
                        <p className="stat-value">8</p>
                    </div>
                </div>

                <section className="recent-activity">
                    <h2>Recent Activity</h2>
                    <div className="activity-list">
                        <div className="activity-item">
                            <span className="dot"></span>
                            <p>New room "Modern Studio" published</p>
                            <span className="time">2 hours ago</span>
                        </div>
                        <div className="activity-item">
                            <span className="dot"></span>
                            <p>Order #5042 received from Sarah J.</p>
                            <span className="time">5 hours ago</span>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    );
};

export default SellerDashboard;
