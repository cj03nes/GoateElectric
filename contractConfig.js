// This file is auto-generated. Do not edit manually.
// It loads contract addresses and ABIs from environment variables (for build-time) and provides a runtime fallback.

const addresses = {
  InstilledInteroperability: process.env.REACT_APP_INSTILLED_INTEROPERABILITY_ADDRESS || '',
  DeviceConnect: process.env.REACT_APP_DEVICE_CONNECT_ADDRESS || '',
  // ...add other contracts as needed
};

const abis = {
  InstilledInteroperability: require('./abis/InstilledInteroperability.json'),
  DeviceConnect: require('./abis/DeviceConnect.json'),
  // ...add other contracts as needed
};

export { addresses, abis };
