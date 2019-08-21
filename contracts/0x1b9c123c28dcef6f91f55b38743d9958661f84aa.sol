pragma solidity ^0.4.15;
contract Emoz {
 uint256 constant private STARTING_PRICE = 0.005 ether;
 address private cO;
 mapping (uint256 => address) public onrs;
 mapping (uint256 => string ) public urls;
 mapping (uint256 => uint256) private prcs;
 mapping (uint256 => uint256) public tyms;
 event Upd(uint256 c, string url, address onr, uint256 prc, uint256 tym);
 function Emoz() public {
  cO = msg.sender;
 }
 function() public payable {
 }
 function prc(uint256 c) constant external returns(uint256) {
  uint256 p = prcs[c];
  return p > 0 ? p : STARTING_PRICE;
 }
 function buy(uint256 c, string url) external payable {
  uint256 p = prcs[c];
  if(p == 0) p = STARTING_PRICE;
  require (msg.value >= p);
  address pO = onrs[c];
  uint256 nP = p << 1;
  prcs[c] = nP;
  onrs[c] = msg.sender;
  urls[c] = url;
  tyms[c] = now;
  Upd(c, url, msg.sender, nP, now);
  if(pO != address(0)) {
   pO.transfer((3 * p) / 5);
  }
  cO.transfer(this.balance);
 }
 function ban(uint256 c) external {
  require (msg.sender == cO);
  delete urls[c];
  Upd(c, "", onrs[c], prcs[c], tyms[c]);
 }
}