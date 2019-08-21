pragma solidity ^0.4.16;

contract ERC20TokenInterface {
    uint256 public totalSupply;
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MigrationRecipientV1Interface {
    function migrateTokensV1(address _owner, uint256 _balance) public;
}

contract MainToken is ERC20TokenInterface, MigrationRecipientV1Interface {
    string public name = "Swag";
    string public symbol = "SWAG";
    uint8 public decimals = 0;
    string public version = '1';
    mapping (address => uint256) balances;
    address migrateToAddress = 0x0;
    address[] migrationSources;

    function MainToken() public {
        migrationSources.push(msg.sender);
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public onlyIfNotMigrating returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false; // Insufficient balance or negative value
        }
    }

    // Migrate tokens to a new version of the contract
    function migrateMyTokens() public onlyIfMigrating {
        var balance = balances[msg.sender];
        if (balance > 0) {
            totalSupply -= balance;
            balances[msg.sender] = 0;
            MigrationRecipientV1Interface(migrateToAddress).migrateTokensV1(msg.sender, balance);
        }
    }

    // Receive tokens from an older version of the token contract
    function migrateTokensV1(address _owner, uint256 _value) public migrationSourcesOnly {
        totalSupply += _value;
        balances[_owner] += _value;
        Transfer(0x0, _owner, _value);
    }

    function setMigrateToAddress(address _to) public migrationSourcesOnly {
        migrateToAddress = _to;
    }

    function setOtherMigrationSources(address[] _otherMigrationSources) public migrationSourcesOnly {
        migrationSources = _otherMigrationSources;
        migrationSources.push(msg.sender);
    }

    function airdrop(address[] _targets, uint256 _value) public migrationSourcesOnly {
        totalSupply += _targets.length * _value;
        for (uint256 i = 0; i < _targets.length; i++) {
            address target = _targets[i];
            balances[target] += _value;
            Transfer(0x0, target, _value);
        }
    }

    function () public {
    }

    modifier onlyIfMigrating() {
        require(migrateToAddress != 0x0);
        _;
    }

    modifier onlyIfNotMigrating() {
        require(migrateToAddress == 0x0);
        _;
    }

    modifier migrationSourcesOnly() {
        require(arrayContainsAddress256(migrationSources, msg.sender));
        _;
    }

    // "addresses" may not be longer than 256
    function arrayContainsAddress256(address[] addresses, address value) internal pure returns (bool) {
        for (uint8 i = 0; i < addresses.length; i++) {
            if (addresses[i] == value) {
                return true;
            }
        }
        return false;
    }

    // Allowances are intentionally not supported.
    // These are only here to implement the ERC20 interface.
    function approve(address, uint256) public returns (bool) {
        return false;
    }

    function allowance(address, address) public constant returns (uint256) {
        return 0;
    }

    function transferFrom(address, address, uint256) public returns (bool) {
        return false;
    }
}