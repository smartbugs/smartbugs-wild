pragma solidity >=0.4.21 <0.6.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20Old interface
 */
contract IERC20Old {
  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);
  
  function transfer(address to, uint256 value) public;
  
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract DecenterPayouts {

    using SafeMath for uint256;

    address public owner;
    IERC20 public daiContract;

    uint public totalCompensation = 0;
    uint public daiBalanceAllocated = 0;

    mapping(address => uint) public shares;
    mapping(address => uint) public balances;
    mapping(address => uint) public daiBalances;
    
    address[] public allAddresses;

// ---------------------------------------------------------------------------------------------

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier ifDaiBalanceNeedUpdate() {
        if (daiBalanceAllocated < daiContract.balanceOf(address(this))) _;
    }

// ---------------------------------------------------------------------------------------------

    constructor() public {
        owner = msg.sender;
        // not sure if we should allow this address to be changed
        // because maybe at some point DAI might move to other token standard with some way of transition of tokens
        // but we can deploy new contract if that happens
        daiContract = IERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);    

        setShareForAddress(0xad79cc871f62409A3aB55C390bd34439e4fC1101, 2000);
        setShareForAddress(0x00158A74921620b39E5c3aFE4dca79feb2c2C143, 2000);
        setShareForAddress(0xD9020855796503009540D924EAaa571C24e003eB, 2000);
        setShareForAddress(0x005cE84caA772a1a87607Fa47f9bAfA457980b20, 2000);
        setShareForAddress(0x1955c2b76b1cF245795950e75eB176080879Da50, 2000);
        setShareForAddress(0x4bB9A1E3bA4AEe6F6bb76De1384E7417fd2C9Dc2, 2000);
        setShareForAddress(0x575F0F46C427EE49dC1fE04874e661dB161AC54E, 1800);
        setShareForAddress(0xd408FB6eFAba343A527b64c0f9d1D730d11717F4, 1500);
        setShareForAddress(0x46015322832a58fA12e669a1ABffa4b63251EEe6, 1400);
        setShareForAddress(0x3e5598681E03026d785215adfB3173acF3Cf2B60, 1200);
    }

// ---------------------------------------------------------------------------------------------

    function setNewOwner(address _owner) public onlyOwner {
        // just in case that its sent by accident
        require(_owner != address(0));
        
        owner = _owner;
    }
       
    // should take care that setting shares to 0 will disable possibility to withdraw for that user
    // make sure that specific user doesn't have balance or daiBalance
    // only owner can set shares (set to 0 if you want to remove user)
    function setShareForAddress(address _to, uint _share) public onlyOwner {
        // it will be done only if needed
        // but needs to allocate DAI balance before shares are changed
        updateDaiBalance();

        if (shares[_to] == 0) {
            addAddress(_to);
        }

        totalCompensation = totalCompensation.sub(shares[_to]);
        totalCompensation = totalCompensation.add(_share);
        shares[_to] = _share;

        if (_share == 0) {
            removeAddress(_to);
        }
    }

    function () external payable {
        
        allocateBalance(msg.value, false);
    }

    // only update if DAI contract is added and if it is needed
    function updateDaiBalance() public ifDaiBalanceNeedUpdate {
        uint daiBalance = daiContract.balanceOf(address(this));
        uint toAllocate = daiBalance.sub(daiBalanceAllocated);

        allocateBalance(toAllocate, true);

        daiBalanceAllocated = daiBalance;
    }

    function withdraw() public {
        require(shares[msg.sender] > 0);
        
        // it will be done only if needed
        // but needs to allocate DAI balance before someone withdraws part of it
        updateDaiBalance();
        
        // withdraw ether balance
        uint val = balances[msg.sender];
        balances[msg.sender] = 0;
        if (val > 0) {
            msg.sender.transfer(val);
        }

        // withdraw DAI balance
        val = daiBalances[msg.sender];
        daiBalances[msg.sender] = 0;
        // contracts DAI balance is changing, so we need to change daiBalanceAllocated also
        daiBalanceAllocated -= val;
        if (val > 0) {
           daiContract.transfer(msg.sender, val);
        }
    }

    // bool _new says if token returns bool on transfer method, most tokens are considered as new
    function withdrawOtherTokens(address _tokenAddress, bool _new) public onlyOwner {
        if (_new){
            // current erc20 returns bool if transfer succeeded
            IERC20 token = IERC20(_tokenAddress);
            uint val = token.balanceOf(address(this));

            require(token.transfer(msg.sender, val));
        } else {
            // old erc20 doesn't return bool if it succeeded or not
            IERC20Old token = IERC20Old(_tokenAddress);
            uint val = token.balanceOf(address(this));

            token.transfer(msg.sender, val);
        }
    }
    
    function withdrawEther() public onlyOwner {

        msg.sender.transfer(address(this).balance);
    }

// ---------------------------------------------------------------------------------------------

    function allocateBalance(uint _val, bool _dai) private {
        uint count = allAddresses.length;

        for (uint i=0; i<count; i++) {
            address _adr = allAddresses[i];
            uint part = _val.mul(shares[_adr]).div(totalCompensation);

            if (_dai) {
                daiBalances[_adr] += part;
            } else {
                balances[_adr] += part;
            }
        }
    }  
    
    function addAddress(address _address) private {
        allAddresses.push(_address);
    }

    function removeAddress(address _address) private {
        uint count = allAddresses.length;
        uint pos = count+1;

        for (uint i=0; i<count; i++) {
            if (_address == allAddresses[i]) {
                pos = i;
                break;
            }
        }

        // if count is 0, this will always fail
        require(pos < count);
        
        allAddresses[pos] = allAddresses[count - 1];
        delete allAddresses[count - 1];
        allAddresses.length--;
    }        
}