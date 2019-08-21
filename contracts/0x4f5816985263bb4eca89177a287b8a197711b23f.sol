/**+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            abcLotto: a Block Chain Lottery

                            Don't trust anyone but the CODE!
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
 /*
 * This product is protected under license.  Any unauthorized copy, modification, or use without 
 * express written consent from the creators is prohibited.
 */
 
/**+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                           this inviter book can be used by your applications too.
                           
                           have you heard about The 2009 DARPA Network Challenge?
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
pragma solidity ^0.4.20;

/**
* @title abc address resolver. 
 */ 
contract abcResolverI{
    function getWalletAddress() public view returns (address);
    function getAddress() public view returns (address);
}

/**
* @title inviters book. 
 */ 
contract inviterBook{
    using SafeMath for *;
    //storage varible
    address public owner;
    abcResolverI public resolver;
    address public wallet;
    address public lotto;
    
    mapping (address=>bytes32) _alias;
    mapping (bytes32=>address) _addressbook;
    mapping (address=>address) _inviter;
    mapping (address=>uint) _earnings;
    mapping (address=>bool) _isRoot;
    uint public rootNumber = 0;

    //constant
    uint constant REGISTRATION_FEE = 10000000000000000;    // registration fee is 0.01 ether.
    
    //modifier

    //check contract interface, are they upgrated?
    modifier abcInterface {
        if((address(resolver)==0)||(getCodeSize(address(resolver))==0)){
            if(abc_initNetwork()){
                wallet = resolver.getWalletAddress();
                lotto = resolver.getAddress();
            }
        }
        else{
            if(wallet != resolver.getWalletAddress())
                wallet = resolver.getWalletAddress();

            if(lotto != resolver.getAddress())
                lotto = resolver.getAddress();
        }    
        
        _;        
    }    

    //modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        
        _;
    }

    modifier onlyAuthorized{
        require(
            msg.sender == lotto
        );
        
        _;
    }
    //events
    event OnRegisterAlias(address user, bytes32 alias);
    event OnAddRoot(address root);
    event OnSetInviter(address user, address inviter);
    event OnWithdraw(address user, uint earning);
    event OnPay(address user, uint value);
    
    /**
    * @dev constructor
    */
    constructor() public{
        owner = msg.sender;
    }

    //++++++++++++++++++++++++++++++++    root inviter functions   +++++++++++++++++++++++++++++++++++++++++++++++++
    //      - root inviter can't be delete.
    /**
    * @dev add a root inviter.
    */
    function addRoot(address addr) onlyOwner public{
        require(_inviter[addr] == address(0x0) && _isRoot[addr] == false); 
        _isRoot[addr] = true;
        rootNumber++;
        emit OnAddRoot(addr);
    }

    /**
    * @dev if address is a root inviter? with address param.
    */
    function isRoot(address addr) 
        public
        view 
        returns(bool)
    {
        return _isRoot[addr];
    }

    /**
    * @dev if i am a root inviter? no param.
    */
    function isRoot() 
        public
        view 
        returns(bool)
    {
        return _isRoot[msg.sender];
    }

    /**
    * @dev change owner address.
    */ 
     function setOwner(address newOwner) 
        onlyOwner 
        public
    {
        require(newOwner != address(0x0));
        owner = newOwner;
    }    

    //++++++++++++++++++++++++++++++++    inviter functions   +++++++++++++++++++++++++++++++++++++++++++++++++++++
    //   - inviter can be set just once.
    //   - can't set yourself as inviter.
    /**
    * @dev does anyone has inviter? with address param.
    */ 
    function hasInviter(address addr) 
        public 
        view
        returns(bool)
    {
        if(_inviter[addr] != address(0x0))
            return true;
        else
            return false;
    } 
    /**
    * @dev does i has inviter? no param.
    */     
    function hasInviter() 
        public 
        view
        returns(bool)
    {
        if(_inviter[msg.sender] != address(0x0))
            return true;
        else
            return false;
    } 

    /**
    * @dev set self's inviter by name.
    */      
    function setInviter(string inviter) public{
         //root player can't set inviter;
        require(_isRoot[msg.sender] == false);

        //inviter can be set just once.
        require(_inviter[msg.sender] == address(0x0)); 

        //inviter must existed.
        bytes32 _name = stringToBytes32(inviter);        
        require(_addressbook[_name] != address(0x0));
        
        //can't set yourself as inviter.
        require(_addressbook[_name] != msg.sender);       

        //inviter must be valid. 
        require(isValidInviter(_addressbook[_name]));

        _inviter[msg.sender] = _addressbook[_name];
        emit OnSetInviter(msg.sender, _addressbook[_name]);
    }
    /**
    * @dev set another's inviter by name. only by authorized contract.
    */   
    function setInviter(address addr, string inviter) 
        abcInterface
        public
        onlyAuthorized
    {
        //root player can't set inviter;
        require(_isRoot[addr] == false);

        //inviter can be set just once.
        require(_inviter[addr] == address(0x0)); 

        //inviter must existed.
        bytes32 _name = stringToBytes32(inviter);        
        require(_addressbook[_name] != address(0x0));

        //can't set yourself as inviter.
        require(_addressbook[_name] != addr);       

        //inviter must be valid. 
        require(isValidInviter(_addressbook[_name]));

        _inviter[addr] = _addressbook[_name];
        emit OnSetInviter(addr, _addressbook[_name]);
    }
 
    /**
    * @dev set self's inviter by address.   
    */ 
    function setInviterXAddr(address inviter) public{
        //root player can't set inviter;
        require(_isRoot[msg.sender] == false);

        //inviter can be set just once.
        require(_inviter[msg.sender] == address(0x0)); 

        //inviter must existed.        
        require(inviter != address(0x0));

        //can't set yourself as inviter.
        require(inviter != msg.sender);       

        //inviter must register his alias;
        require(_alias[inviter] != bytes32(0x0));

        //inviter must be valid. 
        require(isValidInviter(inviter));

        _inviter[msg.sender] = inviter;
        emit OnSetInviter(msg.sender, inviter);
    }
 
    /**
    * @dev  set another's inviter by address. only authorized address can do this.
    */ 
    function setInviterXAddr(address addr, address inviter) 
        abcInterface
        public
        onlyAuthorized
    {
         //root player can't set inviter;
        require(_isRoot[addr] == false);

        //inviter can be set just once.
        require(_inviter[addr] == address(0x0)); 

        //inviter must existed.        
        require(inviter != address(0x0));

        //can't set yourself as inviter.
        require(inviter != addr);       

        //inviter must register his alias;
        require(_alias[inviter] != bytes32(0x0));

        //inviter must be valid. 
        require(isValidInviter(inviter));

         _inviter[addr] = inviter;
         emit OnSetInviter(addr, inviter);
    }
    
     /**
     * @dev get inviter's alias.
     */ 
     function getInviter() 
        public 
        view
        returns(string)
     {
         if(!hasInviter(msg.sender)) return "";
        
         return bytes32ToString(_alias[_inviter[msg.sender]]);
     }  
 
      /**
     * @dev get inviter's address.
     */ 
     function getInviterAddr() 
        public 
        view
        returns(address)
     {
         return _inviter[msg.sender];
     } 

     /**
    * @dev check inviter's addr is valid.
     */
     function isValidInviter(address inviter)
        internal
        view
        returns(bool)
    {
        address addr = inviter;
        while(_inviter[addr] != address(0x0)){
            addr = _inviter[addr];
        } 
        
        if(_isRoot[addr] == true)
            return true;
        else
            return false;
    }
    //++++++++++++++++++++++++++++++++    earning functions   +++++++++++++++++++++++++++++++++++++++++++++++++++++
      /**
     * @dev get self's referral earning.
     */ 
     function getEarning()
        public 
        view 
        returns (uint)
     {
         return _earnings[msg.sender];
     }

     /**
     * @dev withdraw self's referral earning.
     */ 
     function withdraw() public {
         uint earning = _earnings[msg.sender];
         if(earning>0){
             _earnings[msg.sender] = 0;
             msg.sender.transfer(earning);
             emit OnWithdraw(msg.sender, earning);             
         }
     }

     /**
     * @dev fallback funtion, calculate inviter's earning. no param.
     *      - direct inviter get 1/2 of the total value.
     *      - direct inviter's inviter get 1/2 of the direct inviter, and so on.
     *      - remaining balance transfered to a wallet.
     */
    function() 
        abcInterface
        public 
        payable 
    {
        address addr = msg.sender;
        uint balance = msg.value;
        uint earning = 0;
        
        while(_inviter[addr] != address(0x0)){
            addr = _inviter[addr];
            earning = balance.div(2);
            balance = balance.sub(earning);
            _earnings[addr] = _earnings[addr].add(earning);
        }
        
        wallet.transfer(balance);
        emit OnPay(msg.sender, msg.value);
    }
     
     /**
     * @dev pay funtion, calculate inviter's earning. 
     *      - direct inviter get 1/2 of the total value.
     *      - direct inviter's inviter get 1/2 of the direct inviter, and so on.
     *      - remaining balance transfered to a wallet.
     */
    function pay(address addr) 
        abcInterface
        public 
        payable 
        onlyAuthorized
    {
        address _addr = addr;
        uint balance = msg.value;
        uint earning = 0;
        
        while(_inviter[_addr] != address(0x0)){
            _addr = _inviter[_addr];
            earning = balance.div(2);
            balance = balance.sub(earning);
            _earnings[_addr] = _earnings[_addr].add(earning);
        }
        
        wallet.transfer(balance);
        emit OnPay(addr, msg.value);
    }
    //++++++++++++++++++++++++++++++++    alias functions  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     /**
     * @dev register a alias. you can register alias several times.
     */    
     function registerAlias(string alias) 
        abcInterface 
        public 
        payable
     {
         require(msg.value >= REGISTRATION_FEE);
         
         //alias must be unique.
         bytes32 _name = nameFilter(alias);
         require(_addressbook[_name] == address(0x0));

         //player hasn't inviter or no root can't register alias.
         require(hasInviter() || _isRoot[msg.sender] == true);

         if(_alias[msg.sender] != bytes32(0x0)){
             //remove old alias mapping key.
            _addressbook[_alias[msg.sender]] = address(0x0);
         }
         _alias[msg.sender] = _name;
         _addressbook[_name] = msg.sender;

         wallet.transfer(REGISTRATION_FEE);
         //refund extra value.
         if(msg.value > REGISTRATION_FEE){
             msg.sender.transfer( msg.value.sub( REGISTRATION_FEE ));
         }
         emit OnRegisterAlias(msg.sender,_name);
     }    
     
     /**
     * @dev does alias exist?
     */  
     function aliasExist(string alias) 
        public 
        view 
        returns(bool) 
    {
        bytes32 _name = stringToBytes32(alias);
        if(_addressbook[_name] == address(0x0))
            return false;
        else
            return true;
     }
     
     /**
     * @dev get self's alias.
     */ 
    function getAlias() 
        public 
        view 
        returns(string)
    {
         return bytes32ToString(_alias[msg.sender]);
    }

    //++++++++++++++++++++++++++++++++     auxiliary functions  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     /**
     * @dev name string filters
     * -length limited to 32 characters.
     * -restricts characters to A-Z, a-z, 0-9.
     * -cannot be only numbers.
     * -cannot start with 0x.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0);
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78);
            require(_temp[1] != 0x58);
        }
        
        // create a bool to track if we have a non number character
        bool _hasNonNumber;
        
        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            require
            (
                // require character is A-Z
                (_temp[i] > 0x40 && _temp[i] < 0x5b) || 
                // OR lowercase a-z
                (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                // or 0-9
                (_temp[i] > 0x2f && _temp[i] < 0x3a)
             );
                
            // see if we have a character other than a number
            if (_hasNonNumber == false && _temp[i] > 0x3a)
                _hasNonNumber = true;    
        
        }
        
        require(_hasNonNumber == true);
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }    
 
    /*
    * @dev transfer string to bytes32
    */
    function stringToBytes32(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        //limited to 32 characters
        if (_length > 32 || _length == 0) return "";
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }   

    /*
    * @dev transfer bytes32 to string
    */    
     function bytes32ToString(bytes32 x) 
        internal
        pure 
        returns (string) 
    {
         bytes memory bytesString = new bytes(32);
         uint charCount = 0;
         for (uint j = 0; j < 32; j++) {
             byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
             if (char != 0) {
                 bytesString[charCount] = char;
                 charCount++;
             }
         }
         bytes memory bytesStringTrimmed = new bytes(charCount);
         for (j = 0; j < charCount; j++) {
             bytesStringTrimmed[j] = bytesString[j];
         }
         return string(bytesStringTrimmed);
     }
     
    /**
    * @dev init address resolver.
    */ 
    function abc_initNetwork() 
        internal 
        returns(bool) 
    { 
         //mainnet
         if (getCodeSize(0xde4413799c73a356d83ace2dc9055957c0a5c335)>0){     
            resolver = abcResolverI(0xde4413799c73a356d83ace2dc9055957c0a5c335);
            return true;
         }
         
         //rinkeby
         if (getCodeSize(0xcaddb7e777f7a1d4d60914cdae52aca561d539e8)>0){     
            resolver = abcResolverI(0xcaddb7e777f7a1d4d60914cdae52aca561d539e8);
            return true;
         }         
         //others ...

         return false;
    }      
    /**
    * @dev get code size of appointed address.
     */
     function getCodeSize(address _addr) 
        internal 
        view 
        returns(uint _size) 
    {
         assembly {
             _size := extcodesize(_addr)
         }
    }
}

/**
 * @title SafeMath : it's from openzeppelin.
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) public pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) public pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) public pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) public pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}