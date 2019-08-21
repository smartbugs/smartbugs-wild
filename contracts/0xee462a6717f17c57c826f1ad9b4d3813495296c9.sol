//***********************************EthVenturesFinal****************************************************************************
//
// TIRED OF POINTLESS PONZI SCHEMES? Then join EthVentures the first decentralized company!
//
//
// EthVentures is the first decentralized ethereum based company, with shareholder function, dividends, and more...!
//
//
// How it works: You deposit minimum 2 Ether and no maximum deposit, and you will become a shareholder, proportional to how much you deposited. You will own a % of the income of this dapp proportional to how much you deposited.
// Ex: There is 98 Eth deposited, you deposit 2 Eth, new balance becomes 100 Eth, then you will own 2% of the profits!
//
//
//
// Dividends: Every deposit under 2 Eth is considered a dividend and is distributed between shareholders automatically. Even if the profit is bigger than 2 Eth, it will be distributed in 1-2 Ether packages, automatically.
// Ex: We generate 100 Eth profit daily, then it will be distributed in 50 times in 2 ether packages, then those packages get shared between shareholders. With the example above if you hold 2%, then you will earn 50 times 0.04 Eth, which is 2 Eth profit in total.
//
//
// Profit: This contract itself is not generating any profit, it's just a ledger to keep record of investors, and pays out dividends automatically.There will be other contracts linked to this, that will send the profits here. EthVentures is just the core of this business, there will be other contracts built on it.
// Ex: A dice game built on this contract that generates say 10 Eth daily, will send the fees directly here
// Ex: A doubler game built on this contract that generates 50 Eth daily, that will send all fees here
// Ex: Any other form of contract that takes a % fee, and will send the fees directly here to be distributed between EthVentures shareholders.
//
//
// How to invest: Just deposit minimum 2 Ether to the contract address, and you can see your total investments and % ownership in the Mist wallet if you follow this contract. You can deposit multiple times too, the total investments will add up if you send from the same address. The percentage ownership is calculated with a 10 billionth point precision, so you must divide that number by 100,000,000 to get the % ownership rate. Every other information, can be seen in the contract tab from your Mist Wallet, just make sure you are subscribed to this contract.
//
//
//
// Fees: There is a 1% deposit fee, and a 1% dividend payout fee that goes to the contract manager, everything else goes to investors!
//
//============================================================================================================================
//
// When EthVentures will be succesful, it will have tens or hundreds of different contracts, all sending the fees here to our investors, AUTOMATICALLY. It could generate even hundreds of Eth daily at some point.
//
// Imagine it as a decentralized web of income, all sending the money to 1 single point, this contract.
//
// It is literally a DECENTRALIZED MONEY GENERATOR!
//
//
//============================================================================================================================
// Copyright (c) 2016 to "BetGod" from Bitcointalk.org, This piece of code cannot be copied or reused without the author's permission!
//
// Author: https://bitcointalk.org/index.php?action=profile;u=803185
//
// This is the final version of the contract, new and improved, all possible bugs fixed!
//
//
//***********************************START
contract EthVenturesFinal {
struct InvestorArray {
address etherAddress;
uint amount;
//float percentage_ownership; // doesnt work, ethereum doesnt allow float point precision yet
}
InvestorArray[] public investors;
//********************************************PUBLIC VARIABLES
uint public total_investors=0;
uint public fees=0;
uint public balance = 0;
uint public totaldeposited=0;
uint public totalpaidout=0;
uint public totaldividends=0;
string public Message_To_Investors="Welcome to EthVenturesFinal! New and improved! All bugs fixed!"; // the manager can send short messages to investors
address public owner;
// manager privilege
modifier manager { if (msg.sender == owner) _ }
//********************************************INIT
function EthVenturesFinal() {
owner = msg.sender;
}
//********************************************TRIGGER
function() {
Enter();
}
//********************************************ENTER
function Enter() {
//DIVIDEND PAYOUT FUNCTION, IT WILL GET INCOME FROM OTHER CONTRACTS, THE DIVIDENDS WILL ALWAYS BE SENT
//IN LESS THAN 2 ETHER SIZE PACKETS, BECAUSE ANY DEPOSIT OVER 2 ETHER GETS REGISTERED AS AN INVESTOR!!!
if (msg.value < 2 ether)
{
uint PRE_payout;
uint PRE_amount=msg.value;
owner.send(PRE_amount/100); //send the 1% management fee to the manager
totalpaidout+=PRE_amount/100; //update paid out amount
PRE_amount-=PRE_amount/100; //remaining 99% is the dividend
//Distribute Dividends
if(investors.length !=0 && PRE_amount !=0)
{
for(uint PRE_i=0; PRE_i<investors.length;PRE_i++)
{
PRE_payout = PRE_amount * investors[PRE_i].amount /totaldeposited; //calculate pay out
investors[PRE_i].etherAddress.send(PRE_payout); //send dividend to investor
totalpaidout += PRE_payout; //update paid out amount
totaldividends+=PRE_payout; // update paid out dividends
}
Message_To_Investors="Dividends have been paid out!";
}
}
// YOU MUST INVEST AT LEAST 2 ETHER OR HIGHER TO BE A SHAREHOLDER, OTHERWISE THE DEPOSIT IS CONSIDERED A DIVIDEND!!!
else
{
// collect management fees and update contract balance and deposited amount
uint amount=msg.value;
fees = amount / 100; // 1% management fee to the owner
totaldeposited+=amount; //update deposited amount
amount-=amount/100;
balance += amount; // balance update
// add a new participant to the system and calculate total players
bool alreadyinvestor =false;
uint alreadyinvestor_id;
//go through all investors and see if the current investor was already an investor or not
for(uint i=0; i<investors.length;i++)
{
if( msg.sender== investors[i].etherAddress) // if yes then:
{
alreadyinvestor=true; //set it to true
alreadyinvestor_id=i; // and save the id of the investor in the investor array
break; // get out of the loop to save gas, because we already found it
}
}
// if it's a new investor then add it to the array
if(alreadyinvestor==false)
{
total_investors=investors.length+1;
investors.length += 1; //increment first
investors[investors.length-1].etherAddress = msg.sender;
investors[investors.length-1].amount = amount;

//float
//investors[investors.length-1].percentage_ownership = amount /totaldeposited*10000000000;


Message_To_Investors="New Investor has joined us!"; // a new and real investor has joined us

//float
//for(uint k=0; k<investors.length;k++) //if smaller than incremented, goes into loop
//{investors[k].percentage_ownership = investors[k].amount/totaldeposited*10000000000;} //recalculate % ownership

}
else // if its already an investor, then update his investments and his % ownership
{
investors[alreadyinvestor_id].amount += amount;

//float
//investors[alreadyinvestor_id].percentage_ownership = investors[alreadyinvestor_id].amount/totaldeposited*10000000000;
}
// pay out the 1% management fee
if (fees != 0)
{
owner.send(fees); //send the 1% to the manager
totalpaidout+=fees; //update paid out amount
}

}
}
//********************************************NEW MANAGER
//In case the business gets sold, the new manager will take over the management
function NewOwner(address new_owner) manager
{
owner = new_owner;
Message_To_Investors="The contract has a new manager!";
}
//********************************************EMERGENCY WITHDRAW
// It will only be used in case the funds get stuck or any bug gets discovered in the future
// Also if a new version of this contract comes out, the funds then will be transferred to the new one
function Emergency() manager
{
if(balance!=0)
{
owner.send(balance);
balance=0;
Message_To_Investors="Emergency Withdraw has been issued!";
}
}
//********************************************EMERGENCY BALANCE RESET
//In case any errors happen the balance can be modified manually, it will only be used as last resort!
function EmergencyBalanceReset(uint new_balance) manager
{
balance = new_balance;
Message_To_Investors="The Balance has been edited by the Manager!";
}
//********************************************NEW MESSAGE
//The manager can send short messages to investors to keep them updated
function NewMessage(string new_sms) manager
{
Message_To_Investors = new_sms;
}
//********************************************MANUALLY ADD INVESTORS
//The manager can add manually the investors from the previous versions, 
//so that those that invested in the older versions can join us in the new and updated versions
function NewManualInvestor(address new_investor , uint new_amount) manager
{
total_investors=investors.length+1;
investors.length += 1; //increment first
investors[investors.length-1].etherAddress = new_investor;
investors[investors.length-1].amount = new_amount;

//float
//investors[investors.length-1].percentage_ownership = new_amount /totaldeposited*10000000000;


Message_To_Investors="New manual Investor has been added by the Manager!"; // you can see if the newest investor was manually added or not, this will add transparency to the contract, since this function should only be used in emergency situations.
// This will ensure that the manager doesn't add fake investors of his own addresses.
}
//********************************************MANUAL DEPOSIT
//The manager can deposit manually from previous version's balances
function ManualDeposit() manager
{
totaldeposited+=msg.value; //update deposited amount manually
balance+=msg.value; //update balance amount manually

Message_To_Investors = "Manual Deposit received from the Manager";
}

//end
}