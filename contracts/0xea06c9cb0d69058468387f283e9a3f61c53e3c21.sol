pragma solidity ^ 0.4.10;

contract EthMultiplier {

//*****************************           **************************************
//***************************** VARIABLES **************************************
//*****************************           **************************************

//******************************************************************************
//***** PRIVATE VARS ***********************************************************
//******************************************************************************

 uint16 private id;
 uint16 private payoutIdx;
 address private owner;


//******************************************************************************
//***** PUBLIC VARS ************************************************************
//******************************************************************************

 struct Investor {
  address addr;
  uint payout;
  bool paidOut;
 }
 mapping (uint16 => Investor) public investors;

 uint8 public feePercentage = 10;
 uint8 public payOutPercentage = 25;
 bool public smartContactForSale = true;
 uint public priceOfSmartContract = 25 ether;
 

//*****************************           **************************************
//***************************** FUNCTIONS **************************************
//*****************************           **************************************

//******************************************************************************
//***** INIT FUNCTION **********************************************************
//******************************************************************************

 function EthMultiplier() { owner = msg.sender; }


//******************************************************************************
//***** FALLBACK FUNCTION ******************************************************
//******************************************************************************

 function()
 payable {
  // Please be aware: 
  // depositing MORE then the price of the smart contract in one transaction 
  // will call the 'buySmartContract' function, and will make you the owner.
  msg.value >= priceOfSmartContract? 
   buySmartContract(): 
   invest();
 }


//******************************************************************************
//***** ADD INVESTOR FUNCTION **************************************************
//******************************************************************************

 event newInvestor(
  uint16 idx,
  address investor,
  uint amount,
  uint InvestmentNeededForPayOut
 );
 
 event lastInvestorPaidOut(uint payoutIdx);

 modifier entryCosts(uint min, uint max) {
  if (msg.value < min || msg.value > max) throw;
  _;
 }

 function invest()
 payable
 entryCosts(1 finney, 10 ether) {
  // Warning! the creator of this smart contract is in no way
  // responsible for any losses or gains in both the 'invest' function nor 
  // the 'buySmartContract' function.
  
  investors[id].addr = msg.sender;
  investors[id].payout = msg.value * (100 + payOutPercentage) / 100;

  owner.transfer(msg.value * feePercentage / 100);

  while (this.balance >= investors[payoutIdx].payout) {
   investors[payoutIdx].addr.transfer(investors[payoutIdx].payout);
   investors[payoutIdx++].paidOut = true;
  }
  
  lastInvestorPaidOut(payoutIdx - 1);

  newInvestor(
   id++,
   msg.sender,
   msg.value,
   checkInvestmentRequired(id, false)
  );
 }


//******************************************************************************
//***** CHECK REQUIRED INVESTMENT FOR PAY OUT FUNCTION *************************
//******************************************************************************

 event manualCheckInvestmentRequired(uint id, uint investmentRequired);

 modifier awaitingPayOut(uint16 _investorId, bool _manual) {
  if (_manual && (_investorId > id || _investorId < payoutIdx)) throw;
  _;
 }

 function checkInvestmentRequired(uint16 _investorId, bool _clickYes)
 awaitingPayOut(_investorId, _clickYes)
 returns(uint amount) {
  for (uint16 iPayoutIdx = payoutIdx; iPayoutIdx <= _investorId; iPayoutIdx++) {
   amount += investors[iPayoutIdx].payout;
  }

  amount = (amount - this.balance) * 100 / (100 - feePercentage);

  if (_clickYes) manualCheckInvestmentRequired(_investorId, amount);
 }


//******************************************************************************
//***** BUY SMART CONTRACT FUNCTION ********************************************
//******************************************************************************

 event newOwner(uint pricePayed);

 modifier isForSale() {
  if (!smartContactForSale 
  || msg.value < priceOfSmartContract 
  || msg.sender == owner) throw;
  _;
  if (msg.value > priceOfSmartContract)
   msg.sender.transfer(msg.value - priceOfSmartContract);
 }

 function buySmartContract()
 payable
 isForSale {
  // Warning! the creator of this smart contract is in no way
  // responsible for any losses or gains in both the 'invest' function nor 
  // the 'buySmartContract' function.

  // Always correctly identify the risk related before using this function.
  owner.transfer(priceOfSmartContract);
  owner = msg.sender;
  smartContactForSale = false;
  newOwner(priceOfSmartContract);
 }


//*****************************            *************************************
//***************************** OWNER ONLY *************************************
//*****************************            *************************************

 modifier onlyOwner() {
  if (msg.sender != owner) throw;
  _;
 }


//******************************************************************************
//***** SET FEE PERCENTAGE FUNCTION ********************************************
//******************************************************************************

 event newFeePercentageIsSet(uint percentage);

 modifier FPLimits(uint8 _percentage) {
  // fee percentage cannot be higher than 25
  if (_percentage > 25) throw;
  _;
 }

 function setFeePercentage(uint8 _percentage)
 onlyOwner
 FPLimits(_percentage) {
  feePercentage = _percentage;
  newFeePercentageIsSet(_percentage);
 }


//******************************************************************************
//***** SET PAY OUT PERCENTAGE FUNCTION ****************************************
//******************************************************************************

 event newPayOutPercentageIsSet(uint percentageOnTopOfDeposit);

 modifier POTODLimits(uint8 _percentage) {
  // pay out percentage cannot be higher than 100 (so double the investment)
  // it also cannot be lower than the fee percentage
  if (_percentage > 100 || _percentage < feePercentage) throw;
  _;
 }

 function setPayOutPercentage(uint8 _percentageOnTopOfDeposit)
 onlyOwner
 POTODLimits(_percentageOnTopOfDeposit) {
  payOutPercentage = _percentageOnTopOfDeposit;
  newPayOutPercentageIsSet(_percentageOnTopOfDeposit);
 }


//******************************************************************************
//***** TOGGLE SMART CONTRACT SALE FUNCTIONS ***********************************
//******************************************************************************

 event smartContractIsForSale(uint price);
 event smartContractSaleEnded();

 function putSmartContractOnSale(bool _sell)
 onlyOwner {
  smartContactForSale = _sell;
  _sell? 
   smartContractIsForSale(priceOfSmartContract): 
   smartContractSaleEnded();
 }


//******************************************************************************
//***** SET SMART CONTRACT PRICE FUNCTIONS *************************************
//******************************************************************************

 event smartContractPriceIsSet(uint price);

 modifier SCPLimits(uint _price) {
  // smart contract price cannot be lower or equal than 10 ether
  if (_price <= 10 ether) throw;
  _;
 }

 function setSmartContractPrice(uint _price)
 onlyOwner 
 SCPLimits(_price) {
  priceOfSmartContract = _price;
  smartContractPriceIsSet(_price);
 }


}