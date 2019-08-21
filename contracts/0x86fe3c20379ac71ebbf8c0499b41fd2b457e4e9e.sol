pragma solidity ^0.4.18;

/**
 * TradeToken Crowdsale Contract
 *
 * This is the crowdsale contract for the TradeToken. It utilizes Majoolr's
 * CrowdsaleLib library to reduce custom source code surface area and increase
 * overall security.Majoolr provides smart contract services and security reviews
 * for contract deployments in addition to working on open source projects in the
 * Ethereum community.
 * For further information: trade.io, majoolr.io
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

contract TIOCrowdsale {
  using DirectCrowdsaleLib for DirectCrowdsaleLib.DirectCrowdsaleStorage;

  DirectCrowdsaleLib.DirectCrowdsaleStorage sale;
  bool public greenshoeActive;
  function TIOCrowdsale(
                address owner,
                uint256[] saleData,           // [1512633600, 50, 0, 1513238400, 56, 0, 1513843200, 64, 0, 1514448000, 75, 0]
                uint256 fallbackExchangeRate, // 45000
                uint256 capAmountInCents,     // 24750000000
                uint256 endTime,              // 1515052740
                uint8 percentBurn,            // 100
                CrowdsaleToken token)         // 0x80bc5512561c7f85a3a9508c7df7901b370fa1df
  {
  	sale.init(owner, saleData, fallbackExchangeRate, capAmountInCents, endTime, percentBurn, token);
  }

  // fallback function can be used to buy tokens
  function () payable {
    sendPurchase();
  }

  function sendPurchase() payable returns (bool) {
    uint256 _tokensSold = getTokensSold();
    if(_tokensSold > 270000000000000000000000000 && (!greenshoeActive)){
      bool success = activateGreenshoe();
      assert(success);
    }
  	return sale.receivePurchase(msg.value);
  }

  function activateGreenshoe() private returns (bool) {
    uint256 _currentPrice = sale.base.saleData[sale.base.milestoneTimes[sale.base.currentMilestone]][0];
    while(sale.base.milestoneTimes.length > sale.base.currentMilestone + 1)
    {
      sale.base.currentMilestone += 1;
      sale.base.saleData[sale.base.milestoneTimes[sale.base.currentMilestone]][0] = _currentPrice;
    }
    greenshoeActive = true;
    return true;
  }

  function withdrawTokens() returns (bool) {
  	return sale.withdrawTokens();
  }

  function withdrawLeftoverWei() returns (bool) {
    return sale.withdrawLeftoverWei();
  }

  function withdrawOwnerEth() returns (bool) {
    return sale.withdrawOwnerEth();
  }

  function crowdsaleActive() constant returns (bool) {
    return sale.crowdsaleActive();
  }

  function crowdsaleEnded() constant returns (bool) {
    return sale.crowdsaleEnded();
  }

  function setTokenExchangeRate(uint256 _exchangeRate) returns (bool) {
    return sale.setTokenExchangeRate(_exchangeRate);
  }

  function setTokens() returns (bool) {
    return sale.setTokens();
  }

  function getOwner() constant returns (address) {
    return sale.base.owner;
  }

  function getTokensPerEth() constant returns (uint256) {
    return sale.base.tokensPerEth;
  }

  function getExchangeRate() constant returns (uint256) {
    return sale.base.exchangeRate;
  }

  function getCapAmount() constant returns (uint256) {
    if(!greenshoeActive) {
      return sale.base.capAmount - 160000000000000000000000;
    } else {
      return sale.base.capAmount;
    }
  }

  function getStartTime() constant returns (uint256) {
    return sale.base.startTime;
  }

  function getEndTime() constant returns (uint256) {
    return sale.base.endTime;
  }

  function getEthRaised() constant returns (uint256) {
    return sale.base.ownerBalance;
  }

  function getContribution(address _buyer) constant returns (uint256) {
  	return sale.base.hasContributed[_buyer];
  }

  function getTokenPurchase(address _buyer) constant returns (uint256) {
  	return sale.base.withdrawTokensMap[_buyer];
  }

  function getLeftoverWei(address _buyer) constant returns (uint256) {
    return sale.base.leftoverWei[_buyer];
  }

  function getSaleData(uint256 timestamp) constant returns (uint256[3]) {
    return sale.getSaleData(timestamp);
  }

  function getTokensSold() constant returns (uint256) {
    return sale.base.startingTokenBalance - sale.base.withdrawTokensMap[sale.base.owner];
  }

  function getPercentBurn() constant returns (uint256) {
    return sale.base.percentBurn;
  }
}

library DirectCrowdsaleLib {
  using BasicMathLib for uint256;
  using CrowdsaleLib for CrowdsaleLib.CrowdsaleStorage;

  struct DirectCrowdsaleStorage {

  	CrowdsaleLib.CrowdsaleStorage base; // base storage from CrowdsaleLib

  }

  event LogTokensBought(address indexed buyer, uint256 amount);
  event LogAddressCapExceeded(address indexed buyer, uint256 amount, string Msg);
  event LogErrorMsg(uint256 amount, string Msg);
  event LogTokenPriceChange(uint256 amount, string Msg);


  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in cents at that time,
  /// 3 is address purchase cap at that time, 0 if no address cap
  /// @param _fallbackExchangeRate Exchange rate of cents/ETH
  /// @param _capAmountInCents Total to be raised in cents
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _token Token being sold
  function init(DirectCrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _fallbackExchangeRate,
                uint256 _capAmountInCents,
                uint256 _endTime,
                uint8 _percentBurn,
                CrowdsaleToken _token)
                public
  {
  	self.base.init(_owner,
                _saleData,
                _fallbackExchangeRate,
                _capAmountInCents,
                _endTime,
                _percentBurn,
                _token);
  }

  /// @dev Called when an address wants to purchase tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _amount amount of wei that the buyer is sending
  /// @return true on succesful purchase
  function receivePurchase(DirectCrowdsaleStorage storage self, uint256 _amount)
                           public
                           returns (bool)
  {
    require(msg.sender != self.base.owner);
  	require(self.base.validPurchase());

  	// if the token price increase interval has passed, update the current day and change the token price
  	if ((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
        (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
    {
        while((self.base.milestoneTimes.length > self.base.currentMilestone + 1) &&
              (now > self.base.milestoneTimes[self.base.currentMilestone + 1]))
        {
          self.base.currentMilestone += 1;
        }

        self.base.changeTokenPrice(self.base.saleData[self.base.milestoneTimes[self.base.currentMilestone]][0]);
        LogTokenPriceChange(self.base.tokensPerEth,"Token Price has changed!");
    }

  	uint256 _numTokens; //number of tokens that will be purchased
    uint256 _newBalance; //the new balance of the owner of the crowdsale
    uint256 _weiTokens; //temp calc holder
    uint256 _leftoverWei; //wei change for purchaser
    uint256 _remainder; //temp calc holder
    bool err;

    if((self.base.ownerBalance + _amount) > self.base.capAmount){
      _leftoverWei = (self.base.ownerBalance + _amount) - self.base.capAmount;
      _amount = _amount - _leftoverWei;
    }

    // Find the number of tokens as a function in wei
    (err,_weiTokens) = _amount.times(self.base.tokensPerEth);
    require(!err);

    _numTokens = _weiTokens / 1000000000000000000;
    _remainder = _weiTokens % 1000000000000000000;
    _remainder = _remainder / self.base.tokensPerEth;
    _leftoverWei = _leftoverWei + _remainder;
    _amount = _amount - _remainder;
    self.base.leftoverWei[msg.sender] += _leftoverWei;

    // can't overflow because it is under the cap
    self.base.hasContributed[msg.sender] += _amount;

    assert(_numTokens <= self.base.token.balanceOf(this));

    // calculate the amount of ether in the owners balance
    (err,_newBalance) = self.base.ownerBalance.plus(_amount);
    require(!err);

    self.base.ownerBalance = _newBalance;   // "deposit" the amount

    // can't overflow because it will be under the cap
	  self.base.withdrawTokensMap[msg.sender] += _numTokens;

    //subtract tokens from owner's share
    (err,_remainder) = self.base.withdrawTokensMap[self.base.owner].minus(_numTokens);
    require(!err);
    self.base.withdrawTokensMap[self.base.owner] = _remainder;

	  LogTokensBought(msg.sender, _numTokens);

    return true;
  }

  /*Functions "inherited" from CrowdsaleLib library*/

  function setTokenExchangeRate(DirectCrowdsaleStorage storage self, uint256 _exchangeRate)
                                public
                                returns (bool)
  {
    return self.base.setTokenExchangeRate(_exchangeRate);
  }

  function setTokens(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.setTokens();
  }

  function withdrawTokens(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawTokens();
  }

  function withdrawLeftoverWei(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawLeftoverWei();
  }

  function withdrawOwnerEth(DirectCrowdsaleStorage storage self) public returns (bool) {
    return self.base.withdrawOwnerEth();
  }

  function getSaleData(DirectCrowdsaleStorage storage self, uint256 timestamp)
                       public
                       view
                       returns (uint256[3])
  {
    return self.base.getSaleData(timestamp);
  }

  function getTokensSold(DirectCrowdsaleStorage storage self) public view returns (uint256) {
    return self.base.getTokensSold();
  }

  function crowdsaleActive(DirectCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleActive();
  }

  function crowdsaleEnded(DirectCrowdsaleStorage storage self) public view returns (bool) {
    return self.base.crowdsaleEnded();
  }
}

