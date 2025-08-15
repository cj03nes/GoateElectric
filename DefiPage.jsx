import React, { useState } from 'react';
import { ethers } from 'ethers';
import { getAddresses, getAbis } from './contractConfig';
import { toast } from 'react-toastify';
import logo from './images/GoateElectricLogo.jpg';

const DeFiPage = ({ account, balances }) => {
  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');
  const [loading, setLoading] = useState(false);

  const handleAction = async (asset, action) => {
    if (!amount && action !== 'transfer') return toast.error('Amount required');
    if (action === 'transfer' && !recipient) return toast.error('Recipient address required');
    setLoading(true);
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    let contractAddress, contractAbi;
    switch (asset) {
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
      case 'GOATE':
        contractAddress = getAddresses().TheGoateToken;
        contractAbi = getAbis().TheGoateToken;
        break;
      case 'BTC':
      case 'PI':
      case 'USD':
        contractAddress = getAddresses().InstilledInteroperability;
        contractAbi = getAbis().InstilledInteroperability;
        break;
      default:
        setLoading(false);
        return;
    }
    const contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());
    const parsedAmount = ethers.utils.parseUnits(amount || '1', 18);

    try {
      if (action === 'buy') {
        await contract.mint(account, parsedAmount);
        toast.success(`Successfully bought ${asset}`);
      } else if (action === 'sell') {
        await contract.burn(parsedAmount);
        toast.success(`Successfully sold ${asset}`);
      } else if (action === 'transfer') {
        await contract.transfer(recipient, parsedAmount);
        toast.success(`Successfully transferred ${asset}`);
      } else if (action === 'deposit') {
        await contract.updateBalance(account, asset, parsedAmount);
        toast.success(`Successfully deposited ${asset}`);
      } else if (action === 'stake') {
        const stakingContract = new ethers.Contract(
          getAddresses().GoateStaking,
          getAbis().GoateStaking,
          provider.getSigner()
        );
        await stakingContract.stakeAsset(asset, parsedAmount, 30);
        toast.success(`Successfully staked ${asset}`);
      } else if (action === 'dualStake') {
        const tokenPairContract = new ethers.Contract(
          getAddresses().TokenPairStaking,
          getAbis().TokenPairStaking,
          provider.getSigner()
        );
        await tokenPairContract.stakeTokens(asset, 'USD', parsedAmount, parsedAmount, 30);
        toast.success(`Successfully dual-staked ${asset}/USD`);
      } else if (action === 'lend' || action === 'borrow') {
        const lendingContract = new ethers.Contract(
          getAddresses().p2pLendingAndBorrowing,
          getAbis().p2pLendingAndBorrowing,
          provider.getSigner()
        );
        if (action === 'lend') {
          await lendingContract.lend(parsedAmount);
          toast.success(`Successfully lent ${asset}`);
        } else {
          await lendingContract.borrow(parsedAmount);
          toast.success(`Successfully borrowed ${asset}`);
        }
      }
    } catch (error) {
      console.error(`${action} failed for ${asset}:`, error);
      toast.error(`Failed to ${action} ${asset}: ${error.message}`);
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
        {['ZPE', 'ZPW', 'ZPP', 'ZGI', 'GOATE', 'BTC', 'PI', 'USD'].map((asset) => (
          <div key={asset} className="bg-gray-900 p-4 rounded mb-4">
            <h2 className="text-xl mb-2">{asset} (${asset})</h2>
            <p>Balance: {balances[asset]}</p>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mt-2">
              {['buy', 'sell', 'transfer', 'deposit', 'stake', 'dualStake', 'lend', 'borrow'].map((action) => (
                <button
                  key={action}
                  className="bg-gold text-black px-2 py-1 rounded hover:bg-yellow-400"
                  onClick={() => handleAction(asset, action)}
                >
                  {action.charAt(0).toUpperCase() + action.slice(1)}
                </button>
              ))}
            </div>
            <input
              type="text"
              value={recipient}
              onChange={(e) => setRecipient(e.target.value)}
              placeholder="Recipient Address"
              className="bg-gray-900 text-gold p-2 rounded mt-2 w-full"
            />
            <input
              type="number"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="Amount"
              className="bg-gray-900 text-gold p-2 rounded mt-2 w-full"
            />
          </div>
        ))}
        <footer className="text-center mt-8 text-sm">
          Last Updated: {timestamp}
        </footer>
      </main>
      <ToastContainer />
    </div>
  );
};

export default DeFiPage;