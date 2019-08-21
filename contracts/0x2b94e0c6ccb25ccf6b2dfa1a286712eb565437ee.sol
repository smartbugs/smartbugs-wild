/* Owned.sol

Pacio Core Ltd https://www.pacio.io

2017.03.04 djh Originally created
2017.08.16 Brought into use for Pacio token sale use
2017.08.22 Logging revised

Owned is a Base Contract for contracts that are:
• "owned"
• can have their owner changed by a call to ChangeOwner() by the owner
• can be paused  from an active state by a call to Pause() by the owner
• can be resumed from a paused state by a call to Resume() by the owner

Modifier functions available for use here and in child contracts are:
• IsOwner()  which throws if called by other than the current owner
• IsActive() which throws if called when the contract is paused

Changes of owner are logged via event LogOwnerChange(address indexed previousOwner, address newOwner)

*/

pragma solidity ^0.4.15;

contract Owned {
  address public ownerA; // Contract owner
  bool    public pausedB;

  // Constructor NOT payable
  // -----------
  function Owned() {
    ownerA = msg.sender;
  }

  // Modifier functions
  // ------------------
  modifier IsOwner {
    require(msg.sender == ownerA);
    _;
  }

  modifier IsActive {
    require(!pausedB);
    _;
  }

  // Events
  // ------
  event LogOwnerChange(address indexed PreviousOwner, address NewOwner);
  event LogPaused();
  event LogResumed();

  // State changing public methods
  // -----------------------------
  // Change owner
  function ChangeOwner(address vNewOwnerA) IsOwner {
    require(vNewOwnerA != address(0)
         && vNewOwnerA != ownerA);
    LogOwnerChange(ownerA, vNewOwnerA);
    ownerA = vNewOwnerA;
  }

  // Pause
  function Pause() IsOwner {
    pausedB = true; // contract has been paused
    LogPaused();
  }

  // Resume
  function Resume() IsOwner {
    pausedB = false; // contract has been resumed
    LogResumed();
  }
} // End Owned contract


// DSMath.sol
// From https://dappsys.readthedocs.io/en/latest/ds_math.html

// Reduced version - just the fns used by Pacio

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

contract DSMath {
  /*
  standard uint256 functions
  */

  function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
    assert((z = x + y) >= x);
  }

  function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
    assert((z = x - y) <= x);
  }

  function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {
    z = x * y;
    assert(x == 0 || z / x == y);
  }

  // div isn't needed. Only error case is div by zero and Solidity throws on that
  // function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
  //   z = x / y;
  // }

  // subMaxZero(x, y)
  // Pacio addition to avoid throwing if a subtraction goes below zero and return 0 in that case.
  function subMaxZero(uint256 x, uint256 y) constant internal returns (uint256 z) {
    if (y > x)
      z = 0;
    else
      z = x - y;
  }
}

// ERC20Token.sol 2017.08.16 started

// 2017.10.07 isERC20Token changed to isEIP20Token

/*
ERC Token Standard #20 Interface
https://github.com/ethereum/EIPs/issues/20
https://github.com/frozeman/EIPs/blob/94bc4311e889c2c58c561c074be1483f48ac9374/EIPS/eip-20-token-standard.md
Using Dappsys naming style of 3 letter names: src, dst, guy, wad
*/

