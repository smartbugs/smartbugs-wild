pragma solidity ^0.5.0;


// Safe math
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
    
     //not a SafeMath function
    function max(uint a, uint b) private pure returns (uint) {
        return a > b ? a : b;
    }
    
}


// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// Owned contract
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



/// @title  A test contract to store and exchange Dai, Ether, and test INCH tokens. 
/// @author Decentralized
/// @notice Use the 4 withdrawel and deposit functions in your this contract to short and long ETH. ETH/Dai price is
///         pegged at 300 to 1. INCH burn rate is 1% per deposit
///         Because there is no UI for this contract, KEEP IN MIND THAT ALL VALUES ARE IN MINIMUM DENOMINATIONS
///         IN OTHER WORDS ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AND INPUT AS 10^-18 * THE BASE UNIT OF CURRENCY
///         Other warnings: This is a test contract. Do not risk any significant value. You are not guaranteed a 
///         refund, even if it's my fault. Do not send any tokens or assets directly to the contract. 
///         DO NOT SEND ANY TOKENS OR ASSETS DIRECTLY TO THE CONTRACT. Use only the withdrawel and deposit functions
/// @dev    Addresses and 'deployership' must be initialized before use. INCH must be deposited in contract
///         Ownership will be set to 0x0 after initialization
contract VaultPOC is Owned {
    using SafeMath for uint;

    uint public constant initialSupply = 1000000000000000000000;

    uint public constant etherPeg = 300;
    uint8 public constant burnRate = 1;
    
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    ERC20Interface inchWormContract;
    ERC20Interface daiContract;
    address deployer; //retains ability to transfer mistaken ERC20s after ownership is revoked
    
    //____________________________________________________________________________________
    // Inititialization functions
    
    /// @notice Sets the address for the INCH and Dai tokens, as well as the deployer
    function initialize(address _inchwormAddress, address _daiAddress) external onlyOwner {
        inchWormContract = ERC20Interface(_inchwormAddress);
        daiContract = ERC20Interface(_daiAddress);
        deployer = owner;
    }

    //____________________________________________________________________________________
    
    
    
    
    //____________________________________________________________________________________
    // Deposit and withdrawel functions


    /* @notice Make a deposit by including payment in function call
               Wei deposited will be rewarded with INCH tokens. Exchange rate changes over time
               Call will fail with insufficient Wei balance from sender or INCH balance in vault
               ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AND INPUT AS 10^-18 * THE BASE UNIT OF CURRENCY
       @dev    Function will fail if totalSupply < 0.01 * initialSupply.To be fixed 
               Exchange rate is 1 Wei : 300 * totalSupply/initialSupply *10**-18
    */
    function depositWeiForInch() external payable {
        uint _percentOfInchRemaining = inchWormContract.totalSupply().mul(100).div(initialSupply);
        uint _tokensToWithdraw = msg.value.mul(etherPeg);
        _tokensToWithdraw = _tokensToWithdraw.mul(_percentOfInchRemaining).div(100);
        inchWormContract.transfer(msg.sender, _tokensToWithdraw);
    }
    
     /* @param  Dai to deposit in contract, denomination 1*10**-18 Dai
        @notice Dai deposited will be rewarded with INCH tokens. Exchange rate changes over time
                Call will fail with insufficient Dai balance from sender or INCH balance in vault
                ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AND INPUT AS 10^-18 * THE BASE UNIT OF CURRENCY
        @dev    Exchange rate is 1*10**-18 Dai : totalSupply/initialSupply
    */
    function depositDaiForInch(uint _daiToDeposit) external {
        uint _percentOfInchRemaining = inchWormContract.totalSupply().mul(100).div(initialSupply);
        uint _tokensToWithdraw = _daiToDeposit.mul(_percentOfInchRemaining).div(100);
        
        inchWormContract.transfer(msg.sender, _tokensToWithdraw);
        daiContract.transferFrom(msg.sender, address(this), _daiToDeposit);
    }
    
    /* @param  Wei to withdraw from contract
       @notice INCH must be deposited in exchange for the withdrawel. Exchange rate changes over time
               Call will fail with insufficient INCH balance from sender or insufficient Wei balance in the vault
               1% of INCH deposited is burned
               ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AND INPUT AS 10^-18 * THE BASE UNIT OF CURRENCY
       @dev    Exchange rate is 1 Wei : 300 * totalSupply/initialSupply *10**-18
    */
    function withdrawWei(uint _weiToWithdraw) external {
        uint _inchToDeposit = _weiToWithdraw.mul(etherPeg).mul((initialSupply.div(inchWormContract.totalSupply())));
        inchWormContract.transferFrom(msg.sender, address(this), _inchToDeposit); 
        uint _inchToBurn = _inchToDeposit.mul(burnRate).div(100);
        inchWormContract.transfer(address(0), _inchToBurn);
        msg.sender.transfer(1 wei * _weiToWithdraw);
    }
    
    /* @param  Dai to withdraw from contract, denomination 1*10**-18 Dai
       @notice INCH must be deposited in exchange for the withdrawel. Exchange rate changes over time
               Call will fail with insufficient INCH balance from sender or insufficient Dai balance in the vault
               1% of INCH deposited is burned
               ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AND INPUT AS 10^-18 * THE BASE UNIT OF CURRENCY
       @dev    Exchange rate is 1*10**-18 Dai : totalSupply/initialSupply
    */
    function withdrawDai(uint _daiToWithdraw) external {
        uint _inchToDeposit = _daiToWithdraw.mul(initialSupply.div(inchWormContract.totalSupply()));
        inchWormContract.transferFrom(msg.sender, address(this), _inchToDeposit); 
        uint _inchToBurn = _inchToDeposit.mul(burnRate).div(100);
        inchWormContract.transfer(address(0), _inchToBurn);
        daiContract.transfer(msg.sender, _daiToWithdraw); 
    }
    
    //____________________________________________________________________________________
    
    
    
    
    //____________________________________________________________________________________
    // view functions
    
    /// @notice Returns the number of INCH recieved per Dai, 
    ///         ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AS 10^-18 * THE BASE UNIT OF CURRENCY
    function getInchDaiRate() public view returns(uint) {
        return initialSupply.div(inchWormContract.totalSupply());
    }
    
    /// @notice Returns the number of INCH recieved per Eth
    ///         ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AS 10^-18 * THE BASE UNIT OF CURRENCY
    function getInchEthRate() public view returns(uint) {
        etherPeg.mul((initialSupply.div(inchWormContract.totalSupply())));
    }
    
    /// @notice Returns the Wei balance of the vault contract
    ///         ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AS 10^-18 * THE BASE UNIT OF CURRENCY
    function getEthBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    /// @notice Returns the INCH balance of the vault contract
    ///         ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AS 10^-18 * THE BASE UNIT OF CURRENCY
    function getInchBalance() public view returns(uint) {
        return inchWormContract.balanceOf(address(this));
    }
    
    /// @notice Returns the Dai balance of the vault contract
    ///         ALL TOKENS UNCLUDING ETHER ARE DISPLAYED AS 10^-18 * THE BASE UNIT OF CURRENCY
    function getDaiBalance() public view returns(uint) {
        return daiContract.balanceOf(address(this));
    }
    
    /// @notice Returns the percent of INCH that has not been burned (sent to 0X0)
    /// @dev    Implicitly floors the result
    ///         INCH sent to burn addresses other than 0x0 are not currently included in calculation
    function getPercentOfInchRemaining() external view returns(uint) {
       return inchWormContract.totalSupply().mul(100).div(initialSupply);
    }
    
    //____________________________________________________________________________________



    //____________________________________________________________________________________
    // emergency and fallback functions
    
    /// @notice original deployer can transfer out tokens other than Dai and INCH
    function transferAccidentalERC20Tokens(address tokenAddress, uint tokens) external returns (bool success) {
        require(msg.sender == deployer);
        require(tokenAddress != address(inchWormContract));
        require(tokenAddress != address(daiContract));
        
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
    
    // fallback function
    function () external payable {
        revert();
    }
    
    //____________________________________________________________________________________
    
}