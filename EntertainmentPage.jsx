import React, { useState } from 'react';
import { ethers } from 'ethers';
import { getAddresses, getAbis } from './contractConfig';
import logo from './images/GoateElectricLogo.jpg';

const EntertainmentPage = ({ account }) => {
 const [showAuctionModal, setShowAuctionModal] = useState(false);
 const [auctionType, setAuctionType] = useState('buy');
 const [tokenId, setTokenId] = useState('');
 const [amount, setAmount] = useState('');

 const startGame = async (game) => {
 const provider = new ethers.providers.Web3Provider(window.ethereum);
 let contractAddress, contractAbi;
 switch (game) {
 case 'CardWars':
 contractAddress = getAddresses().CardWars;
 contractAbi = getAbis().CardWars;
 break;
 case 'HomeTeamBets':
 contractAddress = getAddresses().HomeTeamBets;
 contractAbi = getAbis().HomeTeamBets;
 break;
 case 'GerastyxOpol':
 contractAddress = getAddresses().GerastyxOpol;
 contractAbi = getAbis().GerastyxOpol;
 break;
 case 'Spades':
 contractAddress = getAddresses().Spades;
 contractAbi = getAbis().Spades;
 break;
 default:
 return;
 }
 const contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());
 try {
 if (game === 'CardWars' || game === 'Spades') {
 await contract.startGame();
 } else if (game === 'HomeTeamBets') {
 await contract.placeBet(0, ethers.utils.parseUnits('1', 6), 0, false);
 } else if (game === 'GerastyxOpol') {
 await contract.startGame([account], 0, [0]);
 }
 } catch (error) {
 console.error(`Error starting ${game}:`, error);
 alert(`Error: ${error.message}`);
 }
 };

 const handleAuction = async () => {
 const provider = new ethers.providers.Web3Provider(window.ethereum);
 const contract = new ethers.Contract(
 getAddresses().GerastyxPropertyNFT,
 getAbis().GerastyxPropertyNFT,
 provider.getSigner()
 );
 const parsedAmount = ethers.utils.parseUnits(amount || '1', 6);
 try {
 if (auctionType === 'buy') {
 await contract.buyPropertyNFT(account, tokenId, parsedAmount);
 } else {
 await contract.sellPropertyNFT(account, tokenId, true);
 }
 setShowAuctionModal(false);
 setTokenId('');
 setAmount('');
 } catch (error) {
 console.error(`Error in ${auctionType} auction:`, error);
 alert(`Error: ${error.message}`);
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
 <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
 {['CardWars', 'HomeTeamBets', 'GerastyxOpol', 'Spades'].map((game) => (
 <button
 key={game}
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={() => startGame(game)}
 >
 {game}
 </button>
 ))}
 </div>
 <div className="flex space-x-4">
 <button
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={() => {
 setAuctionType('buy');
 setShowAuctionModal(true);
 }}
 >
 Auction-For GerastyxOpol PropertyNFT
 </button>
 <button
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={() => {
 setAuctionType('sell');
 setShowAuctionModal(true);
 }}
 >
 Auction-Off GerastyxOpol PropertyNFT
 </button>
 </div>
 {showAuctionModal && (
 <div className="modal">
 <div className="modal-content">
 <span className="close" onClick={() => setShowAuctionModal(false)}>
 &times;
 </span>
 <h2>{auctionType === 'buy' ? 'Buy' : 'Sell'} Gerastyx Property NFT</h2>
 <input
 type="number"
 value={tokenId}
 onChange={(e) => setTokenId(e.target.value)}
 placeholder="Token ID"
 className="bg-gray-900 text-gold p-2 rounded w-full mb-2"
 />
 <input
 type="number"
 value={amount}
 onChange={(e) => setAmount(e.target.value)}
 placeholder="Amount (USDC)"
 className="bg-gray-900 text-gold p-2 rounded w-full mb-2"
 />
 <button
 className="bg-gold text-black px-4 py-2 rounded hover:bg-yellow-400"
 onClick={handleAuction}
 >
 Submit
 </button>
 </div>
 </div>
 )}
 </main>
 </div>
 );
};

export default EntertainmentPage;