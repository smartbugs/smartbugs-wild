pragma solidity 0.4.25;


/******************************************/
/*       Owned starts here           */
/******************************************/

contract owned 
{
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public
    {
        owner = msg.sender;
    }

    modifier onlyOwner
    {
        require(msg.sender == owner, "Sender not authorized.");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner
    {
        require(_newOwner != address(0), "0x00 address not allowed.");
        newOwner = _newOwner;
    }

    function acceptOwnership() public
    {
        require(msg.sender == newOwner, "Sender not authorized.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


/******************************************/
/*       TokenERC20 starts here           */
/******************************************/

contract TokenERC20
{

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
   
    constructor() public
    {
        decimals = 18;                       // decimals  
        totalSupply = 0;                     // initialSupply
        name = "LOOiX";                      // Set the name for display purposes
        symbol = "LOOIX";                    // Set the symbol for display purposes
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param _from The address to transfer from.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        require(_value > 0, "Transferred value has to be grater than 0."); 
        require(_to != address(0), "0x00 address not allowed.");                      // Prevent transfer to 0x0 address.
        require(balanceOf[_from] >= _value, "Not enough funds on sender address.");   // Check if the sender has enough
        require(balanceOf[_to] + _value > balanceOf[_to], "Overflow protection.");    // Check for overflows
        balanceOf[_from] -= _value;                                                   // Subtract from the sender
        balanceOf[_to] += _value;                                                     // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /**
    * @dev Transfer tokens
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transfer(address _to, uint256 _value) public returns(bool success)
    {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Transfer tokens from other address
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success)
    {
        require(_value <= allowance[_from][msg.sender], "Funds not approved.");     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Set allowance for other address
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    */
    function approve(address _spender, uint256 _value) public returns(bool success)
    {
        require(_value == 0 || allowance[msg.sender][_spender] == 0, "Approved funds or value are not 0.");
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

}


/******************************************/
/*       TokenStaking starts here         */
/******************************************/

contract TokenStaking
{

    uint256 internal stakeID;
    uint256 internal threeMonthTime;
    uint256 internal threeMonthPercentage;
    uint256 internal sixMonthTime;
    uint256 internal sixMonthPercentage;
    uint256 internal twelveMonthTime;
    uint256 internal twelveMonthPercentage;

    struct stakeInfo    // Struct for user vestings
    {
        uint256 endDate;
        uint256 amount;
        address initiator;
        address receiver;
    }

    mapping(address => uint256) public stakedBalanceOf;
    mapping(uint256 => stakeInfo) internal vestings;
    mapping(address => uint256[]) internal userVestingIDs;

    enum StakeOption {three, six, twelve}

    constructor() TokenStaking() public 
    { 
        stakeID = 0;
       
        threeMonthTime = 91 days;
        threeMonthPercentage = 1005012520859401063; // e**(0.02*0.25)
                               
        sixMonthTime = 182 days;
        sixMonthPercentage = 1020201340026755810; // e**(0.04*0.5)

        twelveMonthTime = 365 days;
        twelveMonthPercentage = 1061836546545359622; // e**(0.06*1.0)
    }

    /**
    * @dev Function to get the stake info from a corresponding ID.
    * @param _id uint256 The ID from which the stake info should be read.
    * @return endDate uint256 specifying the seconds since the UNIX Epoch. amount uint256 specifying the amount that was staked plus the stake bonus.
    */
    function getStakeInfo(uint256 _id) external view returns(uint256 endDate, uint256 amount, address receiver, address initiator)
    {
        return (vestings[_id].endDate, vestings[_id].amount, vestings[_id].receiver, vestings[_id].initiator);
    }
    
    /**
    * @dev Function to get the stake IDs from a given address.
    * @param _address address The address which staked tokens.
    * @return Ids uint256[] An array of stake IDs from the given address.
    */
    function getStakeIDs(address _address) external view returns(uint256[] memory Ids)
    {
        return userVestingIDs[_address];
    }

    /**
    * @dev Stake an amount of tokens with one of three options.
    * @param _amount uint256 The amount of tokens which will be staked.
    * @param _option StakeOption An enum which decides how long a stake will be frozen (only 0, 1 and 2 are valid values).
    * @return totalSupplyIncreaseds uint256 The total increase in supply from the staked tokens.
    */
    function _stake(uint256 _amount, StakeOption _option, address _receiver) internal returns(uint256 totalSupplyIncrease)
    {
        require(_option >= StakeOption.three && _option <= StakeOption.twelve);
        
        stakeInfo memory stakeStruct;
        stakeStruct.endDate = 0;
        stakeStruct.amount = 0;
        stakeStruct.initiator = msg.sender;
        stakeStruct.receiver = address(0);

        uint256 tempIncrease;

        if (_option == StakeOption.three) 
        {
            stakeStruct.endDate = now + threeMonthTime;
            stakeStruct.amount = _amount * threeMonthPercentage / (10**18);
            stakeStruct.initiator = msg.sender;
            stakeStruct.receiver = _receiver;
            tempIncrease = (_amount * (threeMonthPercentage - (10**18)) / (10**18));
        } 
        else if (_option == StakeOption.six)
        {
            stakeStruct.endDate = now + sixMonthTime;
            stakeStruct.amount = _amount * sixMonthPercentage / (10**18);
            stakeStruct.initiator = msg.sender;
            stakeStruct.receiver = _receiver;
            tempIncrease = (_amount * (sixMonthPercentage - (10**18)) / (10**18));
        } 
        else if (_option == StakeOption.twelve)
        {
            stakeStruct.endDate = now + twelveMonthTime;
            stakeStruct.amount = _amount * twelveMonthPercentage / (10**18);
            stakeStruct.initiator = msg.sender;
            stakeStruct.receiver = _receiver;
            tempIncrease = (_amount * (twelveMonthPercentage - (10**18)) / (10**18));
        }

        stakeID = stakeID + 1;
        vestings[stakeID] = stakeStruct;
        _setVestingID(stakeID, stakeStruct.receiver);
        stakedBalanceOf[msg.sender] += stakeStruct.amount;
        return tempIncrease;
    }

    /**
    * @dev Function to set a new vesting ID on the userVestingIDs mapping. Free ID slots in the array will be overwritten.
    * @param _id uint256 The new ID that has to be written in the corresponding mapping.
    */
    function _setVestingID(uint256 _id, address _receiver) internal
    {
        bool tempEntryWritten = false;
        uint256 arrayLength = userVestingIDs[_receiver].length;

        if(arrayLength != 0)
        {
            for (uint256 i = 0; i < arrayLength; i++) 
            {
                if (userVestingIDs[_receiver][i] == 0) 
                {
                    userVestingIDs[_receiver][i] = _id;
                    tempEntryWritten = true;
                    break;
                } 
            }

            if(!tempEntryWritten)
            {
                userVestingIDs[_receiver].push(_id);
            }
        } 
        else
        {
            userVestingIDs[_receiver].push(_id);
        }
    }

    /**
    * @dev Redeem the staked tokens.
    * @return amount uint256 The amount that has been redeemed.
    */
    function _redeem() internal returns(uint256 amount)
    {
        uint256[] memory IdArray = userVestingIDs[msg.sender];
        uint256 tempAmount = 0;
        uint256 finalAmount = 0;
        address tempInitiator = address(0);

        for(uint256 i = 0; i < IdArray.length; i++)
        {
            if(IdArray[i] != 0 && vestings[IdArray[i]].endDate <= now)
            {
                tempInitiator = vestings[IdArray[i]].initiator;
                tempAmount = vestings[IdArray[i]].amount;

                stakedBalanceOf[tempInitiator] -= tempAmount;
                finalAmount += tempAmount;

                // delete the vesting history
                delete userVestingIDs[msg.sender][i];
                delete vestings[IdArray[i]];
            }
        }

        require(finalAmount > 0, "No funds to redeem.");
        return finalAmount;
    }
}


/******************************************/
/*       LOOiXToken starts here       */
/******************************************/

contract LOOiXToken is owned, TokenERC20, TokenStaking
{

    bool public mintingActive;
    address public mintDelegate;
    uint256 public unlockAt;
    uint256 public ICO_totalSupply;
    uint256 internal constant MAX_UINT = 2**256 - 1;

    mapping(address => uint256) public allocations;

    event Stake(address indexed _target, uint256 _amount);
    event Redeem(address indexed _target, uint256 _amount);

    constructor() TokenERC20() public 
    {
        mintingActive = true;
        mintDelegate = address(0);
        unlockAt;
    }

    /**
    * @dev Modifier defines addresses allowed to mint. 
    */
    modifier mintingAllowed
    {
        require(msg.sender == owner || msg.sender == mintDelegate, "Sender not authorized.");
        _;
    }

    /**
    * @dev Internal ERC20 transfer.
    */
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        require(_value > 0, "Transferred value has to be grater than 0.");            // value has to be greater than 0
        require(_to != address(0), "0x00 address not allowed.");                      // Prevent transfer to 0x0 address
        require(balanceOf[_from] >= _value, "Not enough funds on sender address.");   // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow protection.");   // Check for overflows
        balanceOf[_from] -= _value;                                                   // Subtract from the sender
        balanceOf[_to] += _value;                                                     // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /**
    * @dev ERC20 transferFrom, modified such that an allowance of MAX_UINT represents an unlimited allowance.
    * @param _from Address to transfer from.
    * @param _to Address to transfer to.
    * @param _value Amount to transfer.
    * @return Success of transfer.
    */
    function transferFrom(address _from, address _to, uint _value) public returns (bool success)
    {
        uint256 allowanceTemp = allowance[_from][msg.sender];
        
        require(allowanceTemp >= _value, "Funds not approved."); 
        require(balanceOf[_from] >= _value, "Not enough funds on sender address.");
        require(balanceOf[_to] + _value >= balanceOf[_to], "Overflow protection.");

        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;

        if (allowanceTemp < MAX_UINT) 
        {
            allowance[_from][msg.sender] -= _value;
        }

        emit Transfer(_from, _to, _value);

        return true;
    }

    /**
    * @dev Set new mintDelegate address
    * @param _newDelegate The address authorized to mint
    */  
    function setMintDelegate(address _newDelegate) external onlyOwner
    {
        require(_newDelegate != address(0), "0x00 address not allowed.");
        mintDelegate = _newDelegate;
    }
    
    /**
    * @dev Set unlimited allowance for other address
    * @param _controllerAddress The address authorized to spend
    */   
    function giveAccess(address _controllerAddress) external
    {
        require(msg.sender != owner, "Owner of contract can not use this function.");
        require(_controllerAddress != address(0), "0x00 address not allowed.");
        allowance[msg.sender][_controllerAddress] = MAX_UINT;
        emit Approval(msg.sender, _controllerAddress, MAX_UINT);
    }

    /**
    * @dev Set allowance for other address to 0
    * @param _controllerAddress The address authorized to spend
    */   
    function revokeAccess(address _controllerAddress) external
    {
        require(_controllerAddress != address(0), "0x00 address not allowed.");
        allowance[msg.sender][_controllerAddress] = 0;
    }

    /**
    * @dev Withdraw all LOOiX on the contract.
    */ 
    function withdrawLOOiX() external onlyOwner
    {
        require(balanceOf[address(this)] > 0, "No funds available.");
        _transfer(address(this), owner, balanceOf[address(this)]);
    }

    /**
    * @dev Bulk mint function for airdrops. 
    * @param _address Address array to mint to.
    * @param _mintAmount Amount array to mint.
    */
    function mintTokenBulk(address[] _address, uint256[] _mintAmount) external mintingAllowed
    {
        require(mintingActive, "The mint functions are not available anymore.");
        uint256 tempAmount = 0;

        for (uint256 i = 0; i < _address.length; i++) 
        {
            if(balanceOf[_address[i]] + _mintAmount[i] >= balanceOf[_address[i]])
            {
                balanceOf[_address[i]] += _mintAmount[i] * (10**18);
                tempAmount += _mintAmount[i] * (10**18);

                emit Transfer(address(0), _address[i], _mintAmount[i] * (10**18));
            }
        }

        totalSupply += tempAmount;
    }

    /**
    * @dev Mint function for creating new tokens. 
    * @param _target Address to mint to.
    * @param _mintAmount Amount to mint.
    */
    function mintToken(address _target, uint256 _mintAmount) public mintingAllowed 
    {
        require(mintingActive, "The mint functions are not available anymore.");
        require(_target != address(0), "0x00 address not allowed.");

        balanceOf[_target] += _mintAmount * (10**18);
        totalSupply += _mintAmount * (10**18);

        emit Transfer(address(0), _target, _mintAmount * (10**18));
    }

    /**
    * @dev Stops the minting of the token. After this function is called, no new tokens can be minted using the mintToken or mintTokenBulk functions. Irreversible.
    */
    function terminateMinting() external onlyOwner 
    {
        require(mintingActive, "The mint functions are not available anymore.");
        uint256 tempTotalSupply = totalSupply;

        tempTotalSupply = tempTotalSupply + (tempTotalSupply  * 666666666666666666 / 10**18);
        totalSupply = tempTotalSupply;
        ICO_totalSupply = tempTotalSupply;

        mintingActive = false;
        unlockAt = now + 365 days;

        // 40% of the total token supply
        allocations[0xefbDBA37BD0e825d43bac88Ce570dcEFf50373C2] = tempTotalSupply * 9500 / 100000;      // 9.5% - Founders Pot.
        allocations[0x75dE233590c8Dd593CE1bB89d68e9f18Ecdf34C8] = tempTotalSupply * 9500 / 100000;      // 9.5% - Development and Management.
        allocations[0x357C2e4253389CE79440e867E9De14E17Bb97D2E] = tempTotalSupply * 3120 / 100000;      // 3.12% - Bonuspool.
        allocations[0xf35FF681cbb69b47488269CE2BA5CaA34133813A] = tempTotalSupply * 14250 / 100000;     // 14.25% - Marketing.

        balanceOf[0x2A809456adf8bd5A79D598e880f7Bd78e11B4A1c] += tempTotalSupply * 242 / 100000;        
        balanceOf[0x36c321017a8d8655ec7a2b862328678932E53b87] += tempTotalSupply * 242 / 100000;        
        balanceOf[0xc9ebc197Ee00C1E231817b4eb38322C364cFCFCD] += tempTotalSupply * 242 / 100000;
        balanceOf[0x2BE34a67491c6b1f8e0cA3BAA1249c90686CF6FB] += tempTotalSupply * 726 / 100000;
        balanceOf[0x1cF6725538AAcC9574108845D58cF2e89f62bbE9] += tempTotalSupply * 4 / 100000;
        balanceOf[0xc6a3B6ED936bD18FD72e0ae2D50A10B82EF79851] += tempTotalSupply * 130 / 100000;
        balanceOf[0x204Fb77569ca24C09e1425f979141536B89449E3] += tempTotalSupply * 130 / 100000;

        balanceOf[0xbE3Ece67B61Ef6D3Fd0F8b159d16A80BB04C0F7B] += tempTotalSupply * 164 / 100000;        // Bonuspool.
        balanceOf[0x731953d4c9A01c676fb6b013688AA8D512F5Ec03] += tempTotalSupply * 500 / 100000;        // Development and Management.
        balanceOf[0x84A81f3B42BD99Fd435B1498316F8705f84192bC] += tempTotalSupply * 500 / 100000;        // Founders Pot.
        balanceOf[0xEAeC9b7382e5abEBe76Fc7BDd2Dc22BA1a338918] += tempTotalSupply * 750 / 100000;        // Marketing.
    }

    /**
    * @dev Public unlock allocated Tokens.
    */
    function unlock() public
    {
        require(!mintingActive, "Function not available as long as minting is possible.");
        require(now > unlockAt, "Unlock date not reached.");
        require(allocations[msg.sender] > 0, "No tokens to unlock.");
        uint256 tempAmount;

        tempAmount = allocations[msg.sender];
        allocations[msg.sender] = 0;
        balanceOf[msg.sender] += tempAmount;
    }

    /**
    * @dev Public stake function to stake a given amount of tokens for one of the three options.
    * @param _amount Amount to stake.
    * @param _option StakeOption enum with values from 0 to 2.
    * @return Success of stake.
    */
    function stake(uint256 _amount, StakeOption _option, address _receiver) external returns(bool success)
    {
        require(!mintingActive, "Function not available as long as minting is possible.");
        require(balanceOf[msg.sender] >= _amount, "Not enough funds on sender address.");
        require(_amount >= 100*(10**18), "Amount is less than 100 token.");
        require(_receiver != address(0), "0x00 address not allowed.");
        uint256 supplyIncrease;
        uint256 finalBalance;

        supplyIncrease = _stake(_amount, _option, _receiver);
        totalSupply += supplyIncrease;
        balanceOf[msg.sender] -= _amount;
        finalBalance = _amount + supplyIncrease;

        emit Stake(_receiver, _amount);
        emit Transfer(msg.sender, _receiver, finalBalance);
    
        return true;
    }
    
    /**
    * @dev Public redeem function to redeem all redeemable tokens.
    */
    function redeem() public
    {
        require(userVestingIDs[msg.sender].length > 0, "No funds to redeem.");
        uint256 amount;

        amount = _redeem();
        balanceOf[msg.sender] += amount;
        emit Redeem(msg.sender, amount); 
    }
}