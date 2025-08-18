import React, { useState } from 'react';
import { ethers } from 'ethers';
import { getAddresses, getAbis } from './contractConfig';
import { toast, ToastContainer } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import logo from './images/GoateElectricLogo.jpg';

const EntertainmentPage = ({ account, balances }) => {
  const [showAuctionModal, setShowAuctionModal] = useState(false);
  const [auctionType, setAuctionType] = useState('buy');
  const [tokenId, setTokenId] = useState('');
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);

  const startGame = async (game) => {
    setLoading(true);
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
        setLoading(false);
        return;
    }
    const contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());
    try {
      if (game === 'CardWars' || game === 'Spades') {
        await contract.startGame();
        toast.success(`Started ${game}`);
      } else if (game === 'HomeTeamBets') {
        await contract.placeBet(0, ethers.utils.parseUnits('1', 6), 0, false);
        toast.success('Placed bet in HomeTeamBets');
      } else if (game === 'GerastyxOpol') {
        await contract.startGame([account], 0, [0]);
        toast.success('Started GerastyxOpol');
      }
    } catch (error) {
      console.error(`Error starting ${game}:`, error);
      toast.error(`Failed to start ${game}`);
    }
    setLoading(false);
  };

  const handleAuction = async () => {
    if (!tokenId || !amount) return toast.error('Token ID and amount required');
    setLoading(true);
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const contract = new ethers.Contract(
      getAddresses().GerastyxPropertyNFT,
      getAbis().GerastyxPropertyNFT,
      provider.getSigner()
    );
    const parsedAmount = ethers.utils.parseUnits(amount, 6);
    try {
      if (auctionType === 'buy') {
        await contract.buyPropertyNFT(account, tokenId, parsedAmount);
        toast.success('Property NFT purchased');
      } else {
        await contract.sellPropertyNFT(account, tokenId, true);
        toast.success('Property NFT listed for sale');
      }
      setShowAuctionModal(false);
      setTokenId('');
      setAmount('');
    } catch (error) {
      console.error(`Error in ${auctionType} auction:`, error);
      toast.error(`Failed to ${auctionType} NFT`);
    }
    setLoading(false);
  };

  const timestamp = new Date().toLocaleString();

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
        <footer className="text-center mt-8 text-sm">
          Last Updated: {timestamp}
        </footer>
      </main>
      <ToastContainer />
    </div>
  );
};

export default EntertainmentPage;