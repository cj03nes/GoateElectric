pragma solidity ^0.8;

import { VerifiedChains, VerifiedTokenAssets } from "../InstilledInteroperability.sol" ; 


user flow
// win , lose or tie ... optional overtime: yes or no
// deposit yes or deposit no
// money sits in contract & msg.sender gets a receiptNFT
// await end of the game && scores
// sort winners && losers
// find pro rata of totalPoolAmount - winner[amountBet] = remainder
// 25% out of remainder to owner , then split the remainder between winners
// remainder % number of winners = amountToPay;
// transfer winner[amountDeposited] + amountToPay to msg.sender[winner]

createBets
// get weekly matchups
// distinguish which one is the home team
// create bet for the hometeam
// !deposits, 5 minutes before kickoff
// get score updates Q1, Q2, halftime, Q3, Q4, End of Regulation
// start winnerVsLoser and function transferWinnerProRata, 5 minutes after end of regulation for aggregate

back-end answers
*/ an aggregate of team && score watchers
1. bleacher report , https://bleacherreport.com/scores/nfl?from=sub
2. espn football , https://www.espn.com/nfl/scoreboard
3. nfl.com , https://www.nfl.com/scores/
4. fox football , https://www.foxsports.com/scores/nfl
5. cbs football , https://www.cbssports.com/nfl/scoreboard/
6.The Athletic, https://www.nytimes.com/athletic/nfl/schedule

//*


contract HomeTeamBets ={ 
   (require == VerifiedChain);
   (require == VerifiedTokenAsset);

const receiptNFT ={

name = msg.sender[address];
homeTeamName = homeTeamName[name];
homeTeamBet = depositYes || depositNo;
timestamp = deposit.timestamp[msg.sender]
}
   

const willTheHometeamWin ={
   (require == depositYes || depositNo);
   (require == !depositYes && !depositNo);
   (!require == wasThereOvertime);

   if willTheHometeamWin returns false, then msg.sender = loser;
   if willTheHometeamWin = true, then msg.sender = winner;

function depositYes ={ 

msg.sender[balances] - amountDepositYes = msg.sender[newBalances];
amountDepositYes + betPool[balance] = betPool[newBalance];
return msg.sender[receiptNFT];      }


function depositNo ={   
msg.sender[balances] - amountDepositNo = msg.sender[newBalances];
amountDepositNo + betPool[balance] = betPool[newBalance];
return msg.sender[receiptNFT];}  
}




await gameResults, then return winnersVsLosers;
if msg.sender = loser, then return string("SORRY YOU LOST, TRY AGAIN"),
else if msg.sender = winner, then return function transferProRata;





const wasThereOvertime ={

function depositYesOT ={}


function depositNoOT ={}  }

if willTheHometeamWin returns true && wasThereOvertime returns false, then msg.sender = winner;
if willTheHometeamWin returns true && wasThereOvertime returns true, then msg.sender = winner;
if willTheHometeamWin returns false && wasThereOvertime returns true, then msg.sender = loser;
if willTheHometeamWin returns false && wasThereOvertime returns false, then msg.sender = loser;
   
}
