import React, { useState } from 'react';
import { ethers } from 'ethers';
import { addresses, abis } from './contractConfig';

const DeFiPage = ({ account, balances }) => {
  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');

  const handleAction = async (asset, action) => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    let contractAddress, contractAbi;
    switch (asset) {
      case 'ZPE':
        contractAddress = addresses.Zeropoint;
        contractAbi = abis.Zeropoint;
        break;
      case 'ZPW':
        contractAddress = addresses.ZeropointWifi;
        contractAbi = abis.ZeropointWifi;
        break;
      case 'ZPP':
        contractAddress = addresses.ZeropointPhoneService;
        contractAbi = abis.ZeropointPhoneService;
        break;
      case 'ZGI':
        contractAddress = addresses.ZeropointInsurance;
        contractAbi = abis.ZeropointInsurance;
        break;
      case 'GOATE':
        contractAddress = addresses.TheGoateToken;
        contractAbi = abis.TheGoateToken;
        break;
      case 'BTC':
      case 'PI':
      case 'USD':
        contractAddress = addresses.InstilledInteroperability;
        contractAbi = abis.InstilledInteroperability;
        break;
      default:
        return;
    }
    const contract = new ethers.Contract(contractAddress, contractAbi, provider.getSigner());
    const parsedAmount = ethers.utils.parseUnits(amount || '1', 18);

    try {
      if (action === 'buy') {
        await contract.mint(account, parsedAmount);
      } else if (action === 'sell') {
        await contract.burn(parsedAmount);
      } else if (action === 'transfer') {
        await contract.transfer(recipient, parsedAmount);
      } else if (action === 'deposit') {
        await contract.updateBalance(account, asset, parsedAmount);
      } else if (action === 'stake') {
        const stakingContract = new ethers.Contract(
          addresses.GoateStaking,
          abis.GoateStaking,
          provider.getSigner()
        );
        await stakingContract.stakeAsset(asset, parsedAmount, 30);
      } else if (action === 'dualStake') {
        const tokenPairContract = new ethers.Contract(
          addresses.TokenPairStaking,
          abis.TokenPairStaking,
          provider.getSigner()
        );
        await tokenPairContract.stakeTokens(asset, 'USD', parsedAmount, parsedAmount, 30);
      } else if (action === 'lend' || action === 'borrow') {
        const lendingContract = new ethers.Contract(
          addresses.p2pLendingAndBorrowing,
          abis.p2pLendingAndBorrowing,
          provider.getSigner()
        );
        if (action === 'lend') {
          await lendingContract.lend(parsedAmount);
        } else {
          await lendingContract.borrow(parsedAmount);
        }
      }
    } catch (error) {
      console.error(`${action} failed:`, error);
    }
  };

  const timestamp = new Date().toLocaleString();

  return (
    <div className="bg-black text-gold p-4">
      <header className="flex justify-between items-center p-4 border-b border-gold">
        <div className="flex items-center">
          <img src="/images/GoateElectricLogo.jpg" alt="Logo" className="h-12 w-12 mr-2" />
          <h1 className="text-2xl font-normal">Goate Electric</h1>
        </div>
        <div className="flex space-x-4">
          <p>{account}</p>
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
            {action === 'transfer' && (
              <input
                type="text"
                value={recipient}
                onChange={(e) => setRecipient(e.target.value)}
                placeholder="Recipient Address"
                className="bg-gray-900 text-gold p-2 rounded mt-2 w-full"
              />
            )}
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
    </div>
  );
};

export default DeFiPage;