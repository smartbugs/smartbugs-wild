pragma solidity ^0.5.2;

library SafeMath {
    //uint256
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Manager is Ownable {
    
    address[] managers;

    modifier onlyManagers() {
        bool exist = false;
        uint index = 0;
        (exist, index) = existManager(msg.sender);
        if(owner == msg.sender)
            exist = true;
        require(exist);
        _;
    }
    
    function getManagers() public view returns (address[] memory){
        return managers;
    }
    
    function existManager(address _to) private returns (bool, uint) {
        for (uint i = 0 ; i < managers.length; i++) {
            if (managers[i] == _to) {
                return (true, i);
            }
        }
        return (false, 0);
    }
    function addManager(address _to) onlyOwner public {
        bool exist = false;
        uint index = 0;
        (exist, index) = existManager(_to);
        
        require(!exist);
        
        managers.push(_to);
    }

}

contract Pausable is Manager {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyManagers whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyManagers whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract Withdrawable is Manager {
    event PauseWithdraw();
    event UnpauseWithdraw();

    bool withdrawable = true;

    function pauseWithdraw() onlyManagers public {
        withdrawable = false;
        emit PauseWithdraw();
    }

    function unpauseWithdraw() onlyManagers public {
        withdrawable = true;
        emit UnpauseWithdraw();
    }
    
    function isWithdrawable() public view returns (bool)  {
        return withdrawable;
    }
}

interface ERC20 {
    function transfer(address _to, uint256 _value) external;
}

contract SaleRecord {
    
    using SafeMath for uint256;

    struct sProperty {
        uint256 time;
        uint256 inputEther;
        uint256 outputToken;
        uint256 priceToken;
        bool withdraw;
    }
    
    sProperty propertyTotal;

    mapping (address => sProperty[]) propertyMember;
    address payable[] propertyKeys;
    
    function recordPropertyWithdraw(address _sender, uint256 _token) internal {
        for(uint256 i = 0; i < propertyMember[_sender].length; i++){
            if(propertyMember[_sender][i].withdraw == false && propertyMember[_sender][i].outputToken == _token){
                propertyMember[_sender][i].withdraw = true;
                break;
            }
        }
    }
    function recordProperty(address payable _sender, uint256 _amount, uint256 _token, uint256 _priceToken, bool _withdraw) internal {
        
        sProperty memory property = sProperty(now, _amount, _token, _priceToken, _withdraw);
        propertyMember[_sender].push(property);
        
        propertyTotal.time = now;
        propertyTotal.inputEther = propertyTotal.inputEther.add(_amount);
        propertyTotal.outputToken = propertyTotal.outputToken.add(_token);
        if (!contains(_sender)) {
            propertyKeys.push(_sender);
        }
    }
    function contains(address _addr) internal view returns (bool) {
        uint256 len = propertyKeys.length;
        for (uint256 i = 0 ; i < len; i++) {
            if (propertyKeys[i] == _addr) {
                return true;
            }
        }
        return false;
    }
    
    //get
    function getPropertyKeyCount() public view returns (uint){
        return propertyKeys.length;
    }
    function getPropertyInfo(address _addr) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory){
        uint256[] memory time;
        uint256[] memory inputEther;
        uint256[] memory outputToken;
        uint256[] memory priceToken;
        bool[] memory withdraw;
        
        if(contains(_addr)){
            
            uint256 size = propertyMember[_addr].length;
            
            time = new uint256[](size);
            inputEther = new uint256[](size);
            outputToken = new uint256[](size);
            priceToken = new uint256[](size);
            withdraw = new bool[](size);
            
            for (uint i = 0 ; i < size ; i++) {
                time[i] = propertyMember[_addr][i].time;
                inputEther[i] = propertyMember[_addr][i].inputEther;
                outputToken[i] = propertyMember[_addr][i].outputToken;
                priceToken[i] = propertyMember[_addr][i].priceToken;
                withdraw[i] = propertyMember[_addr][i].withdraw;
            }
        } else {
            time = new uint256[](0);
            inputEther = new uint256[](0);
            outputToken = new uint256[](0);
            priceToken = new uint256[](0);
            withdraw = new bool[](0);
        }
        return (time, inputEther, outputToken, priceToken, withdraw);
        
    }
    function getPropertyValue(address _addr) public view returns (uint256, uint256){
        uint256 inputEther = 0;
        uint256 outputToken = 0;
        
        if(contains(_addr)){
            
            uint256 size = propertyMember[_addr].length;

            for (uint i = 0 ; i < size ; i++) {
                inputEther = inputEther.add(propertyMember[_addr][i].inputEther);
                outputToken = outputToken.add(propertyMember[_addr][i].outputToken);
            }
        } 
        
        return (inputEther, outputToken);
        
    }
    
    function getPropertyTotal() public view returns (uint256, uint256, uint256){
        return (propertyTotal.time, propertyTotal.inputEther, propertyTotal.outputToken);
    }
    
}

contract PageViewRecord is SaleRecord, Pausable {
    
    using SafeMath for uint256;
    
    uint16 itemCount = 100;
    
    function setPage(uint16 _itemCount) public onlyManagers {
        itemCount = _itemCount;
    }
    
    //get
    function getPageValueCount() public view returns (uint256) {
        uint256 userSize = propertyKeys.length;
        uint256 pageCount = userSize.div(itemCount);
        if((userSize.sub(pageCount.mul(itemCount))) > 0) {
            pageCount++;
        }
        return pageCount;
    }
    function getPageItemValue(uint256 _pageIndex) public view returns (address[] memory, uint256[] memory, uint256[] memory){
        require(getPageValueCount()> _pageIndex);
        
        uint256 startIndex =_pageIndex.mul(itemCount);
        uint256 remain = propertyKeys.length - startIndex;
        uint256 loopCount = (remain >= itemCount) ? itemCount : remain;
        
        address[] memory keys = new address[](loopCount);
        uint256[] memory inputEther = new uint256[](loopCount);
        uint256[] memory outputToken = new uint256[](loopCount);

        for (uint256 i = 0 ; i < loopCount ; i++) {
            uint256 index = startIndex + i;
            address key = propertyKeys[index];
            keys[i] = key;
            
            uint256 size = propertyMember[keys[i]].length;
            for (uint256 k = 0 ; k < size ; k++) {
                inputEther[i] = inputEther[i].add(propertyMember[key][k].inputEther);
                outputToken[i] = outputToken[i].add(propertyMember[key][k].outputToken);
            }

        }
        
        return (keys, inputEther, outputToken);
    }
    
    function getPageInfoCount() public view returns (uint256) {
        uint256 infoSize = 0;
        for (uint256 i = 0 ; i < propertyKeys.length ; i++) {
            infoSize = infoSize.add(propertyMember[propertyKeys[i]].length);
        }

        uint256 pageCount = infoSize.div(itemCount);
        if((infoSize.sub(pageCount.mul(itemCount))) > 0) {
            pageCount++;
        }
        return pageCount;
    }
    function getPageItemInfo(uint256 _pageIndex) public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
        require(getPageInfoCount()> _pageIndex);
        
        uint256 infoSize = 0;
        for (uint256 i = 0 ; i < propertyKeys.length ; i++) {
            infoSize = infoSize.add(propertyMember[propertyKeys[i]].length);
        }
        
        uint256 startIndex =_pageIndex.mul(itemCount);
        uint256 remain = infoSize - startIndex;
        uint256 loopCount = (remain >= itemCount) ? itemCount : remain;
        
        address[] memory keys = new address[](loopCount);
        uint256[] memory time = new uint256[](loopCount);
        uint256[] memory inputEther = new uint256[](loopCount);
        uint256[] memory outputToken = new uint256[](loopCount);
        
        uint256 loopIndex = 0;
        uint256 index = 0;
        for (uint256 i = 0 ; i < propertyKeys.length && loopIndex < loopCount; i++) {

            address key = propertyKeys[i];
            
            for (uint256 k = 0 ; k < propertyMember[key].length && loopIndex < loopCount ; k++) {
                if(index >=startIndex){
                    keys[loopIndex] = key;
                    time[loopIndex]        = propertyMember[key][k].time;
                    inputEther[loopIndex]  = propertyMember[key][k].inputEther;
                    outputToken[loopIndex] = propertyMember[key][k].outputToken;
                    loopIndex++;
                } else {
                    index++;
                }
            }

        }
        
        return (keys, time, inputEther, outputToken);
    }
    
    function getPageNotWithdrawCount() public view returns (uint256) {
        uint256 infoSize = 0;
        for (uint256 i = 0 ; i < propertyKeys.length ; i++) {
            for (uint256 j = 0 ; j < propertyMember[propertyKeys[i]].length ; j++) {
                if(!propertyMember[propertyKeys[i]][j].withdraw)
                    infoSize++;
            }
        }

        uint256 pageCount = infoSize.div(itemCount);
        if((infoSize.sub(pageCount.mul(itemCount))) > 0) {
            pageCount++;
        }
        return pageCount;
    }
    function getPageNotWithdrawInfo(uint256 _pageIndex) public view returns (address[] memory, uint256[] memory, uint256[] memory, uint256[] memory){
        require(getPageInfoCount()> _pageIndex);
        
        uint256 infoSize = 0;
        for (uint256 i = 0 ; i < propertyKeys.length ; i++) {
            for (uint256 j = 0 ; j < propertyMember[propertyKeys[i]].length ; j++) {
                if(!propertyMember[propertyKeys[i]][j].withdraw)
                    infoSize++;
            }
        }
        
        uint256 startIndex =_pageIndex.mul(itemCount);
        uint256 remain = infoSize - startIndex;
        uint256 loopCount = (remain >= itemCount) ? itemCount : remain;
        
        address[] memory keys = new address[](loopCount);
        uint256[] memory time = new uint256[](loopCount);
        uint256[] memory inputEther = new uint256[](loopCount);
        uint256[] memory outputToken = new uint256[](loopCount);
        
        uint256 loopIndex = 0;
        uint256 index = 0;
        for (uint256 i = 0 ; i < propertyKeys.length && loopIndex < loopCount; i++) {

            address key = propertyKeys[i];
            
            for (uint256 k = 0 ; k < propertyMember[key].length && loopIndex < loopCount ; k++) {
                if(propertyMember[key][k].withdraw)
                    continue;
                if(index >=startIndex){
                    keys[loopIndex] = key;
                    time[loopIndex]        = propertyMember[key][k].time;
                    inputEther[loopIndex]  = propertyMember[key][k].inputEther;
                    outputToken[loopIndex] = propertyMember[key][k].outputToken;
                    loopIndex++;
                } else {
                    index++;
                }
            }

        }
        
        return (keys, time, inputEther, outputToken);
    }

}

