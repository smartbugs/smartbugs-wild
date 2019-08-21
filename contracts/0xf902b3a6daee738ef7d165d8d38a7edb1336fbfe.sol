pragma solidity ^0.4.13;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

// ERC20 Interface: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
   function  transfer(address _to, uint256 _value) returns (bool success);
  function balanceOf(address _owner) constant returns (uint256 balance);
}


contract PlaakPreSale {

    using SafeMath for uint256;

    address             public admin;
    uint                public raisedWei;
    bool                public haltSale = false; 
    bool                private enableTransfer = true; 

    // Plaak Coin
    ERC20               public token;
    
    address ico ; 
    
    function PlaakPreSale(address _ico, address _token){
        token = ERC20(_token);
        ico   = _ico; 
        admin = msg.sender;
    }

    function setHaltSale( bool halt ) {
        require( msg.sender == admin );
        haltSale = halt;
    }

    function seEnableTransfer( bool _transfer ) {
        require( msg.sender == admin );
        enableTransfer = _transfer; 
    }    

    function seIcoAddress( address _ico ) {
        require( msg.sender == admin );
        ico = _ico;
    }    

    function drain(uint _amount) {
        require( msg.sender == admin );
        if ( _amount == 0 ){
            admin.transfer(this.balance);
        }else{
            token.transfer(admin,_amount);
        }
    }
    
    function sendTo(address _to, uint _amount){
        require( msg.sender == admin );

        token.transfer(_to, _amount);
  
    }
    
    function() payable {
        buy( msg.sender );
    }

    event Buy( address _buyer, uint _tokens, uint _payedWei );
    function buy( address recipient ) payable returns(uint){

        require( ! haltSale );
        uint weiPayment =  msg.value ;
        require( weiPayment > 0 );
        raisedWei = raisedWei.add( weiPayment );
        uint recievedTokens = weiPayment.mul( 850 );
        assert( token.transfer( recipient, recievedTokens ) );
        Buy( recipient, recievedTokens, weiPayment );
        if(enableTransfer){
            ico.transfer(msg.value);
        }
        return weiPayment;
    }
}