contract ERC20Token is Owned, DSMath {
  // Data
  bool public constant isEIP20Token = true; // Interface declaration
  uint public totalSupply;     // Total tokens minted
  bool public saleInProgressB; // when true stops transfers

  mapping(address => uint) internal iTokensOwnedM;                 // Tokens owned by an account
  mapping(address => mapping (address => uint)) private pAllowedM; // Owner of account approves the transfer of an amount to another account

  // ERC20 Events
  // ============
  // Transfer
  // Triggered when tokens are transferred.
  event Transfer(address indexed src, address indexed dst, uint wad);

  // Approval
  // Triggered whenever approve(address spender, uint wad) is called.
  event Approval(address indexed Sender, address indexed Spender, uint Wad);

  // ERC20 Methods
  // =============
  // Public Constant Methods
  // -----------------------
  // balanceOf()
  // Returns the token balance of account with address guy
  function balanceOf(address guy) public constant returns (uint) {
    return iTokensOwnedM[guy];
  }

  // allowance()
  // Returns the number of tokens approved by guy that can be transferred ("spent") by spender
  function allowance(address guy, address spender) public constant returns (uint) {
    return pAllowedM[guy][spender];
  }

  // Modifier functions
  // ------------------
  modifier IsTransferOK(address src, address dst, uint wad) {
    require(!saleInProgressB          // Sale not in progress
         && !pausedB                  // IsActive
         && iTokensOwnedM[src] >= wad // Source has the tokens available
      // && wad > 0                   // Non-zero transfer No! The std says: Note Transfers of 0 values MUST be treated as normal transfers and fire the Transfer event
         && dst != src                // Destination is different from source
         && dst != address(this)      // Not transferring to this token contract
         && dst != ownerA);           // Not transferring to the owner of this contract - the token sale contract
    _;
  }

  // State changing public methods made pause-able and with call logging
  // -----------------------------
  // transfer()
  // Transfers wad of sender's tokens to another account, address dst
  // No need for overflow check given that totalSupply is always far smaller than max uint
  function transfer(address dst, uint wad) IsTransferOK(msg.sender, dst, wad) returns (bool) {
    iTokensOwnedM[msg.sender] -= wad; // There is no need to check this for underflow via a sub() call given the IsTransferOK iTokensOwnedM[src] >= wad check
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(msg.sender, dst, wad);
    return true;
  }

  // transferFrom()
  // Sender transfers wad tokens from src account src to dst account, if
  // sender had been approved by src for a transfer of >= wad tokens from src's account
  // by a prior call to approve() with that call's sender being this calls src,
  //  and its spender being this call's sender.
  function transferFrom(address src, address dst, uint wad) IsTransferOK(src, dst, wad) returns (bool) {
    require(pAllowedM[src][msg.sender] >= wad); // Transfer is approved
    iTokensOwnedM[src]         -= wad; // There is no need to check this for underflow given the require above
    pAllowedM[src][msg.sender] -= wad; // There is no need to check this for underflow given the require above
    iTokensOwnedM[dst] = add(iTokensOwnedM[dst], wad);
    Transfer(src, dst, wad);
    return true;
  }

  // approve()
  // Approves the passed address (of spender) to spend up to wad tokens on behalf of msg.sender,
  //  in one or more transferFrom() calls
  // If this function is called again it overwrites the current allowance with wad.
  function approve(address spender, uint wad) IsActive returns (bool) {
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    // djh: This appears to be of doubtful value, and is not used in the Dappsys library though it is in the Zeppelin one. Removed.
    // require((wad == 0) || (pAllowedM[msg.sender][spender] == 0));
    pAllowedM[msg.sender][spender] = wad;
    Approval(msg.sender, spender, wad);
    return true;
  }
} // End ERC20Token contracts

// PacioToken.sol 2017.08.22 started

/* The Pacio Token named PIOE for the Ethereum version

Follows the EIP20 standard: https://github.com/frozeman/EIPs/blob/94bc4311e889c2c58c561c074be1483f48ac9374/EIPS/eip-20-token-standard.md

2017.10.08 Changed to suit direct deployment rather than being created via the PacioICO constructor, so that Etherscan can recognise it.

*/

