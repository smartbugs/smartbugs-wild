/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20

/// @title Abstract token contract - Functions to be implemented by token contracts.
/// @author Stefan George - <stefan.george@consensys.net>
contract Token {
    // This is not an abstract function, because solc won't recognize generated getter functions for public variables as functions
    function totalSupply() constant returns (uint256 supply) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract SingularDTVToken is Token {
    function issueTokens(address _for, uint tokenCount) returns (bool);
}
contract SingularDTVCrowdfunding {
    function twoYearsPassed() returns (bool);
    function startDate() returns (uint);
    function CROWDFUNDING_PERIOD() returns (uint);
    function TOKEN_TARGET() returns (uint);
    function valuePerShare() returns (uint);
    function fundBalance() returns (uint);
    function campaignEndedSuccessfully() returns (bool);
}


/// @title Fund contract - Implements revenue distribution.
/// @author Stefan George - <stefan.george@consensys.net>
contract SingularDTVFund {

    /*
     *  External contracts
     */
    SingularDTVToken public singularDTVToken;
    SingularDTVCrowdfunding public singularDTVCrowdfunding;

    /*
     *  Storage
     */
    address public owner;
    address constant public workshop = 0xc78310231aA53bD3D0FEA2F8c705C67730929D8f;
    uint public totalRevenue;

    // User's address => Revenue at time of withdraw
    mapping (address => uint) public revenueAtTimeOfWithdraw;

    // User's address => Revenue which can be withdrawn
    mapping (address => uint) public owed;

    /*
     *  Modifiers
     */
    modifier noEther() {
        if (msg.value > 0) {
            throw;
        }
        _
    }

    modifier onlyOwner() {
        // Only guard is allowed to do this action.
        if (msg.sender != owner) {
            throw;
        }
        _
    }

    modifier campaignEndedSuccessfully() {
        if (!singularDTVCrowdfunding.campaignEndedSuccessfully()) {
            throw;
        }
        _
    }

    /*
     *  Contract functions
     */
    /// @dev Deposits revenue. Returns success.
    function depositRevenue()
        external
        campaignEndedSuccessfully
        returns (bool)
    {
        totalRevenue += msg.value;
        return true;
    }

    /// @dev Withdraws revenue for user. Returns revenue.
    /// @param forAddress user's address.
    function calcRevenue(address forAddress) internal returns (uint) {
        return singularDTVToken.balanceOf(forAddress) * (totalRevenue - revenueAtTimeOfWithdraw[forAddress]) / singularDTVToken.totalSupply();
    }

    /// @dev Withdraws revenue for user. Returns revenue.
    function withdrawRevenue()
        external
        noEther
        returns (uint)
    {
        uint value = calcRevenue(msg.sender) + owed[msg.sender];
        revenueAtTimeOfWithdraw[msg.sender] = totalRevenue;
        owed[msg.sender] = 0;
        if (value > 0 && !msg.sender.send(value)) {
            throw;
        }
        return value;
    }

    /// @dev Credits revenue to owed balance.
    /// @param forAddress user's address.
    function softWithdrawRevenueFor(address forAddress)
        external
        noEther
        returns (uint)
    {
        uint value = calcRevenue(forAddress);
        revenueAtTimeOfWithdraw[forAddress] = totalRevenue;
        owed[forAddress] += value;
        return value;
    }

    /// @dev Setup function sets external contracts' addresses.
    /// @param singularDTVTokenAddress Token address.
    function setup(address singularDTVCrowdfundingAddress, address singularDTVTokenAddress)
        external
        noEther
        onlyOwner
        returns (bool)
    {
        if (address(singularDTVCrowdfunding) == 0 && address(singularDTVToken) == 0) {
            singularDTVCrowdfunding = SingularDTVCrowdfunding(singularDTVCrowdfundingAddress);
            singularDTVToken = SingularDTVToken(singularDTVTokenAddress);
            return true;
        }
        return false;
    }

    /// @dev Contract constructor function sets guard address.
    function SingularDTVFund() noEther {
        // Set owner address
        owner = msg.sender;
    }
}