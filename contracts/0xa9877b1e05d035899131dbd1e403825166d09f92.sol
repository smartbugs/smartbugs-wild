pragma solidity ^0.4.18;

// https://github.com/ethereum/EIPs/issues/20

contract ERC20 {
    function totalSupply() public constant returns (uint256 supply);
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    // These generate a public event on the blockchain that will notify clients
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract Owned {
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract MNTToken is ERC20, Owned {
    // Public variables of the token
    string public name = "Media Network Token";
    string public symbol = "MNT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 0; // 125 * 10**6 * 10**18;
    uint256 public maxSupply = 125 * 10**6 * 10**18;
    address public cjTeamWallet = 0x9887c2da3aC5449F3d62d4A04372a4724c21f54C;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;

    // This creates an array with all allowances
    mapping (address => mapping (address => uint256)) public allowance;


    /**
     * Constructor function
     *
     * Gives ownership of all initial tokens to the Coin Joker Team. Sets ownership of contract
     */
    function MNTToken(
        address cjTeam
    ) public {
        //balanceOf[msg.sender] = totalSupply;              // Give the creator all initial tokens
        totalEthRaised = 0;
        /*if (cjTeam != 0) {
            owner = cjTeam;
        }*/
        cjTeamWallet = cjTeam;
    }
	
    function changeCJTeamWallet(address newWallet) public onlyOwner {
        cjTeamWallet = newWallet;
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address
        require(balanceOf[_from] >= _value);                // Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) public returns (bool success) 
    {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(
        address _spender, 
        uint256 _value
    ) public returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Get current balance of account _owner
     *
     * @param _owner The owner of the account
     */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOf[_owner];
    }

    /**
     * Get allowance from _owner to _spender
     *
     * @param _owner The address that authorizes to spend
     * @param _spender The address authorized to spend
     */
    function allowance(
        address _owner, 
        address _spender
    ) public constant returns (uint256 remaining)
    {
        return allowance[_owner][_spender];
    }

    /**
     * Get total supply of all tokens
     */
    function totalSupply() public constant returns (uint256 supply) {
        return totalSupply;
    }

    // --------------------------------
    // Token sale variables and methods
    // --------------------------------

    bool saleHasStarted = false;
    bool saleHasEnded = false;
    uint256 public saleEndTime   = 1518649200; // 15.2.2018, 0:00:00, GMT+1
    uint256 public saleStartTime = 1513435000; // 16.12.2017, 15:36:40, GMT+1
    uint256 public maxEthToRaise = 7500 * 10**18;
    uint256 public totalEthRaised;
    uint256 public ethAvailable;
    uint256 public eth2mnt = 10000; // number of MNTs you get for 1 ETH - actually for 1/10**18 of ETH

    /* Issue new tokens - internal function */     
    function _mintTokens (address _to, uint256 _amount) internal {             
        require(balanceOf[_to] + _amount >= balanceOf[_to]); // check for overflows
        require(totalSupply + _amount <= maxSupply);
        totalSupply += _amount;                                      // Update total supply
        balanceOf[_to] += _amount;                               // Set minted coins to target
        Transfer(0x0, _to, _amount);                            // Create Transfer event from 0x
    }


    /* Users send ETH and enter the token sale*/  
    function () public payable {
        require(msg.value != 0);
        require(!(saleHasEnded || now > saleEndTime)); // Throw if the token sale has ended
        if (!saleHasStarted) {                                                // Check if this is the first token sale transaction   
            if (now >= saleStartTime) {                             // Check if the token sale should start        
                saleHasStarted = true;                                           // Set that the token sale has started         
            } else {
                require(false);
            }
        }     
     
        if (maxEthToRaise > (totalEthRaised + msg.value)) {                 // Check if the user sent too much ETH         
            totalEthRaised += msg.value;                                    // Add to total eth Raised
            ethAvailable += msg.value;
            _mintTokens(msg.sender, msg.value * eth2mnt);
            cjTeamWallet.transfer(msg.value); 
        } else {                                                              // If user sent to much eth       
            uint maxContribution = maxEthToRaise - totalEthRaised;            // Calculate maximum contribution       
            totalEthRaised += maxContribution;  
            ethAvailable += maxContribution;
            _mintTokens(msg.sender, maxContribution * eth2mnt);
            uint toReturn = msg.value - maxContribution;                       // Calculate how much should be returned       
            saleHasEnded = true;
            msg.sender.transfer(toReturn);                                  // Refund the balance that is over the cap   
            cjTeamWallet.transfer(msg.value-toReturn);       
        }
    } 

    /**
     * Withdraw the funds
     *
     * Sends the raised amount to the CJ Team. Mints 40% of tokens to send to the CJ team.
     */
    function endOfSaleFullWithdrawal() public onlyOwner {
        if (saleHasEnded || now > saleEndTime) {
            //if (owner.send(ethAvailable)) {
            cjTeamWallet.transfer(this.balance);
            ethAvailable = 0;
            //_mintTokens (owner, totalSupply * 2 / 3);
            _mintTokens (cjTeamWallet, 50 * 10**6 * 10**18); // CJ team gets 40% of token supply
        }
    }

    /**
     * Withdraw the funds
     *
     * Sends partial amount to the CJ Team
     */
    function partialWithdrawal(uint256 toWithdraw) public onlyOwner {
        cjTeamWallet.transfer(toWithdraw);
        ethAvailable -= toWithdraw;
    }
}