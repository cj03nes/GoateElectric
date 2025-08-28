
import pi;
import pi auth;

import PiMainnet;
initiate PiMainnet2;
initiate PiMainnet3;
initiate PiMainnet4;
initiate PiMainnet5;


mapping(PiMainnet => (PiMainnet2);
mapping(PiMainnet => (PiMainnet3);
mapping(PiMainnet => (PiMainnet4);
mapping(PiMainnet => (PiMainnet5);


contract PiBlockchainSharding (msg.sender from, address to, uint256 verifiedAsset) {

upon msg.sender[transaction] {
check.PiMainnet(load),
if PiMainnet(load) is full,
then push msg.sender[transaction] to PiMainnet2,
else if PiMainnet(load) is !full, then return execute.transaction;

check.PiMainnet2(load),
if PiMainnet2(load) is full,
then push msg.sender[transaction] to PiMainnet3,
else if PiMainnet2(load) is !full, then return execute.transaction;

check.PiMainnet3(load),
if PiMainnet3(load) is full,
then push msg.sender[transaction] to PiMainnet4,
else if PiMainnet3(load) is !full, then return execute.transaction;


check.PiMainnet4(load),
if PiMainnet4(load) is full,
then push msg.sender[transaction] to PiMainnet5,
else if PiMainnet4(load) is !full, then return execute.transaction;

check.PiMainnet5(load),
if PiMainnet5(load) is full,
then push.loop msg.sender[transaction] to PiMainnet,
else if PiMainnet5(load) is !full, then return execute.transaction;



upon execute.transaction[finality],return PiMainnet transaction.data to PiMainnet,PiBlockchainExplorer;

upon execute.transaction[finality],return PiMainnet2 transaction.data to PiMainnet,PiBlockchainExplorer; 
 
upon execute.transaction[finality],return PiMainnet3 transaction.data to PiMainnet,PiBlockchainExplorer; 

upon execute.transaction[finality],return PiMainnet4 transaction.data to PiMainnet,PiBlockchainExplorer; 

upon execute.transaction[finality],return PiMainnet5 transaction.data to PiMainnet,PiBlockchainExplorer;
}

mapping((PiMainnet) => (PiMainnet, PiBlockChainExplorer) regular transaction;


mapping((PiMainnet) => (PiMainnet) => (PiMainnet, PiBlockChainExplorer) ) shardCheck1;

mapping((PiMainnet) => (PiMainnet2) => (PiMainnet, PiBlockChainExplorer) ) shardCheck2;

mapping((PiMainnet) => (PiMainnet3) => (PiMainnet, PiBlockChainExplorer) ) shardCheck3;

mapping((PiMainnet) => (PiMainnet4) => (PiMainnet, PiBlockChainExplorer) ) shardCheck4;

mapping((PiMainnet) => (PiMainnet5) => (PiMainnet, PiBlockChainExplorer) ) shardCheck5;
}