import React, { useState, useEffect } from 'react';
import { ChainlinkIntegration } from '../chainlinkConfig';

const PriceFeed = ({ provider, signer }) => {
  const [prices, setPrices] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [chainlink, setChainlink] = useState(null);

  useEffect(() => {
    if (provider) {
      const chainlinkInstance = new ChainlinkIntegration(provider, signer);
      setChainlink(chainlinkInstance);
    }
  }, [provider, signer]);

  useEffect(() => {
    let interval;
    
    const fetchPrices = async () => {
      if (!chainlink) return;
      
      setLoading(true);
      setError(null);
      
      try {
        const allPrices = await chainlink.getAllPrices();
        setPrices(allPrices);
      } catch (err) {
        setError('Failed to fetch price data');
        console.error('Price fetch error:', err);
      } finally {
        setLoading(false);
      }
    };

    if (chainlink) {
      fetchPrices();
      // Update prices every 30 seconds
      interval = setInterval(fetchPrices, 30000);
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [chainlink]);

  const formatPrice = (price) => {
    if (!price) return 'N/A';
    return `$${price.toLocaleString(undefined, { 
      minimumFractionDigits: 2, 
      maximumFractionDigits: 2 
    })}`;
  };

  const getTimeDifference = (updatedAt) => {
    if (!updatedAt) return '';
    const now = new Date();
    const diff = Math.floor((now - updatedAt) / 1000);
    
    if (diff < 60) return `${diff}s ago`;
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`;
    return `${Math.floor(diff / 3600)}h ago`;
  };

  if (loading && Object.keys(prices).length === 0) {
    return (
      <div className="price-feed-container">
        <div className="price-feed-header">
          <h3>📊 Live Prices</h3>
          <div className="loading-indicator">Loading...</div>
        </div>
      </div>
    );
  }

  return (
    <div className="price-feed-container">
      <div className="price-feed-header">
        <h3>📊 Chainlink Price Feeds</h3>
        {loading && <div className="loading-indicator">🔄 Updating...</div>}
        {error && <div className="error-indicator">⚠️ {error}</div>}
      </div>
      
      <div className="price-grid">
        {Object.entries(prices).map(([pair, data]) => (
          <div key={pair} className="price-card">
            <div className="price-pair">{pair}</div>
            {data ? (
              <>
                <div className="price-value">{formatPrice(data.price)}</div>
                <div className="price-meta">
                  <span className="price-update">
                    {getTimeDifference(data.updatedAt)}
                  </span>
                  <span className="price-round">#{data.roundId?.slice(-6)}</span>
                </div>
              </>
            ) : (
              <div className="price-error">❌ Unavailable</div>
            )}
          </div>
        ))}
      </div>
      
      <div className="chainlink-attribution">
        <span>⚡ Powered by Chainlink Oracles</span>
      </div>
    </div>
  );
};

export default PriceFeed;