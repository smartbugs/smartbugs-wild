pragma solidity ^0.4.25;

contract DecentralizationSmartGames{
    using SafeMath for uint256;
    
    string public constant name   = "Decentralization Smart Games";
    string public constant symbol = "DSG";
    uint8 public constant decimals = 18;
    uint256 public constant tokenPrice = 0.00065 ether;
    uint256 public totalSupply; /* Total number of existing DSG tokens */
    uint256 public divPerTokenPool; /* Trigger for calculating dividends on "Pool dividends" program */
    uint256 public divPerTokenGaming; /* Trigger for calculating dividends on "Gaming dividends" program */
    uint256 public developmentBalance; /* Balance that is used to support the project and games development */
    uint256 public charityBalance;  /* Balance that is used for charity */
    address[2] public owners;  /* Addresses of the contract owners */
    address[2] public candidates; /* Addresses of the future contract owners */
    /**Fee public fee - Structure where all percentages of the distribution of incoming funds are stored
     * uint8 fee.r0 - First referrer - 6%
     * uint8 fee.r1 - Second referrer - 4%
     * uint8 fee.r2 - Third referrer - 3%
     * uint8 fee.r3 - Fourth referrer - 2%
     * uint8 fee.r4 - Fifth referrer - 1%
     * uint8 fee.charity - Charity - 1%
     * uint8 fee.development - For game development and project support - 18%
     * uint8 fee.buy - For buying DSG tokens - 65%
     */
    Fee public fee = Fee(6,4,3,2,1,1,18,65);
    /**Dividends public totalDividends - Structure where general dividend payments are kept
     * uint256 totalDividends.referrer - Referrer Dividends
     * uint256 totalDividends.gaming - Gaming Dividends
     * uint256 totalDividends.pool - Pool Dividends
     */
    Dividends public totalDividends  = Dividends(0,0,0);
    mapping (address => mapping (address => uint256)) private allowed;
    /**mapping (address => Account) private account - Investors accounts data
     * uint256 account[address].tokenBalance - Number of DSG tokens on balance
     * uint256 account[address].ethereumBalance - The amount of ETH on balance (dividends)
     * uint256 account[address].lastDivPerTokenPool - The trigger of last dividend payment upon the "Pool dividends" program 
     * uint256 account[address].lastDivPerTokenGaming - The trigger of last dividend payment upon the "Gaming dividends" program
     * uint256 account[address].totalDividendsReferrer - Total amount of dividends upon the "Referrer dividends" program
     * uint256 account[address].totalDividendsGaming - Total amount of dividends upon the "Gaming dividends" program 
     * uint256 account[address].totalDividendsPool -Total amount of dividends upon the "Pool dividends" program
     * address[5] account[address].referrer - Array of all the referrers
     * bool account[address].active - True, if the account is active
     */
    mapping (address => Account) public account;
    mapping (address => bool) public games; /* The list of contracts from which dividends are allowed */
    
    struct Account {
        uint256 tokenBalance;
        uint256 ethereumBalance;
        uint256 lastDivPerTokenPool;
        uint256 lastDivPerTokenGaming;
        uint256 totalDividendsReferrer;
        uint256 totalDividendsGaming;
        uint256 totalDividendsPool;
        address[5] referrer;
        bool active;
    }
    struct Fee{
        uint8 r1;
        uint8 r2;
        uint8 r3;
        uint8 r4;
        uint8 r5;
        uint8 charity;
        uint8 development;
        uint8 buy;
    }
    struct Dividends{
        uint256 referrer;
        uint256 gaming;
        uint256 pool;
    }
    /* Allowed if the address is not 0x */
    modifier check0x(address address0x) {
        require(address0x != address(0), "Address is 0x");
        _;
    }
    /* Allowed if on balance of DSG tokens >= amountDSG */
    modifier checkDSG(uint256 amountDSG) {
        require(account[msg.sender].tokenBalance >= amountDSG, "You don't have enough DSG on balance");
        _;
    }
    /* Allowed if on balance ETH >= amountETH */
    modifier checkETH(uint256 amountETH) {
        require(account[msg.sender].ethereumBalance >= amountETH, "You don't have enough ETH on balance");
        _;
    }
    /* Allowed if the function is called by one the contract owners */
    modifier onlyOwners() {
        require(msg.sender == owners[0] || msg.sender == owners[1], "You are not owner");
        _;
    }
    /* Allowed if the sale is still active */
    modifier sellTime() { 
        require(now <= 1560211200, "The sale is over");
        _;
    }
    /* Dividends upon the "Pool Dividends" program are being paid */
    /* Dividends upon the "Gaming Dividends" program are being paid */
    modifier payDividends(address sender) {
        uint256 poolDividends = getPoolDividends();
        uint256 gamingDividends = getGamingDividends();
		if(poolDividends > 0 && account[sender].active == true){
			account[sender].totalDividendsPool = account[sender].totalDividendsPool.add(poolDividends);
			account[sender].ethereumBalance = account[sender].ethereumBalance.add(poolDividends);
		}
        if(gamingDividends > 0 && account[sender].active == true){
			account[sender].totalDividendsGaming = account[sender].totalDividendsGaming.add(gamingDividends);
			account[sender].ethereumBalance = account[sender].ethereumBalance.add(gamingDividends);
		}
        _;
	    account[sender].lastDivPerTokenPool = divPerTokenPool;
        account[sender].lastDivPerTokenGaming = divPerTokenGaming;
        
    }
    /**We assign two contract owners, whose referrers are from the same address
     * In the same manner we activate their accounts
     */
    constructor(address owner2) public{
        address owner1 = msg.sender;
        owners[0]                = owner1;
        owners[1]                = owner2;
        account[owner1].active   = true;
        account[owner2].active   = true;
        account[owner1].referrer = [owner1, owner1, owner1, owner1, owner1];
        account[owner2].referrer = [owner2, owner2, owner2, owner2, owner2];
    }
    /**buy() - the function of buying DSG tokens.
     * It is active only during the time interval specified in sellTime()
     * Dividends upon Pool Dividends program are being paid
     * Dividends upon the Gaming Dividends program are being paid
     * address referrerAddress - The address of the referrer who invited to the program
     * require - Minimum purchase is 100 DSG or 0.1 ETH
     */
    function buy(address referrerAddress) payDividends(msg.sender) sellTime public payable
    {
        require(msg.value >= 0.1 ether, "Minimum investment is 0.1 ETH");
        uint256 forTokensPurchase = msg.value.mul(fee.buy).div(100); /* 65% */
        uint256 forDevelopment = msg.value.mul(fee.development).div(100); /* 18% */
        uint256 forCharity = msg.value.mul(fee.charity).div(100); /* 1% */
        uint256 tokens = forTokensPurchase.mul(10 ** uint(decimals)).div(tokenPrice); /* The number of DSG tokens is counted (1ETH = 1000 DSG) */
        _setReferrer(referrerAddress, msg.sender);  /* Assigning of referrers */
        _mint(msg.sender, tokens); /* We create new DSG tokens and add to balance */
        _setProjectDividends(forDevelopment, forCharity); /*  ETH is accrued to the project balances (18%, 1%) */
        _distribution(msg.sender, msg.value.mul(fee.r1).div(100), 0); /* Dividends are accrued to the first refferer - 6% */
        _distribution(msg.sender, msg.value.mul(fee.r2).div(100), 1); /* Dividends are accrued to the second refferer - 4% */
        _distribution(msg.sender, msg.value.mul(fee.r3).div(100), 2); /* Dividends are accrued to the third refferer - 3% */
        _distribution(msg.sender, msg.value.mul(fee.r4).div(100), 3); /* Dividends are accrued to the fourth refferer - 2% */
        _distribution(msg.sender, msg.value.mul(fee.r5).div(100), 4); /* Dividends are accrued to the fifth referrer - 1% */
        emit Buy(msg.sender, msg.value, tokens, totalSupply, now);
    }
    /**reinvest() - dividends reinvestment function.
     * It is active only during the time interval specified in sellTime()
     * Dividends upon the Pool Dividends and Gaming Dividends programs are being paid - payDividends(msg.sender)
     * Checking whether the investor has a given amount of ETH in the contract - checkETH(amountEthereum)
     * address amountEthereum - The amount of ETH sent for reinvestment (dividends)
     */
    function reinvest(uint256 amountEthereum) payDividends(msg.sender) checkETH(amountEthereum) sellTime public
    {
        uint256 tokens = amountEthereum.mul(10 ** uint(decimals)).div(tokenPrice); /* The amount of DSG tokens is counted (1ETH = 1000 DSG) */
        _mint(msg.sender, tokens); /* We create DSG tokens and add to the balance */
        account[msg.sender].ethereumBalance = account[msg.sender].ethereumBalance.sub(amountEthereum);/* The amount of ETH from the investor is decreased */
        emit Reinvest(msg.sender, amountEthereum, tokens, totalSupply, now);
    }
    /**reinvest() - dividends reinvestment function.
     * Checking whether there are enough DSG tokens on balance - checkDSG(amountTokens)
     * Dividends upon the Pool Dividends and Gaming Dividends program are being paid - payDividends(msg.sender)
     * address amountEthereum - The amount of ETH sent for reinvestment (dividends)
     * require - Checking whether the investor has a given amount of ETH in the contract
     */
    function sell(uint256 amountTokens) payDividends(msg.sender) checkDSG(amountTokens) public
    {
        uint256 ethereum = amountTokens.mul(tokenPrice).div(10 ** uint(decimals));/* Counting the number of ETH (1000 DSG = 1ETH) */
        account[msg.sender].ethereumBalance = account[msg.sender].ethereumBalance.add(ethereum);
        _burn(msg.sender, amountTokens);/* Tokens are burnt */
        emit Sell(msg.sender, amountTokens, ethereum, totalSupply, now);
    }
    /**withdraw() - the function of ETH withdrawal from the contract
     * Dividends upon the Pool Dividends and Gaming Dividends programs are being paid - payDividends(msg.sender)
     * Checking whether the investor has a given amount of ETH in the contract - checkETH(amountEthereum)
     * address amountEthereum - The amount of ETH requested for withdrawal
     */
    function withdraw(uint256 amountEthereum) payDividends(msg.sender) checkETH(amountEthereum) public
    {
        msg.sender.transfer(amountEthereum); /* ETH is sent */
        account[msg.sender].ethereumBalance = account[msg.sender].ethereumBalance.sub(amountEthereum);/* Decreasing the amount of ETH from the investor */
        emit Withdraw(msg.sender, amountEthereum, now);
    }
    /**gamingDividendsReception() - function that receives and distributes dividends upon the "Gaming Dividends" program
     * require - if the address of the game is not registered in mapping games, the transaction will be declined
     */
    function gamingDividendsReception() payable external{
        require(getGame(msg.sender) == true, "Game not active");
        uint256 eth            = msg.value;
        uint256 forDevelopment = eth.mul(19).div(100); /* To support the project - 19% */
        uint256 forInvesotrs   = eth.mul(80).div(100); /* To all DSG holders - 80% */
        uint256 forCharity     = eth.div(100); /* For charity - 1% */
        _setProjectDividends(forDevelopment, forCharity); /* Dividends for supporting the projects are distributed */
        _setGamingDividends(forInvesotrs); /* Gaming dividends are distributed */
    }
    /**_distribution() - function of dividends distribution upon the "Referrer Dividends" program
     * With a mimimum purchase ranging from 100 to 9999 DSG
     * Only the first level of the referral program is open and a floating percentage is offered, which depends on the amount of investment.
     * Formula - ETH * DSG / 10000 = %
     * ETH   - the amount of Ethereum, which the investor should have received  if the balance had been >= 10000 DSG (6%)
     * DSG   - the amount of tokens on the referrer's balance, which accrues interest
     * 10000 - minimum amount of tokens when all the percentage levels are open
     * - The first level is a floating percentage depending on the amount of holding
     * - The second level - for all upon the "Pool dividends" program
     * - The third level - for all upon the "Pool dividends" program
     * - The fourth level - for all upon the "Pool dividends" program
     * - The fifth level - for all upon the "Pool dividends" program
     * With 10000 DSG on balance and more the entire referral system will be activated and the investor will receive all interest from all levels
     * The function automatically checks the investor's DSG balance at the time of dividends distribution, this that referral
     * program can be fully activated or deactivated automatically depending on the DSG balance at the time of distribution
     * address senderAddress - the address of referral that sends dividends to his referrer
     * uint256 eth - the amount of ETH which referrer should send to the referrer
     * uint8 k - the number of referrer
     */
    function _distribution(address senderAddress, uint256 eth, uint8 k) private{
        address referrer = account[senderAddress].referrer[k];
        uint256 referrerBalance = account[referrer].tokenBalance;
        uint256 senderTokenBalance = account[senderAddress].tokenBalance;
        uint256 minReferrerBalance = 10000e18;
        if(referrerBalance >= minReferrerBalance){
            _setReferrerDividends(referrer, eth);/* The interest is sent to the referrer */
        }
        else if(k == 0 && referrerBalance < minReferrerBalance && referrer != address(0)){
            uint256 forReferrer = eth.mul(referrerBalance).div(minReferrerBalance);/* The floating percentage is counted */
            uint256 forPool = eth.sub(forReferrer);/* Amount for Pool Dividends (all DSG holders) */
            _setReferrerDividends(referrer, forReferrer);/* The referrer is sent his interest */
            _setPoolDividends(forPool, senderTokenBalance);/* Dividends are paid to all the DSG token holders */
        }
        else{
            _setPoolDividends(eth, senderTokenBalance);/* If the refferal is 0x - Dividends are paid to all the DSG token holders */
        }
    }
    /* _setReferrerDividends() - the function which sends referrer his dividends */
    function _setReferrerDividends(address referrer, uint256 eth) private {
        account[referrer].ethereumBalance = account[referrer].ethereumBalance.add(eth);
        account[referrer].totalDividendsReferrer = account[referrer].totalDividendsReferrer.add(eth);
        totalDividends.referrer = totalDividends.referrer.add(eth);
    }
    /**_setReferrer() - the function which assigns referrers to the buyer
     * address referrerAddress - the address of referrer who invited the investor to the project
     * address senderAddress - the buyer's address
     * The function assigns referrers only once when buying tokens
     * Referrers can not be changed
     * require(referrerAddress != senderAddress) - Checks whether the buyer is not a referrer himself
     * require(account[referrerAddress].active == true || referrerAddress == address(0))
     * Checks whether the referrer exists in the project
     */
    function _setReferrer(address referrerAddress, address senderAddress) private
    {
        if(account[senderAddress].active == false){
            require(referrerAddress != senderAddress, "You can't be referrer for yourself");
            require(account[referrerAddress].active == true || referrerAddress == address(0), "Your referrer was not found in the contract");
            account[senderAddress].referrer = [
                                               referrerAddress, /* The referrer who invited the investor */
                                               account[referrerAddress].referrer[0],
                                               account[referrerAddress].referrer[1],
                                               account[referrerAddress].referrer[2],
                                               account[referrerAddress].referrer[3]
                                              ];
            account[senderAddress].active   = true; /* The account is activated */
            emit Referrer(
                senderAddress,
                account[senderAddress].referrer[0],
                account[senderAddress].referrer[1],
                account[senderAddress].referrer[2],
                account[senderAddress].referrer[3],
                account[senderAddress].referrer[4],
                now
            );
        }
    }
    /**setRef_setProjectDividendserrer() - the function of dividends payment to support the project
     * uint256 forDevelopment - To support the project - 18%
     * uint256 forCharity - For charity - 1%
     */
    function _setProjectDividends(uint256 forDevelopment, uint256 forCharity) private{
        developmentBalance = developmentBalance.add(forDevelopment);
        charityBalance = charityBalance.add(forCharity);
    }
    /**_setPoolDividends() - the function of uniform distribution of dividends to all DSG holders upon the "Pool Dividends" program
     * During the distribution of dividends, the amount of tokens that are on the buyer's balance is not taken into account,
     * since he does not participate in the distribution of dividends
     * uint256 amountEthereum - the amount of ETH which should be distributed to all DSG holders
     * uint256 userTokens - the amount of DSG that is on the buyer's balance
     */
    function _setPoolDividends(uint256 amountEthereum, uint256 userTokens) private{
        if(amountEthereum > 0){
		    divPerTokenPool = divPerTokenPool.add(amountEthereum.mul(10 ** uint(decimals)).div(totalSupply.sub(userTokens)));
		    totalDividends.pool = totalDividends.pool.add(amountEthereum);
        }
    }
    /**_setGamingDividends() - the function of uniform distribution of dividends to all DSG holders upon the "Gaming Dividends" program
     * uint256 amountEthereum - the amount of ETH which should be distributed to all DSG holders
     */
    function _setGamingDividends(uint256 amountEthereum) private{
        if(amountEthereum > 0){
		    divPerTokenGaming = divPerTokenGaming.add(amountEthereum.mul(10 ** uint(decimals)).div(totalSupply));
		    totalDividends.gaming = totalDividends.gaming.add(amountEthereum);
        }
    }
    /**setGame() - the function of adding a new address of the game contract, from which you can receive dividends
     * address gameAddress - the address of the game contract
     * bool active - if TRUE, the dividends can be received
     */
    function setGame(address gameAddress, bool active) public onlyOwners returns(bool){
        games[gameAddress] = active;
        return true;
    }
    /**getPoolDividends() - the function of calculating dividends for the investor upon the "Pool Dividends" program
     * returns(uint256) - the amount of ETH that was counted to the investor is returned
     * and which has not been paid to him yet
     */
    function getPoolDividends() public view returns(uint256)
    {
        uint newDividendsPerToken = divPerTokenPool.sub(account[msg.sender].lastDivPerTokenPool);
        return account[msg.sender].tokenBalance.mul(newDividendsPerToken).div(10 ** uint(decimals));
    }
    /**getGameDividends() - the function of calculating dividends for the investor upon the "Gaming Dividends" program
     * returns(uint256) - the amount of ETH that was counted to the investor is returned,
     * and which has not been paid to him yet
     */
    function getGamingDividends() public view returns(uint256)
    {
        uint newDividendsPerToken = divPerTokenGaming.sub(account[msg.sender].lastDivPerTokenGaming);
        return account[msg.sender].tokenBalance.mul(newDividendsPerToken).div(10 ** uint(decimals));
    }
    /* getAccountData() - the function that returns all the data of the investor */
    function getAccountData() public view returns(
        uint256 tokenBalance,
        uint256 ethereumBalance, 
        uint256 lastDivPerTokenPool,
        uint256 lastDivPerTokenGaming,
        uint256 totalDividendsPool,
        uint256 totalDividendsReferrer,
        uint256 totalDividendsGaming,
        address[5] memory referrer,
        bool active)
    {
        return(
            account[msg.sender].tokenBalance,
            account[msg.sender].ethereumBalance,
            account[msg.sender].lastDivPerTokenPool,
            account[msg.sender].lastDivPerTokenGaming,
            account[msg.sender].totalDividendsPool,
            account[msg.sender].totalDividendsReferrer,
            account[msg.sender].totalDividendsGaming,
            account[msg.sender].referrer,
            account[msg.sender].active
        );
    }
    /* getContractBalance() - the function that returns a contract balance */
    function getContractBalance() view public returns (uint256) {
        return address(this).balance;
    }
    /* getGame() - the function that checks whether the game is active or not. If TRUE - the game is active. If FALSE - the game is not active */
    function getGame(address gameAddress) view public returns (bool) {
        return games[gameAddress];
    }
    /* transferOwnership() - the function that assigns the future founder of the contract */
    function transferOwnership(address candidate, uint8 k) check0x(candidate) onlyOwners public
    {
        candidates[k] = candidate;
    }
    /* confirmOwner() - the function that confirms the new founder of the contract and assigns him */
    function confirmOwner(uint8 k) public
    {
        require(msg.sender == candidates[k], "You are not candidate");
        owners[k] = candidates[k];
        delete candidates[k];
    }
    /* charitytWithdraw() - the function of withdrawal for charity */
    function charitytWithdraw(address recipient) onlyOwners check0x(recipient) public
    {
        recipient.transfer(charityBalance);
        delete charityBalance;
    }
    /* developmentWithdraw() - the function of withdrawal for the project support */
    function developmentWithdraw(address recipient) onlyOwners check0x(recipient) public
    {
        recipient.transfer(developmentBalance);
        delete developmentBalance;
    }
    /* balanceOf() - the function that returns the amount of DSG tokens on balance (ERC20 standart) */
    function balanceOf(address owner) public view returns(uint256)
    {
        return account[owner].tokenBalance;
    }
    /* allowance() - the function that checks how much spender can spend tokens of the owner user (ERC20 standart) */
    function allowance(address owner, address spender) public view returns(uint256)
    {
        return allowed[owner][spender];
    }
    /* transferTo() - the function sends DSG tokens to another user (ERC20 standart) */
    function transfer(address to, uint256 value) public returns(bool)
    {
        _transfer(msg.sender, to, value);
        return true;
    }
    /* transferTo() - the function that allows the user to spend n-number of tokens for spender (ERC20 standart) */
    function approve(address spender, uint256 value) check0x(spender) checkDSG(value) public returns(bool)
    {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    /* transferFrom() - the function sends tokens from one address to another, only to the address that gave the permission (ERC20 standart) */
    function transferFrom(address from, address to, uint256 value) public returns(bool)
    {
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, allowed[from][msg.sender]);
        return true;
    }
    /* _transfer() - the function of tokens sending  (ERC20 standart) */
    function _transfer(address from, address to, uint256 value) payDividends(from) payDividends(to) checkDSG(value) check0x(to) private
    {
        account[from].tokenBalance = account[from].tokenBalance.sub(value);
        account[to].tokenBalance = account[to].tokenBalance.add(value);
        if(account[to].active == false) account[to].active = true;
        emit Transfer(from, to, value);
    }
    /* transferFrom() - the function of tokens creating (ERC20 standart) */
    function _mint(address customerAddress, uint256 value) check0x(customerAddress) private
    {
        totalSupply = totalSupply.add(value);
        account[customerAddress].tokenBalance = account[customerAddress].tokenBalance.add(value);
        emit Transfer(address(0), customerAddress, value);
    }
    /* transferFrom() - the function of tokens _burning (ERC20 standart) */
    function _burn(address customerAddress, uint256 value) check0x(customerAddress) private
    {
        totalSupply = totalSupply.sub(value);
        account[customerAddress].tokenBalance = account[customerAddress].tokenBalance.sub(value);
        emit Transfer(customerAddress, address(0), value);
    }
    event Buy(
        address indexed customerAddress,
        uint256 inputEthereum,
        uint256 outputToken,
        uint256 totalSupply,
        uint256 timestamp
    );
    event Sell(
        address indexed customerAddress,
        uint256 amountTokens,
        uint256 outputEthereum,
        uint256 totalSupply,
        uint256 timestamp
    );
    event Reinvest(
        address indexed customerAddress,
        uint256 amountEthereum,
        uint256 outputToken,
        uint256 totalSupply,
        uint256 timestamp
    );
    event Withdraw(
        address indexed customerAddress,
        uint256 indexed amountEthereum,
        uint256 timestamp
    );
    event Referrer(
        address indexed customerAddress,
        address indexed referrer1,
        address referrer2,
        address referrer3,
        address referrer4,
        address referrer5,
        uint256 timestamp
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint tokens
    );
    event Approval(
        address indexed tokenOwner,
        address indexed spender,
        uint tokens
    );
}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {  return 0; }
        uint256 c = a * b;
        require(c / a == b, "Mul error");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Div error");
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Sub error");
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Add error");
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Mod error");
        return a % b;
    }
}