pragma solidity ^0.4.8;
/// Prospectors obligation Token (OBG) - crowdfunding code for Prospectors game
contract ProspectorsObligationToken {
    string public constant name = "Prospectors Obligation Token";
    string public constant symbol = "OBG";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.

    uint256 public constant tokenCreationRate = 1000;

    // The funding cap in weis.
    uint256 public constant tokenCreationCap = 1 ether * tokenCreationRate;
    uint256 public constant tokenCreationMin = 0.5 ether * tokenCreationRate;

    uint256 public fundingStartBlock;
    uint256 public fundingEndBlock;

    // The flag indicates if the OBG contract is in Funding state.
    bool public funding = true;

    // Receives ETH and its own OBG endowment.
    address public prospectors_team;

    // Has control over token migration to next version of token.
    address public migrationMaster;

    OBGAllocation lockedAllocation;

    // The current total token supply.
    uint256 totalTokens;

    mapping (address => uint256) balances;

    address public migrationAgent;
    uint256 public totalMigrated;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

    function ProspectorsObligationToken() {

        // if (_prospectors_team == 0) throw;
        // if (_migrationMaster == 0) throw;
        // if (_fundingStartBlock <= block.number) throw;
        // if (_fundingEndBlock   <= _fundingStartBlock) throw;

        // lockedAllocation = new OBGAllocation(_prospectors_team);
        // migrationMaster = _migrationMaster;
        // prospectors_team = _prospectors_team;
        // fundingStartBlock = _fundingStartBlock;
        // fundingEndBlock = _fundingEndBlock;
        
        prospectors_team = 0xCCe6DA2086DD9348010a2813be49E58530852b46;
        migrationMaster = 0xCCe6DA2086DD9348010a2813be49E58530852b46;
        fundingStartBlock = block.number + 10;
        fundingEndBlock = block.number + 30;
        lockedAllocation = new OBGAllocation(prospectors_team);
        
    }

    /// @notice Transfer `_value` OBG tokens from sender's account
    /// `msg.sender` to provided account address `_to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Operational
    /// @param _to The address of the tokens recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool) {
        // Abort if not in Operational state.
        if (funding) throw;

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    // Token migration support:

    /// @notice Migrate tokens to the new token contract.
    /// @dev Required state: Operational Migration
    /// @param _value The amount of token to be migrated
    function migrate(uint256 _value) external {
        // Abort if not in Operational Migration state.
        if (funding) throw;
        if (migrationAgent == 0) throw;

        // Validate input value.
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        totalTokens -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    /// @notice Set address of migration target contract and enable migration
	/// process.
    /// @dev Required state: Operational Normal
    /// @dev State transition: -> Operational Migration
    /// @param _agent The address of the MigrationAgent contract
    function setMigrationAgent(address _agent) external {
        // Abort if not in Operational Normal state.
        if (funding) throw;
        if (migrationAgent != 0) throw;
        if (msg.sender != migrationMaster) throw;
        migrationAgent = _agent;
    }

    function setMigrationMaster(address _master) external {
        if (msg.sender != migrationMaster) throw;
        if (_master == 0) throw;
        migrationMaster = _master;
    }

    // Crowdfunding:

    /// @notice Create tokens when funding is active.
    /// @dev Required state: Funding Active
    /// @dev State transition: -> Funding Success (only if cap reached)
    function () payable external {
        // Abort if not in Funding Active state.
        // The checks are split (instead of using or operator) because it is
        // cheaper this way.
        if (!funding) throw;
        if (block.number < fundingStartBlock) throw;
        if (block.number > fundingEndBlock) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
        if (msg.value > (tokenCreationCap - totalTokens) / tokenCreationRate)
            throw;

        var numTokens = msg.value * tokenCreationRate;
        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;

        // Log token creation event
        Transfer(0, msg.sender, numTokens);
    }

    /// @notice Finalize crowdfunding
    /// @dev If cap was reached or crowdfunding has ended then:
    /// create OBG for the Prospectors Team and developer,
    /// transfer ETH to the Prospectors Team address.
    /// @dev Required state: Funding Success
    /// @dev State transition: -> Operational Normal
    function finalize() external {
        // Abort if not in Funding Success state.
        if (!funding) throw;
        if ((block.number <= fundingEndBlock ||
             totalTokens < tokenCreationMin) &&
            totalTokens < tokenCreationCap) throw;

        // Switch to Operational state. This is the only place this can happen.
        funding = false;

        // Create additional OBG for the Prospectors Team and developers as
        // the 18% of total number of tokens.
        // All additional tokens are transfered to the account controller by
        // OBGAllocation contract which will not allow using them for 6 months.
        uint256 percentOfTotal = 18;
        uint256 additionalTokens =
            totalTokens * percentOfTotal / (100 - percentOfTotal);
        totalTokens += additionalTokens;
        balances[lockedAllocation] += additionalTokens;
        Transfer(0, lockedAllocation, additionalTokens);

        // Transfer ETH to the Prospectors Team address.
        if (!prospectors_team.send(this.balance)) throw;
    }

    /// @notice Get back the ether sent during the funding in case the funding
    /// has not reached the minimum level.
    /// @dev Required state: Funding Failure
    function refund() external {
        // Abort if not in Funding Failure state.
        if (!funding) throw;
        if (block.number <= fundingEndBlock) throw;
        if (totalTokens >= tokenCreationMin) throw;

        var obgValue = balances[msg.sender];
        if (obgValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= obgValue;

        var ethValue = obgValue / tokenCreationRate;
        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }
	
	function kill()
	{
	    lockedAllocation.kill();
		suicide(prospectors_team);
	}
}


/// @title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}


/// @title OBG Allocation - Time-locked vault of tokens allocated
/// to developers and Prospectors Team
contract OBGAllocation {
    // Total number of allocations to distribute additional tokens among
    // developers and the Prospectors Team. The Prospectors Team has right to 20000
    // allocations, developers to 10000 allocations, divides among individual
    // developers by numbers specified in  `allocations` table.
    uint256 constant totalAllocations = 30000;

    // Addresses of developer and the Prospectors Team to allocations mapping.
    mapping (address => uint256) allocations;

    ProspectorsObligationToken obg;
    uint256 unlockedAt;

    uint256 tokensCreated = 0;

    function OBGAllocation(address _prospectors_team) internal {
        obg = ProspectorsObligationToken(msg.sender);
        unlockedAt = now + 6 * 30 days;

        // For the Prospectors Team:
        allocations[_prospectors_team] = 30000; // 12/18 pp of 30000 allocations.
    }

    /// @notice Allow developer to unlock allocated tokens by transferring them
    /// from OBGAllocation to developer's address.
    function unlock() external {
        if (now < unlockedAt) throw;

        // During first unlock attempt fetch total number of locked tokens.
        if (tokensCreated == 0)
            tokensCreated = obg.balanceOf(this);

        var allocation = allocations[msg.sender];
        allocations[msg.sender] = 0;
        var toTransfer = tokensCreated * allocation / totalAllocations;

        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!obg.transfer(msg.sender, toTransfer)) throw;
    }
	function kill()
	{
		suicide(0);
	}
}