library CrowdsaleLib {
  using BasicMathLib for uint256;

  struct CrowdsaleStorage {
  	address owner;     //owner of the crowdsale

  	uint256 tokensPerEth;  //number of tokens received per ether
  	uint256 capAmount; //Maximum amount to be raised in wei
  	uint256 startTime; //ICO start time, timestamp
  	uint256 endTime; //ICO end time, timestamp automatically calculated
    uint256 exchangeRate; //cents/ETH exchange rate at the time of the sale
    uint256 ownerBalance; //owner wei Balance
    uint256 startingTokenBalance; //initial amount of tokens for sale
    uint256[] milestoneTimes; //Array of timestamps when token price and address cap changes
    uint8 currentMilestone; //Pointer to the current milestone
    uint8 tokenDecimals; //stored token decimals for calculation later
    uint8 percentBurn; //percentage of extra tokens to burn
    bool tokensSet; //true if tokens have been prepared for crowdsale
    bool rateSet; //true if exchange rate has been set

    //Maps timestamp to token price and address purchase cap starting at that time
    mapping (uint256 => uint256[2]) saleData;

    //shows how much wei an address has contributed
  	mapping (address => uint256) hasContributed;

    //For token withdraw function, maps a user address to the amount of tokens they can withdraw
  	mapping (address => uint256) withdrawTokensMap;

    // any leftover wei that buyers contributed that didn't add up to a whole token amount
    mapping (address => uint256) leftoverWei;

  	CrowdsaleToken token; //token being sold
  }

  // Indicates when an address has withdrawn their supply of tokens
  event LogTokensWithdrawn(address indexed _bidder, uint256 Amount);

  // Indicates when an address has withdrawn their supply of extra wei
  event LogWeiWithdrawn(address indexed _bidder, uint256 Amount);

  // Logs when owner has pulled eth
  event LogOwnerEthWithdrawn(address indexed owner, uint256 amount, string Msg);

  // Generic Notice message that includes and address and number
  event LogNoticeMsg(address _buyer, uint256 value, string Msg);

  // Indicates when an error has occurred in the execution of a function
  event LogErrorMsg(uint256 amount, string Msg);

  /// @dev Called by a crowdsale contract upon creation.
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _owner Address of crowdsale owner
  /// @param _saleData Array of 3 item sets such that, in each 3 element
  /// set, 1 is timestamp, 2 is price in cents at that time,
  /// 3 is address token purchase cap at that time, 0 if no address cap
  /// @param _fallbackExchangeRate Exchange rate of cents/ETH
  /// @param _capAmountInCents Total to be raised in cents
  /// @param _endTime Timestamp of sale end time
  /// @param _percentBurn Percentage of extra tokens to burn
  /// @param _token Token being sold
  function init(CrowdsaleStorage storage self,
                address _owner,
                uint256[] _saleData,
                uint256 _fallbackExchangeRate,
                uint256 _capAmountInCents,
                uint256 _endTime,
                uint8 _percentBurn,
                CrowdsaleToken _token)
                public
  {
  	require(self.capAmount == 0);
  	require(self.owner == 0);
    require(_saleData.length > 0);
    require((_saleData.length%3) == 0); // ensure saleData is 3-item sets
    require(_saleData[0] > (now + 3 days));
    require(_endTime > _saleData[0]);
    require(_capAmountInCents > 0);
    require(_owner > 0);
    require(_fallbackExchangeRate > 0);
    require(_percentBurn <= 100);
    self.owner = _owner;
    self.capAmount = ((_capAmountInCents/_fallbackExchangeRate) + 1)*(10**18);
    self.startTime = _saleData[0];
    self.endTime = _endTime;
    self.token = _token;
    self.tokenDecimals = _token.decimals();
    self.percentBurn = _percentBurn;
    self.exchangeRate = _fallbackExchangeRate;

    uint256 _tempTime;
    for(uint256 i = 0; i < _saleData.length; i += 3){
      require(_saleData[i] > _tempTime);
      require(_saleData[i + 1] > 0);
      require((_saleData[i + 2] == 0) || (_saleData[i + 2] >= 100));
      self.milestoneTimes.push(_saleData[i]);
      self.saleData[_saleData[i]][0] = _saleData[i + 1];
      self.saleData[_saleData[i]][1] = _saleData[i + 2];
      _tempTime = _saleData[i];
    }
    changeTokenPrice(self, _saleData[1]);
  }

  /// @dev function to check if the crowdsale is currently active
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleActive(CrowdsaleStorage storage self) public view returns (bool) {
  	return (now >= self.startTime && now <= self.endTime);
  }

  /// @dev function to check if the crowdsale has ended
  /// @param self Stored crowdsale from crowdsale contract
  /// @return success
  function crowdsaleEnded(CrowdsaleStorage storage self) public view returns (bool) {
  	return now > self.endTime;
  }

  /// @dev function to check if a purchase is valid
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if the transaction can buy tokens
  function validPurchase(CrowdsaleStorage storage self) internal returns (bool) {
    bool nonZeroPurchase = msg.value != 0;
    if (crowdsaleActive(self) && nonZeroPurchase) {
      return true;
    } else {
      LogErrorMsg(msg.value, "Invalid Purchase! Check start time and amount of ether.");
      return false;
    }
  }

  /// @dev Function called by purchasers to pull tokens
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if tokens were withdrawn
  function withdrawTokens(CrowdsaleStorage storage self) public returns (bool) {
    bool ok;

    if (self.withdrawTokensMap[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no tokens to withdraw!");
      return false;
    }

    if (msg.sender == self.owner) {
      if(!crowdsaleEnded(self)){
        LogErrorMsg(0, "Owner cannot withdraw extra tokens until after the sale!");
        return false;
      } else {
        if(self.percentBurn > 0){
          uint256 _burnAmount = (self.withdrawTokensMap[msg.sender] * self.percentBurn)/100;
          self.withdrawTokensMap[msg.sender] = self.withdrawTokensMap[msg.sender] - _burnAmount;
          ok = self.token.burnToken(_burnAmount);
          require(ok);
        }
      }
    }

    var total = self.withdrawTokensMap[msg.sender];
    self.withdrawTokensMap[msg.sender] = 0;
    ok = self.token.transfer(msg.sender, total);
    require(ok);
    LogTokensWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev Function called by purchasers to pull leftover wei from their purchases
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if wei was withdrawn
  function withdrawLeftoverWei(CrowdsaleStorage storage self) public returns (bool) {
    if (self.leftoverWei[msg.sender] == 0) {
      LogErrorMsg(0, "Sender has no extra wei to withdraw!");
      return false;
    }

    var total = self.leftoverWei[msg.sender];
    self.leftoverWei[msg.sender] = 0;
    msg.sender.transfer(total);
    LogWeiWithdrawn(msg.sender, total);
    return true;
  }

  /// @dev send ether from the completed crowdsale to the owners wallet address
  /// @param self Stored crowdsale from crowdsale contract
  /// @return true if owner withdrew eth
  function withdrawOwnerEth(CrowdsaleStorage storage self) public returns (bool) {
    if ((!crowdsaleEnded(self)) && (self.token.balanceOf(this)>0)) {
      LogErrorMsg(0, "Cannot withdraw owner ether until after the sale!");
      return false;
    }

    require(msg.sender == self.owner);
    require(self.ownerBalance > 0);

    uint256 amount = self.ownerBalance;
    self.ownerBalance = 0;
    self.owner.transfer(amount);
    LogOwnerEthWithdrawn(msg.sender,amount,"Crowdsale owner has withdrawn all funds!");

    return true;
  }

  /// @dev Function to change the price of the token
  /// @param self Stored crowdsale from crowdsale contract
  /// @param _newPrice new token price (amount of tokens per ether)
  /// @return true if the token price changed successfully
  function changeTokenPrice(CrowdsaleStorage storage self,
                            uint256 _newPrice)
                            internal
                            returns (bool)
  {
  	require(_newPrice > 0);

    bool err;
    uint256 result;

    (err, result) = self.exchangeRate.times(10**uint256(self.tokenDecimals));
    require(!err);

    self.tokensPerEth = result / _newPrice;

    return true;
  }

  /// @dev function that is called three days before the sale to set the token and price
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param _exchangeRate  ETH exchange rate expressed in cents/ETH
  /// @return true if the exchange rate has been set
  function setTokenExchangeRate(CrowdsaleStorage storage self, uint256 _exchangeRate)
                                public
                                returns (bool)
  {
    require(msg.sender == self.owner);
    require((now > (self.startTime - 3 days)) && (now < (self.startTime)));
    require(!self.rateSet);   // the exchange rate can only be set once!
    require(self.token.balanceOf(this) > 0);
    require(_exchangeRate > 0);

    uint256 _capAmountInCents;
    bool err;

    (err, _capAmountInCents) = self.exchangeRate.times(self.capAmount);
    require(!err);

    self.exchangeRate = _exchangeRate;
    self.capAmount = (_capAmountInCents/_exchangeRate) + 1;
    changeTokenPrice(self,self.saleData[self.milestoneTimes[0]][0]);
    self.rateSet = true;

    err = !(setTokens(self));
    require(!err);

    LogNoticeMsg(msg.sender,self.tokensPerEth,"Owner has set the exchange Rate and tokens bought per ETH!");
    return true;
  }

  /// @dev fallback function to set tokens if the exchange rate function was not called
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return true if tokens set successfully
  function setTokens(CrowdsaleStorage storage self) public returns (bool) {
    require((msg.sender == self.owner) || (msg.sender == address(this)));
    require(!self.tokensSet);

    uint256 _tokenBalance;

    _tokenBalance = self.token.balanceOf(this);
    self.withdrawTokensMap[msg.sender] = _tokenBalance;
    self.startingTokenBalance = _tokenBalance;
    self.tokensSet = true;

    return true;
  }

  /// @dev Gets the price and buy cap for individual addresses at the given milestone index
  /// @param self Stored Crowdsale from crowdsale contract
  /// @param timestamp Time during sale for which data is requested
  /// @return A 3-element array with 0 the timestamp, 1 the price in cents, 2 the address cap
  function getSaleData(CrowdsaleStorage storage self, uint256 timestamp)
                       public
                       view
                       returns (uint256[3])
  {
    uint256[3] memory _thisData;
    uint256 index;

    while((index < self.milestoneTimes.length) && (self.milestoneTimes[index] < timestamp)) {
      index++;
    }
    if(index == 0)
      index++;

    _thisData[0] = self.milestoneTimes[index - 1];
    _thisData[1] = self.saleData[_thisData[0]][0];
    _thisData[2] = self.saleData[_thisData[0]][1];
    return _thisData;
  }

  /// @dev Gets the number of tokens sold thus far
  /// @param self Stored Crowdsale from crowdsale contract
  /// @return Number of tokens sold
  function getTokensSold(CrowdsaleStorage storage self) public view returns (uint256) {
    return self.startingTokenBalance - self.token.balanceOf(this);
  }
}

library TokenLib {
  using BasicMathLib for uint256;

  struct TokenStorage {
    bool initialized;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    string name;
    string symbol;
    uint256 totalSupply;
    uint256 initialSupply;
    address owner;
    uint8 decimals;
    bool stillMinting;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event OwnerChange(address from, address to);
  event Burn(address indexed burner, uint256 value);
  event MintingClosed(bool mintingClosed);

  /// @dev Called by the Standard Token upon creation.
  /// @param self Stored token from token contract
  /// @param _name Name of the new token
  /// @param _symbol Symbol of the new token
  /// @param _decimals Decimal places for the token represented
  /// @param _initial_supply The initial token supply
  /// @param _allowMinting True if additional tokens can be created, false otherwise
  function init(TokenStorage storage self,
                address _owner,
                string _name,
                string _symbol,
                uint8 _decimals,
                uint256 _initial_supply,
                bool _allowMinting)
                public
  {
    require(!self.initialized);
    self.initialized = true;
    self.name = _name;
    self.symbol = _symbol;
    self.totalSupply = _initial_supply;
    self.initialSupply = _initial_supply;
    self.decimals = _decimals;
    self.owner = _owner;
    self.stillMinting = _allowMinting;
    self.balances[_owner] = _initial_supply;
  }

  /// @dev Transfer tokens from caller's account to another account.
  /// @param self Stored token from token contract
  /// @param _to Address to send tokens
  /// @param _value Number of tokens to send
  /// @return True if completed
  function transfer(TokenStorage storage self, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    bool err;
    uint256 balance;

    (err,balance) = self.balances[msg.sender].minus(_value);
    require(!err);
    self.balances[msg.sender] = balance;
    //It's not possible to overflow token supply
    self.balances[_to] = self.balances[_to] + _value;
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Authorized caller transfers tokens from one account to another
  /// @param self Stored token from token contract
  /// @param _from Address to send tokens from
  /// @param _to Address to send tokens to
  /// @param _value Number of tokens to send
  /// @return True if completed
  function transferFrom(TokenStorage storage self,
                        address _from,
                        address _to,
                        uint256 _value)
                        public
                        returns (bool)
  {
    var _allowance = self.allowed[_from][msg.sender];
    bool err;
    uint256 balanceOwner;
    uint256 balanceSpender;

    (err,balanceOwner) = self.balances[_from].minus(_value);
    require(!err);

    (err,balanceSpender) = _allowance.minus(_value);
    require(!err);

    self.balances[_from] = balanceOwner;
    self.allowed[_from][msg.sender] = balanceSpender;
    self.balances[_to] = self.balances[_to] + _value;

    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Retrieve token balance for an account
  /// @param self Stored token from token contract
  /// @param _owner Address to retrieve balance of
  /// @return balance The number of tokens in the subject account
  function balanceOf(TokenStorage storage self, address _owner) public view returns (uint256 balance) {
    return self.balances[_owner];
  }

  /// @dev Authorize an account to send tokens on caller's behalf
  /// @param self Stored token from token contract
  /// @param _spender Address to authorize
  /// @param _value Number of tokens authorized account may send
  /// @return True if completed
  function approve(TokenStorage storage self, address _spender, uint256 _value) public returns (bool) {
    // must set to zero before changing approval amount in accordance with spec
    require((_value == 0) || (self.allowed[msg.sender][_spender] == 0));

    self.allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Remaining tokens third party spender has to send
  /// @param self Stored token from token contract
  /// @param _owner Address of token holder
  /// @param _spender Address of authorized spender
  /// @return remaining Number of tokens spender has left in owner's account
  function allowance(TokenStorage storage self, address _owner, address _spender)
                     public
                     view
                     returns (uint256 remaining) {
    return self.allowed[_owner][_spender];
  }

  /// @dev Authorize third party transfer by increasing/decreasing allowed rather than setting it
  /// @param self Stored token from token contract
  /// @param _spender Address to authorize
  /// @param _valueChange Increase or decrease in number of tokens authorized account may send
  /// @param _increase True if increasing allowance, false if decreasing allowance
  /// @return True if completed
  function approveChange (TokenStorage storage self, address _spender, uint256 _valueChange, bool _increase)
                          public returns (bool)
  {
    uint256 _newAllowed;
    bool err;

    if(_increase) {
      (err, _newAllowed) = self.allowed[msg.sender][_spender].plus(_valueChange);
      require(!err);

      self.allowed[msg.sender][_spender] = _newAllowed;
    } else {
      if (_valueChange > self.allowed[msg.sender][_spender]) {
        self.allowed[msg.sender][_spender] = 0;
      } else {
        _newAllowed = self.allowed[msg.sender][_spender] - _valueChange;
        self.allowed[msg.sender][_spender] = _newAllowed;
      }
    }

    Approval(msg.sender, _spender, _newAllowed);
    return true;
  }

  /// @dev Change owning address of the token contract, specifically for minting
  /// @param self Stored token from token contract
  /// @param _newOwner Address for the new owner
  /// @return True if completed
  function changeOwner(TokenStorage storage self, address _newOwner) public returns (bool) {
    require((self.owner == msg.sender) && (_newOwner > 0));

    self.owner = _newOwner;
    OwnerChange(msg.sender, _newOwner);
    return true;
  }

  /// @dev Mints additional tokens, new tokens go to owner
  /// @param self Stored token from token contract
  /// @param _amount Number of tokens to mint
  /// @return True if completed
  function mintToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
    require((self.owner == msg.sender) && self.stillMinting);
    uint256 _newAmount;
    bool err;

    (err, _newAmount) = self.totalSupply.plus(_amount);
    require(!err);

    self.totalSupply =  _newAmount;
    self.balances[self.owner] = self.balances[self.owner] + _amount;
    Transfer(0x0, self.owner, _amount);
    return true;
  }

  /// @dev Permanent stops minting
  /// @param self Stored token from token contract
  /// @return True if completed
  function closeMint(TokenStorage storage self) public returns (bool) {
    require(self.owner == msg.sender);

    self.stillMinting = false;
    MintingClosed(true);
    return true;
  }

  /// @dev Permanently burn tokens
  /// @param self Stored token from token contract
  /// @param _amount Amount of tokens to burn
  /// @return True if completed
  function burnToken(TokenStorage storage self, uint256 _amount) public returns (bool) {
      uint256 _newBalance;
      bool err;

      (err, _newBalance) = self.balances[msg.sender].minus(_amount);
      require(!err);

      self.balances[msg.sender] = _newBalance;
      self.totalSupply = self.totalSupply - _amount;
      Burn(msg.sender, _amount);
      Transfer(msg.sender, 0x0, _amount);
      return true;
  }
}

library BasicMathLib {
  /// @dev Multiplies two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The product of a and b, or 0 if there is overflow
  function times(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
    assembly{
      res := mul(a,b)
      switch or(iszero(b), eq(div(res,b), a))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Divides two numbers but checks for 0 in the divisor first.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if `b` is 0
  /// @return res The quotient of a and b, or 0 if `b` is 0
  function dividedBy(uint256 a, uint256 b) public view returns (bool err,uint256 i) {
    uint256 res;
    assembly{
      switch iszero(b)
      case 0 {
        res := div(a,b)
        let loc := mload(0x40)
        mstore(add(loc,0x20),res)
        i := mload(add(loc,0x20))
      }
      default {
        err := 1
        i := 0
      }
    }
  }

  /// @dev Adds two numbers and checks for overflow before returning.
  /// Does not throw.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is overflow
  /// @return res The sum of a and b, or 0 if there is overflow
  function plus(uint256 a, uint256 b) public view returns (bool err, uint256 res) {
    assembly{
      res := add(a,b)
      switch and(eq(sub(res,b), a), or(gt(res,b),eq(res,b)))
      case 0 {
        err := 1
        res := 0
      }
    }
  }

  /// @dev Subtracts two numbers and checks for underflow before returning.
  /// Does not throw but rather logs an Err event if there is underflow.
  /// @param a First number
  /// @param b Second number
  /// @return err False normally, or true if there is underflow
  /// @return res The difference between a and b, or 0 if there is underflow
  function minus(uint256 a, uint256 b) public view returns (bool err,uint256 res) {
    assembly{
      res := sub(a,b)
      switch eq(and(eq(add(res,b), a), or(lt(res,a), eq(res,a))), 1)
      case 0 {
        err := 1
        res := 0
      }
    }
  }
}

contract CrowdsaleToken {
  using TokenLib for TokenLib.TokenStorage;

  TokenLib.TokenStorage public token;

  function CrowdsaleToken(address owner,
                                   string name,
                                   string symbol,
                                   uint8 decimals,
                                   uint256 initialSupply,
                                   bool allowMinting)
                                   public
  {
    token.init(owner, name, symbol, decimals, initialSupply, allowMinting);
  }

  function name() public view returns (string) {
    return token.name;
  }

  function symbol() public view returns (string) {
    return token.symbol;
  }

  function decimals() public view returns (uint8) {
    return token.decimals;
  }

  function totalSupply() public view returns (uint256) {
    return token.totalSupply;
  }

  function initialSupply() public view returns (uint256) {
    return token.initialSupply;
  }

  function balanceOf(address who) public view returns (uint256) {
    return token.balanceOf(who);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return token.allowance(owner, spender);
  }

  function transfer(address to, uint256 value) public returns (bool ok) {
    return token.transfer(to, value);
  }

  function transferFrom(address from, address to, uint value) public returns (bool ok) {
    return token.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public returns (bool ok) {
    return token.approve(spender, value);
  }

  function approveChange(address spender, uint256 valueChange, bool increase)
                         public
                         returns (bool)
  {
    return token.approveChange(spender, valueChange, increase);
  }

  function changeOwner(address newOwner) public returns (bool ok) {
    return token.changeOwner(newOwner);
  }

  function burnToken(uint256 amount) public returns (bool ok) {
    return token.burnToken(amount);
  }
}