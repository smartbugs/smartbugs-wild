pragma solidity ^0.4.21;

/**
 * @title Description: This code is for creating a token contract
 * This contract is mintable, pausable, burnable, administered, admin-transferrable and 
 * has safety Maths and security operations checks done and yet have been kept short and simple
 * It has got 3 contracts
 * 1. Manager Contract - This contract gives a user the power to manage the token functions
 * 2. ERC20 Standard Contract - It implements ERC20 pre requisites
 * 3. WIMT Token Contract - It is a custom contract that inherits from the above two contracts
 * This source code was tested with Remix and solidity compiler version 0.4.21
 * The source code was adapted and modified by wims.io
 * source : https://github.com/tintinweb/smart-contract-sanctuary/blob/master/contracts/ropsten/46/46b8357a9a9361258358308d3668e2072d6732a9_AxelToken.sol
 */

 /**
 * @notice Manager contract
 */
 
contract Manager
{
    address public contractManager; //address to manage the token contract
    
    bool public paused = false; // Indicates whether the token contract is paused or not.
	
	event NewContractManager(address newManagerAddress); //Will display change of token manager

    /**
    * @notice Function constructor for contract Manager with no parameters
    * 
    */
    function Manager() public
	{
        contractManager = msg.sender; //address that creates contracts will manage it
    }

	/**
	* @notice onlyManager restrict management operations to the Manager of contract
	*/
    modifier onlyManager()
	{
        require(msg.sender == contractManager); 
        _;
    }
    
	/**
	* @notice Manager set a new manager
	*/
    function newManager(address newManagerAddress) public onlyManager 
	{
		require(newManagerAddress != 0);
		
        contractManager = newManagerAddress;
		
		emit NewContractManager(newManagerAddress);

    }
    
    /**
     * @dev Event fired when the token contracts gets paused.
     */
    event Pause();

    /**
     * @notice Event fired when the token contracts gets unpaused.
     */
    event Unpause();

    /**
     * @notice Allows a function to be called only when the token contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Pauses the token contract.
     */
    function pause() public onlyManager whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @notice Unpauses the token contract.
     */
    function unpause() public onlyManager {
        require(paused);

        paused = false;
        emit Unpause();
    }


}

/**
 *@notice ERC20 This is the traditional ERC20 contract
 */
