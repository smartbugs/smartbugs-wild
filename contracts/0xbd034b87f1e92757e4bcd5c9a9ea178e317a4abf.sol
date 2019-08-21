pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account)
    internal
    view
    returns (bool)
    {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private minters;

    constructor() internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        minters.remove(account);
        emit MinterRemoved(account);
    }
}


interface IQRToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
    external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value)
    external returns (bool);

    function transferFrom(address from, address to, uint256 value)
    external returns (bool);

    function mint(address to, uint256 value)
    external returns (bool);

    function addMinter(address account)
    external;

    function frozenTime(address owner)
    external view returns (uint);

    function setFrozenTime(address owner, uint newtime)
    external;
}

contract IQRSaleFirst is MinterRole {

    using SafeMath for uint256;

    uint256 private  _usdc_for_iqr;
    uint256 private _usdc_for_eth;
    uint256 private _leftToSale;

    address private _cold_wallet;

    IQRToken private _token;

    constructor() public  {
        // price usd cents for one IQR. Default: 1 IQR = $0.06
        _usdc_for_iqr = 6;
        // usd cents for one ether. Default: 1 ETH = $130.92
        _usdc_for_eth = 13092;
        // MAX tokens to sale for this contract
        _leftToSale = 200000000 ether;
        // Address for ether
        _cold_wallet = 0x5BAC0CE2276ebE6845c31C86499C6D7F5C9b0650;
    }

    function() public payable {
        require(msg.value > 0.1 ether);
        require(_token != address(0x0));
        require(_cold_wallet != address(0x0));

        uint256 received = msg.value;
        uint256 tokens_to_send = received.mul(_usdc_for_eth).div(_usdc_for_iqr);
        _leftToSale = _leftToSale.sub(tokens_to_send);
        _token.mint(msg.sender, tokens_to_send);

        _cold_wallet.transfer(msg.value);
    }

    function sendTokens(address beneficiary, uint256 tokens_to_send) public onlyMinter {
        require(_token != address(0x0));
        _leftToSale = _leftToSale.sub(tokens_to_send);
        _token.mint(beneficiary, tokens_to_send);
    }

    function sendTokensToManyAddresses(address[] beneficiaries, uint256 tokens_to_send) public onlyMinter {
        require(_token != address(0x0));
        _leftToSale = _leftToSale.sub(tokens_to_send * beneficiaries.length);
        for (uint i = 0; i < beneficiaries.length; i++) {
            _token.mint(beneficiaries[i], tokens_to_send);
        }
    }

    function setFrozenTime(address _owner, uint _newtime) public onlyMinter {
        require(_token != address(0x0));
        _token.setFrozenTime(_owner, _newtime);
    }

    function setFrozenTimeToManyAddresses(address[] _owners, uint _newtime) public onlyMinter {
        require(_token != address(0x0));
        for (uint i = 0; i < _owners.length; i++) {
            _token.setFrozenTime(_owners[i], _newtime);
        }
    }

    function unFrozen(address _owner) public onlyMinter {
        require(_token != address(0x0));
        _token.setFrozenTime(_owner, 0);
    }

    function unFrozenManyAddresses(address[] _owners) public onlyMinter {
        require(_token != address(0x0));
        for (uint i = 0; i < _owners.length; i++) {
            _token.setFrozenTime(_owners[i], 0);
        }
    }

    function usdc_for_iqr() public view returns (uint256) {
        return _usdc_for_iqr;
    }

    function usdc_for_eth() public view returns (uint256) {
        return _usdc_for_eth;
    }

    function leftToSale() public view returns (uint256) {
        return _leftToSale;
    }

    function cold_wallet() public view returns (address) {
        return _cold_wallet;
    }

    function token() public view returns (IQRToken) {
        return _token;
    }

    function setUSDCforIQR(uint256 _usdc_for_iqr_) public onlyMinter {
        _usdc_for_iqr = _usdc_for_iqr_;
    }

    function setUSDCforETH(uint256 _usdc_for_eth_) public onlyMinter {
        _usdc_for_eth = _usdc_for_eth_;
    }

    function setColdWallet(address _cold_wallet_) public onlyMinter {
        _cold_wallet = _cold_wallet_;
    }

    function setToken(IQRToken _token_) public onlyMinter {
        _token = _token_;
    }


}