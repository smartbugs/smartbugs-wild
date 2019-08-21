pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
/**
* 
* AXPR ERC20 Tokens Hodling
* 
* Copyright: © All Rights Reserved  |  Axpire 2019
* 
* Author: Gustavo Basanta
* 
*/
contract OwnableContract {
     
    event onTransferOwnership(address newOwner);
 
    address superOwner;
      
    constructor() public { 
        superOwner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == superOwner);
        _;
    } 
      
    function viewSuperOwner() public view returns (address owner) {
        return superOwner;
    }
      
    function changeOwner(address newOwner) onlyOwner public {
        require(newOwner != superOwner);
        
        superOwner = newOwner;
        
        emit onTransferOwnership(superOwner);
    }
}

contract BlockableContract is OwnableContract {
    
    event onBlockHODLs(bool status);
 
    bool public blockedContract;
    
    constructor() public { 
        blockedContract = false;  
    }
    
    modifier contractActive() {
        require(!blockedContract);
        _;
    } 
    
    function doBlockContract() onlyOwner public {
        blockedContract = true;
        
        emit onBlockHODLs(blockedContract);
    }
    
    function unBlockContract() onlyOwner public {
        blockedContract = false;
        
        emit onBlockHODLs(blockedContract);
    }
}

contract ERC20tokensHodl is BlockableContract {
    
    /**
    * Events
    */
    event onStoreProfileHash(address indexed hodler, string profileHashed);
    event onHodlTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onClaimTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onReturnAll(uint256 returned);

    /**
    * State variables
    */
    address internal AXPRtoken;
    mapping(address => string) public profileHashed;
    uint256 public hodlingTime;
    uint256 public allTimeHighPrice;

    struct Safe {
        uint256 id;
        uint256 amount;
        uint256 endtime;
        address user;
        address tokenAddress;
        string tokenSymbol;
    }
    
    /**
    * @dev safes variables
    */
    mapping(address => uint256[]) public _userSafes;
    mapping(uint256 => Safe) private _safes;
    uint256 private _currentIndex;
    uint256 public _countSafes;
    mapping(address => uint256) public _totalSaved;
    
    /**
    * @dev owner variables
    */
    uint256 public comission; //0..30
    mapping(address => uint256) private _systemReserves;    
    address[] public _listedReserves;
    
    /**
    * constructor
    */
    constructor() public {
        
        AXPRtoken = 0xC39E626A04C5971D770e319760D7926502975e47;
        
        hodlingTime = 365 days;
        _currentIndex = 1;
        comission = 5;
    }
    
    /**
    * fallback function to receive donation in eth
    */
    function () public payable {
        require(msg.value > 0);
        
        _systemReserves[0x0] = add(_systemReserves[0x0], msg.value);
    }

    /**
    * store the profile's hash in the blockchain
    */
    function storeProfileHashed(string _profileHashed) public {
        profileHashed[msg.sender] = _profileHashed;        

        emit onStoreProfileHash(msg.sender, _profileHashed);
    }
    
    /**
    * add new hodl safe (ERC20 token)
    */
    function HodlTokens(address tokenAddress, uint256 amount) public contractActive {
        require(tokenAddress != 0x0);
        require(amount > 0);
          
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.transferFrom(msg.sender, address(this), amount));
        
        _userSafes[msg.sender].push(_currentIndex);
        _safes[_currentIndex] = Safe(_currentIndex, amount, now + hodlingTime, msg.sender, tokenAddress, token.symbol());
        
        _totalSaved[tokenAddress] = add(_totalSaved[tokenAddress], amount);
        
        _currentIndex++;
        _countSafes++;
        
        emit onHodlTokens(msg.sender, tokenAddress, token.symbol(), amount, now + hodlingTime);
    }

    /**
    * user, claim back a hodl safe
    */
    function ClaimTokens(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);
        
        RetireHodl(tokenAddress, id);
    }
    
    function RetireHodl(address tokenAddress, uint256 id) private {

        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.tokenAddress == tokenAddress);
        require(
                (tokenAddress == AXPRtoken && s.endtime < now ) ||
                    tokenAddress != AXPRtoken
                );

        uint256 eventAmount;
        address eventTokenAddress = s.tokenAddress;
        string memory eventTokenSymbol = s.tokenSymbol;
        
        if(s.endtime < now) // hodl complete
        {
            PayToken(s.user, s.tokenAddress, s.amount);
            
            eventAmount = s.amount;
        }
        else // hodl still in progress (penalty fee applies), not for AXPR tokens
        {
            uint256 realComission = mul(s.amount, comission) / 100;
            uint256 realAmount = sub(s.amount, realComission);
            
            PayToken(s.user, s.tokenAddress, realAmount);
                
            StoreComission(s.tokenAddress, realComission);
            
            eventAmount = realAmount;
        }
        
        DeleteSafe(s);
        _countSafes--;
        
        emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
    }    
    
    /**
    * store comission from unfinished hodl
    */
    function StoreComission(address tokenAddress, uint256 amount) private {
            
        _systemReserves[tokenAddress] = add(_systemReserves[tokenAddress], amount);
        
        bool isNew = true;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            if(_listedReserves[i] == tokenAddress) {
                isNew = false;
                break;
            }
        }         
        if(isNew) _listedReserves.push(tokenAddress); 
    }    
    
    /**
    * private pay token to address
    */
    function PayToken(address user, address tokenAddress, uint256 amount) private {
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
    }   
    
    /**
    * delete safe values in storage
    */
    function DeleteSafe(Safe s) private {
        
        _totalSaved[s.tokenAddress] = sub(_totalSaved[s.tokenAddress], s.amount);
        delete _safes[s.id];
        
        uint256[] storage vector = _userSafes[msg.sender];
        uint256 size = vector.length; 
        for(uint256 i = 0; i < size; i++) {
            if(vector[i] == s.id) {
                vector[i] = vector[size-1];
                vector.length--;
                break;
            }
        } 
    }

    /**
    * Get user's any token balance
    */
    function GetHodlTokensBalance(address tokenAddress) public view returns (uint256 balance) {
        require(tokenAddress != 0x0);
        
        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if(s.user == msg.sender && s.tokenAddress == tokenAddress)
                balance += s.amount;
        }
        return balance;
    }

    /**
    * Get how many safes has the user
    */
    function GetUserSafesLength(address hodler) public view returns (uint256 length) {
        return _userSafes[hodler].length;
    }
    
    /**
    * Get safes values
    */
    function GetSafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 time)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.endtime);
    }
    
    /**
    * Get tokens reserved for the owner as commission
    */
    function GetTokenFees(address tokenAddress) private view returns (uint256 amount) {
        return _systemReserves[tokenAddress];
    }    
    
    /**
    * Get contract's balance
    */
    function GetContractBalance() public view returns(uint256)
    {
        return address(this).balance;
    }    
    
    /**
    * ONLY OWNER
    * 
    * owner: retire hodl safe
    */
    function OwnerRetireHodl(address tokenAddress, uint256 id) public onlyOwner {
        require(tokenAddress != 0x0);
        require(id != 0);
        
        RetireHodl(tokenAddress, id);
    }
    
    /**
    * owner: change hodling time
    */
    function ChangeHodlingTime(uint256 newHodlingDays) onlyOwner public {
        require(newHodlingDays >= 60);
        
        hodlingTime = newHodlingDays * 1 days;
    }   
    
    /**
    * owner: change all time high price
    */
    function ChangeAllTimeHighPrice(uint256 newAllTimeHighPrice) onlyOwner public {
        require(newAllTimeHighPrice > allTimeHighPrice);
        
        allTimeHighPrice = newAllTimeHighPrice;
    }              

    /**
    * owner: change comission value
    */
    function ChangeComission(uint256 newComission) onlyOwner public {
        require(newComission <= 30);
        
        comission = newComission;
    }
    
    /**
    * owner: withdraw token fees by address
    */
    function WithdrawTokenFees(address tokenAddress) onlyOwner public {
        require(_systemReserves[tokenAddress] > 0);
        
        uint256 amount = _systemReserves[tokenAddress];
        _systemReserves[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }

    /**
    * owner: withdraw all eth and all tokens fees
    */
    function WithdrawAllFees() onlyOwner public {
        
        // ether
        uint256 x = _systemReserves[0x0];
        if(x > 0 && x <= address(this).balance) {
            _systemReserves[0x0] = 0;
            msg.sender.transfer(_systemReserves[0x0]);
        }
        
        // tokens
        address ta;
        ERC20Interface token;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            ta = _listedReserves[i];
            if(_systemReserves[ta] > 0)
            { 
                x = _systemReserves[ta];
                _systemReserves[ta] = 0;
                
                token = ERC20Interface(ta);
                token.transfer(msg.sender, x);
            }
        }
        _listedReserves.length = 0; 
    }
    
    /**
    * owner: withdraw ether received through fallback function
    */
    function WithdrawEth(uint256 amount) onlyOwner public {
        require(amount > 0); 
        require(address(this).balance >= amount); 
        
        msg.sender.transfer(amount);
    }

    /**
    * owner: returns all tokens addresses with fees
    */    
    function GetTokensAddressesWithFees() 
        onlyOwner public view 
        returns (address[], string[], uint256[])
    {
        uint256 length = _listedReserves.length;
        
        address[] memory tokenAddress = new address[](length);
        string[] memory tokenSymbol = new string[](length);
        uint256[] memory tokenFees = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
    
            tokenAddress[i] = _listedReserves[i];
            
            ERC20Interface token = ERC20Interface(tokenAddress[i]);
            
            tokenSymbol[i] = token.symbol();
            tokenFees[i] = GetTokenFees(tokenAddress[i]);
        }
        
        return (tokenAddress, tokenSymbol, tokenFees);
    }

    /**
    * owner: return all tokens to their respective addresses
    */
    function ReturnAllTokens(bool onlyAXPR) onlyOwner public
    {
        uint256 returned;

        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if (s.id != 0) {
                if (
                    (onlyAXPR && s.tokenAddress == AXPRtoken) ||
                    !onlyAXPR
                    )
                {
                    PayToken(s.user, s.tokenAddress, s.amount);
                    DeleteSafe(s);
                    
                    _countSafes--;
                    returned++;
                }
            }
        }

        emit onReturnAll(returned);
    }    


    /**
    * SAFE MATH FUNCTIONS
    * 
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
    
}

contract ERC20Interface {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    // total amount of tokens
    uint256 public totalSupply;
    
    //How many decimals to show.
    uint256 public decimals;
    
    // token symbol
    function symbol() public view returns (string);
    
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}