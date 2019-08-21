pragma solidity ^0.4.16;  
/*
ETHB Crowdsale Contract

*/

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
  }
}

contract ERC20Token {

	function balanceOf(address who) public constant returns (uint);
	function transfer(address to, uint value) public;	
}

/**
 * This contract is administered
 */

contract admined {
    address public admin; //Admin address is public
    /**
    * @dev This constructor set the initial admin of the contract
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-allowed functions
        require(msg.sender == admin);
        _;
    }
    /**
    * @dev Transfer the adminship of the contract
    * @param _newAdmin The address of the new admin.
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != address(0));
        admin = _newAdmin;
        TransferAdminship(admin);
    }
    //All admin actions have a log for public review
    event TransferAdminship(address newAdmin);
    event Admined(address administrador);
}


contract ETHBCrowdsale is admined{
	/**
    * Variables definition - Public
    */
    uint256 public startTime = now; //block-time when it was deployed
    uint256 public totalDistributed = 0;
    uint256 public currentBalance = 0;
    ERC20Token public tokenReward;
    address public creator;
    address public ethWallet;
    string public campaignUrl;
    uint256 public constant version = 1;
    uint256 public exchangeRate = 10**7; //1 ETH (18decimals) = 1000 ETHB (8decimals)
    									 //(1*10^18)/(1000*10^8) = 1*10^7 ETH/ETHB

    event TokenWithdrawal(address _to,uint256 _withdraw);
	event PayOut(address _to,uint256 _withdraw);
	event TokenBought(address _buyer, uint256 _amount);

    /**
    * @dev Transfer the adminship of the contract
    * @param _ethWallet The address of the wallet used to payout ether.
    * @param _campaignUrl URL of this crowdsale.
    */
    function ETHBCrowdsale(
    	address _ethWallet,
    	string _campaignUrl) public {

    	tokenReward = ERC20Token(0x3a26746Ddb79B1B8e4450e3F4FFE3285A307387E);
    	creator = msg.sender;
    	ethWallet = _ethWallet;
    	campaignUrl = _campaignUrl;
    }
    /**
    * @dev Exchange function
    */
    function exchange() public payable {
    	require (tokenReward.balanceOf(this) > 0);
    	require (msg.value > 1 finney);

    	uint256 tokenBought = SafeMath.div(msg.value,exchangeRate);

    	require(tokenReward.balanceOf(this) >= tokenBought );
    	currentBalance = SafeMath.add(currentBalance,msg.value);
    	totalDistributed = SafeMath.add(totalDistributed,tokenBought);
    	tokenReward.transfer(msg.sender,tokenBought);
		TokenBought(msg.sender, tokenBought);

    }
    /**
    * @dev Withdraw remaining tokens to an specified address
    * @param _to address to transfer tokens.
    */
    function tokenWithdraw (address _to) onlyAdmin public {
    	require( _to != 0x0 );
    	require(tokenReward.balanceOf(this)>0);
    	uint256 withdraw = tokenReward.balanceOf(this);
    	tokenReward.transfer(_to,withdraw);
    	TokenWithdrawal(_to,withdraw);
    }
    /**
    * @dev Withdraw collected ether to ethWallet
    */
    function ethWithdraw () onlyAdmin public {
    	require(this.balance > 0);
    	uint256 withdraw = this.balance;
    	currentBalance = 0;
    	require(ethWallet.send(withdraw));
    	PayOut(ethWallet,withdraw);
    }
    /**
    * @dev callback function to deal with direct transfers
    */
    function () public payable{
        exchange();
    }
}