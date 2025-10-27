import PiNFT;
import PiDomains;
import PiCollectibles;
import timestamp, date, timer;



contract Auction (category, startAuction, endAuction){
category:(
domains,
collectibles, (GOAT/EBAY/FACEBOOKARKETPLACE)
nft,)

startAuction:(
beginTime,
owner address,
auction item,
minimum bid,
auction lasts,)

endAuction:(
endTime,
owner address,
highest bid[asset],
highest bidder address,
auction item,
confirmation,)

comfirmation (owner address, confirmation, highest bidder address{

upon.endAuction(
return message("Confirm" || "Cancel") to owner address),
if owner address confirm,
then transfer highest bidder(highest bid[asset]) to owner address,
then transfer auctionItem to highest bidder address == new owner, new owner address,

else if owner address cancel,
then return auction item to owner address,
then return higjest bid[asset] to highest bidder address;

}





}
