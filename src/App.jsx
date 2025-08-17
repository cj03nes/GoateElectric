import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Link, useLocation } from 'react-router-dom';
import Web3 from 'web3';
import { ethers } from 'ethers';
import { getAddresses, getAbis, updateContractConfig } from './contractConfig';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import './styles.css';
import logo from './images/GoateElectricLogo.jpg';
import UtilitiesPage from './UtilitiesPage';
import DeFiPage from './DefiPage';
import EntertainmentPage from './EntertainmentPage';

// Firebase configuration
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

if (!firebase.apps.length) {
  firebase.initializeApp(firebaseConfig);
}

// Header Component with Static Navigation
const Header = ({ account, connectWallet, user, logout, balances }) => {
  const location = useLocation();
  
  const isActive = (path) => location.pathname === path;
  
  return (
    <header className="static-header">
      <div className="header-container">
        {/* Logo and Brand */}
        <div className="brand-section">
          <img src={logo} alt="GoateElectric" className="logo" />
          <h1 className="brand-title">⚡ GoateElectric</h1>
        </div>

        {/* Navigation */}
        <nav className="main-navigation">
          <Link 
            to="/utilities" 
            className={`nav-button ${isActive('/utilities') ? 'active' : ''}`}
          >
            🔧 Goate Utilities
          </Link>
          <Link 
            to="/defi" 
            className={`nav-button ${isActive('/defi') ? 'active' : ''}`}
          >
            💰 Goate DeFi
          </Link>
          <Link 
            to="/entertainment" 
            className={`nav-button ${isActive('/entertainment') ? 'active' : ''}`}
          >
            🎮 Goate Entertainment
          </Link>
        </nav>

        {/* Wallet & Auth Section */}
        <div className="auth-section">
          {account ? (
            <div className="wallet-info">
              <div className="account-display">
                🦊 {account.slice(0, 6)}...{account.slice(-4)}
              </div>
              <div className="balance-display">
                💰 {balances.GOATE} GOATE
              </div>
            </div>
          ) : (
            <button className="connect-wallet-btn" onClick={connectWallet}>
              🦊 Connect MetaMask
            </button>
          )}
          
          {user && (
            <div className="user-info">
              👤 {user.email}
              <button className="logout-btn" onClick={logout}>Logout</button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

// Main App Component
const App = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');
  const [balances, setBalances] = useState({
    ZPE: 0, ZPP: 0, ZPW: 0, BTC: 0, USD: 0, PI: 0, GOATE: 0, ZGI: 0
  });
  const [devices, setDevices] = useState([]);
  const [user, setUser] = useState(null);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [isWalletConnecting, setIsWalletConnecting] = useState(false);

  // Initialize app
  useEffect(() => {
    const init = async () => {
      setLoading(true);
      try {
        await updateContractConfig();
        
        // Check if wallet is already connected
        if (window.ethereum) {
          const web3Instance = new Web3(window.ethereum);
          const accounts = await web3Instance.eth.getAccounts();
          if (accounts.length > 0) {
            setWeb3(web3Instance);
            setAccount(accounts[0]);
            await fetchBalances(accounts[0]);
            await fetchDevices(accounts[0]);
          }
        }
      } catch (error) {
        console.error('Initialization error:', error);
      }
      setLoading(false);
    };

    init();
    
    // Firebase auth state listener
    const unsubscribe = firebase.auth().onAuthStateChanged((user) => {
      setUser(user);
    });

    return () => unsubscribe();
  }, []);

  // MetaMask connection function
  const connectWallet = async () => {
    if (!window.ethereum) {
      toast.error('MetaMask is not installed. Please install MetaMask to continue.');
      return;
    }

    try {
      setIsWalletConnecting(true);
      await window.ethereum.request({ method: 'eth_requestAccounts' });
      
      const web3Instance = new Web3(window.ethereum);
      setWeb3(web3Instance);
      
      const accounts = await web3Instance.eth.getAccounts();
      setAccount(accounts[0]);
      
      await fetchBalances(accounts[0]);
      await fetchDevices(accounts[0]);
      
      toast.success('🦊 MetaMask connected successfully!');
    } catch (error) {
      console.error('Error connecting wallet:', error);
      toast.error('Failed to connect MetaMask. Please try again.');
    } finally {
      setIsWalletConnecting(false);
    }
  };

  // Fetch token balances
  const fetchBalances = async (userAccount) => {
    try {
      const addresses = getAddresses();
      const abis = getAbis();
      
      if (!web3) return;

      // Fetch ETH balance
      const ethBalance = await web3.eth.getBalance(userAccount);
      const ethBalanceFormatted = web3.utils.fromWei(ethBalance, 'ether');
      
      // Initialize balances with ETH
      const newBalances = {
        ETH: parseFloat(ethBalanceFormatted).toFixed(4),
        ZPE: 0,
        ZPP: 0,
        ZPW: 0,
        BTC: 0,
        USD: 0,
        PI: 0,
        GOATE: 0,
        ZGI: 0
      };

      // Fetch token balances (placeholder for now)
      // TODO: Implement actual token balance fetching when contracts are deployed
      
      setBalances(newBalances);
    } catch (error) {
      console.error('Error fetching balances:', error);
    }
  };

  // Fetch user devices
  const fetchDevices = async (userAccount) => {
    try {
      // TODO: Implement device fetching logic
      setDevices([]);
    } catch (error) {
      console.error('Error fetching devices:', error);
    }
  };

  // Firebase authentication functions
  const login = async () => {
    try {
      await firebase.auth().signInWithEmailAndPassword(email, password);
      toast.success('🔥 Logged in successfully!');
    } catch (error) {
      toast.error('⚠️ Login failed: ' + error.message);
    }
  };

  const register = async () => {
    try {
      await firebase.auth().createUserWithEmailAndPassword(email, password);
      toast.success('🎉 Account created successfully!');
    } catch (error) {
      toast.error('⚠️ Registration failed: ' + error.message);
    }
  };

  const logout = async () => {
    try {
      await firebase.auth().signOut();
      toast.success('👋 Logged out successfully!');
    } catch (error) {
      toast.error('⚠️ Logout failed: ' + error.message);
    }
  };

  // Social login with X (Twitter)
  const loginWithX = async () => {
    try {
      const provider = new firebase.auth.TwitterAuthProvider();
      await firebase.auth().signInWithPopup(provider);
      toast.success('🐦 Logged in with X successfully!');
    } catch (error) {
      toast.error('⚠️ X login failed: ' + error.message);
    }
  };

  // Google login
  const loginWithGoogle = async () => {
    try {
      const provider = new firebase.auth.GoogleAuthProvider();
      await firebase.auth().signInWithPopup(provider);
      toast.success('📧 Logged in with Google successfully!');
    } catch (error) {
      toast.error('⚠️ Google login failed: ' + error.message);
    }
  };

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="loading-content">
          <img src={logo} alt="GoateElectric" className="loading-logo" />
          <h1>⚡ GoateElectric ⚡</h1>
          <p>Loading your Web3 DApp...</p>
          <div className="loading-spinner"></div>
        </div>
      </div>
    );
  }

  return (
    <BrowserRouter>
      <div className="app">
        <Header 
          account={account}
          connectWallet={connectWallet}
          user={user}
          logout={logout}
          balances={balances}
        />
        
        <main className="main-content">
          <Routes>
            <Route path="/" element={<HomePage />} />
            <Route 
              path="/utilities" 
              element={
                <UtilitiesPage 
                  account={account} 
                  devices={devices} 
                  fetchDevices={fetchDevices} 
                  balances={balances} 
                />
              } 
            />
            <Route 
              path="/defi" 
              element={
                <DeFiPage 
                  account={account} 
                  balances={balances} 
                />
              } 
            />
            <Route 
              path="/entertainment" 
              element={
                <EntertainmentPage 
                  account={account} 
                  balances={balances} 
                />
              } 
            />
          </Routes>
        </main>

        {/* Authentication Modal */}
        {!user && (
          <div className="auth-section-main">
            <div className="auth-card">
              <h3>🔐 Access GoateElectric</h3>
              <div className="auth-form">
                <input
                  type="email"
                  placeholder="Email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="auth-input"
                />
                <input
                  type="password"
                  placeholder="Password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="auth-input"
                />
                <div className="auth-buttons">
                  <button onClick={login} className="auth-btn login">Login</button>
                  <button onClick={register} className="auth-btn register">Register</button>
                </div>
                <div className="social-auth">
                  <button onClick={loginWithGoogle} className="social-btn google">
                    📧 Google
                  </button>
                  <button onClick={loginWithX} className="social-btn twitter">
                    🐦 X (Twitter)
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}

        <ToastContainer 
          position="top-right"
          autoClose={5000}
          hideProgressBar={false}
          newestOnTop={false}
          closeOnClick
          rtl={false}
          pauseOnFocusLoss
          draggable
          pauseOnHover
        />
      </div>
    </BrowserRouter>
  );
};

// Home Page Component
const HomePage = () => {
  return (
    <div className="home-page">
      <div className="hero-section">
        <h1>⚡ Welcome to GoateElectric ⚡</h1>
        <p>The Next-Gen Web3 Ecosystem for Utilities, DeFi & Entertainment</p>
        <div className="feature-cards">
          <div className="feature-card">
            <h3>🔧 Utilities</h3>
            <p>Manage devices, purchase services, and control your digital infrastructure</p>
          </div>
          <div className="feature-card">
            <h3>💰 DeFi</h3>
            <p>Trade, stake, lend, and borrow with advanced financial instruments</p>
          </div>
          <div className="feature-card">
            <h3>🎮 Entertainment</h3>
            <p>Play games, bet on teams, and trade NFTs in our gaming ecosystem</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default App;