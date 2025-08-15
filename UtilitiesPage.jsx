import React, { useState } from 'react';
import { ethers } from 'ethers';
import { getAddresses, getAbis } from './contractConfig';
import logo from './images/GoateElectricLogo.jpg';

const UtilitiesPage = ({ account, devices, fetchDevices }) => {
 const [activeTab, setActiveTab] = useState('handheld');
 const [deviceId, setDeviceId] = useState('');
 const [scanResult, setScanResult] = useState(null);

 const tabs = ['handheld', 'vehicle', 'home', 'appliance', 'accessories'];

 const buyService = async (service) => {
 const provider = new ethers.providers.Web3Provider(window.ethereum);
 let contractAddress, contractAbi;
 switch (service) {
 case 'ZPE':
 contractAddress = getAddresses().Zeropoint;
 contractAbi = getAbis().Zeropoint;
 break;
 case 'ZPW':
 contractAddress = getAddresses().ZeropointWifi;
 contractAbi = getAbis().ZeropointWifi;
 break;
 case 'ZPP':
 contractAddress = getAddresses().ZeropointPhoneService;
 contractAbi = getAbis().ZeropointPhoneService;
 break;
 case 'ZGI':
 contractAddress = getAddresses().ZeropointInsurance;
 contractAbi = getAbis().ZeropointInsurance;
 break;
 default:
 return;
 }
 const contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());
 try {
 const amount = ethers.utils.parseUnits('1', 18); // Example: $1 worth
 await contract.mint(account, amount);
 } catch (error) {
 console.error(`Error buying ${service}:`, error);
 }
 };

 const addDevice = async () => {
 const provider = new ethers.providers.Web3Provider(window.ethereum);
 const contract = new ethers.Contract(
 getAddresses().DeviceConnect,
 getAbis().DeviceConnect,
 provider.getSigner()
 );
 try {
 await contract.addDevice(deviceId);
 fetchDevices(account);
 setDeviceId('');
 setScanResult(null);
 } catch (error) {
 console.error('Error adding device:', error);
 }
 };

 const scanDevice = async () => {
 // Mock QR code scan
 const scannedId = `device-${Math.random().toString(36).substr(2, 9)}`;
 setScanResult(scannedId);
 setDeviceId(scannedId);
 };

 const toggleInsurance = async (deviceId, enable) => {
 const provider = new ethers.providers.Web3Provider(window.ethereum);
 const contract = new ethers.Contract(
 getAddresses().ZeropointInsurance,
 getAbis().ZeropointInsurance,
 provider.getSigner()
 );
 try {
 if (enable) {
 await contract.subscribe(deviceId, ethers.utils.parseUnits('6', 18));
 } else {
 await contract.deactivateShield(deviceId);
 }
 fetchDevices(account);
 } catch (error) {
 console.error('Error toggling insurance:', error);
 }
 };

 return (
 <div className="bg-black text-gold p-4">
 <header className="flex justify-between items-center p-4 border-b border-gold">
 <div className="flex items-center">
 <img src={logo} alt="Goate Electric Logo" className="h-12 w-12 mr-2" />
 <h1 className="text-2xl font-normal">Goate Electric</h1>
 </div>
 <div className="flex space-x-4">
 <p>{account.slice(0, 6)}...{account.slice(-4)}</p>
 <p>Devices: {devices.length}</p>
 <select className="bg-gold text-black px-4 py-2 rounded">
 <option>Settings</option>
 <option>Wallet</option>
 <option>Logout</option>
 </select>
 </div>
 </header>
 <main className="p-4">
 <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
 {['ZPE', 'ZPP', 'ZPW', 'BTC', 'USD', 'PI', 'GOATE', 'ZGI'].map((asset) => (
 <div key={asset} className="bg-gray-900 p-4 rounded text-center">
 <p className="text-lg">${asset} Balance</p>
 <p>0.0</p> {/* Replace with actual balance from parent */}
 </div>
 ))}
 </div>
 <div className="flex space-x-4 mb-4">
 {['ZPE', 'ZPW', 'ZPP', 'ZGI'].map((service) => (
 <button
 key={service}
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={() => buyService(service)}
 >
 Buy {service}
 </button>
 ))}
 </div>
 <div className="flex space-x-4 mb-4">
 {tabs.map((tab) => (
 <button
 key={tab}
 className={`px-4 py-2 rounded ${activeTab === tab ? 'bg-gold text-black' : 'bg-gray-900 text-gold'}`}
 onClick={() => setActiveTab(tab)}
 >
 {tab.charAt(0).toUpperCase() + tab.slice(1)}
 </button>
 ))}
 </div>
 <div className="mb-4">
 <input
 type="text"
 value={deviceId}
 onChange={(e) => setDeviceId(e.target.value)}
 placeholder="Enter Device ID"
 className="bg-gray-900 text-gold p-2 rounded mr-2"
 />
 <button
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400 mr-2"
 onClick={addDevice}
 >
 Add Manually
 </button>
 <button
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={scanDevice}
 >
 Scan QR
 </button>
 {scanResult && <p className="mt-2">Scanned: {scanResult}</p>}
 </div>
 <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
 {devices
 .filter((device) => device.deviceId.toLowerCase().includes(activeTab))
 .map((device, index) => (
 <div key={index} className="bg-gray-900 p-4 rounded">
 <p>Device: {device.deviceId}</p>
 <p>Battery: {device.batteryCapacity}%</p>
 <p>WiFi: Add $ZPW</p>
 <p>Phone Service: Add $ZPP</p>
 <p>
 Insurance:{' '}
 <label className="switch">
 <input
 type="checkbox"
 checked={device.isInsured}
 onChange={() => toggleInsurance(device.deviceId, !device.isInsured)}
 />
 <span className="slider"></span>
 </label>
 </p>
 </div>
 ))}
 </div>
 </main>
 </div>
 );
};

export default UtilitiesPage;