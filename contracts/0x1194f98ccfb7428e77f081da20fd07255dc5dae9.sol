pragma solidity 0.4.15;

contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

contract REMMEPreSale {
    uint public constant SALES_START = 1512399600; // 04.12.2017 15:00:00 UTC
    uint public constant SALES_DEADLINE = 1514214000; // 25.12.2017 15:00:00 UTC
    address public constant ASSET_MANAGER_WALLET = 0xbb12800E7446A51395B2d853D6Ce7F22210Bb5E5;
    address public constant TOKEN = 0x83984d6142934bb535793A82ADB0a46EF0F66B6d; // REMME token
    address public constant WHITELIST_SUPPLIER = 0x1Ff21eCa1c3ba96ed53783aB9C92FfbF77862584;
    uint public constant ETH_PRICE_USD = 470;
    uint public constant TOKEN_PRICE_WEI = 0.04 ether / ETH_PRICE_USD; // 0.000085106382978723 ETH
    uint public constant TOKEN_CENTS = 10000; // 1 REM is 1.0000 REM
    uint public constant BONUS = 20; // 20%
    // 1,000 ETH
    uint public constant PRE_SALE_SOFT_CAP = 1000 ether;
    // 6,700 ETH, 78,725,000 REM + 15,745,000 REM BONUS = 94,470,000 REM
    uint public constant PRE_SALE_MAX_CAP = 6700 ether;
    // 10 ETH
    uint public constant MINIMAL_PARTICIPATION = 10 ether;
    // 1100 ETH
    uint public constant MAXIMAL_PARTICIPATION = 1100 ether;
    uint public preSaleContributions;
    mapping(address => uint) public participantContribution;
    mapping(address => bool) public whitelist;

    event Contributed(address receiver, uint contribution, uint reward);
    event WhitelistUpdated(address participant, bool isWhitelisted);

    function contribute() payable returns(bool) {
        return contributeFor(msg.sender);
    }

    function contributeFor(address _participant) payable returns(bool) {
        require(now >= SALES_START);
        require(now < SALES_DEADLINE);
        require((participantContribution[_participant] + msg.value) >= MINIMAL_PARTICIPATION);
        require((participantContribution[_participant] + msg.value) <= MAXIMAL_PARTICIPATION);
        require((preSaleContributions + msg.value) <= PRE_SALE_MAX_CAP);
        // Only the whitelisted addresses can participate.
        require(whitelist[_participant]);

        // If there is some division reminder, we just collect it too.
        uint tokensAmount = (msg.value * TOKEN_CENTS) / TOKEN_PRICE_WEI;
        require(tokensAmount > 0);
        uint bonusTokens = (tokensAmount * BONUS) / 100;
        uint totalTokens = tokensAmount + bonusTokens;

        require(ERC20(TOKEN).transferFrom(ASSET_MANAGER_WALLET, _participant, totalTokens));
        preSaleContributions += msg.value;
        participantContribution[_participant] += msg.value;
        ASSET_MANAGER_WALLET.transfer(msg.value);

        Contributed(_participant, msg.value, totalTokens);
        return true;
    }

    modifier onlyWhitelistSupplier() {
        require(msg.sender == WHITELIST_SUPPLIER || msg.sender == ASSET_MANAGER_WALLET);
        _;
    }

    function addToWhitelist(address _participant) onlyWhitelistSupplier() returns(bool) {
        if (whitelist[_participant]) {
            return true;
        }
        whitelist[_participant] = true;
        WhitelistUpdated(_participant, true);
        return true;
    }

    function removeFromWhitelist(address _participant) onlyWhitelistSupplier() returns(bool) {
        if (!whitelist[_participant]) {
            return true;
        }
        whitelist[_participant] = false;
        WhitelistUpdated(_participant, false);
        return true;
    }

    function isSoftCapReached() constant returns(bool) {
        return preSaleContributions >= PRE_SALE_SOFT_CAP;
    }

    function () payable {
        contribute();
    }
}