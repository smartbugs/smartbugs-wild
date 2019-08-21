pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/DIP_Team_Transfer.sol

contract DIP_Team_Transfer is Ownable {

    uint256 constant DIP = 10**18;
    IERC20 public DIP_Token;

    event LogTokensSent(address receiver, uint256 amount);

    address Pool_B = 0x36500E8366b0477fe68842271Efb1Bb31D9a102B; // Team & Early Contributors
    address Pool_C = 0xF27daB6Bf108c8Ba6EA81F66ef336Df4f1F975b3; // Founders

    struct grant {
        address pool;
        uint256 amount;
    }

    mapping (address => grant) teamTokens;

    function () external {
        getMyTokens();
    }

    function getMyTokens() public {
        grant memory myGrant;
        uint256 amount;
        myGrant = teamTokens[msg.sender];
        amount = myGrant.amount;
        myGrant.amount = 0;
        require(amount > 0, "No Tokens available at address");
        teamTokens[msg.sender] = grant(myGrant.pool, 0);
        DIP_Token.transferFrom(myGrant.pool, msg.sender, amount);
        emit LogTokensSent(msg.sender, amount);
    }

    constructor () public Ownable() {

        DIP_Token = IERC20(0xc719d010B63E5bbF2C0551872CD5316ED26AcD83);

        teamTokens[0x0024df2bE7524b132Ced68Ca2906eD1D9CdAbDA4] = grant(Pool_B, 84000 * DIP);
        teamTokens[0x025f020e2C1e540c3fBe3E80C23Cb192dFb65514] = grant(Pool_B, 2957000 * DIP);
        teamTokens[0x1FeA19BA0Cd8e068Fb1C538B2C3a700965d1952e] = grant(Pool_B, 119000 * DIP);
        teamTokens[0x2718874048aBcCEbE24693e689D31B011c6101EA] = grant(Pool_B, 314000 * DIP);
        teamTokens[0x317c250bFF0AC2b1913Aa6F2d6C609e4bE1AaeE0] = grant(Pool_B, 100000 * DIP);
        teamTokens[0x398c901146F569Bf5FCd70375311eFa02E119aF8] = grant(Pool_B, 588000 * DIP);
        teamTokens[0x4E268abEDa13152E60722035328E83f28eed0275] = grant(Pool_B, 314000 * DIP);
        teamTokens[0x5509cE67333342e7758bF845A0897b51E062f502] = grant(Pool_B, 115000 * DIP);
        teamTokens[0x559F1a36Ea6435f22EF814a654645051b1639c9d] = grant(Pool_B, 30000 * DIP);
        teamTokens[0x5A6189cE8e6Ae1c86098af24103CA77D386Ae643] = grant(Pool_B, 5782000 * DIP);
        teamTokens[0x63CE9f57E2e4B41d3451DEc20dDB89143fD755bB] = grant(Pool_B, 115000 * DIP);
        teamTokens[0x6D970711335B3d3AC8Ee1bB88D7b3780bf580e5b] = grant(Pool_B, 46000 * DIP);
        teamTokens[0x842d48Ebb8E8043A98Cd176368F39d777d1fF78E] = grant(Pool_B, 19000 * DIP);
        teamTokens[0x8567104a7b6EA93a87c551F5D00ABB222EdB45d2] = grant(Pool_B, 46000 * DIP);
        teamTokens[0x886ed4Bb4Db7d160C25942dD9E5e1668cdA646D8] = grant(Pool_B, 250000 * DIP);
        teamTokens[0x98eA564573dE3AbD60181Df8b491C24C45b77e37] = grant(Pool_B, 115000 * DIP);
        teamTokens[0x9B8242f93dB16185bb6719C3831f768a261E5d55] = grant(Pool_B, 600000 * DIP);
        teamTokens[0xaC97d99B1cCdAE787B5022fE323C1079dbe41ccC] = grant(Pool_B, 115000 * DIP);
        teamTokens[0xB2Dc68B318eCEC2acf5f098D57775c90541612E2] = grant(Pool_B, 7227000 * DIP);
        teamTokens[0xb7686e8b325f39A6A62Ea1ea81fd29F50C7737ab] = grant(Pool_B, 115000 * DIP);
        teamTokens[0xba034d25a226705A84Ffe716eEEC90C1aD2aFE00] = grant(Pool_B, 115000 * DIP);
        teamTokens[0xC370D781D734222A8863053A8C5A7afF87b0896a] = grant(Pool_B, 100000 * DIP);
        teamTokens[0xCA0B0cA0d90e5008c31167FFb9a38fdA33aa36a8] = grant(Pool_B, 115000 * DIP);
        teamTokens[0xE2E5f8e18dD933aFbD61d81Fd188fB2637A2DaB6] = grant(Pool_B, 621000 * DIP);
        teamTokens[0xe5759a0d285BB2D14B82111532cf1c660Fe57481] = grant(Pool_B, 115000 * DIP);
        teamTokens[0xF8cB04BfC21ebBc63E7eB49c9f8edF2E97707eE5] = grant(Pool_B, 314000 * DIP);

        teamTokens[0x2EE8619CCa46c44cDD5C527FBa68E1f7E5F3478a] = grant(Pool_C, 33333333333333333333333333);
        teamTokens[0xa8e679191AE2C669F4550db7f52b20CF3d19c069] = grant(Pool_C, 33333333333333333333333333);
        teamTokens[0xbC6b0862e6394067DC5Be2147c4de35DeB4424fE] = grant(Pool_C, 33333333333333333333333333);

    }

    function cleanUp () public onlyOwner {
        selfdestruct(address (uint160(owner())));
    }
}