contract HenaSale is PageViewRecord, Withdrawable {
    
    using SafeMath for uint256;
    
    
    //wallet(eth)
    address payable walletETH;
    
    //token
    address tokenAddress;
    uint8 tokenDecimal = 18;
    
    uint256 oneEther = 1 * 10 ** uint(18);
    uint256 oneToken = 1 * 10 ** uint(tokenDecimal);
  
    //price
    //(usd decimal 5)
    uint256[] priceTokenUSD;// = {15000, 16000, 17000, 18000};
    uint256[] priceTokenSaleCount;// = {30000 * oneToken, 20000 * oneToken, 10000 * oneToken, 1000 * oneToken};
    uint256 priceEthUSD;// 17111000
    
    //cap
    uint256 capMaximumToken;

    //time
    uint256 timeStart;
    uint256 timeEnd;
    

    
    event TokenPurchase(address indexed sender, uint256 amount, bool withdraw);
    event WithdrawalEther(address _sender, uint256 _weiEther);
    event WithdrawalToken(address _sender, uint256 _weiToken);
    
    constructor(
        
        address _tokenAddress, 
        
        uint64[] memory _priceTokenUSD,
        uint64[] memory _priceTokenSaleCount,
        uint64 _priceEthUSD, 

        uint64 _capMaximumToken, 

        uint64 _timeEnd,  
        address[] memory _managers
        
        ) public {
        

        require(address(0) != _tokenAddress);
        
        require(_priceTokenUSD.length == _priceTokenSaleCount.length);
        require(_priceEthUSD > 0);
        
        require(_capMaximumToken > 0);
  
        require(_timeEnd > 0);
        
        require(_managers.length > 0);
          
          
        
        walletETH = msg.sender;
        
        tokenAddress = _tokenAddress;
        
        priceTokenUSD = _priceTokenUSD;
        
     
        for (uint256 i = 0 ; i < _priceTokenSaleCount.length; i++) {
            require(_priceTokenSaleCount[i] < oneToken);
            priceTokenSaleCount.push(uint256(_priceTokenSaleCount[i]).mul(oneToken));
        }
        priceEthUSD = _priceEthUSD;
            
        capMaximumToken = uint256(_capMaximumToken).mul(oneToken);

        timeStart = now;
        timeEnd = _timeEnd;

        
        for (uint256 i = 0 ; i < _managers.length; i++) {
            require(address(0) != _managers[i]);
            addManager(_managers[i]);
        }
 
    }  
     
    
    function validPurchase(address _sender, uint256 _amount, uint256 _token) internal {
        require(_sender != address(0));
        require(timeStart <= now && now <= timeEnd);
        
        uint256 recordTime;
        uint256 recordETH;
        uint256 recordTOKEN;
        (recordTime, recordETH, recordTOKEN) = getPropertyTotal();

        require(capMaximumToken >= recordTOKEN.add(_token));
    }
    
    function () external payable {
        buyToken();
    }

    function buyToken() public payable whenNotPaused {
        address payable sender = msg.sender;
        uint256 amount = msg.value;
        uint256 priceToken;
        uint256 countToken;
        (priceToken, countToken) = getEthToToken(amount);
        
        require(priceToken > 0);

        validPurchase(sender, amount, countToken);
            
        bool isWithdrawable = isWithdrawable();
        
        recordProperty(sender, amount, countToken, priceToken, isWithdrawable);
        
        if(isWithdrawable) {
            transferToken(sender, countToken);
        }
        
        emit TokenPurchase(sender, countToken, isWithdrawable);   
        
    }

    function transferToken(address to, uint256 amount) internal {
        ERC20(tokenAddress).transfer(to, amount);
        emit WithdrawalToken(to, amount);
    }
    
    function withdrawEther() onlyOwner public {
        uint256 balanceETH = address(this).balance;
        require(balanceETH > 0);
        walletETH.transfer(balanceETH);
        emit WithdrawalEther(msg.sender, balanceETH);
    }
    function withdrawToken(uint256 _amountToken) onlyOwner public {
        transferToken(owner, _amountToken);
    }

    function setTime(uint64 _timeEnd) onlyOwner public {
        timeEnd = _timeEnd;
    }
    
    function setPriceTokenEthUSD(uint64[] memory _priceTokenUSD, uint64[] memory _priceTokenSaleCount, uint64 _priceEthUSD) onlyManagers public {
        require(_priceTokenUSD.length == _priceTokenSaleCount.length);

        while(priceTokenSaleCount.length > 0){
            delete priceTokenSaleCount[priceTokenSaleCount.length - 1];
            priceTokenSaleCount.length--;
        }

        for (uint256 i = 0 ; i < _priceTokenSaleCount.length; i++) {
            require(_priceTokenSaleCount[i] < oneToken);
            priceTokenSaleCount.push(uint256(_priceTokenSaleCount[i]).mul(oneToken));
        }
        
        priceTokenUSD = _priceTokenUSD;
        priceEthUSD = _priceEthUSD;
        
    }    
    
    function setEthUSD(uint64 _priceEthUSD) onlyManagers public {
        priceEthUSD = _priceEthUSD;
    }    
    
    function setCapMaximumToken(uint256 _capMaximumToken) onlyManagers public {
        require(_capMaximumToken > oneToken);
        capMaximumToken = _capMaximumToken;
    }

    function setWithdrawTokens(address[] memory _user, uint256[] memory _token) onlyManagers public {
        require(_user.length == _token.length);
        for(uint256 i = 0; i < _user.length; i++){
            recordPropertyWithdraw(_user[i], _token[i]);
        }
    }

    function getRemainWithdrawEth() public view returns (uint256) {
        uint256 balanceETH = address(this).balance;
        return balanceETH;
    }
    
    function getPriceTokenEthUSD() public view returns (uint256[] memory, uint256[] memory, uint256) {
        return (priceTokenUSD, priceTokenSaleCount, priceEthUSD);
    }
    
    function getCapToken() public view returns (uint256) {
        return capMaximumToken;
    }
 
    function getTokenToEth(uint256 amountToken) public view returns (uint256, uint256) {
        for(uint256 i = 0; i < priceTokenSaleCount.length; i++){
            if(priceTokenSaleCount[i] <= amountToken) {
                uint256 oneTokenEthValue = getOneTokenToEth(priceTokenUSD[i]);
                uint256 ethCount = amountToken.mul(oneTokenEthValue).div(oneToken);
                return (priceTokenUSD[i], ethCount);
            }
        }
        return (0, 0);
    }
    function getEthToToken(uint256 amountEth) public view returns (uint256, uint256) {
        for(uint256 i = 0; i < priceTokenUSD.length; i++){
            uint256 oneTokenEthValue = getOneTokenToEth(priceTokenUSD[i]);
            uint256 tokenCount = amountEth.mul(oneToken).div(oneTokenEthValue);
            if(priceTokenSaleCount[i] <= tokenCount)
                return (priceTokenUSD[i], tokenCount);
        }
        return (0, 0);
    }
    function getOneTokenToEth(uint256 _priceUSD) public view returns (uint256) {
       return _priceUSD.mul(oneEther).div(priceEthUSD); 
    }

    
    function getTokenInfo() public view returns (address, uint8) {
        return (tokenAddress, tokenDecimal);
    }
    function getTimeICO() public view returns (uint256, uint256) {
        return (timeStart, timeEnd);
    }

}