// SendMoneyScreen.js
import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet } from 'react-native';
import transfer from './util.sol';
import { transferFromCard, transferToCard, transferFromBank, transferToBank}  from './accountSettings/util.sol';


export default function TransferScreen() {
  const [amount, setAmount] = useState('');
  const [recipient, setRecipient] = useState('');

  const handleSendMoney = () => {
    // Logic to send money
    console.log(`Sending $${amount} to ${recipient}`);
  };

  return (
    <View style={styles.container}>
      <Text>Send Money</Text>
      <TextInput
        style={styles.input}
        placeholder="Amount"
        value={amount}
        keyboardType="numeric"
        onChangeText={setAmount}
      />
      <TextInput
        style={styles.input}
        placeholder="Recipient"
        value={recipient}
        onChangeText={setRecipient}
      />
      <Button title="Send" onPress={handleSendMoney} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center' },
  input: { height: 40, borderColor: 'gray', borderWidth: 1, marginBottom: 10, width: '80%', padding: 10 },
});
