pragma solidity ^0.4.16;

    contract owned {
        address public owner;

        function owned() public {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) onlyOwner public {
            owner = newOwner;
        }
    }

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract MyTestToken is owned {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    bool private b_enableTransfer = true;
    uint256 public creationDate;
    string public name;
    string public symbol;
    uint8 public decimals = 18;    
    uint256 public totalSupply;
    uint8 public tipoCongelamento = 0;
        // 0 = unfreeze; 1 = frozen by 10 minutes; 2 = frozen by 30 minutes; 3 = frozen by 1 hour
        // 4 = frozen by 2 hours; 5 = frozen by 1 day; 6 = frozen by 2 days

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyTestToken (
                           uint256 initialSupply,
                           string tokenName,
                           string tokenSymbol
        ) owned() public 
    {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
        creationDate = now;
        name = tokenName;
        symbol = tokenSymbol;
    }

    /* Send coins */
    function transfer2(address _to, uint256 _value) public
    {
        require(b_enableTransfer); 
        
        
        _transfer(_to, _value);
    }

    function transfer(address _to, uint256 _value) public
    {
        // testa periodos de congelamento
        // 0 = unfreeze; 1 = frozen by 10 minutes; 2 = frozen by 30 minutes; 3 = frozen by 1 hour
        // 4 = frozen by 2 hours; 5 = frozen by 1 day; 6 = frozen by 2 days
        if(tipoCongelamento == 0) // unfrozen
        {
            _transfer(_to, _value);
        }
        if(tipoCongelamento == 1) // 10 minutes
        {
            if(now >= creationDate + 10 * 1 minutes) _transfer(_to, _value);
        }
        if(tipoCongelamento == 2) // 30 minutes
        {
            if(now >= creationDate + 30 * 1 minutes) _transfer(_to, _value);
        }        
        if(tipoCongelamento == 3) // 1 hour
        {
            if(now >= creationDate + 1 * 1 hours) _transfer(_to, _value);
        }        
        if(tipoCongelamento == 4) // 2 hours
        {
            if(now >= creationDate + 2 * 1 hours) _transfer(_to, _value);
        }        
        if(tipoCongelamento == 5) // 1 day
        {
            if(now >= creationDate + 1 * 1 days) _transfer(_to, _value);
        }        
        if(tipoCongelamento == 6) // 2 days
        {
            if(now >= creationDate + 2 * 1 days) _transfer(_to, _value);
        }        
    }

    function freezingStatus() view public returns (string)
    {
        // 0 = unfreeze; 1 = frozen by 10 minutes; 2 = frozen by 30 minutes; 3 = frozen by 1 hour
        // 4 = frozen by 2 hours; 5 = frozen by 1 day; 6 = frozen by 2 days
        
        if(tipoCongelamento == 0) return ( "Tokens free to transfer!");
        if(tipoCongelamento == 1) return ( "Tokens frozen by 10 minutes.");
        if(tipoCongelamento == 2) return ( "Tokens frozen by 30 minutes.");
        if(tipoCongelamento == 3) return ( "Tokens frozen by 1 hour.");
        if(tipoCongelamento == 4) return ( "Tokens frozen by 2 hours.");        
        if(tipoCongelamento == 5) return ( "Tokens frozen by 1 day.");        
        if(tipoCongelamento == 6) return ( "Tokens frozen by 2 days.");                

    }

    function setFreezingStatus(uint8 _mode) onlyOwner public
    {
        require(_mode>=0 && _mode <=6);
        tipoCongelamento = _mode;
    }

    function _transfer(address _to, uint256 _value) private 
    {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
    }
    
    function enableTransfer(bool _enableTransfer) onlyOwner public
    {
        b_enableTransfer = _enableTransfer;
    }
}