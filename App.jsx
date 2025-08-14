import React, { useState, useEffect } from 'react';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import Web3 from 'web3';
import { ethers } from 'ethers';
import { addresses, abis } from './contractConfig';
import './styles.css';
import logo from './assets/goate-electric-logo.svg'; // Gold goat silhouette

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState('');
  const [balances, setBalances] = useState({
    ZPE: 0, ZPP: 0, ZPW: 0, BTC: 0, USD: 0, PI: 0, GOATE: 0, ZGI: 0
  });
  const [devices, setDevices] = useState([]);
  const [username, setUsername] = useState('Guest');

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        setWeb3(web3Instance);
        const accounts = await web3Instance.eth.getAccounts();
        setAccount(accounts[0]);
        fetchBalances(accounts[0]);
        fetchDevices(accounts[0]);
      }
    };
    initWeb3();
  }, []);

  const fetchBalances = async (user) => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      addresses.InstilledInteroperability,
      abis.InstilledInteroperability,
      provider
    );
    const assets = ['ZPE', 'ZPP', 'ZPW', 'BTC', 'USD', 'PI', 'GOATE', 'ZGI'];
    const newBalances = {};
    for (let asset of assets) {
      const balance = await contract.activeBalances(user, asset);
      newBalances[asset] = ethers.utils.formatUnits(balance, 18);
    }
    setBalances(newBalances);
  };

  const fetchDevices = async (user) => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      addresses.DeviceConnect,
      abis.DeviceConnect,
      provider.getSigner()
    );
    const deviceList = await contract.getUserDevices(user);
    setDevices(deviceList);
  };

  const connectDevice = async (deviceId) => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      addresses.DeviceConnect,
      abis.DeviceConnect,
      provider.getSigner()
    );
    await contract.connectDevice(deviceId);
    fetchDevices(account);
  };

  return (
    <BrowserRouter>
      <div className="bg-black text-gold min-h-screen">
        <header className="flex justify-between items-center p-4 border-b border-gold">
          <div className="flex items-center">
            <img src={logo} alt="Goate Electric Logo" className="h-12 w-12 mr-2" />
            <h1 className="text-2xl font-normal">Goate Electric</h1>
          </div>
          <div className="flex space-x-4">
            <button className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400">
              Signup/Login
            </button>
            <button
              className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
              onClick={() => connectDevice(prompt('Enter Device ID'))}
            >
              Connect Device
            </button>
            <select className="bg-gold text-black px-4 py-2 rounded">
              <option>Settings</option>
              <option>Wallet</option>
              <option>Logout</option>
            </select>
          </div>
        </header>
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
        </main>
      </div>
      <Routes>
        <Route path="/utilities" element={<UtilitiesPage account={account} devices={devices} fetchDevices={fetchDevices} />} />
        <Route path="/defi" element={<DeFiPage account={account} balances={balances} />} />
        <Route path="/entertainment" element={<EntertainmentPage account={account} />} />
      </Routes>
    </BrowserRouter>
  );
};

const UtilitiesPage = ({ account, devices, fetchDevices }) => {
  // Implement device tabs, buy buttons, and device cards as described
  return <div>Utilities Page (Placeholder)</div>;
};

const DeFiPage = ({ account, balances }) => {
  // Implement token sections with buy/sell/transfer/deposit/stake/etc.
  return <div>DeFi Page (Placeholder)</div>;
};

const EntertainmentPage = ({ account }) => {
  // Implement game buttons and auction modals
  return <div>Entertainment Page (Placeholder)</div>;
};

export default App;
