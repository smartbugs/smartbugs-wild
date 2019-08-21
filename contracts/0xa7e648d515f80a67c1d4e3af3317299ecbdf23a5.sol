pragma solidity 0.4.24;

interface Token {
    function mint(address to, uint256 value) external returns (bool);
}

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original owner of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Investing is Ownable {
    using SafeMath for uint;
    Token public token;
    address public trust;
    address[] public investors;

    struct Investor {
        address investor;
        string currency;
        uint rate;
        uint amount;
        bool redeemed;
        uint timestamp;
		uint tokens;
    }

    mapping(address => Investor[]) public investments;
    mapping(address => uint) public investmentsCount;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyTrust() {
        require(msg.sender == trust);
        _;
    }

    function makeInvestment(address _investor, string _currency, uint _rate, uint _amount) onlyTrust public returns (bool){
        uint numberOfTokens;
        numberOfTokens = _amount.div(_rate);
        uint _counter = investments[_investor].push(Investor(_investor, _currency, _rate, _amount, false, now, numberOfTokens));
        investmentsCount[_investor] = _counter;
        require(token.mint(_investor, numberOfTokens));
        investors.push(_investor);
        return true;
    }

    function redeem(address _investor, uint _index) public onlyTrust returns (bool) {
        require(investments[_investor][_index].redeemed == false);
        investments[_investor][_index].redeemed = true;
        return true;
    }

    function setTokenContractsAddress(address _tokenContract) public onlyOwner {
        require(_tokenContract != address(0));
        token = Token(_tokenContract);
    }

    function setTrustAddress(address _trust) public onlyOwner {
        require(_trust != address(0));
        trust = _trust;
    }

    function returnInvestors() public view returns (address[]) {
        return investors;
    }
    
    function getInvestmentsCounter(address _investor) public view returns(uint) {
        return investmentsCount[_investor];
    }
    
    function getInvestor(address _investor, uint _index) public view returns(string, uint, uint, bool, uint, uint) {
        return (
            investments[_investor][_index].currency,
            investments[_investor][_index].rate,
            investments[_investor][_index].amount,
            investments[_investor][_index].redeemed,
            investments[_investor][_index].timestamp,
            investments[_investor][_index].tokens
        );
    }
    

    function isRedeemed(address _investor, uint _index) public view returns(bool) {
        return investments[_investor][_index].redeemed;
    }
}