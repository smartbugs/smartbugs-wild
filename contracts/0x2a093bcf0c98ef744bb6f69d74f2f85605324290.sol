/*
	Utility functions for safe math operations.  See link below for more information:
	https://ethereum.stackexchange.com/questions/15258/safemath-safe-add-function-assertions-against-overflows
*/
pragma solidity ^0.4.19;

contract SafeMath {

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x + y;
        assert((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) pure internal returns (uint256) {
        assert(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) pure internal returns (uint256) {
        uint256 z = x * y;
        assert((x == 0) || (z / x == y));
        return z;
    }

    function safeDiv(uint256 a, uint256 b) pure internal returns (uint256) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
}

contract Owner {
	
	// Token Name
	string public name = "FoodCoin";
	// Token Symbol
	string public symbol = "FOOD";
	// Decimals
	uint256 public decimals = 8;
	// Version 
	string public version = "v1";
	
	// Emission Address
	address public emissionAddress = address(0);
	// Withdraw address
	address public withdrawAddress = address(0);
	
	// Owners Addresses
	mapping ( address => bool ) public ownerAddressMap;
	// Owner Address/Number
	mapping ( address => uint256 ) public ownerAddressNumberMap;
	// Owners List
	mapping ( uint256 => address ) public ownerListMap;
	// Amount of owners
	uint256 public ownerCountInt = 0;

	// Modifier - Owner
	modifier isOwner {
        require( ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// Owner Creation/Activation
	function ownerOn( address _onOwnerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onOwnerAddress != address(0) );
		// If the owner is already exist
		if ( ownerAddressNumberMap[ _onOwnerAddress ]>0 )
		{
			// If the owner is disablead, activate him again
			if ( !ownerAddressMap[ _onOwnerAddress ] )
			{
				ownerAddressMap[ _onOwnerAddress ] = true;
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// If the owner is not exist
		else
		{
			ownerAddressMap[ _onOwnerAddress ] = true;
			ownerAddressNumberMap[ _onOwnerAddress ] = ownerCountInt;
			ownerListMap[ ownerCountInt ] = _onOwnerAddress;
			ownerCountInt++;
			retrnVal = true;
		}
	}
	
	// Owner disabled
	function ownerOff( address _offOwnerAddress ) external isOwner returns (bool retrnVal) {
		// If owner exist and he is not 0 and active
		// 0 owner can`t be off
		if ( ownerAddressNumberMap[ _offOwnerAddress ]>0 && ownerAddressMap[ _offOwnerAddress ] )
		{
			ownerAddressMap[ _offOwnerAddress ] = false;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}
	
	// Token name changing function
	function contractNameUpdate( string _newName, bool updateConfirmation ) external isOwner returns (bool retrnVal) {
		
		if ( updateConfirmation )
		{
			name = _newName;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}
	
	// Token symbol changing function
	function contractSymbolUpdate( string _newSymbol, bool updateConfirmation ) external isOwner returns (bool retrnVal) {

		if ( updateConfirmation )
		{
			symbol = _newSymbol;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}
	
	// Token decimals changing function
	function contractDecimalsUpdate( uint256 _newDecimals, bool updateConfirmation ) external isOwner returns (bool retrnVal) {
		
		if ( updateConfirmation && _newDecimals != decimals )
		{
			decimals = _newDecimals;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}
	
	// New token emission address setting up 
	function emissionAddressUpdate( address _newEmissionAddress ) external isOwner {
		emissionAddress = _newEmissionAddress;
	}
	
	// New token withdrawing address setting up
	function withdrawAddressUpdate( address _newWithdrawAddress ) external isOwner {
		withdrawAddress = _newWithdrawAddress;
	}

	// Constructor adds owner to undeletable list
	function Owner() public {
		// Owner creation
		ownerAddressMap[ msg.sender ] = true;
		ownerAddressNumberMap[ msg.sender ] = ownerCountInt;
		ownerListMap[ ownerCountInt ] = msg.sender;
		ownerCountInt++;
	}
}

contract SpecialManager is Owner {

	// Special Managers Addresses
	mapping ( address => bool ) public specialManagerAddressMap;
	// Special Manager Address/Number Mapping
	mapping ( address => uint256 ) public specialManagerAddressNumberMap;
	// Special Managers List
	mapping ( uint256 => address ) public specialManagerListMap;
	// Special Manager Amount
	uint256 public specialManagerCountInt = 0;
	
	// Special Manager or Owner modifier
	modifier isSpecialManagerOrOwner {
        require( specialManagerAddressMap[msg.sender]==true || ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// Special Manager creation/actination
	function specialManagerOn( address _onSpecialManagerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onSpecialManagerAddress != address(0) );
		// If this special manager already exists
		if ( specialManagerAddressNumberMap[ _onSpecialManagerAddress ]>0 )
		{
			// If this special manager disabled, activate him again
			if ( !specialManagerAddressMap[ _onSpecialManagerAddress ] )
			{
				specialManagerAddressMap[ _onSpecialManagerAddress ] = true;
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// If this special manager doesn`t exist
		else
		{
			specialManagerAddressMap[ _onSpecialManagerAddress ] = true;
			specialManagerAddressNumberMap[ _onSpecialManagerAddress ] = specialManagerCountInt;
			specialManagerListMap[ specialManagerCountInt ] = _onSpecialManagerAddress;
			specialManagerCountInt++;
			retrnVal = true;
		}
	}
	
	// Special manager disactivation
	function specialManagerOff( address _offSpecialManagerAddress ) external isOwner returns (bool retrnVal) {
		// If this special manager exists and he is non-zero and also active 
		// 0-number manager can`t be disactivated
		if ( specialManagerAddressNumberMap[ _offSpecialManagerAddress ]>0 && specialManagerAddressMap[ _offSpecialManagerAddress ] )
		{
			specialManagerAddressMap[ _offSpecialManagerAddress ] = false;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}


	// Constructor adds owner to superowner list
	function SpecialManager() public {
		// owner creation
		specialManagerAddressMap[ msg.sender ] = true;
		specialManagerAddressNumberMap[ msg.sender ] = specialManagerCountInt;
		specialManagerListMap[ specialManagerCountInt ] = msg.sender;
		specialManagerCountInt++;
	}
}


contract Manager is SpecialManager {
	
	// Managers addresses
	mapping ( address => bool ) public managerAddressMap;
	// Manager Address/Number Mapping
	mapping ( address => uint256 ) public managerAddressNumberMap;
	// Managers` List
	mapping ( uint256 => address ) public managerListMap;
	// Amount of managers
	uint256 public managerCountInt = 0;
	
	// Modifier - Manager Or Owner
	modifier isManagerOrOwner {
        require( managerAddressMap[msg.sender]==true || ownerAddressMap[msg.sender]==true );
        _;
    }
	
	// Owner Creation/Activation
	function managerOn( address _onManagerAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onManagerAddress != address(0) );
		// If this special manager exists
		if ( managerAddressNumberMap[ _onManagerAddress ]>0 )
		{
			// If this special manager disabled, activate him again
			if ( !managerAddressMap[ _onManagerAddress ] )
			{
				managerAddressMap[ _onManagerAddress ] = true;
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// If this special manager doesn`t exist
		else
		{
			managerAddressMap[ _onManagerAddress ] = true;
			managerAddressNumberMap[ _onManagerAddress ] = managerCountInt;
			managerListMap[ managerCountInt ] = _onManagerAddress;
			managerCountInt++;
			retrnVal = true;
		}
	}
	
	// Manager disactivation
	function managerOff( address _offManagerAddress ) external isOwner returns (bool retrnVal) {
		// if it's a non-zero manager and already exists and active
		// 0-number manager can`t be disactivated
		if ( managerAddressNumberMap[ _offManagerAddress ]>0 && managerAddressMap[ _offManagerAddress ] )
		{
			managerAddressMap[ _offManagerAddress ] = false;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}


	// Constructor adds owner to manager list 
	function Manager() public {
		// manager creation
		managerAddressMap[ msg.sender ] = true;
		managerAddressNumberMap[ msg.sender ] = managerCountInt;
		managerListMap[ managerCountInt ] = msg.sender;
		managerCountInt++;
	}
}


contract Management is Manager {
	
	// Description
	string public description = "";
	
	// Current tansaction status 
	// TRUE - tansaction available
	// FALSE - tansaction not available
	bool public transactionsOn = false;
	// Special permissions to allow/prohibit transactions to move tokens for specific accounts
	// 0 - depends on transactionsOn
	// 1 - always "forbidden"
	// 2 - always "allowed"
	mapping ( address => uint256 ) public transactionsOnForHolder;
	
	
	// Displaying tokens in the balanceOf function for all tokens
	// TRUE - Displaying available
	// FALSE - Displaying hidden, shows 0. Checking the token balance available in function balanceOfReal
	bool public balanceOfOn = true;
	// Displaying the token balance in function balanceOfReal for definit holder
	// 0 - depends on transactionsOn
	// 1 - always "forbidden"
	// 2 - always "allowed"
	mapping ( address => uint256 ) public balanceOfOnForHolder;
	
	
	// Current emission status
	// TRUE - emission is available, managers may add tokens to contract
	// FALSE - emission isn`t available, managers may not add tokens to contract
	bool public emissionOn = true;

	// emission cap
	uint256 public tokenCreationCap = 0;
	
	// Addresses list for verification of acoounts owners
	// Addresses
	mapping ( address => bool ) public verificationAddressMap;
	// Verification Address/Number Mapping
	mapping ( address => uint256 ) public verificationAddressNumberMap;
	// Verification List Mapping
	mapping ( uint256 => address ) public verificationListMap;
	// Amount of verifications
	uint256 public verificationCountInt = 1;
	
	// Verification holding
	// Verification Holders Timestamp
	mapping (address => uint256) public verificationHoldersTimestampMap;
	// Verification Holders Value
	mapping (address => uint256) public verificationHoldersValueMap;
	// Verification Holders Verifier Address
	mapping (address => address) public verificationHoldersVerifierAddressMap;
	// Verification Address Holders List Count
	mapping (address => uint256) public verificationAddressHoldersListCountMap;
	// Verification Address Holders List Number
	mapping (address => mapping ( uint256 => address )) public verificationAddressHoldersListNumberMap;
	
	// Modifier - Transactions On
	modifier isTransactionsOn( address addressFrom ) {
		
		require( transactionsOnNowVal( addressFrom ) );
		_;
    }
	
	// Modifier - Emission On
	modifier isEmissionOn{
        require( emissionOn );
        _;
    }
	
	// Function transactions On now validate for definit address 
	function transactionsOnNowVal( address addressFrom ) public view returns( bool )
	{
		return ( transactionsOnForHolder[ addressFrom ]==0 && transactionsOn ) || transactionsOnForHolder[ addressFrom ]==2 ;
	}
	
	// transaction allow/forbidden for definit token holder
	function transactionsOnForHolderUpdate( address _to, uint256 _newValue ) external isOwner
	{
		if ( transactionsOnForHolder[ _to ] != _newValue )
		{
			transactionsOnForHolder[ _to ] = _newValue;
		}
	}

	// Function of changing allow/forbidden transfer status
	function transactionsStatusUpdate( bool _on ) external isOwner
	{
		transactionsOn = _on;
	}
	
	// Function of changing emission status
	function emissionStatusUpdate( bool _on ) external isOwner
	{
		emissionOn = _on;
	}
	
	// Emission cap setting up
	function tokenCreationCapUpdate( uint256 _newVal ) external isOwner
	{
		tokenCreationCap = _newVal;
	}
	
	// balanceOfOnForHolder; balanceOfOn
	
	// Function on/off token displaying in function balanceOf
	function balanceOfOnUpdate( bool _on ) external isOwner
	{
		balanceOfOn = _on;
	}
	
	// Function on/off token displaying in function balanceOf for definit token holder
	function balanceOfOnForHolderUpdate( address _to, uint256 _newValue ) external isOwner
	{
		if ( balanceOfOnForHolder[ _to ] != _newValue )
		{
			balanceOfOnForHolder[ _to ] = _newValue;
		}
	}
	
	
	// Function adding of new verification address
	function verificationAddressOn( address _onVerificationAddress ) external isOwner returns (bool retrnVal) {
		// Check if it's a non-zero address
		require( _onVerificationAddress != address(0) );
		// If this address is already exists
		if ( verificationAddressNumberMap[ _onVerificationAddress ]>0 )
		{
			// If address off, activate it again
			if ( !verificationAddressMap[ _onVerificationAddress ] )
			{
				verificationAddressMap[ _onVerificationAddress ] = true;
				retrnVal = true;
			}
			else
			{
				retrnVal = false;
			}
		}
		// If this address doesn`t exist
		else
		{
			verificationAddressMap[ _onVerificationAddress ] = true;
			verificationAddressNumberMap[ _onVerificationAddress ] = verificationCountInt;
			verificationListMap[ verificationCountInt ] = _onVerificationAddress;
			verificationCountInt++;
			retrnVal = true;
		}
	}
	
	// Function of disactivation of verification address
	function verificationOff( address _offVerificationAddress ) external isOwner returns (bool retrnVal) {
		// If this verification address exists and disabled
		if ( verificationAddressNumberMap[ _offVerificationAddress ]>0 && verificationAddressMap[ _offVerificationAddress ] )
		{
			verificationAddressMap[ _offVerificationAddress ] = false;
			retrnVal = true;
		}
		else
		{
			retrnVal = false;
		}
	}
	
	// Event "Description updated"
	event DescriptionPublished( string _description, address _initiator);
	
	// Description update
	function descriptionUpdate( string _newVal ) external isOwner
	{
		description = _newVal;
		DescriptionPublished( _newVal, msg.sender );
	}
}

// Token contract FoodCoin Ecosystem
contract FoodcoinEcosystem is SafeMath, Management {
	
	// Token total supply
	uint256 public totalSupply = 0;
	
	// Balance
	mapping ( address => uint256 ) balances;
	// Balances List Address
	mapping ( uint256 => address ) public balancesListAddressMap;
	// Balances List/Number Mapping
	mapping ( address => uint256 ) public balancesListNumberMap;
	// Balances Address Description
	mapping ( address => string ) public balancesAddressDescription;
	// Total amount of all balances
	uint256 balancesCountInt = 1;
	
	// Forwarding of address managing for definit amount of tokens
	mapping ( address => mapping ( address => uint256 ) ) allowed;
	
	
	// Standard ERC-20 events
	// Event - token transfer
	event Transfer( address indexed from, address indexed to, uint value );
	// Event - Forwarding of address managing
    event Approval( address indexed owner, address indexed spender, uint value );
	
	// Token transfer
	event FoodTransferEvent( address from, address to, uint256 value, address initiator, uint256 newBalanceFrom, uint256 newBalanceTo );
	// Event - Emission
	event FoodTokenEmissionEvent( address initiator, address to, uint256 value, bool result, uint256 newBalanceTo );
	// Event - Withdraw
	event FoodWithdrawEvent( address initiator, address to, bool withdrawOk, uint256 withdraw, uint256 withdrawReal, uint256 newBalancesValue );
	
	
	// Balance View
	function balanceOf( address _owner ) external view returns ( uint256 )
	{
		// If allows to display balance for all or definit holder
		if ( ( balanceOfOnForHolder[ _owner ]==0 && balanceOfOn ) || balanceOfOnForHolder[ _owner ]==2 )
		{
			return balances[ _owner ];
		}
		else
		{
			return 0;
		}
	}
	// Real Balance View
	function balanceOfReal( address _owner ) external view returns ( uint256 )
	{
		return balances[ _owner ];
	}
	// Check if a given user has been delegated rights to perform transfers on behalf of the account owner
	function allowance( address _owner, address _initiator ) external view returns ( uint256 remaining )
	{
		return allowed[ _owner ][ _initiator ];
	}
	// Total balances quantity
	function balancesQuantity() external view returns ( uint256 )
	{
		return balancesCountInt - 1;
	}
	
	// Function of token transaction. For the first transaction will be created the detailed information
	function _addClientAddress( address _balancesAddress, uint256 _amount ) internal
	{
		// check if this address is not on the list yet
		if ( balancesListNumberMap[ _balancesAddress ] == 0 )
		{
			// add it to the list
			balancesListAddressMap[ balancesCountInt ] = _balancesAddress;
			balancesListNumberMap[ _balancesAddress ] = balancesCountInt;
			// increment account counter
			balancesCountInt++;
		}
		// add tokens to the account 
		balances[ _balancesAddress ] = safeAdd( balances[ _balancesAddress ], _amount );
	}
	// Internal function that performs the actual transfer (cannot be called externally)
	function _transfer( address _from, address _to, uint256 _value ) internal isTransactionsOn( _from ) returns ( bool success )
	{
		// If the amount to transfer is greater than 0, and sender has funds available
		if ( _value > 0 && balances[ _from ] >= _value )
		{
			// Subtract from sender account
			balances[ _from ] -= _value;
			// Add to receiver's account
			_addClientAddress( _to, _value );
			// Perform the transfer
			Transfer( _from, _to, _value );
			FoodTransferEvent( _from, _to, _value, msg.sender, balances[ _from ], balances[ _to ] );
			// Successfully completed transfer
			return true;
		}
		// Return false if there are problems
		else
		{
			return false;
		}
	}
	// Function token transfer
	function transfer(address _to, uint256 _value) external returns ( bool success )
	{
		// If it is transfer to verification address
		if ( verificationAddressNumberMap[ _to ]>0 )
		{
			_verification(msg.sender, _to, _value);
		}
		// Regular transfer
		else
		{
			// Call function transfer. 
			return _transfer( msg.sender, _to, _value );
		}
	}
	// Function of transferring tokens from a delegated account
	function transferFrom(address _from, address _to, uint256 _value) external isTransactionsOn( _from ) returns ( bool success )
	{
		// Regular transfer. Not to verification address
		require( verificationAddressNumberMap[ _to ]==0 );
		// Check if the transfer initiator has permissions to move funds from the sender's account
		if ( allowed[_from][msg.sender] >= _value )
		{
			// If yes - perform transfer 
			if ( _transfer( _from, _to, _value ) )
			{
				// Decrease the total amount that initiator has permissions to access
				allowed[_from][msg.sender] = safeSubtract(allowed[_from][msg.sender], _value);
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}
	// Function of delegating account management for a certain amount
	function approve( address _initiator, uint256 _value ) external isTransactionsOn( msg.sender ) returns ( bool success )
	{
		// Grant the rights for a certain amount of tokens only
		allowed[ msg.sender ][ _initiator ] = _value;
		// Initiate the Approval event
		Approval( msg.sender, _initiator, _value );
		return true;
	}
	
	// The emission function (the manager or contract owner creates tokens and sends them to a specific account)
	function _emission (address _reciever, uint256 _amount) internal isManagerOrOwner isEmissionOn returns ( bool returnVal )
	{
		// if non-zero address
		if ( _reciever != address(0) )
		{
			// Calculate number of tokens after generation
			uint256 checkedSupply = safeAdd( totalSupply, _amount );
			// Emission amount
			uint256 amountTmp = _amount;
			// If emission cap settled additional emission is impossible
			if ( tokenCreationCap > 0 && tokenCreationCap < checkedSupply )
			{
				amountTmp = 0;
			}
			// if try to add more than 0 tokens
			if ( amountTmp > 0 )
			{
				// If no error, add generated tokens to a given address
				_addClientAddress( _reciever, amountTmp );
				// increase total supply of tokens
				totalSupply = checkedSupply;
				// event "token transfer"
				Transfer( emissionAddress, _reciever, amountTmp );
				// event "emission successfull"
				FoodTokenEmissionEvent( msg.sender, _reciever, _amount, true, balances[ _reciever ] );
			}
			else
			{
				returnVal = false;
				// event "emission failed"
				FoodTokenEmissionEvent( msg.sender, _reciever, _amount, false, balances[ _reciever ] );
			}
		}
	}
	// emission to definit 1 address
	function tokenEmission(address _reciever, uint256 _amount) external isManagerOrOwner isEmissionOn returns ( bool returnVal )
	{
		// Check if it's a non-zero address
		require( _reciever != address(0) );
		// emission in process
		returnVal = _emission( _reciever, _amount );
	}
	// adding 5 addresses at once
	function tokenEmission5( address _reciever_0, uint256 _amount_0, address _reciever_1, uint256 _amount_1, address _reciever_2, uint256 _amount_2, address _reciever_3, uint256 _amount_3, address _reciever_4, uint256 _amount_4 ) external isManagerOrOwner isEmissionOn
	{
		_emission( _reciever_0, _amount_0 );
		_emission( _reciever_1, _amount_1 );
		_emission( _reciever_2, _amount_2 );
		_emission( _reciever_3, _amount_3 );
		_emission( _reciever_4, _amount_4 );
	}
	
	// Function Tokens withdraw
	function withdraw( address _to, uint256 _amount ) external isSpecialManagerOrOwner returns ( bool returnVal, uint256 withdrawValue, uint256 newBalancesValue )
	{
		// check if this is a valid account
		if ( balances[ _to ] > 0 )
		{
			// Withdraw amount
			uint256 amountTmp = _amount;
			// It is impossible to withdraw more than available on balance
			if ( balances[ _to ] < _amount )
			{
				amountTmp = balances[ _to ];
			}
			// Withdraw in process
			balances[ _to ] = safeSubtract( balances[ _to ], amountTmp );
			// Changing of current tokens amount
			totalSupply = safeSubtract( totalSupply, amountTmp );
			// Return reply
			returnVal = true;
			withdrawValue = amountTmp;
			newBalancesValue = balances[ _to ];
			FoodWithdrawEvent( msg.sender, _to, true, _amount, amountTmp, balances[ _to ] );
			// Event "Token transfer"
			Transfer( _to, withdrawAddress, amountTmp );
		}
		else
		{
			returnVal = false;
			withdrawValue = 0;
			newBalancesValue = 0;
			FoodWithdrawEvent( msg.sender, _to, false, _amount, 0, balances[ _to ] );
		}
	}
	
	// Balance description update
	function balancesAddressDescriptionUpdate( string _newDescription ) external returns ( bool returnVal )
	{
		// If this address or contrat`s owher exists
		if ( balancesListNumberMap[ msg.sender ] > 0 || ownerAddressMap[msg.sender]==true )
		{
			balancesAddressDescription[ msg.sender ] = _newDescription;
			returnVal = true;
		}
		else
		{
			returnVal = false;
		}
	}
	
	// Recording of verification details
	function _verification( address _from, address _verificationAddress, uint256 _value) internal
	{
		// If verification address is active
		require( verificationAddressMap[ _verificationAddress ] );
		
		// If it is updating of already verificated address
		if ( verificationHoldersVerifierAddressMap[ _from ] == _verificationAddress )
		{
			// Verification Address Holders List Count
			uint256 tmpNumberVerification = verificationAddressHoldersListCountMap[ _verificationAddress ];
			verificationAddressHoldersListCountMap[ _verificationAddress ]++;
			// Verification Address Holders List Number
			verificationAddressHoldersListNumberMap[ _verificationAddress ][ tmpNumberVerification ] = _from;
		}
		
		// Verification Holders Timestamp 
		verificationHoldersTimestampMap[ _from ] = now;
		// Verification Value
		verificationHoldersValueMap[ _from ] = _value;
		// Verification Holders Verifier Address
		verificationHoldersVerifierAddressMap[ _from ] = _verificationAddress;
	}
}