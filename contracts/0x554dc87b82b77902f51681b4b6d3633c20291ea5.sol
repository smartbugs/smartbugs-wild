pragma solidity 0.5.4;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function claimEcoSystemReservePart1() public;

    function claimEcoSystemReservePart2() public;

    function recoverToken(address _token) public;

    function claimTeamReserve() public;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title The Multisig contract contains functions to transfer ETH and LYMPO tokens.
 * @author Roman Holovay
 */
contract Multisig {
	struct WithdrawEtherStruct {
		address payable toAddr;
		uint amount;
		address[] confirmators;
		bool completed;
	}
	
	struct SendTokensStruct {
		address toAddr;
		uint amount;
		address[] confirmators;
		bool completed;
	}
	
	IERC20 public token;

	WithdrawEtherStruct[] public withdrawEther;
	SendTokensStruct[] public sendTokens;

	uint public confirmationCount;
	mapping(address => bool) public owners;

	modifier onlyOwners { 
		require(owners[msg.sender]); 
		_; 
	}
	
	constructor(address _tokenAddress, address[] memory _addresses, uint _confirmationCount) public {
		require(_addresses.length >= _confirmationCount && _confirmationCount > 1);
		
		for (uint i = 0; i < _addresses.length; i++){
			owners[_addresses[i]] = true;
		}
		
		token = IERC20(_tokenAddress);

		confirmationCount = _confirmationCount;
	}

	/**
     * @dev changeTokenAddress changing token address only when it is not set yet.
     * @param _tokenAddress New token address.
     */
	function changeTokenAddress(address _tokenAddress) public  {
		require (owners[msg.sender]);
		require (token == IERC20(address(0)));
		token = IERC20(_tokenAddress);
	}
	
    
    /**
     * @dev createNewEtherWithdrawRequest creates a new ETH transfer request
     * @param _toAddr The addresses that will receive ETH.
     * @param _amount The number of ETH that can be received.
     */
	function createNewEtherWithdrawRequest(address payable _toAddr, uint _amount) public onlyOwners {
		address[] memory conf;
		withdrawEther.push(WithdrawEtherStruct(_toAddr, _amount, conf, false));
		withdrawEther[withdrawEther.length-1].confirmators.push(msg.sender);
	}
	
	/**
     * @dev approveEtherWithdrawRequest approve already created ETH transfer request.
     * This function can be used only by one of owners.
     * @param withdrawEtherId means position of withdrawEther array.
     */
	function approveEtherWithdrawRequest(uint withdrawEtherId) public onlyOwners {
	    require(!withdrawEther[withdrawEtherId].completed);
	    
	    for (uint i = 0; i < withdrawEther[withdrawEtherId].confirmators.length; i++) {
	        require (msg.sender != withdrawEther[withdrawEtherId].confirmators[i]);
	    }
	    
	    withdrawEther[withdrawEtherId].confirmators.push(msg.sender);
	    
	    if (withdrawEther[withdrawEtherId].confirmators.length >= confirmationCount) {
	        withdrawEther[withdrawEtherId].completed = true;
	        withdrawEther[withdrawEtherId].toAddr.transfer(withdrawEther[withdrawEtherId].amount);
	    }
	}
	
	/**
     * @dev createTransferTokensRequest creates a new Token transfer request
     * @param _toAddr The addresses that will receive tokens.
     * @param _amount The number of tokens that can be received.
     */
	function createTransferTokensRequest(address _toAddr, uint _amount) public onlyOwners {
	    address[] memory conf;
		sendTokens.push(SendTokensStruct(_toAddr, _amount, conf, false));
		sendTokens[sendTokens.length-1].confirmators.push(msg.sender);
	}
	
	/**
     * @dev approveEtherWithdrawRequest approve already created ETH transfer request.
     * This function can be used only by one of owners.
     * @param sendTokensId means position of sendTokens array.
     */
	function approveTransferTokensRequest(uint sendTokensId) public onlyOwners {
	    require(!sendTokens[sendTokensId].completed);
	    
	    for (uint i = 0; i < sendTokens[sendTokensId].confirmators.length; i++) {
	        require(msg.sender != sendTokens[sendTokensId].confirmators[i]);
	    }
	    
	    sendTokens[sendTokensId].confirmators.push(msg.sender);
	    
	    if (sendTokens[sendTokensId].confirmators.length >= confirmationCount) {
	       sendTokens[sendTokensId].completed = true;
	       token.transfer(sendTokens[sendTokensId].toAddr, sendTokens[sendTokensId].amount);
	    }
	}

	function claimTeamReserve() public onlyOwners {
        token.claimTeamReserve();
    }

    function claimEcoSystemReservePart1() public onlyOwners {
    	token.claimEcoSystemReservePart1();
    }

    function claimEcoSystemReservePart2() public onlyOwners {
    	token.claimEcoSystemReservePart2();
    }

    function recoverToken(address _token) public onlyOwners {
    	token.recoverToken(_token);
    }
}