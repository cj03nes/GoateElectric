import { ethers } from 'ethers';

// Chainlink Price Feed Addresses (Ethereum Mainnet)
export const PRICE_FEEDS = {
  'ETH/USD': '0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419',
  'BTC/USD': '0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c',
  'LINK/USD': '0x2c1d072e956AFFC0D435Cb7AC38EF18d24d9127c',
  'USDC/USD': '0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6',
  'USDT/USD': '0x3E7d1eAB13ad0104d2750B8863b489D65364e32D'
};

// Chainlink VRF Configuration
export const VRF_CONFIG = {
  coordinator: '0x271682DEB8C4E0901D1a1550aD2e64D568E69909', // Ethereum Mainnet
  keyHash: '0x8af398995b04c28e9951adb9721ef74c74f93e6a478f39e7e0777be13527e7ef',
  subscriptionId: '0', // You'll need to create a subscription
  callbackGasLimit: '100000',
  requestConfirmations: '3',
  numWords: '1'
};

// Price Feed ABI (minimal)
export const PRICE_FEED_ABI = [
  {
    "inputs": [],
    "name": "latestRoundData",
    "outputs": [
      { "internalType": "uint80", "name": "roundId", "type": "uint80" },
      { "internalType": "int256", "name": "answer", "type": "int256" },
      { "internalType": "uint256", "name": "startedAt", "type": "uint256" },
      { "internalType": "uint256", "name": "updatedAt", "type": "uint256" },
      { "internalType": "uint80", "name": "answeredInRound", "type": "uint80" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "decimals",
    "outputs": [{ "internalType": "uint8", "name": "", "type": "uint8" }],
    "stateMutability": "view",
    "type": "function"
  }
];

// VRF Consumer ABI (minimal)
export const VRF_ABI = [
  {
    "inputs": [],
    "name": "requestRandomWords",
    "outputs": [{ "internalType": "uint256", "name": "requestId", "type": "uint256" }],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "name": "s_randomWords",
    "outputs": [{ "internalType": "uint256", "name": "", "type": "uint256" }],
    "stateMutability": "view",
    "type": "function"
  }
];

// Chainlink Integration Class
export class ChainlinkIntegration {
  constructor(provider, signer) {
    this.provider = provider;
    this.signer = signer;
    this.priceFeeds = {};
    this.initializePriceFeeds();
  }

  // Initialize price feed contracts
  initializePriceFeeds() {
    Object.keys(PRICE_FEEDS).forEach(pair => {
      this.priceFeeds[pair] = new ethers.Contract(
        PRICE_FEEDS[pair],
        PRICE_FEED_ABI,
        this.provider
      );
    });
  }

  // Get latest price for a trading pair
  async getLatestPrice(pair) {
    try {
      if (!this.priceFeeds[pair]) {
        throw new Error(`Price feed not available for ${pair}`);
      }

      const [roundId, answer, startedAt, updatedAt, answeredInRound] = 
        await this.priceFeeds[pair].latestRoundData();
      
      const decimals = await this.priceFeeds[pair].decimals();
      const price = Number(answer) / Math.pow(10, decimals);

      return {
        pair,
        price,
        roundId: roundId.toString(),
        updatedAt: new Date(updatedAt.toNumber() * 1000),
        decimals
      };
    } catch (error) {
      console.error(`Error fetching price for ${pair}:`, error);
      throw error;
    }
  }

  // Get all available prices
  async getAllPrices() {
    const prices = {};
    const pairs = Object.keys(PRICE_FEEDS);

    await Promise.allSettled(
      pairs.map(async (pair) => {
        try {
          prices[pair] = await this.getLatestPrice(pair);
        } catch (error) {
          console.error(`Failed to fetch ${pair}:`, error);
          prices[pair] = null;
        }
      })
    );

    return prices;
  }

  // Request random number (VRF)
  async requestRandomNumber(vrfContractAddress) {
    try {
      const vrfContract = new ethers.Contract(
        vrfContractAddress,
        VRF_ABI,
        this.signer
      );

      const tx = await vrfContract.requestRandomWords();
      const receipt = await tx.wait();
      
      return {
        transactionHash: receipt.transactionHash,
        requestId: receipt.events?.[0]?.args?.requestId?.toString()
      };
    } catch (error) {
      console.error('Error requesting random number:', error);
      throw error;
    }
  }

  // Get random number result
  async getRandomNumber(vrfContractAddress, requestId) {
    try {
      const vrfContract = new ethers.Contract(
        vrfContractAddress,
        VRF_ABI,
        this.provider
      );

      const randomWord = await vrfContract.s_randomWords(requestId);
      return randomWord.toString();
    } catch (error) {
      console.error('Error getting random number:', error);
      throw error;
    }
  }

  // Calculate price impact for trading
  calculatePriceImpact(tradeAmount, liquidity, slippage = 0.005) {
    const impact = (tradeAmount / liquidity) * (1 + slippage);
    return Math.min(impact, 0.1); // Cap at 10%
  }

  // Get proof of reserves data
  async getProofOfReserves(reserveContractAddress) {
    try {
      // This would integrate with Chainlink Proof of Reserve feeds
      // Implementation depends on specific PoR contract structure
      const reserveContract = new ethers.Contract(
        reserveContractAddress,
        PRICE_FEED_ABI, // Simplified - would use specific PoR ABI
        this.provider
      );

      const [, reserves] = await reserveContract.latestRoundData();
      return {
        reserves: reserves.toString(),
        timestamp: Date.now(),
        contractAddress: reserveContractAddress
      };
    } catch (error) {
      console.error('Error fetching proof of reserves:', error);
      throw error;
    }
  }
}

// React Hook for Chainlink Integration
export const useChainlink = (provider, signer) => {
  const [chainlink, setChainlink] = React.useState(null);
  const [prices, setPrices] = React.useState({});
  const [loading, setLoading] = React.useState(false);

  React.useEffect(() => {
    if (provider) {
      const chainlinkInstance = new ChainlinkIntegration(provider, signer);
      setChainlink(chainlinkInstance);
    }
  }, [provider, signer]);

  const fetchPrices = React.useCallback(async () => {
    if (!chainlink) return;
    
    setLoading(true);
    try {
      const allPrices = await chainlink.getAllPrices();
      setPrices(allPrices);
    } catch (error) {
      console.error('Error fetching prices:', error);
    } finally {
      setLoading(false);
    }
  }, [chainlink]);

  return {
    chainlink,
    prices,
    loading,
    fetchPrices
  };
};

export default ChainlinkIntegration;