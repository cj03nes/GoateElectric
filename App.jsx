import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import Web3 from 'web3';
import { ethers } from 'ethers';
import { getAddresses, getAbis, updateContractConfig } from './contractConfig';
import { ToastContainer, toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import firebase from 'firebase/compat/app';
import 'firebase/compat/auth';
import './styles.css';
import logo from './images/GoateElectricLogo.jpg';

// Firebase configuration
const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID
};

firebase.initializeApp(firebaseConfig);

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

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      await updateContractConfig();
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        setWeb3(web3Instance);
        const accounts = await web3Instance.eth.getAccounts();
        setAccount(accounts[0]);
        await fetchBalances(accounts[0]);
        await fetchDevices(accounts[0]);
      }
      firebase.auth().onAuthStateChanged((user) => {
        setUser(user);
        setLoading(false);
      });
    };
    init();
  }, []);

  const fetchBalances = async (user) => {
    setLoading(true);
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      getAddresses().InstilledInteroperability,
      getAbis().InstilledInteroperability,
      provider
    );
    const assets = ['ZPE', 'ZPP', 'ZPW', 'BTC', 'USD', 'PI', 'GOATE', 'ZGI'];
    const newBalances = {};
    for (let asset of assets) {
      try {
        const balance = await contract.activeBalances(user, asset);
        newBalances[asset] = ethers.utils.formatUnits(balance, 18);
      } catch (error) {
        console.error(`Error fetching ${asset} balance:`, error);
        newBalances[asset] = '0';
        toast.error(`Failed to fetch ${asset} balance`);
      }
    }
    setBalances(newBalances);
    setLoading(false);
  };

  const fetchDevices = async (user) => {
    setLoading(true);
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      getAddresses().DeviceConnect,
      getAbis().DeviceConnect,
      provider.getSigner()
    );
    try {
      const deviceList = await contract.getUserDevices(user);
      setDevices(deviceList);
      toast.success('Devices fetched successfully');
    } catch (error) {
      console.error('Error fetching devices:', error);
      toast.error('Failed to fetch devices');
    }
    setLoading(false);
  };

  const connectDevice = async (deviceId) => {
    if (!deviceId) return toast.error('Device ID required');
    setLoading(true);
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      getAddresses().DeviceConnect,
      getAbis().DeviceConnect,
      provider.getSigner()
    );
    try {
      await contract.connectDevice(deviceId);
      await fetchDevices(account);
      toast.success('Device connected successfully');
    } catch (error) {
      console.error('Error connecting device:', error);
      toast.error('Failed to connect device');
    }
    setLoading(false);
  };

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await firebase.auth().signInWithEmailAndPassword(email, password);
      toast.success('Logged in successfully');
    } catch (error) {
      console.error('Login error:', error);
      toast.error(`Login failed: ${error.message}`);
    }
    setLoading(false);
  };

  const handleSocialLogin = async (provider) => {
    setLoading(true);
    let authProvider;
    switch (provider) {
      case 'google':
        authProvider = new firebase.auth.GoogleAuthProvider();
        break;
      case 'microsoft':
        authProvider = new firebase.auth.OAuthProvider('microsoft.com');
        break;
      case 'twitter':
        authProvider = new firebase.auth.TwitterAuthProvider();
        break;
      default:
        return;
    }
    try {
      await firebase.auth().signInWithPopup(authProvider);
      toast.success(`Logged in with ${provider}`);
    } catch (error) {
      console.error(`${provider} login error:`, error);
      toast.error(`Failed to login with ${provider}`);
    }
    setLoading(false);
  };

  const handleLogout = async () => {
    setLoading(true);
    try {
      await firebase.auth().signOut();
      setUser(null);
      setEmail('');
      setPassword('');
      toast.success('Logged out successfully');
    } catch (error) {
      console.error('Logout error:', error);
      toast.error('Failed to logout');
    }
    setLoading(false);
  };

  const timestamp = new Date().toLocaleString();

  return (
    <BrowserRouter>
      <div className="bg-black text-gold min-h-screen">
        <header className="flex justify-between items-center p-4 border-b border-gold">
          <div className="flex items-center">
            <img src={logo} alt="Goate Electric Logo" className="h-12 w-12 mr-2" />
            <h1 className="text-2xl font-normal">Goate Electric</h1>
          </div>
          <div className="flex space-x-4">
            {user ? (
              <>
                <p>{user.displayName || user.email}</p>
                <button
                  className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
                  onClick={handleLogout}
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <form onSubmit={handleLogin} className="flex space-x-2">
                  <input
                    type="email"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    placeholder="Email"
                    className="bg-gray-900 text-gold p-2 rounded"
                  />
                  <input
                    type="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="Password"
                    className="bg-gray-900 text-gold p-2 rounded"
                  />
                  <button
                    type="submit"
                    className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
                  >
                    Login
                  </button>
                </form>
                <button
                  className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
                  onClick={() => handleSocialLogin('google')}
                >
                  Google
                </button>
                <button
                  className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
                  onClick={() => handleSocialLogin('microsoft')}
                >
                  Microsoft
                </button>
                <button
                  className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
                  onClick={() => handleSocialLogin('twitter')}
                >
                  X
                </button>
              </>
            )}
            <button
              className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
              onClick={() => connectDevice(prompt('Enter Device ID'))}
            >
              Connect Device ({devices.length})
            </button>
            <select className="bg-gold text-black px-4 py-2 rounded">
              <option>Settings</option>
              <option>Wallet</option>
            </select>
          </div>
        </header>
        {loading && <div className="loading">Loading...</div>}
        <main className="p-4">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
            {Object.entries(balances).map(([asset, balance]) => (
              <div key={asset} className="bg-gray-900 p-4 rounded text-center">
                <p className="text-lg">${asset} Balance</p>
                <p>{balance}</p>
              </div>
            ))}
          </div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <Link
              to="/utilities"
              className="bg-gray-900 p-6 rounded text-center hover:bg-gray-800"
            >
              Goate Utilities
            </Link>
            <Link
              to="/defi"
              className="bg-gray-900 p-6 rounded text-center hover:bg-gray-800"
            >
              Goate DeFi
            </Link>
            <Link
              to="/entertainment"
              className="bg-gray-900 p-6 rounded text-center hover:bg-gray-800"
            >
              Goate Entertainment
            </Link>
          </div>
          <footer className="text-center mt-8 text-sm">
            Last Updated: {timestamp}
          </footer>
        </main>
        <ToastContainer />
      </div>
      <Routes>
        <Route path="/utilities" element={<UtilitiesPage account={account} devices={devices} fetchDevices={fetchDevices} balances={balances} />} />
        <Route path="/defi" element={<DeFiPage account={account} balances={balances} />} />
        <Route path="/entertainment" element={<EntertainmentPage account={account} balances={balances} />} />
      </Routes>
    </BrowserRouter>
  );
};

export default App;