contract PacioToken is ERC20Token {
  // enum NFF {  // Founders/Foundation enum
  //   Founders, // 0 Pacio Founders
  //   Foundatn} // 1 Pacio Foundation
  string public constant name   = "Pacio Token";
  string public constant symbol = "PIOE";
  uint8  public constant decimals = 12;
  uint   public tokensIssued;           // Tokens issued - tokens in circulation
  uint   public tokensAvailable;        // Tokens available = total supply less allocated and issued tokens
  uint   public contributors;           // Number of contributors
  uint   public founderTokensAllocated; // Founder tokens allocated
  uint   public founderTokensVested;    // Founder tokens vested. Same as iTokensOwnedM[pFounderToksA] until tokens transferred. Unvested tokens = founderTokensAllocated - founderTokensVested
  uint   public foundationTokensAllocated; // Foundation tokens allocated
  uint   public foundationTokensVested;    // Foundation tokens vested. Same as iTokensOwnedM[pFoundationToksA] until tokens transferred. Unvested tokens = foundationTokensAllocated - foundationTokensVested
  bool   public icoCompleteB;           // Is set to true when both presale and full ICO are complete. Required for vesting of founder and foundation tokens and transfers of PIOEs to PIOs
  address private pFounderToksA;        // Address for Founder tokens issued
  address private pFoundationToksA;     // Address for Foundation tokens issued

  // Events
  // ------
  event LogIssue(address indexed Dst, uint Picos);
  event LogSaleCapReached(uint TokensIssued); // not tokensIssued just to avoid compiler Warning: This declaration shadows an existing declaration
  event LogIcoCompleted();
  event LogBurn(address Src, uint Picos);
  event LogDestroy(uint Picos);

  // No Constructor
  // --------------

  // Initialisation/Settings Methods IsOwner but not IsActive
  // -------------------------------

  // Initialise()
  // To be called by deployment owner to change ownership to the sale contract, and do the initial allocations and minting.
  // Can only be called once. If the sale contract changes but the token contract stays the same then ChangeOwner() can be called via PacioICO.ChangeTokenContractOwner() to change the owner to the new contract
  function Initialise(address vNewOwnerA) { // IsOwner c/o the super.ChangeOwner() call
    require(totalSupply == 0);          // can only be called once
    super.ChangeOwner(vNewOwnerA);      // includes an IsOwner check so don't need to repeat it here
    founderTokensAllocated    = 10**20; // 10% or 100 million = 1e20 Picos
    foundationTokensAllocated = 10**20; // 10% or 100 million = 1e20 Picos This call sets tokensAvailable
    // Equivalent of Mint(10**21) which can't be used here as msg.sender is the old (deployment) owner // 1 Billion PIOEs    = 1e21 Picos, all minted)
    totalSupply           = 10**21; // 1 Billion PIOEs    = 1e21 Picos, all minted)
    iTokensOwnedM[ownerA] = 10**21;
    tokensAvailable       = 8*(10**20); // 800 million [String: '800000000000000000000'] s: 1, e: 20, c: [ 8000000 ] }
    // From the EIP20 Standard: A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
    Transfer(0x0, ownerA, 10**21); // log event 0x0 from == minting
  }

  // Mint()
  // PacioICO() includes a Mint() fn to allow manual calling of this if necessary e.g. re full ICO going over the cap
  function Mint(uint picos) IsOwner {
    totalSupply           = add(totalSupply,           picos);
    iTokensOwnedM[ownerA] = add(iTokensOwnedM[ownerA], picos);
    tokensAvailable = subMaxZero(totalSupply, tokensIssued + founderTokensAllocated + foundationTokensAllocated);
    // From the EIP20 Standard: A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
    Transfer(0x0, ownerA, picos); // log event 0x0 from == minting
  }

  // PrepareForSale()
  // stops transfers and allows purchases
  function PrepareForSale() IsOwner {
    require(!icoCompleteB); // Cannot start selling again once ICO has been set to completed
    saleInProgressB = true; // stops transfers
  }

  // ChangeOwner()
  // To be called by owner to change the token contract owner, expected to be to a sale contract
  // Transfers any minted tokens from old to new sale contract
  function ChangeOwner(address vNewOwnerA) { // IsOwner c/o the super.ChangeOwner() call
    transfer(vNewOwnerA, iTokensOwnedM[ownerA]); // includes checks
    super.ChangeOwner(vNewOwnerA); // includes an IsOwner check so don't need to repeat it here
  }

  // Public Constant Methods
  // -----------------------
  // None. Used public variables instead which result in getter functions

  // State changing public methods made pause-able and with call logging
  // -----------------------------
  // Issue()
  // Transfers picos tokens to dst to issue them. IsOwner because this is expected to be called from the token sale contract
  function Issue(address dst, uint picos) IsOwner IsActive returns (bool) {
    require(saleInProgressB      // Sale is in progress
         && iTokensOwnedM[ownerA] >= picos // Owner has the tokens available
      // && picos > 0            // Non-zero issue No need to check for this
         && dst != address(this) // Not issuing to this token contract
         && dst != ownerA);      // Not issuing to the owner of this contract - the token sale contract
    if (iTokensOwnedM[dst] == 0)
      contributors++;
    iTokensOwnedM[ownerA] -= picos; // There is no need to check this for underflow via a sub() call given the iTokensOwnedM[ownerA] >= picos check
    iTokensOwnedM[dst]     = add(iTokensOwnedM[dst], picos);
    tokensIssued           = add(tokensIssued,       picos);
    tokensAvailable    = subMaxZero(tokensAvailable, picos); // subMaxZero() in case a sale goes over, only possible for full ICO, when cap is for all available tokens.
    LogIssue(dst, picos);                                    // If that should happen,may need to mint some more PIOEs to allow founder and foundation vesting to complete.
    return true;
  }

  // SaleCapReached()
  // To be be called from the token sale contract when a cap (pre or full) is reached
  // Allows transfers
  function SaleCapReached() IsOwner IsActive {
    saleInProgressB = false; // allows transfers
    LogSaleCapReached(tokensIssued);
  }

  // Functions for manual calling via same name function in PacioICO()
  // =================================================================
  // IcoCompleted()
  // To be be called manually via PacioICO after full ICO ends. Could be called before cap is reached if ....
  function IcoCompleted() IsOwner IsActive {
    require(!icoCompleteB);
    saleInProgressB = false; // allows transfers
    icoCompleteB    = true;
    LogIcoCompleted();
  }

  // SetFFSettings(address vFounderTokensA, address vFoundationTokensA, uint vFounderTokensAllocation, uint vFoundationTokensAllocation)
  // Allows setting Founder and Foundation addresses (or changing them if an appropriate transfer has been done)
  //  plus optionally changing the allocations which are set by the constructor, so that they can be varied post deployment if required re a change of plan
  // All values are optional - zeros can be passed
  // Must have been called with non-zero Founder and Foundation addresses before Founder and Foundation vesting can be done
  function SetFFSettings(address vFounderTokensA, address vFoundationTokensA, uint vFounderTokensAllocation, uint vFoundationTokensAllocation) IsOwner {
    if (vFounderTokensA    != address(0)) pFounderToksA    = vFounderTokensA;
    if (vFoundationTokensA != address(0)) pFoundationToksA = vFoundationTokensA;
    if (vFounderTokensAllocation > 0)    assert((founderTokensAllocated    = vFounderTokensAllocation)    >= founderTokensVested);
    if (vFoundationTokensAllocation > 0) assert((foundationTokensAllocated = vFoundationTokensAllocation) >= foundationTokensVested);
    tokensAvailable = totalSupply - founderTokensAllocated - foundationTokensAllocated - tokensIssued;
  }

  // VestFFTokens()
  // To vest Founder and/or Foundation tokens
  // 0 can be passed meaning skip that one
  // No separate event as the LogIssue event can be used to trace vesting transfers
  // To be be called manually via PacioICO
  function VestFFTokens(uint vFounderTokensVesting, uint vFoundationTokensVesting) IsOwner IsActive {
    require(icoCompleteB); // ICO must be completed before vesting can occur. djh?? Add other time restriction?
    if (vFounderTokensVesting > 0) {
      assert(pFounderToksA != address(0)); // Founders token address must have been set
      assert((founderTokensVested  = add(founderTokensVested,          vFounderTokensVesting)) <= founderTokensAllocated);
      iTokensOwnedM[ownerA]        = sub(iTokensOwnedM[ownerA],        vFounderTokensVesting);
      iTokensOwnedM[pFounderToksA] = add(iTokensOwnedM[pFounderToksA], vFounderTokensVesting);
      LogIssue(pFounderToksA,          vFounderTokensVesting);
      tokensIssued = add(tokensIssued, vFounderTokensVesting);
    }
    if (vFoundationTokensVesting > 0) {
      assert(pFoundationToksA != address(0)); // Foundation token address must have been set
      assert((foundationTokensVested  = add(foundationTokensVested,          vFoundationTokensVesting)) <= foundationTokensAllocated);
      iTokensOwnedM[ownerA]           = sub(iTokensOwnedM[ownerA],           vFoundationTokensVesting);
      iTokensOwnedM[pFoundationToksA] = add(iTokensOwnedM[pFoundationToksA], vFoundationTokensVesting);
      LogIssue(pFoundationToksA,       vFoundationTokensVesting);
      tokensIssued = add(tokensIssued, vFoundationTokensVesting);
    }
    // Does not affect tokensAvailable as these tokens had already been allowed for in tokensAvailable when allocated
  }

  // Burn()
  // For use when transferring issued PIOEs to PIOs
  // To be be called manually via PacioICO or from a new transfer contract to be written which is set to own this one
  function Burn(address src, uint picos) IsOwner IsActive {
    require(icoCompleteB);
    iTokensOwnedM[src] = subMaxZero(iTokensOwnedM[src], picos);
    tokensIssued       = subMaxZero(tokensIssued, picos);
    totalSupply        = subMaxZero(totalSupply,  picos);
    LogBurn(src, picos);
    // Does not affect tokensAvailable as these are issued tokens that are being burnt
  }

  // Destroy()
  // For use when transferring unissued PIOEs to PIOs
  // To be be called manually via PacioICO or from a new transfer contract to be written which is set to own this one
  function Destroy(uint picos) IsOwner IsActive {
    require(icoCompleteB);
    totalSupply     = subMaxZero(totalSupply,     picos);
    tokensAvailable = subMaxZero(tokensAvailable, picos);
    LogDestroy(picos);
  }

  // Fallback function
  // =================
  // No sending ether to this contract!
  // Not payable so trying to send ether will throw
  function() {
    revert(); // reject any attempt to access the token contract other than via the defined methods with their testing for valid access
  }
} // End PacioToken contract

