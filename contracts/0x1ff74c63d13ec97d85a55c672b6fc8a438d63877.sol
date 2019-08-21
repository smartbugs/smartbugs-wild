pragma solidity ^0.4.6;

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

contract Owned {

    // The address of the account that is the current owner
    address public owner;

    // Contract which manage issuing of new tokens (airdrop and referral tokens) 
    address public issuer;

    // The publiser is the inital owner
    function Owned() {
        owner = msg.sender;
    }

    /**
     * Restricted access to the current owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    /**
     * Restricted access to the issuer and owner
     */
    modifier onlyIssuer() {
        if (msg.sender != owner && msg.sender != issuer) throw;
        _;
    }

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner
     */
    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
contract Token {
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Mail token
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 with the addition
 * of ownership, a lock and issuing.
 *
 */
contract Mail is Owned, Token {

    using SafeMath for uint256;

    // Ethereum token standaard
    string public standard = "Token 0.2";

    // Full name
    string public name = "Ethereum Mail";

    // Symbol
    string public symbol = "MAIL";

    // No decimal points
    uint8 public decimals = 0;
    
    // Token distribution
    uint256 public freeToUseTokens = 10 * 10 ** 6; // 10 million tokens are free to use

    // List of available tokens for attachment
    mapping (bytes32 => Token) public tokens;
    
    // No decimal points
    uint256 public maxTotalSupply = 10 ** 9; // 1 billion

    // Token starts if the locked state restricting transfers
    bool public locked;

    mapping (address => uint256) public balances;
    mapping (address => uint256) public usableBalances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    uint256 public currentMessageNumber;
    
    struct Message {
        bytes32 content;
        uint256 weight;
        uint256 validUntil;
        uint256 time;
        bytes32 attachmentSymbol;
        uint256 attachmentValue;
        address from;
        address[] to;
        address[] read;
    }
    
    mapping (uint256 => Message) messages;
    
    struct UnreadMessage {
        uint256 id;
        bool isOpened;
        bool free;
        address from;
        uint256 time;
        uint256 weight;
    }
    
    mapping (address => UnreadMessage[]) public unreadMessages;
    mapping (address => uint256) public unreadMessageCount;
    uint[] indexesUnread;
    uint[] indexesRead;
    mapping (address => uint256) public lastReceivedMessage;

    /**
     * Set up issuer
     *
     * @param _issuer The address of the account that will become the new issuer
     */
    function setIssuer(address _issuer) onlyOwner {
        issuer = _issuer;
    }
    
    /**
     * Unlocks the token irreversibly so that the transfering of value is enabled
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() onlyOwner returns (bool success)  {
        locked = false;
        return true;
    }
    
    /**
     * Everyone can call this function to invalidate mail if its validation time is already in past  
     *
     * @param _number Number od unread messages
     */
    function invalidateMail(uint256 _number) {
        if (messages[_number].validUntil >= now) {
            throw;
        }
        
        if (messages[_number].attachmentSymbol.length != 0x0 && messages[_number].attachmentValue > 0) {
            Token token = tokens[messages[_number].attachmentSymbol];
            token.transfer(messages[_number].from, messages[_number].attachmentValue.mul(messages[_number].to.length.sub(messages[_number].read.length)).div(messages[_number].to.length));
        }
        
        uint256 i = 0;
        while (i < messages[_number].to.length) {
            address recipient = messages[_number].to[i];

            for (uint a = 0; a < unreadMessages[recipient].length; ++a) {
                if (unreadMessages[recipient][a].id == _number) {

                    if (!unreadMessages[recipient][a].isOpened) {
                        unreadMessages[recipient][a].weight = 0;
                        unreadMessages[recipient][a].time = 0;

                        uint256 value = messages[_number].weight.div(messages[_number].to.length);

                        unreadMessageCount[recipient]--;
                        balances[recipient] = balances[recipient].sub(value);

                        if (!unreadMessages[recipient][a].free) {
                            usableBalances[messages[_number].from] = usableBalances[messages[_number].from].add(value);
                            balances[messages[_number].from] = balances[messages[_number].from].add(value);
                        }
                    }

                    break;
                }
            }
            
            i++;
        }
    }
    
    /**
     * Returns number of unread messages for specific user
     *
     * @param _userAddress Address of user
     * @return Number od unread messages
     */
    function getUnreadMessageCount(address _userAddress) constant returns (uint256 count)  {
        uint256 unreadCount;
        for (uint i = 0; i < unreadMessageCount[_userAddress]; ++i) {
            if (unreadMessages[_userAddress][i].isOpened == false) {
                unreadCount++;    
            }
        }
        
        return unreadCount;
    }
    

    /**
     * Returns unread messages for current user
     * 
     * @param _userAddress Address of user
     * @return Unread messages as array of message numbers
     */
    function getUnreadMessages(address _userAddress) constant returns (uint[] mmessages)  {
        for (uint i = 0; i < unreadMessageCount[_userAddress]; ++i) {
            if (unreadMessages[_userAddress][i].isOpened == false) {
                indexesUnread.push(unreadMessages[_userAddress][i].id);
            }
        }
        
        return indexesUnread;
    }


    function getUnreadMessagesArrayContent(uint256 _number) public constant returns(uint256, bool, address, uint256, uint256) {
        for (uint a = 0; a < unreadMessageCount[msg.sender]; ++a) {
            if (unreadMessages[msg.sender][a].id == _number) {
                return (unreadMessages[msg.sender][a].id,unreadMessages[msg.sender][a].isOpened,unreadMessages[msg.sender][a].from, unreadMessages[msg.sender][a].time,unreadMessages[msg.sender][a].weight);
            }
        }
    }

    /**
     * Returns read messages for current user
     * 
     * @param _userAddress Address of user
     * @return Read messages as array of message numbers
     */
    function getReadMessages(address _userAddress) constant returns (uint[] mmessages)  {        
        for (uint i = 0; i < unreadMessageCount[_userAddress]; ++i) {
            if (unreadMessages[_userAddress][i].isOpened == true) {
                indexesRead.push(unreadMessages[_userAddress][i].id);
            }
        }
        
        return indexesRead;
    }
    
    /**
     * Add token which will can be used as attachment
     * 
     * @param _tokenAddress Address of token contract
     * @param _symbol Symbol of token
     * @return If action was successful
     */
    function addToken(address _tokenAddress, bytes32 _symbol) onlyOwner returns (bool success)  {
        Token token = Token(_tokenAddress);
        tokens[_symbol] = token;
        
        return true;
    }

    /**
     * Locks the token irreversibly so that the transfering of value is not enabled
     *
     * @return Whether the locking was successful or not
     */
    function lock() onlyOwner returns (bool success)  {
        locked = true;
        return true;
    }
    
    /**
     * Restricted access to the current owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }
    
    /**
     * Get balance of `_owner`
     *
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    /**
     * Prevents accidental sending of ether
     */
    function () {
        throw;
    }

    /**
     * Send `_value` token to `_to` from `msg.sender`
     *
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _value) returns (bool success) {

        // Unable to transfer while still locked
        if (locked) {
            throw;
        }

        // Check if the sender has enough tokens
        if (balances[msg.sender] < _value || usableBalances[msg.sender] < _value) {
            throw;
        }

        // Check for overflows
        if (balances[_to] + _value < balances[_to])  {
            throw;
        }

        // Transfer tokens
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        
        usableBalances[msg.sender] -= _value;
        usableBalances[_to] += _value;

        // Notify listners
        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

         // Unable to transfer while still locked
        if (locked) {
            throw;
        }

        // Check if the sender has enough
        if (balances[_from] < _value || usableBalances[_from] < _value) {
            throw;
        }

        // Check for overflows
        if (balances[_to] + _value < balances[_to]) {
            throw;
        }

        // Check allowance
        if (_value > allowed[_from][msg.sender]) {
            throw;
        }

        // Transfer tokens
        balances[_to] += _value;
        balances[_from] -= _value;
        
        usableBalances[_from] -= _value;
        usableBalances[_to] += _value;

        // Update allowance
        allowed[_from][msg.sender] -= _value;

        // Notify listners
        Transfer(_from, _to, _value);
        
        return true;
    }

    /**
     * `msg.sender` approves `_spender` to spend `_value` tokens
     *
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) returns (bool success) {

        // Unable to approve while still locked
        if (locked) {
            throw;
        }

        // Update allowance
        allowed[msg.sender][_spender] = _value;

        // Notify listners
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     *
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /**
     * Sends an mail to the specific list of recipients with amount of MAIL tokens to spend on them, hash message, time unti when is 
     * message available and tokens
     *
     * @param _to List of recipients
     * @param _weight Tokens to be spent on messages
     * @param _hashedMessage Hashed content of mail
     * @param _validUntil Mail is available until this specific time when will be returned to sender
     * @param _attachmentToken Name of attached token
     * @param _attachmentAmount Amount of attached token
     */
    function sendMail(address[] _to, uint256 _weight, bytes32 _hashedMessage, uint256 _validUntil, bytes32 _attachmentToken, uint256 _attachmentAmount) {
        bool useFreeTokens = false;
        if (_weight == 0 && freeToUseTokens > 0) {
            _weight = _to.length;
            useFreeTokens = true;
        }

        if ((!useFreeTokens && usableBalances[msg.sender] < _weight) || _weight < _to.length) {
            throw;
        }
        
        messages[currentMessageNumber].content = _hashedMessage;
        messages[currentMessageNumber].validUntil = _validUntil;
        messages[currentMessageNumber].time = now;
        messages[currentMessageNumber].from = msg.sender;
        messages[currentMessageNumber].to = _to;
        
        if (_attachmentToken != "") {
            Token token = tokens[_attachmentToken];
            
            if (!token.transferFrom(msg.sender, address(this), _attachmentAmount)) {
                throw;
            }
            
            messages[currentMessageNumber].attachmentSymbol = _attachmentToken;
            messages[currentMessageNumber].attachmentValue = _attachmentAmount;
        }
        
        UnreadMessage memory currentUnreadMessage;
        currentUnreadMessage.id = currentMessageNumber;
        currentUnreadMessage.isOpened = false;
        currentUnreadMessage.from = msg.sender;
        currentUnreadMessage.time = now;
        currentUnreadMessage.weight = _weight;
        currentUnreadMessage.free = useFreeTokens;

        uint256 i = 0;
        uint256 duplicateWeight = 0;
        
        while (i < _to.length) {
            if (lastReceivedMessage[_to[i]] == currentMessageNumber) {
                i++;
                duplicateWeight = duplicateWeight.add(_weight.div(_to.length));
                continue;
            }

            lastReceivedMessage[_to[i]] = currentMessageNumber;
        
            unreadMessages[_to[i]].push(currentUnreadMessage);
        
            unreadMessageCount[_to[i]]++;
            balances[_to[i]] = balances[_to[i]].add(_weight.div(_to.length));
            i++;
        }
        
        if (useFreeTokens) {
            freeToUseTokens = freeToUseTokens.sub(_weight.sub(duplicateWeight));
        } else {
            usableBalances[msg.sender] = usableBalances[msg.sender].sub(_weight.sub(duplicateWeight));
            balances[msg.sender] = balances[msg.sender].sub(_weight.sub(duplicateWeight));
        }  

        messages[currentMessageNumber].weight = _weight.sub(duplicateWeight);  

        currentMessageNumber++;
    }
    
    function getUnreadMessage(uint256 _number) constant returns (UnreadMessage unread) {
        for (uint a = 0; a < unreadMessages[msg.sender].length; ++a) {
            if (unreadMessages[msg.sender][a].id == _number) {
                return unreadMessages[msg.sender][a];
            }
        }
    }
    
    /**
     * Open specific mail for current user who receives MAIL tokens and tokens attached to mail 
     *
     * @param _number Number of message recipient is trying to open
     * @return Success of opeining mail
     */
    function openMail(uint256 _number) returns (bool success) {
        UnreadMessage memory currentUnreadMessage = getUnreadMessage(_number);

        // throw error if it is already opened or invalidate 
        if (currentUnreadMessage.isOpened || currentUnreadMessage.weight == 0) {
            throw;
        }
        
        if (messages[_number].attachmentSymbol != 0x0 && messages[_number].attachmentValue > 0) {
            Token token = tokens[messages[_number].attachmentSymbol];
            token.transfer(msg.sender, messages[_number].attachmentValue.div(messages[_number].to.length));
        }
        
        for (uint a = 0; a < unreadMessages[msg.sender].length; ++a) {
            if (unreadMessages[msg.sender][a].id == _number) {
                unreadMessages[msg.sender][a].isOpened = true;
            }
        }
        
        messages[_number].read.push(msg.sender);
        
        usableBalances[msg.sender] = usableBalances[msg.sender].add(messages[_number].weight.div(messages[_number].to.length));
        
        return true;
    }
    
    /**
     * Return opened mail with specific number 
     *
     * @param _number Number of message 
     * @return Mail content
     */
    function getMail(uint256 _number) constant returns (bytes32 message) {
        UnreadMessage memory currentUnreadMessage = getUnreadMessage(_number);
        if (!currentUnreadMessage.isOpened || currentUnreadMessage.weight == 0) {
            throw;
        }
        
        return messages[_number].content;
    }
    
    /**
     * Issuing MAIL tokens  
     *
     * @param _recipient Recipient of tokens
     * @param _value Amount of tokens
     * @return Success of issuing
     */
    function issue(address _recipient, uint256 _value) onlyIssuer returns (bool success) {

        if (totalSupply.add(_value) > maxTotalSupply) {
            return;
        }
        
        // Create tokens
        balances[_recipient] = balances[_recipient].add(_value);
        usableBalances[_recipient] = usableBalances[_recipient].add(_value);
        totalSupply = totalSupply.add(_value);

        return true;
    }
    
    function Mail() {
        balances[msg.sender] = 0;
        totalSupply = 0;
        locked = false;
    }
}