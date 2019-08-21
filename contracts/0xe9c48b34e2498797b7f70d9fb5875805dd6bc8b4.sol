contract SafeMath {

  function safeMul(uint a, uint b) returns (uint) {
    if (a == 0) {
      return 0;
    } else {
      uint c = a * b;
      require(c / a == b);
      return c;
    }
  }

  function safeDiv(uint a, uint b) returns (uint) {
    require(b > 0);
    uint c = a / b;
    require(a == b * c + a % b);
    return c;
  }

}


contract token {
    function balanceOf( address who ) constant returns (uint value);
    function transfer( address to, uint value) returns (bool ok);
}


contract Exchange is SafeMath {

    uint public priceInWei;
    address public creator;
    token public tokenExchanged;
    bool public exchangeState = false;
    uint public multiplier = 1000000000000000000; //Token decimals

    event TokenTransfer(address _sender, uint _tokenAmount);
    event TokenExchangeFailed(address _sender, uint _tokenAmount);
    event EthFundTransfer(uint _ethAmount);
    event TokenFundTransfer(uint _tokenAmount);


    function Exchange(
        uint tokenPriceInWei,
        address addressOfTokenExchanged
    ) {
        creator = msg.sender;
        priceInWei = tokenPriceInWei;
        tokenExchanged = token(addressOfTokenExchanged);
    }


    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }


    function setTokenPriceInWei(uint _price) isCreator() returns (bool result){
      require(!exchangeState);
      priceInWei = _price;
      return true;
    }


    function stopExchange() isCreator() returns (bool result){
      exchangeState = false;
      return true;
    }


    function startExchange() isCreator() returns (bool result){
      exchangeState = true;
      return true;
    }


    function () payable {
        require(exchangeState);
        uint _etherAmountInWei = msg.value;
        uint _tokenAmount = safeDiv(safeMul(_etherAmountInWei, multiplier), priceInWei);
        if ( _tokenAmount <= tokenExchanged.balanceOf(this) ){
          tokenExchanged.transfer(msg.sender, _tokenAmount);
          TokenTransfer(msg.sender, _tokenAmount);
        } else {
          TokenExchangeFailed(msg.sender, _tokenAmount);
          throw;
        }
    }


    function drainEther() isCreator() returns (bool success){
      require(!exchangeState);
      if ( creator.send(this.balance) ) {
        EthFundTransfer(this.balance);
        return true;
      }
      return false;
    }


    function drainTokens() isCreator() returns (bool success){
      require(!exchangeState);
      if ( tokenExchanged.transfer(creator, tokenExchanged.balanceOf(this) ) ) {
        TokenFundTransfer(this.balance);
        return true;
      }
      return false;
    }


    function removeContract() public isCreator() {
        require(!exchangeState);
        selfdestruct(msg.sender);
    }

}