contract ERC20 is Manager
{

    mapping(address => uint256) public balanceOf; //this variable displays users balances
    
    string public name;//this variable displays token contract name
	
    string public symbol;//this variable displays token contract ticker symbol
	
    uint256 public decimal; //this variable displays the number of decimals for the token
	
    uint256 public totalSupply;//this variable displays the total supply of tokens
    
    mapping(address => mapping(address => uint256)) public allowance;//this will list of addresses a user will allow to Transfer his/her tokens
    
    event Transfer(address indexed from, address indexed to, uint256 value); //this event will notifies Transfers
	
    event Approval(address indexed owner, address indexed spender, uint256 value);//this event will notifies Approval
    
    /**
    * @notice Function constructor for ERC20 contract
    */
    function ERC20(uint256 initialSupply, string _name, string _symbol, uint256 _decimal)  public
	{
		require(initialSupply >= 0);//prevent negative numbers

		require(_decimal >= 0);//no negative decimals allowed
		
        balanceOf[msg.sender] = initialSupply;//give the contract creator address the total created tokens
		
        name = _name; //When the contract is being created give it a name
		
        symbol = _symbol;//When the contract is being created give it a symbol
		
        decimal = _decimal;//When the contract is being created give it decimals standard is  18
		
        totalSupply = initialSupply; //When the contract is being created set the token total supply
    }
    
    /**
    * @notice function transfer which will move tokens from user account to an address specified at to parameter
    *
    */
    function transfer(address _to, uint256 _value)public whenNotPaused returns (bool success)
	{
		require(_value > 0);//prevent transferring nothing
		
		require(balanceOf[msg.sender] >= _value);//the token sender must have tokens to transfer
		
		require(balanceOf[_to] + _value >= balanceOf[_to]);//the token receiver balance must change and be bigger

        balanceOf[msg.sender] -= _value;//the balance of the token sender must decrease accordingly
		
        balanceOf[_to] += _value;//effect the actual transfer of tokens
		
        emit Transfer(msg.sender, _to, _value);//publish addresses and amount Transferred

        return true;
    }
    
    /**
    * @notice function approve gives an address power to spend specified amount
    *
    */
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) 
	{
		require(_value > 0); //approved amount must be greater than zero
		
		allowance[msg.sender][_spender] = _value;//_spender will be approved to spend _value from as user's address that called this function

        emit Approval(msg.sender, _spender, _value);//broadcast the activity
		
        return true;
    }
    
    /**
    * @notice function allowance : displays address allow to transfer tokens from owner
    * 
    */    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) 
	{
      return allowance[_owner][_spender];
    }

	/**
    * @notice function transferFrom : moves tokens from one address to another
    * 
    */
    function transferFrom(address _from, address _to, uint256 _value)public whenNotPaused returns (bool success)
	{
		require(_value > 0); //move at least 1 token
		
        require(balanceOf[_from] >= _value);//check that there tokens to move
		
        require(balanceOf[_to] + _value >= balanceOf[_to]);//after the move the new value must be greater
        
        require(_value <= allowance[_from][msg.sender]); //only authorized addresses can transferFrom

        balanceOf[_from] -= _value;//remove tokens from _from address
		
        balanceOf[_to] += _value;//add these tokens to _to address
        
        allowance[_from][msg.sender] -= _value; //change the base token balance

        emit Transfer(_from, _to, _value);//publish transferFrom activity to network

        return true;
    }
    
    /**
    * @notice function balanceOf will display balance of given address
    * 
    */
    function balanceOf(address _owner)public constant returns (uint256 balance) 
	{
        return balanceOf[_owner];
    }
}

/**
 *@notice  WIMT Token implements Manager and ERC contracts
 */
contract WIMT is Manager, ERC20
{
    /**
     * @notice function constructor for the WIMT contract
     */
     
    function WIMT(uint256 _totalSupply, string _name, string _symbol, uint8 _decimal ) public  ERC20(_totalSupply, _name, _symbol, _decimal)
	{

        contractManager = msg.sender;

        balanceOf[contractManager] = _totalSupply;
		
        totalSupply = _totalSupply;
		
		decimal = _decimal;

    }
    
    /**
    * @notice function mint to be executed by Manager of token
    * 
    */
    function mint(address target, uint256 mintedAmount)public onlyManager whenNotPaused
	{
		require(target != 0);//check executor is supplied 
		
		require(mintedAmount > 0);//disallow negative minting
		
	    require(balanceOf[target] + mintedAmount >= balanceOf[target]);//after the move the new value must be greater
        
        require(totalSupply + mintedAmount >= totalSupply);//after the move the new value must be greater
        
        balanceOf[target] += mintedAmount;//add tokens to address target
		
        totalSupply += mintedAmount;//increase totalSupply
		
        emit Transfer(0, this, mintedAmount);//publish transfer
		
        emit Transfer(this, target, mintedAmount);//publish transfer
    }
    
	/**
    * @notice function burn decrease total Supply of tokens
    * 
    */
	function burn(uint256 mintedAmount) public onlyManager whenNotPaused
	{
		
		require(mintedAmount > 0);//at least 1 token must be destroyed
		
		require(totalSupply - mintedAmount <= totalSupply);//after the move the new value must be greater
        
	    require(balanceOf[msg.sender] - mintedAmount <= balanceOf[msg.sender]);//after the move the new value must be greater

        balanceOf[msg.sender] -= mintedAmount;//decrease balance of destroyer
		
        totalSupply -= mintedAmount;//decrease totalSupply by destroyed tokens
		
        emit Transfer(0, msg.sender, mintedAmount);//publish burn activity
		
        

    }

}