// PacioICO.sol 2017.08.16 started

/* Token sale for Pacio.io

Works with PacioToken.sol as the contract for the Pacio Token

The contract is intended to handle both presale and full ICO, though, if necessary a new contract could be used for the full ICO, with the token contract unchanged apart from its owner.

Min purchase Ether 0.1
No end date - just cap or pause

Decisions
---------
No threshold

2017.10.07 Removed ForwardFunds() and made forward happen on each receipt
           Changed from use of fallback fn to specific Buy() fn and made fallback revert, re best practices re fallback fn use.
           Since fallback functions can be misused or abused, Vitalik Buterin suggested "establishing as a convention that fallback functions should generally not be used except in very specific cases."
2017.10.08 Changed to deploy PacioToken contract directly rather than create it via the constructor here, and then to pass the address to  PrepareToStart() as part of getting Etherscan te recognise the Token contract

*/

contract PacioICO is Owned, DSMath {
  string public name;         // Contract name
  uint public  startTime;     // start time of the sale
  uint public  picosCap;      // Cap for the sale
  uint public  picosSold;     // Cumulative Picos sold which should == PIOE.pTokensIssued
  uint public  picosPerEther; // 3,000,000,000,000,000 for ETH = $300 and target PIOE price = $0.10
  uint public  weiRaised;     // cumulative wei raised
  PacioToken public PIOE;     // the Pacio token contract
  address private pPCwalletA; // address of the Pacio Core wallet to receive funds raised

  // Constructor not payable
  // -----------
  //
  function PacioICO() {
    pausedB = true; // start paused
  }

  // Events
  // ------
  event LogPrepareToStart(string Name, uint StartTime, uint PicosCap, PacioToken TokenContract, address PCwallet);
  event LogSetPicosPerEther(uint PicosPerEther);
  event LogChangePCWallet(address PCwallet);
  event LogSale(address indexed Purchaser, uint SaleWei, uint Picos);
  event LogAllocate(address indexed Supplier, uint SuppliedWei, uint Picos);
  event LogSaleCapReached(uint WeiRaised, uint PicosSold);

  // PrepareToStart()
  // --------------
  // To be called manually by owner just prior to the start of the presale or the full ICO
  // Can also be called by owner to adjust settings. With care!!
  function PrepareToStart(string vNameS, uint vStartTime, uint vPicosCap, uint vPicosPerEther, PacioToken vTokenA, address vPCwalletA) IsOwner {
    require(vTokenA != address(0)
         && vPCwalletA != address(0));
    name       = vNameS;     // Pacio Presale | Pacio Token Sale
    startTime  = vStartTime;
    picosCap   = vPicosCap;  // Cap for the sale, 20 Million PIOEs = 20,000,000,000,000,000,000 = 20**19 Picos for the Presale
    PIOE       = vTokenA;    // The token contract
    pPCwalletA = vPCwalletA; // Pacio Code wallet to receive funds
    pausedB    = false;
    PIOE.PrepareForSale();   // stops transfers
    LogPrepareToStart(vNameS, vStartTime, vPicosCap, vTokenA, vPCwalletA);
    SetPicosPerEther(vPicosPerEther);
  }

  // Public Constant Methods
  // -----------------------
  // None. Used public variables instead which result in getter functions

  // State changing public method made pause-able
  // ----------------------------

  // Buy()
  // Fn to be called to buy PIOEs
  function Buy() payable IsActive {
    require(now >= startTime);       // sale is running (in conjunction with the IsActive test)
    require(msg.value >= 0.1 ether); // sent >= the min
    uint picos = mul(picosPerEther, msg.value) / 10**18; // Picos = Picos per ETH * Wei / 10^18 <=== calc for integer arithmetic as in Solidity
    weiRaised = add(weiRaised, msg.value);
    pPCwalletA.transfer(this.balance); // throws on failure
    PIOE.Issue(msg.sender, picos);
    LogSale(msg.sender, msg.value, picos);
    picosSold += picos; // ok wo overflow protection as PIOE.Issue() would have thrown on overflow
    if (picosSold >= picosCap) {
      // Cap reached so end the sale
      pausedB = true;
      PIOE.SaleCapReached(); // Allows transfers
      LogSaleCapReached(weiRaised, picosSold);
    }
  }

  // Functions to be called Manually
  // ===============================
  // SetPicosPerEther()
  // Fn to be called daily (hourly?) or on significant Ether price movement to set the Pico price
  function SetPicosPerEther(uint vPicosPerEther) IsOwner {
    picosPerEther = vPicosPerEther; // 3,000,000,000,000,000 for ETH = $300 and target PIOE price = $0.10
    LogSetPicosPerEther(picosPerEther);
  }

  // ChangePCWallet()
  // Fn to be called to change the PC Wallet to receive funds raised. This is set initially via PrepareToStart()
  function ChangePCWallet(address vPCwalletA) IsOwner {
    require(vPCwalletA != address(0));
    pPCwalletA = vPCwalletA;
    LogChangePCWallet(vPCwalletA);
  }

  // Allocate()
  // Allocate in lieu for goods or services or fiat supplied valued at wad wei in return for picos issued. Not payable
  // no picosCap check
  function Allocate(address vSupplierA, uint wad, uint picos) IsOwner IsActive {
     PIOE.Issue(vSupplierA, picos);
    LogAllocate(vSupplierA, wad, picos);
    picosSold += picos; // ok wo overflow protection as PIOE.Issue() would have thrown on overflow
  }

  // Token Contract Functions to be called Manually via Owner calls to ICO Contract
  // ==============================================================================
  // ChangeTokenContractOwner()
  // To be called manually if a new sale contract is deployed to change the owner of the PacioToken contract to it.
  // Expects the sale contract to have been paused
  // Calling ChangeTokenContractOwner() will stop calls from the old sale contract to token contract IsOwner functions from working
  function ChangeTokenContractOwner(address vNewOwnerA) IsOwner {
    require(pausedB);
    PIOE.ChangeOwner(vNewOwnerA);
  }

  // PauseTokenContract()
  // To be called manually to pause the token contract
  function PauseTokenContract() IsOwner {
    PIOE.Pause();
  }

  // ResumeTokenContract()
  // To be called manually to resume the token contract
  function ResumeTokenContract() IsOwner {
    PIOE.Resume();
  }

  // Mint()
  // To be called manually if necessary e.g. re full ICO going over the cap
  // Expects the sale contract to have been paused
  function Mint(uint picos) IsOwner {
    require(pausedB);
    PIOE.Mint(picos);
  }

  // IcoCompleted()
  // To be be called manually after full ICO ends. Could be called before cap is reached if ....
  // Expects the sale contract to have been paused
  function IcoCompleted() IsOwner {
    require(pausedB);
    PIOE.IcoCompleted();
  }

  // SetFFSettings()
  // Allows setting Founder and Foundation addresses (or changing them if an appropriate transfer has been done)
  //  plus optionally changing the allocations which are set by the PacioToken constructor, so that they can be varied post deployment if required re a change of plan
  // All values are optional - zeros can be passed
  // Must have been called with non-zero Founder and Foundation addresses before Founder and Foundation vesting can be done
  function SetFFSettings(address vFounderTokensA, address vFoundationTokensA, uint vFounderTokensAllocation, uint vFoundationTokensAllocation) IsOwner {
    PIOE.SetFFSettings(vFounderTokensA, vFoundationTokensA, vFounderTokensAllocation, vFoundationTokensAllocation);
  }

  // VestFFTokens()
  // To vest Founder and/or Foundation tokens
  // 0 can be passed meaning skip that one
  // SetFFSettings() must have been called with non-zero Founder and Foundation addresses before this fn can be used
  function VestFFTokens(uint vFounderTokensVesting, uint vFoundationTokensVesting) IsOwner {
    PIOE.VestFFTokens(vFounderTokensVesting, vFoundationTokensVesting);
  }

  // Burn()
  // For use when transferring issued PIOEs to PIOs
  // To be replaced by a new transfer contract to be written which is set to own the PacioToken contract
  function Burn(address src, uint picos) IsOwner {
    PIOE.Burn(src, picos);
  }

  // Destroy()
  // For use when transferring unissued PIOEs to PIOs
  // To be replaced by a new transfer contract to be written which is set to own the PacioToken contract
  function Destroy(uint picos) IsOwner {
    PIOE.Destroy(picos);
  }

  // Fallback function
  // =================
  // No sending ether to this contract!
  // Not payable so trying to send ether will throw
  function() {
    revert(); // reject any attempt to access the token contract other than via the defined methods with their testing for valid access
  }

} // End PacioICO contract