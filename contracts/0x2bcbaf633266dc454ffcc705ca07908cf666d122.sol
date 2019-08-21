pragma solidity ^0.4.24;

contract I4D_Contract{
    using SafeMath for uint256;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Attributes set.
    string public name = "I4D";
    uint256 public tokenPrice = 0.01 ether;
    uint256 public mintax = 0.003 ether; // about 1 USD
    uint16[3] public Gate = [10, 100, 1000];
    uint8[4] public commissionRate = [1, 2, 3, 4];
    uint256 public newPlayerFee=0.1 ether;
    bytes32 internal SuperAdmin_id = 0x0eac2ad3c8c41367ba898b18b9f85aab3adac98f5dfc76fafe967280f62987b4;
    
    ///////////////////////////////////////////////////////////////////////////////
    // Data stored.
    uint256 internal administratorETH;
    uint256 public totalTokenSupply;
    uint256 internal DivsSeriesSum;
    mapping(bytes32 => bool) public administrators;  // type of byte32, keccak256 of address
    mapping(address=>uint256) public tokenBalance;
    mapping(address=>address) public highlevel;
    mapping(address=>address) public rightbrother;
    mapping(address=>address) public leftchild;
    mapping(address=>uint256) public deltaDivsSum;
    mapping(address=>uint256) public commission;
    mapping(address=>uint256) public withdrawETH;
    

    constructor() public{
        administrators[SuperAdmin_id] = true;
        
    }


    ///////////////////////////////////////////////////////////////////////////////
    // modifier and Events
    modifier onlyAdmin(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(_customerAddress)]);
        _;
    }
    modifier onlyTokenholders() {
        require(tokenBalance[msg.sender] > 0);
        _;
    }
    
    event onEthSell(
        address indexed customerAddress,
        uint256 ethereumEarned
    );
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
    event testOutput(
        uint256 ret
    );
    event taxOutput(
        uint256 tax,
        uint256 sumoftax
    );
    
    
    ///////////////////////////////////////////////////////////////////////////////
    //Administrator api
    function withdrawAdministratorETH(uint256 amount)
        public
        onlyAdmin()
    {
        address administrator = msg.sender;
        require(amount<=administratorETH,"Too much");
        administratorETH = administratorETH.sub(amount);
        administrator.transfer(amount);
    }
    
    function getAdministratorETH()
        public
        onlyAdmin()
        view
        returns(uint256)
    {
        return administratorETH;
    }
    
    /** add Adimin here
     * you can not change status of  super administrator.
     */
    function setAdministrator(bytes32 _identifier, bool _status)
        onlyAdmin()
        public
    {
        require(_identifier!=SuperAdmin_id);
        administrators[_identifier] = _status;
    }
    
    
    function setName(string _name)
        onlyAdmin()
        public
    {
        name = _name;
    }
    
    /////////////////////////////////////////////////////////////////////////////
    function setTokenValue(uint256 _value)
        onlyAdmin()
        public
    {
        // we may increase our token price.
        require(_value > tokenPrice);
        tokenPrice = _value;
    }
    
    ///////////////////////////////////////////////////////////////////////////////
    // Player api.
    
    /** 
     * api of buy tokens.
     */
    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        PurchaseTokens(msg.value, _referredBy);
    }
    
    /**
     * reinvest your profits to puchase more tokens.
     */
    function reinvest(uint256 reinvestAmount)
    onlyTokenholders()
    public
    {
        require(reinvestAmount>=1,"At least 1 Token!");
        address _customerAddress = msg.sender;
        require(getReinvestableTokenAmount(_customerAddress)>=reinvestAmount,"You DO NOT have enough ETH!");
        withdrawETH[_customerAddress] = withdrawETH[_customerAddress].add(reinvestAmount*tokenPrice);
        uint256 tokens = PurchaseTokens(reinvestAmount.mul(tokenPrice), highlevel[_customerAddress]);
        
        ///////////////////
        emit onReinvestment(_customerAddress,tokens*tokenPrice,tokens);
    }
    
    /**
     * withdraw the profits(include commissions and divs).
     */
    function withdraw(uint256 _amountOfEths)
    public
    onlyTokenholders()
    {
        address _customerAddress=msg.sender;
        uint256 eth_all = getWithdrawableETH(_customerAddress);
        require(eth_all >= _amountOfEths);
        withdrawETH[_customerAddress] = withdrawETH[_customerAddress].add(_amountOfEths);
        _customerAddress.transfer(_amountOfEths);
        emit onEthSell(_customerAddress,_amountOfEths);
        
        //sell logic here
    }
    
    // some view functions to get your information.
    function getMaxLevel(address _customerAddress, uint16 cur_level)
    public
    view
    returns(uint32)
    {
        address children = leftchild[_customerAddress];
        uint32 maxlvl = cur_level;
        while(children!=0x0000000000000000000000000000000000000000){
            uint32 child_lvl = getMaxLevel(children, cur_level+1);
            if(maxlvl < child_lvl){
                maxlvl = child_lvl;
            }
            children = rightbrother[children];
        }
        return maxlvl;
    }
    
    function getTotalNodeCount(address _customerAddress)
    public
    view
    returns(uint32)
    {
        uint32 ctr=1;
        address children = leftchild[_customerAddress];
        while(children!=0x0000000000000000000000000000000000000000){
            ctr += getTotalNodeCount(children);
            children = rightbrother[children];
        }
        return ctr;
    }
    
    function getMaxProfitAndtoken(address[] playerList)
    public
    view
    returns(uint256[],uint256[],address[])
    {
        uint256 len=playerList.length;
        uint256 i;
        uint256 Profit;
        uint256 token;
        address hl;
        uint[] memory ProfitList=new uint[](len);
        uint[] memory tokenList=new uint[](len);
        address[] memory highlevelList=new address[](len);
        for(i=0;i<len;i++)
        {
            Profit=getTotalProfit(playerList[i]);
            token=tokenBalance[playerList[i]];
            hl=highlevel[playerList[i]];
            ProfitList[i]=Profit;
            tokenList[i]=token;
            highlevelList[i]=hl;
        }
        return (ProfitList,tokenList,highlevelList);
    }
    function getReinvestableTokenAmount(address _customerAddress)
    public
    view
    returns(uint256)
    {
        return getWithdrawableETH(_customerAddress).div(tokenPrice);
    }
    
    /**
     * Total profit = your withdrawable ETH + ETHs you have withdrew.
     */
    function getTotalProfit(address _customerAddress)
    public
    view
    returns(uint256)
    {
        return commission[_customerAddress].add(DivsSeriesSum.sub(deltaDivsSum[_customerAddress]).mul(tokenBalance[_customerAddress])/10*3);
    }
    
    function getWithdrawableETH(address _customerAddress)
    public
    view
    returns(uint256)
    {
        uint256 divs = DivsSeriesSum.sub(deltaDivsSum[_customerAddress]).mul(tokenBalance[_customerAddress])/10*3;
        return commission[_customerAddress].add(divs).sub(withdrawETH[_customerAddress]);
    }
    
    function getTokenBalance()
    public
    view
    returns(uint256)
    {
    address _address = msg.sender;
    return tokenBalance[_address];
    }
    
    function getContractBalance()public view returns (uint) {
        return address(this).balance;
    }  
    
    /**
     * get your commission rate by your token held.
     */
    function getCommissionRate(address _customerAddress)
    public
    view
    returns(uint8)
    {
        if(tokenBalance[_customerAddress]<1){
            return 0;
        }
        uint8 i;
        for(i=0; i<Gate.length; i++){
            if(tokenBalance[_customerAddress]<Gate[i]){
                break;
            }
        }
        return commissionRate[i];
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////
    // functions to calculate commissions and divs when someone purchase some tokens.
    
    /**
     * api for buying tokens.
     */
    function PurchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns(uint256)
    {   
        /////////////////////////////////
        address _customerAddress=msg.sender;
        uint256 numOfToken;
        require(_referredBy==0x0000000000000000000000000000000000000000 || tokenBalance[_referredBy] > 0);
        if(tokenBalance[_customerAddress] > 0)
        {
            require(_incomingEthereum >= tokenPrice,"ETH is NOT enough");
            require(_incomingEthereum % tokenPrice ==0);
            require(highlevel[_customerAddress] == _referredBy);
            numOfToken = ETH2Tokens(_incomingEthereum);
        }
        else
        {
            //New player without a inviter will be taxed for newPlayerFee, and this value can be changed by administrator
            if(_referredBy==0x0000000000000000000000000000000000000000 || _referredBy==_customerAddress)
            {
                require(_incomingEthereum >= newPlayerFee+tokenPrice,"ETH is NOT enough");
                require((_incomingEthereum-newPlayerFee) % tokenPrice ==0);
                _incomingEthereum -= newPlayerFee;
                numOfToken = ETH2Tokens(_incomingEthereum);
                highlevel[_customerAddress] = 0x0000000000000000000000000000000000000000;
                administratorETH = administratorETH.add(newPlayerFee);
            }
            else
            {
                // new player with invite address.
                require(_incomingEthereum >= tokenPrice,"ETH is NOT enough");
                require(_incomingEthereum % tokenPrice ==0);
                numOfToken = ETH2Tokens(_incomingEthereum);
                highlevel[_customerAddress] = _referredBy;
                addMember(_referredBy,_customerAddress);
            }
            commission[_customerAddress] = 0;
        }
        calDivs(_customerAddress,numOfToken);
        calCommission(_incomingEthereum,_customerAddress);
        emit onTokenPurchase(_customerAddress,_incomingEthereum,numOfToken,_referredBy); 
        return numOfToken;
        
    }
    
    /**
     * Calculate the dividends of the members hold tokens.
     * There are two methods to calculate the dividends.
     * We chose the second method for you that you can get more divs.
     */
    function calDivs(address customer,uint256 num)
    internal
    {
        // Approach 1.
        // Use harmonic series to cal player divs. This is a precise algorithm.
        // Approach 2.
        // Simplify the "for loop" of approach 1.
        // You can get more divs than approach 1 when you buy more than 1 token at one time.
        // cal average to avoid overflow.
        uint256 average_before = deltaDivsSum[customer].mul(tokenBalance[customer]) / tokenBalance[customer].add(num);
        uint256 average_delta = DivsSeriesSum.mul(num) / (num + tokenBalance[customer]);
        deltaDivsSum[customer] = average_before.add(average_delta);
        DivsSeriesSum = DivsSeriesSum.add(tokenPrice.mul(num) / totalTokenSupply.add(num));
        totalTokenSupply += num;
        tokenBalance[customer] = num.add(tokenBalance[customer]);
    }
    
    /**
     * Calculate the commissions of your inviters.
     */
    function calCommission(uint256 _incomingEthereum,address _customerAddress)
        internal 
        returns(uint256)
    {
        address _highlevel=highlevel[_customerAddress];
        uint256 tax;
        uint256 sumOftax=0;
        uint8 i=0;
        uint256 tax_chain=_incomingEthereum;
        uint256 globalfee = _incomingEthereum.mul(3).div(10);
        // The maximum deepth of tree you can get commission is 14. You can never get any eth from your children of more than 15 lvl.
        for(i=1; i<=14; i++)
        {
            if(_highlevel==0x0000000000000000000000000000000000000000 || tokenBalance[_highlevel]==0){
                break;
            }
            uint8 com_rate = getCommissionRate(_highlevel);
            tax_chain = tax_chain.mul(com_rate).div(10);
            if(tokenBalance[_highlevel]>=Gate[2]){
                tax=mul_float_power(_incomingEthereum, i, com_rate, 10);
            }
            else{
                tax=tax_chain;
            }

            // The minimum deepth of tree you can get commission is 2.
            // If the deepth is higher than 2 and the tax is lower than mintax, you can never get any commission.
            if(i>2 && tax <= mintax){
                break;
            }
            commission[_highlevel] = commission[_highlevel].add(tax);
            sumOftax = sumOftax.add(tax);
            _highlevel = highlevel[_highlevel];
            emit taxOutput(tax,sumOftax);
        }
        
        if(sumOftax.add(globalfee) < _incomingEthereum)
        {
            administratorETH = _incomingEthereum.sub(sumOftax).sub(globalfee).add(administratorETH);
        }
        
    }
    
    /**
     * New player with inviter should add member to the group tree.
     */
    function addMember(address _referredBy,address _customer)
    internal
    {
        require(tokenBalance[_referredBy] > 0);
        if(leftchild[_referredBy]!=0x0000000000000000000000000000000000000000)
        {
            rightbrother[_customer] = leftchild[_referredBy];
        }
        leftchild[_referredBy] = _customer;
    }
    
    function ETH2Tokens(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        return _ethereum.div(tokenPrice);
    }
    
    function Tokens2ETH(uint256 _tokens)
        internal
        view
        returns(uint256)
    {
        return _tokens.mul(tokenPrice);
    }
    
    /**
     * Calculate x  *  (numerator / denominator) ** n
     * Use "For Loop" to avoid overflow.
     */
    function mul_float_power(uint256 x, uint8 n, uint8 numerator, uint8 denominator)
        internal
        pure
        returns(uint256)
    {
        uint256 ret = x;
        if(x==0 || numerator==0){
            return 0;
        }
        for(uint8 i=0; i<n; i++){
            ret = ret.mul(numerator).div(denominator);
        }
        return ret;

    }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}