/**
 *  Crowdfunding.sol v1.0.0
 * 
 *  Bilal Arif - https://twitter.com/furusiyya_
 *  Notary Platform
 */

pragma solidity ^0.4.16;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
contract Ownable {
     /*
      @title Ownable
      @dev The Ownable contract has an owner address, and provides basic authorization control
      functions, this simplifies the implementation of "user permissions".
    */

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable(address _owner){
    owner = _owner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}
contract Pausable is Ownable {
  
  event Pause(bool indexed state);

  bool private paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev return the current state of contract
   */
  function Paused() external constant returns(bool){ return paused; }

  /**
   * @dev called by the owner to pause or unpause, triggers stopped state
   * on first call and returns to normal state on second call
   */
  function tweakState() external onlyOwner {
    paused = !paused;
    Pause(paused);
  }

}

contract Crowdfunding is Pausable, ReentrancyGuard {

      using SafeMath for uint256;
    
      /* the starting time of the crowdsale */
      uint256 private startsAt;
    
      /* the ending time of the crowdsale */
      uint256 private endsAt;
    
      /* how many token units a buyer gets per wei */
      uint256 private rate;
    
      /* How many wei of funding we have received so far */
      uint256 private weiRaised = 0;
    
      /* How many distinct addresses have invested */
      uint256 private investorCount = 0;
      
      /* How many total investments have been made */
      uint256 private totalInvestments = 0;
      
      /* Address of multiSig contract*/
      address private multiSig;
      
      /* Address of tokenStore*/
      address private tokenStore;
      
      /* Address of pre-ico contract*/
      NotaryPlatformToken private token;
     
    
      /** How much ETH each address has invested to this crowdsale */
      mapping (address => uint256) private investedAmountOf;
    
      /** Whitelisted addresses */
      mapping (address => bool) private whiteListed;
      
      /** State machine
       *
       * - Prefunding: We have not passed start time yet
       * - Funding: Active crowdsale
       * - Closed: Funding is closed.
       */
      enum State{PreFunding, Funding, Closed}
    
      /**
       * event for token purchase logging
       * @param purchaser who paid for the tokens
       * @param beneficiary who got the tokens
       * @param value weis paid for purchase
       * @param amount amount of tokens purchased
       */
      event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
      // Funds transfer to other address
      event Transfer(address indexed receiver, uint256 weiAmount);
    
      // Crowdsale end time has been changed
      event EndsAtChanged(uint256 endTimestamp);
    
      event NewExchangeRate(uint256 indexed _rate);
      event TokenContractAddress(address indexed oldAddress,address indexed newAddress);
      event TokenStoreUpdated(address indexed oldAddress,address indexed newAddress);
      event WalletAddressUpdated(address indexed oldAddress,address indexed newAddress);
      event WhiteListUpdated(address indexed investor, bool status);
      event BonusesUpdated(address indexed investor, bool status);

      function Crowdfunding() 
      Ownable(0x0587e235a5906ed8143d026dE530D77AD82F8A92)
      {
        require(earlyBirds());       // load bonuses
        
        multiSig = 0x1D1739F37a103f0D7a5f5736fEd2E77DE9863450;
        tokenStore = 0x244092a2FECFC48259cf810b63BA3B3c0B811DCe;
        
        token = NotaryPlatformToken(0xbA5787e07a0636A756f4B4d517b595dbA24239EF);
        require(token.isTokenContract());
    
        startsAt = now + 2 minutes;
        endsAt = now + 31 days;
        rate = 2730;
      }
    
      /**
       * Allow investor to just send in money
       */
      function() nonZero payable{
        buy(msg.sender);
      }
    
      /**
       * Make an investment.
       *
       * Crowdsale must be running for one to invest.
       * We must have not pressed the emergency brake.
       *
       * @param receiver The Ethereum address who will receive tokens
       *
       */
      function buy(address receiver) public whenNotPaused nonReentrant inState(State.Funding) nonZero payable returns(bool){
        require(receiver != 0x00);
        require(whiteListed[receiver] || isEarlyBird(receiver));

        if(investedAmountOf[msg.sender] == 0) {
          // A new investor
          investorCount++;
        }
    
        // count all investments
        totalInvestments++;
    
        // Update investor
        investedAmountOf[msg.sender] = investedAmountOf[msg.sender].add(msg.value);
        
        // Up total accumulated fudns
        weiRaised = weiRaised.add(msg.value);
        
        uint256 value = getBonus(receiver,msg.value);
        
        // calculate token amount to be transfered
        uint256 tokens = value.mul(rate);
        
        // Transfer NTRY tokens to receiver address
        if(!token.transferFrom(tokenStore,receiver,tokens)){
            revert();
        }
        
        // Tell us purchase was success
        TokenPurchase(msg.sender, receiver, msg.value, tokens);
        
        // Pocket the money
        forwardFunds();
        
        return true;
      }
      
      
      // send ether to the fund collection wallet
      function forwardFunds() internal {
        multiSig.transfer(msg.value);
      }
    
    
     // getters, constant functions
    
      /**
       * @return address of multisignature wallet 
       */
      function multiSigAddress() external constant returns(address){
          return multiSig;
      }
      
      /**
       * @return address of Notary Platform token
       */
      function tokenContractAddress() external constant returns(address){
          return token;
      }
      
      /**
       * @return address of NTRY tokens owner
       */
      function tokenStoreAddress() external constant returns(address){
          return tokenStore;
      }
      
      /**
       * @return startDate Crowdsale opening date
       */
      function fundingStartAt() external constant returns(uint256 ){
          return startsAt;
      }
      
      /**
       * @return endDate Crowdsale closing date
       */
      function fundingEndsAt() external constant returns(uint256){
          return endsAt;
      }
      
      /**
       * @return investors Total of distinct investors
       */
      function distinctInvestors() external constant returns(uint256){
          return investorCount;
      }
      
      /**
       * @return investments Crowdsale closing date
       */
      function investments() external constant returns(uint256){
          return totalInvestments;
      }
      
      /**
       * @param _addr Address of investor
       * @return Number of ethers invested by investor 
       */
      function investedAmoun(address _addr) external constant returns(uint256){
          require(_addr != 0x00);
          return investedAmountOf[_addr];
      }
      
       /**
       * @return total of amount of wie collected by the contract 
       */
      function fundingRaised() external constant returns (uint256){
        return weiRaised;
      }

      /**
       * @return exchage rate of ethers to NTRY tokens 
       */
      function exchnageRate() external constant returns (uint256){
        return rate;
      }

      /**
       * @return the status of the contract if it is allowed to participate. 
       */
      function isWhiteListed(address _address) external constant returns(bool){
        require(_address != 0x00);
        return whiteListed[_address];
      }
      
      /**
       * Crowdfund state machine management.
       *
       * We make it a function and do not assign the result to a variable, so there is no chance of the variable being stale.
       */
      function getState() public constant returns (State) {
        if (now < startsAt) return State.PreFunding;
        else if (now <= endsAt) return State.Funding;
        else if (now > endsAt) return State.Closed;
      }
      
      // Setters, onlyOwner functions
      
       /**
       * @param _newAddress is address of multisignature wallet
       * @return true for case of success
       */
      function updateMultiSig(address _newAddress) external onlyOwner returns(bool){
          require(_newAddress != 0x00);
          WalletAddressUpdated(multiSig,_newAddress);
          multiSig = _newAddress;
          return true;
      }
      
       /**
       * @param _newAddress is address of NTRY token contract
       * @return true for case of success
       */
      function updateTokenContractAddr(address _newAddress) external onlyOwner returns(bool){
          require(_newAddress != 0x00);
          TokenContractAddress(token,_newAddress);
          token = NotaryPlatformToken(_newAddress);
          return true;
      }
      
       /**
       * @param _newAddress is address of NTRY tokens owner
       * @return true for case of success
       */
      function updateTokenStore(address _newAddress) external onlyOwner returns(bool){
          require(_newAddress != 0x00);
          TokenStoreUpdated(tokenStore,_newAddress);
          tokenStore = _newAddress;
          return true;
      }
      
      /**
       * Allow crowdsale owner to close early or extend the crowdsale.
       *
       * This is useful e.g. for a manual soft cap implementation:
       * - after X amount is reached determine manual closing
       *
       * This may put the crowdsale to an invalid state,
       * but we trust owners know what they are doing.
       *
       */
      function updateEndsAt(uint256 _endsAt) external  onlyOwner {
        
        // Don't change past
        require(_endsAt > now);
    
        endsAt = _endsAt;
        EndsAtChanged(_endsAt);
      }

      /**
       * Allow crowdsale owner to change exchange rate.
       */
      function updateExchangeRate(uint256 _newRate) external onlyOwner {
        
        // Don't change past
        require(_newRate > 0);
    
        rate = _newRate;
        NewExchangeRate(_newRate);
      }

      function updateWhiteList(address _address,bool _status) external onlyOwner returns(bool){
        require(_address != 0x00);
        whiteListed[_address] = _status;
        WhiteListUpdated(_address, _status);
        return true;
      }
    
    
      /** Interface marker. */
      function isCrowdsale() external constant returns (bool) {
        return true;
      }
    
      //
      // Modifiers
      //
      /** Modifier allowing execution only if the crowdsale is currently running.  */
      modifier inState(State state) {
        require(getState() == state);
        _;
      }
    
      /** Modifier allowing execution only if received value is greater than zero */
      modifier nonZero(){
        require(msg.value >= 75000000000000000);
        _;
      }


      //////////////////////////////////// Bonuses ////////////////////////////////

      mapping (address => bool) private bonuses;

      function earlyBirds() private returns(bool){
        bonuses[0x017ABCC1012A7FfA811bBe4a26804f9DDac1Af4D] = true;
        bonuses[0x1156ABCBA63ACC64162b0bbf67726a3E5eA1E157] = true;
        bonuses[0xEAC8483261078517528DE64956dBD405f631265c] = true;
        bonuses[0xB0b0D639b612937D50dd26eA6dc668e7AE51642A] = true;
        bonuses[0x417535DEF791d7BBFBC97b0f743a4Da67fD9eC3B] = true;
        bonuses[0x6723f81CDc9a5D5ef2Fe1bFbEdb4f83Bd017D3dC] = true;
        bonuses[0xb9Bd4f154Bb5F2BE5E7Db0357C54720c7f35405d] = true;
        bonuses[0x21CA5617f0cd02f13075C7c22f7231D061F09189] = true;
        bonuses[0x0a6Cd7e558c69baF7388bb0B3432E29Ecc29ac55] = true;
        bonuses[0x6a7f63709422A986A953904c64F10D945c8AfBA1] = true;
        bonuses[0x7E046CB5cE19De94b2D0966B04bD8EF90cDC35d3] = true;
        bonuses[0x1C3118b84988f42007c548e62DFF47A12c955886] = true;
        bonuses[0x7736154662ba56C57B2Be628Fe0e44A609d33Dfb] = true;
        bonuses[0xCcC8d4410a825F3644D3a5BBC0E9dF4ac6B491B3] = true;
        bonuses[0x9Eff6628545E1475C73dF7B72978C2dF90eDFeeD] = true;
        bonuses[0x235377dFB1Da49e39692Ac2635ef091c1b1cF63A] = true;
        bonuses[0x6a8d793026BeBaef1a57e3802DD4bB6B1C844755] = true;
        bonuses[0x26c32811447c8D0878b2daE7F4538AE32de82d57] = true;
        bonuses[0x9CEdb0e60B3C2C1cd9A2ee2E18FD3f68870AF230] = true;
        bonuses[0x28E102d747dF8Ae2cBBD0266911eFB609986515d] = true;
        bonuses[0x5b35061Cc9891c3616Ea05d1423e4CbCfdDF1829] = true;
        bonuses[0x47f2404fa0da21Af5b49F8E011DF851B69C24Aa4] = true;
        bonuses[0x046ec2a3a16e76d5dFb0CFD0BF75C7CA6EB8A4A2] = true;
        bonuses[0x01eD3975993c8BebfF2fb6a7472679C6F7b408Fb] = true;
        bonuses[0x011afc4522663a310AF1b72C5853258CCb2C8f80] = true;
        bonuses[0x3A167819Fd49F3021b91D840a03f4205413e316B] = true;
        bonuses[0xd895E6E5E0a13EC2A16e7bdDD6C1151B01128488] = true;
        bonuses[0xE5d4AaFC54CF15051BBE0bA11f65dE4f4Ccedbc0] = true;
        bonuses[0x21C4ff1738940B3A4216D686f2e63C8dbcb7DC44] = true;
        bonuses[0x196a484dB36D2F2049559551c182209143Db4606] = true;
        bonuses[0x001E0d294383d5b4136476648aCc8D04a6461Ae3] = true;
        bonuses[0x2052004ee9C9a923393a0062748223C1c76a7b59] = true;
        bonuses[0x80844Fb6785c1EaB7671584E73b0a2363599CB2F] = true;
        bonuses[0x526127775D489Af1d7e24bF4e7A8161088Fb90ff] = true;
        bonuses[0xD4340FeF5D32F2754A67bF42a44f4CEc14540606] = true;
        bonuses[0x51A51933721E4ADA68F8C0C36Ca6E37914A8c609] = true;
        bonuses[0xD0780AB2AA7309E139A1513c49fB2127DdC30D3d] = true;
        bonuses[0xE4AFF5ECB1c686F56C16f7dbd5d6a8Da9E200ab7] = true;
        bonuses[0x04bC746A174F53A3e1b5776d5A28f3421A8aE4d0] = true;
        bonuses[0x0D5f69C67DAE06ce606246A8bd88B552d1DdE140] = true;
        bonuses[0x8854f86F4fBd88C4F16c4F3d5A5500de6d082AdC] = true;
        bonuses[0x73c8711F2653749DdEFd7d14Ab84b0c4419B91A5] = true;
        bonuses[0xb8B0eb45463d0CBc85423120bCf57B3283D68D42] = true;
        bonuses[0x7924c67c07376cf7C4473D27BeE92FE82DFD26c5] = true;
        bonuses[0xa6A14A81eC752e0ed5391A22818F44aA240FFBB1] = true;
        bonuses[0xdF88295a162671EFC14f3276A467d31a5AFb63AC] = true;
        bonuses[0xC1c113c60ebf7d92A3D78ff7122435A1e307cE05] = true;
        bonuses[0x1EAaD141CaBA0C85EB28E0172a30dd8561dde030] = true;
        bonuses[0xDE3270049C833fF2A52F18C7718227eb36a92323] = true;
        bonuses[0x2348f7A9313B33Db329182f4FA78Bc0f94d2F040] = true;
        bonuses[0x07c9CC6C24aBDdaB4a7aD82c813b059DD04a7F07] = true;
        bonuses[0xd45BF2dEBD1C4196158DcB177D1Ae910949DC00A] = true;
        bonuses[0xD1F3A1A16F4ab35e5e795Ce3f49Ee2DfF2dD683B] = true;
        bonuses[0x6D567fa2031D42905c40a7E9CFF6c30b8DA4abf6] = true;
        bonuses[0x4aF3b3947D4b4323C241c99eB7FD3ddcAbaef0d7] = true;
        bonuses[0x386167E3c00AAfd9f83a89c05E0fB7e1c2720095] = true;
        bonuses[0x916F356Ccf821be928201505c59a44891168DC08] = true;
        bonuses[0x47cb69881e03213D1EC6e80FCD375bD167336621] = true;
        bonuses[0x36cFB5A6be6b130CfcEb934d3Ca72c1D72c3A7D8] = true;
        bonuses[0x1b29291cF6a57EE008b45f529210d6D5c5f19D91] = true;
        bonuses[0xe6D0Bb9FBb78F10a111bc345058a9a90265622F3] = true;
        bonuses[0x3e83Fc87256142dD2FDEeDc49980f4F9Be9BB1FB] = true;
        bonuses[0xf360b24a530d29C96a26C2E34C0DAbCAB12639F4] = true;
        bonuses[0xF49C6e7e36A714Bbc162E31cA23a04E44DcaF567] = true;
        bonuses[0xa2Ac3516A33e990C8A3ce7845749BaB7C63128C0] = true;
        bonuses[0xdC5984a2673c46B68036076026810FfDfFB695B8] = true;
        bonuses[0xfFfdFaeF43029d6C749CEFf04f65187Bd50A5311] = true;
        bonuses[0xe752737DD519715ab0FA9538949D7F9249c7c168] = true;
        bonuses[0x580d0572DBD9F27C75d5FcC88a6075cE32924C2B] = true;
        bonuses[0x6ee541808C463116A82D76649dA0502935fA8D08] = true;
        bonuses[0xA68B4208E0b7aACef5e7cF8d6691d5B973bAd119] = true;
        bonuses[0x737069E6f9F02062F4D651C5C8C03D50F6Fc99C6] = true;
        bonuses[0x00550191FAc279632f5Ff23d06Cb317139543840] = true;
        bonuses[0x9e6EB194E26649B1F17e5BafBcAbE26B5db433E2] = true;
        bonuses[0x186a813b9fB34d727fE1ED2DFd40D87d1c8431a6] = true;
        bonuses[0x7De8D937a3b2b254199F5D3B38F14c0D0f009Ff8] = true;
        bonuses[0x8f066F3D9f75789d9f126Fdd7cFBcC38a768985D] = true;
        bonuses[0x7D1826Fa8C84608a6C2d5a61Ed5A433D020AA543] = true;
        return true;
      }

      function updateBonuses(address _address,bool _status) external onlyOwner returns(bool){
        require(_address != 0x00);
        bonuses[_address] = _status;
        BonusesUpdated(_address,_status);
        return true;
      }

      function getBonus(address _address,uint256 _value) private returns(uint256){
        if(bonuses[_address]){
           // 10% bonus
           if(_value > 166 ether){
            return (_value*11)/10;
           }
           // 7.5% bonus
           if(_value > 33 ether){
            return (_value*43)/40;
           }
           return (_value*21)/20;
        }
        return _value;
      }

      function isEarlyBird(address _address) constant returns(bool){
        require(_address != 0x00);
        return bonuses[_address];
      }
}

contract NotaryPlatformToken{
    function isTokenContract() returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool);
}