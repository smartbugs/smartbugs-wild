// Each person can be able to send <= 0.1 ETH and receive LMO (Just received Only once).
// 1ETH = 88888 LMO

// ABOUT LUCKY MONEY
// Put in a small red envelop or packets, the Chinese lucky money, also known as Hongbao or Yasuiqian in Chinese, is a monetary gift which are given during the Chinese Spring Festival holidays.
// The money was called “Yasuiqian” in Chinese, meaning "money warding off evil spirits", and was believed to protect the kids from sickness and misfortune. Sometimes, the Lucky Money are given to elderly to wish them longevity and health.


pragma solidity ^0.4.19;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract LuckyMoney {
    // Public variables of the token
    string public name = "Lucky Money";
    string public symbol = "LMO";
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default
    uint256 public totalSupply;
    uint256 public LMOSupply = 88888888;
    uint256 public buyPrice = 88888;
    address public creator;
    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FundTransfer(address backer, uint amount, bool isContribution);
    
    
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    function LuckyMoney() public {
        totalSupply = LMOSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;    // Give all total created tokens
        creator = msg.sender;
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
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
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    
    
    /// @notice Buy tokens from contract by sending ether
    function () payable internal {
        uint amount = msg.value * buyPrice;                   
        uint amountRaised;                                     
        amountRaised += msg.value;                            
        require(balanceOf[creator] >= amount);               
        require(msg.value <= 10**17);                        
        balanceOf[msg.sender] += amount;                  
        balanceOf[creator] -= amount;                        
        Transfer(creator, msg.sender, amount);              
        creator.transfer(amountRaised);
    }

 }