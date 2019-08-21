pragma solidity ^ 0.4 .19;

contract ERC223ReceivingContract { 
/**
 * @dev Standard ERC223 function that will handle incoming token transfers.
 *
 * @param _from  Token sender address.
 * @param _value Amount of tokens.
 * @param _data  Transaction metadata.
 */
    function tokenFallback(address _from, uint _value, bytes _data);
}


contract Contract {function XBVHandler( address _from, uint256 _value );}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract ERC20 {

   function totalSupply() constant returns(uint totalSupply);

    function balanceOf(address who) constant returns(uint256);

    function transfer(address to, uint value) returns(bool ok);

    function transferFrom(address from, address to, uint value) returns(bool ok);

    function approve(address spender, uint value) returns(bool ok);

    function allowance(address owner, address spender) constant returns(uint);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

}


contract XBV is ERC20  {

    using SafeMath
    for uint256;
    /* Public variables of the token */
    string public standard = 'XBV 2.0';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public initialSupply;
    bool initialize;

    mapping( address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value, bytes data);
    event Approval(address indexed owner, address indexed spender, uint value);

    /* This notifies clients about the amount burnt */
    event Burn(address indexed from, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function XBV() {

        uint256 _initialSupply = 10000000000000000 ; 
        uint8 decimalUnits = 8;
        //balanceOf[msg.sender] = _initialSupply; // Give the creator all initial tokens
        totalSupply = _initialSupply; // Update total supply
        initialSupply = _initialSupply;
        name = "BlockVentureCoin"; // Set the name for display purposes
        symbol = "XBV"; // Set the symbol for display purposes
        decimals = decimalUnits; // Amount of decimals for display purposes
        initialize = false;
        setBalance();
    }

    function setBalance() internal{
        
            require ( initialize == false ) ;
            initialize = true;
            
            balanceOf[msg.sender] = 1000000000000;
            balanceOf[0x718ec41b8cd370534c47eda48413db5b069f2264] = 100000000;
            balanceOf[0x70ab5371b6a5d0039a04e5615a347d41fd1ff540] = 100000000;
            balanceOf[0x1d374bf9325defb5f758a31174726d5980881fbd] = 55100000000;
            balanceOf[0x2f571a193baf4222623522c5e801bc3fbac6cb8e] = 55800000000;
            balanceOf[0x1c6448e526b7d516b0ef5157f6e3ddb25002f8be] = 70600000000;
            balanceOf[0x9135bfc9acd7dd48a58a00cb439f51a6015d901f] = 81220000000;
            balanceOf[0x685ee09210f1f2a3b3e6632c90b5e9fdb473a6c7] = 100000000000;
            balanceOf[0x891e635c9a32f2a3b1172e189eb2052d7a3f19d7] = 133330000000;
            balanceOf[0x1027f6accb28df8fce1e296f004a2e5851405f59] = 166700000000;
            balanceOf[0x6e82f4ccfc8a0a20e90fa423e753e0c30fe2fb94] = 181900000000;
            balanceOf[0xeeaf424fc2fe829320e7a41fe679b9834874acdf] = 230000000000;
            balanceOf[0xbefe18acdfa765b27ad684b4c8a0b097884fc91a] = 266700000000;
            balanceOf[0x4c819ef91eebc5062204060812b09958a495cb9f] = 275000000000;
            balanceOf[0xc051e7debb67c2164c047956cb9617c01cff3fde] = 294800000000;
            balanceOf[0x1e7991f48f6316e5f8f10bf86dddb1745e682e34] = 300000000000;
            balanceOf[0x3875e5995e56b038254fe36cd98ce15a4b419c60] = 333400000000;
            balanceOf[0x87a370d1058116f14b600094386317bb8e0accf8] = 350000000000;
            balanceOf[0x4696ae46bdfad34ece52079c32be3d765b443691] = 400000000000;
            balanceOf[0x46a0cd7990e9d676e026be03818ac38c8850f145] = 500100000000;
            balanceOf[0x71be8c36fd63be8b10c0ff30ac934084eefcbc52] = 500100000000;
            balanceOf[0xb85dc96d30367ca32caf88c92e4ef065896df5b7] = 500100000000;
            balanceOf[0xd3265d59ab1e993691f4c07a71224191bed82530] = 500200000000;
            balanceOf[0x50fad3ec6f89608d80828f0e063d286f763d55b3] = 528800000000;
            balanceOf[0x7d05ddb4da85c234d258dd76675ffc85ea891cae] = 588300000000;
            balanceOf[0x1df7869bfc74ccb399d5662a29a7fa2ccce1c1cf] = 588300000000;
            balanceOf[0x58b37584e3b1e7e81d2088815aa6f2bc4a3fe301] = 667000000000;
            balanceOf[0xb038737abbfd748a2add5d5630d4912b474eb1d8] = 727300000000;
            balanceOf[0xf070fd60c05e1bf94138b6812f83f9602dc96e2f] = 750100000000;
            balanceOf[0xebffa1332eacff2bc6237c9aa52f2b53c855a37d] = 800100000000;
            balanceOf[0x3746f87c5d7bdc87be9f64dfe2a01ea29fdc9b72] = 800600000000;
            balanceOf[0xcb4a751335bbfd5e94797356d97bee8f1a9fd7e2] = 832200000000;
            balanceOf[0x2bb920535b080ee031a454f0054964dcf3a18850] = 891150000000;
            balanceOf[0xead097df95cfb9d802386e97d1c61cf8d4d03932] = 1000100000000;
            balanceOf[0x616047f120b4fb45b1c319eaa4b09369cfffb0e7] = 1176500000000;
            balanceOf[0x8078699fc27a3eca008ad91e753fe9a5935f8be0] = 1234700000000;
            balanceOf[0x8f0d62374e0ba428ebb87c198552fd0ca30af1ec] = 1250100000000;
            balanceOf[0x9cdeabd3d42045cb2e395e4a19d1023a1443222e] = 1333400000000;
            balanceOf[0x8ae05817e62c17d5b0ab1998b1bce2cfa53df32b] = 1333400000000;
            balanceOf[0x1c2113aa18708079c61b05bee2a27687dda95619] = 1450100000000;
            balanceOf[0x8c1c6314ba99fe606e9615aaf9cb60dfbc9b3455] = 1763100000000;
            balanceOf[0x7e9a52c87bdffa1c8757cef52563328d31628418] = 1873500000000;
            balanceOf[0xc79b3d00b2458d7c929d48492d280e24e6819069] = 1882347060000;
            balanceOf[0xc2758bac4b2c63717122dad1d6f8151e514d773f] = 2030700000000;
            balanceOf[0x9eb1f346eb3a5a93ee93f572e8d34ef638625c0d] = 2313400000000;
            balanceOf[0xc44945ba79ca836aa36714975d1d77e50c2616a5] = 2438500000000;
            balanceOf[0x240249ee0c7cfd3a84f49f99800971b1c0c95dd3] = 2500100000000;
            balanceOf[0x202b40adb3e8b6cbbe0d02f9008141c4dccbcb43] = 2500100000000;
            balanceOf[0xef7a4d5324fb66aed44c821e5a9b71fbba2874ea] = 2516800000000;
            balanceOf[0x4d8a3df24d07912cdfb2f5daa6ffb852f756ca31] = 2725100000000;
            balanceOf[0x18f5af12824dea73a95d0de135b0e71c311cb080] = 5100100000000;
            balanceOf[0x85890f06dbc1c2a91b46d065095577dec76eab4c] = 5732400000000;
            balanceOf[0x2d8ef50c17438bf8645983a0dc8b26fe11e8cc2c] = 6500100000000;
            balanceOf[0xae96d1582382648b35745f09a83ae91ee59354e6] = 6750100000000;
            balanceOf[0xdff80d82b9b6814630e3b967b8398064405ff3db] = 14666800000000;
            balanceOf[0x5586a462f12ca02836588c637f98eb5032afe1b9] = 21493552940000;
            balanceOf[0x5292c33821a65ef6227aba61f65e3326e5c256b6] = 30291700000000;
            balanceOf[0xfddedaaa4a86b0b68fd85d77e8399d0fe8264289] = 50000000000000;
            balanceOf[0x27fc7a7672fa3d53cc010287a28009cc61743436] = 72491400000000;
            balanceOf[0x59250a3ca05b4bad492b5805d3ff76b47f6a83b5] = 100000000000000;
            balanceOf[0xf04a7350a8631b2e4fe57d8b9659705e1ddda7db] = 101316400000000;
            balanceOf[0x77430a0f74a4659207fcf40e9bb1abc049592ddf] = 101863800000000;
            balanceOf[0x1d8ab06767d4f5964e3b3f3c395cf7a9f4f9ac8d] = 9438999600000000;
            }




    function balanceOf(address tokenHolder) constant returns(uint256) {

        return balanceOf[tokenHolder];
    }

    function totalSupply() constant returns(uint256) {

        return totalSupply;
    }


    function transfer(address _to, uint256 _value) returns(bool ok) {
        
        if (_to == 0x0) throw; // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[msg.sender] < _value) throw; // Check if the sender has enough
        bytes memory empty;
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(  _value ); // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add( _value ); // Add the same to the recipient
        
         if(isContract( _to )) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        
        Transfer(msg.sender, _to, _value); // Notify anyone listening that this transfer took place
        return true;
    }
    
     function transfer(address _to, uint256 _value, bytes _data ) returns(bool ok) {
        
        if (_to == 0x0) throw; // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[msg.sender] < _value) throw; // Check if the sender has enough
        bytes memory empty;
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(  _value ); // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add( _value ); // Add the same to the recipient
        
         if(isContract( _to )) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        
        Transfer(msg.sender, _to, _value, _data); // Notify anyone listening that this transfer took place
        return true;
    }
    
    
    
    function isContract( address _to ) internal returns ( bool ){
        
        
        uint codeLength = 0;
        
        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }
        
         if(codeLength>0) {
           
           return true;
           
        }
        
        return false;
        
    }
    
    
    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
    returns(bool success) {
        allowance[msg.sender][_spender] = _value;
        Approval( msg.sender ,_spender, _value);
        return true;
    }

    /* Approve and then communicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    returns(bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
        return allowance[_owner][_spender];
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns(bool success) {
        
        if (_from == 0x0) throw; // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[_from] < _value) throw; // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw; // Check allowance
        balanceOf[_from] = balanceOf[_from].sub( _value ); // Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add( _value ); // Add the same to the recipient
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub( _value ); 
        Transfer(_from, _to, _value);
        return true;
    }
  
    function burn(uint256 _value) returns(bool success) {
        
        if (balanceOf[msg.sender] < _value) throw; // Check if the sender has enough
        if ( (totalSupply - _value) <  ( initialSupply / 2 ) ) throw;
        balanceOf[msg.sender] = balanceOf[msg.sender].sub( _value ); // Subtract from the sender
        totalSupply = totalSupply.sub( _value ); // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

   function burnFrom(address _from, uint256 _value) returns(bool success) {
        
        if (_from == 0x0) throw; // Prevent transfer to 0x0 address. Use burn() instead
        if (balanceOf[_from] < _value) throw; 
        if (_value > allowance[_from][msg.sender]) throw; 
        balanceOf[_from] = balanceOf[_from].sub( _value ); 
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub( _value ); 
        totalSupply = totalSupply.sub( _value ); // Updates totalSupply
        Burn(_from, _value);
        return true;
    }


    
    
}