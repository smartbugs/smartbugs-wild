pragma solidity ^0.5.0;

interface tokenRecipient
{
    function receiveApproval (address wallet, uint256 amount, address sender, bytes calldata extra) external;
}

library safemath
{
	function mul (uint256 _a, uint256 _b) internal pure returns (uint256)
	{
		if (_a == 0) return 0;

		uint256 c = _a * _b;
		require (c / _a == _b);

		return c;
	}

	function div (uint256 _a, uint256 _b) internal pure returns (uint256)
	{
		require (_b > 0);
		uint256 c = _a / _b;

		return c;
	}

	function sub (uint256 _a, uint256 _b) internal pure returns (uint256)
	{
		require (_b <= _a);
		uint256 c = _a - _b;

		return c;
	}

	function add (uint256 _a, uint256 _b) internal pure returns (uint256)
	{
		uint256 c = _a + _b;
		require (c >= _a);

		return c;
	}
}

contract upishki
{
	using	safemath for uint;

	string	public name = "upishki";
	string	public symbol = "ups";
	uint8	public decimals = 0;

	address	public owner = address (0);

	uint256	public totalAllowed = 24000000;
	uint256	public totalSupply = 0;

	bool	public transferAllowed = true;

	uint256	public price = 2691000000000000;

	mapping (address => holder_t) public holder;
	address	[] public holders;

	bool	private locker = false;

	modifier locked {require (locker == false); locker = true; _; locker = false;}
	modifier owners {require (msg.sender == owner); _;}

	event	Transfer (address indexed From, address indexed To, uint256 Tokens);
	event	Approval (address indexed ownerWallet, address indexed spenderWallet, uint256 amount);
    event	Burn (address indexed Wallet, uint256 Amount);

    event   HolderLocked (address Wallet, string Reason);
    event   HolderUnlocked (address Wallet, string Reason);

    event   TransferAllowed (string Reason);
    event   TransferDisallowed (string Reason);

    event   AllowedTokensValueChanged (uint256 AllowedTokensCount, string Reason);

    event   PriceChanged (uint256 NewPrice, string Reason);

    event   ContractOwnerChanged (address NewOwner);

	constructor () public
	{
		owner = msg.sender;

		holders.push (msg.sender);
		holder [msg.sender] = holder_t (msg.sender, 0, 0, true);
	}

	function holdersCount () public view returns (uint256 Count)
	{
		return holders.length;
	}

	function balanceOf (address wallet) public view returns (uint256 Balance)
	{
		return holder [wallet].tokens;
	}

	function isHolderExists (address wallet) public view returns (bool Exists)
	{
		if (holder [wallet].wallet != address (0)) return true;

		return false;
	}

	function isHolderLocked (address wallet) public view returns (bool IsLocked)
	{
		return holder [wallet].active;
	}

	function setHolderLockedState (address wallet, bool locking, string memory reason) public owners locked
	{
		if (holder [wallet].wallet != address (0) && holder [wallet].active != locking)
		{
			holder [wallet].active = locking;

			if (locking == true) emit HolderLocked (wallet, reason);
			else emit HolderUnlocked (wallet, reason);
		}
	}

	function setTransferAllowedState (bool allowed, string memory reason) public owners locked
	{
		if (transferAllowed != allowed)
		{
			transferAllowed = allowed;

			if (allowed == true) emit TransferAllowed (reason);
			else emit TransferDisallowed (reason);
		}
	}

	function setPrice (uint256 new_price, string memory reason) public owners locked
	{
		if (new_price > 0 && new_price != price)
		{
			price = new_price;

			emit PriceChanged (new_price, reason);
		}
	}

    function transfer (address recipient, uint256 amount) public returns (bool Success)
    {
        return _transfer (msg.sender, recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool Success)
    {
	    if (holder [msg.sender].wallet == msg.sender && holder [sender].allowed [msg.sender] >= amount)
	    {
		    holder [sender].allowed [msg.sender] = holder [sender].allowed [msg.sender].sub (amount);

		    return _transfer (sender, recipient, amount);
	    }

	    return false;
    }

    function approve (address spender, uint256 amount) public returns (bool Success)
    {
        return _approve (spender, amount);
    }

    function approveAndCall (address spender, uint256 amount, bytes memory extra) public returns (bool Success)
    {
        tokenRecipient recipient = tokenRecipient (spender);

        if (_approve (spender, amount) == true)
        {
            recipient.receiveApproval (msg.sender, amount, address (this), extra);

            return true;
        }

        return false;
    }

    function burn (address wallet, uint256 value) public owners locked returns (bool success)
    {
        if (holder [wallet].wallet == wallet && holder [wallet].tokens >= value)
        {
            holder [wallet].tokens = holder [wallet].tokens.sub (value);
            totalSupply = totalSupply.sub (value);

            emit Burn (msg.sender, value);

            return true;
        }

        return false;
    }

    function burnFrom (address wallet, uint256 amount) public locked returns (bool Success)
    {
        if (holder [wallet].wallet == wallet && holder [wallet].tokens >= amount && holder [wallet].allowed [msg.sender] >= amount)
        {
		    holder [wallet].tokens = holder [wallet].tokens.sub (amount);

		    holder [wallet].allowed [msg.sender] = holder [wallet].allowed [msg.sender].sub (amount);

		    totalSupply = totalSupply.sub (amount);
		    totalAllowed = totalAllowed.add (amount);

		    emit Burn (wallet, amount);

		    return true;
        }

        return false;
    }

	function () external payable locked
	{
		_sale (msg.sender, msg.value);
	}

	/*	**************************************************************	*/
	/*																	*/
	/*		INTERNAL METHODS											*/
	/*																	*/
	/*	**************************************************************	*/

	function _sale (address target, uint256 value) internal returns (bool success, uint256 count, uint256 cost)
	{
		require (value >= price);

		if (holder [target].wallet == address (0))
		{
			holders.push (target);
			holder [target] = holder_t (target, 0, 0, true);
		}

		require (holder [target].active == true);

		uint256 tokens = value.div (price);

		if (tokens > totalAllowed) tokens = totalAllowed;

		uint256 calc_price = tokens.mul (price);

		totalAllowed = totalAllowed.sub (tokens);
		totalSupply = totalSupply.add (tokens);

		holder [target].tokens = holder [target].tokens.add (tokens);

		if (value > calc_price) address (uint160 (target)).transfer (value.sub (calc_price));
		if (address (this).balance > 0) address (uint160 (owner)).transfer (address (this).balance);

		emit Transfer (address (this), target, tokens);

		return (true, tokens, calc_price);
	}

    function _approve (address spender, uint256 amount) internal returns (bool Success)
    {
        if (holder [msg.sender].wallet != address (0))
        {
            holder [msg.sender].allowed [spender] = amount;

            emit Approval (msg.sender, spender, amount);

            return true;
        }

        return false;
    }

	function _transfer (address from, address to, uint value) internal returns (bool Success)
	{
        require (transferAllowed == true && to != address (0x0) && holder [from].wallet != address (0) && ((from != address (this) && holder [from].tokens >= value) || (from == address (this) && totalAllowed >= value)));

        if (holder [to].wallet == address (0))
        {
	        holder [to] = holder_t (to, 0, 0, true);
			holders.push (to);
        }

		require (holder [from].active == true && holder [to].active == true);

        holder [to].tokens = holder [to].tokens.add (value);

		if (from != address (this)) holder [from].tokens = holder [from].tokens.sub (value);
		else
		{
			totalAllowed = totalAllowed.sub (value);
			totalSupply = totalSupply.add (value);
		}

        emit Transfer (from, to, value);

        return true;
    }

	function _contract (address contract_address) internal view returns (bool)
	{
		uint codeLength;

		if (contract_address == address (0)) return false;

		assembly {codeLength := extcodesize (contract_address)}

		if (codeLength > 0) return true;
		else return false;
	}

	struct holder_t
	{
		address	wallet;
		uint256	tokens;
		uint256 locked;
		bool	active;
		mapping (address => uint256) allowed;
	}
}