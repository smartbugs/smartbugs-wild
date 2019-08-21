pragma solidity >=0.4.25;

library AddressUtils {


  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

contract ERC20Interface {
    function allowance(address _from, address _to) public view returns(uint);
    function transferFrom(address _from, address _to, uint _sum) public;
    function transfer(address _to, uint _sum) public;
    function balanceOf(address _owner) public view returns(uint);
}

contract WalletInterface {
    function getTransaction(uint _id) public view returns(address, uint, address, uint, uint, bool);
}

contract ContractCreator {
    function setContract() public returns(address);
}

contract MaxiCreditCompany {
    
    event Transfer(address indexed _from, address indexed _to, uint _sum);
    event TokenBoughtFromContract(address indexed _buyer, uint indexed _promoter, uint _sum);
    event TokenBoughtFromSeller(address indexed _buyer, address _seller, uint _amount, uint indexed _offerId);
    event Approval(address indexed _seller, address indexed _buyer, uint _amount);
    event DescriptionChange(bytes32 _txt);
    event NewServer(address indexed _serverAddress, uint indexed _id);
    event ServerChanged(address indexed _newServerAddress, address indexed _oldServerAddress, uint indexed _id);
    event ETHWithdraw(address indexed _to, uint _sum);
    event ERC20Withdraw(address indexed _erc20Address, address indexed _to, uint _sum);
    event SupplyIncreased(uint _amount, uint _totalSupply);
    event NewSaleOffer(uint indexed saleOffersCounter, uint indexed _amount, uint indexed _unitPrice);
    event SetToBuyBack(uint _amount, uint _price);
    event BuyBack(uint indexed _amount, uint indexed buyBackPrice);
    event SetOwner(uint indexed _id, address indexed _newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnerDeleted(uint indexed _id, address indexed _owner);
    event OperatorRightChanged(address indexed _operator, uint _txRight);
    event NewOperator(uint indexed _id, address indexed _newOperator, uint _txRight);
    event OperatorChanged(uint indexed _id, address indexed _newOperator, address indexed oldOperator, uint _txRight);
    event DeleteOperator(uint indexed _id, address indexed _operator);
    event OwnerChangedPrice(uint _priceETH, uint _priceUSD);
    event ServerChangedPrice(uint _priceETH, uint _priceUSD);
    event NewContract(address indexed _addr, uint indexed newContractsLength);
    
    using AddressUtils for address;
    string public name = "MaxiCreditCompanyShare";
    string public symbol = "MC2";
    uint public supply = 80000000;
    uint public decimals = 0;
    bytes32 public description;
    
    uint public unitPriceETH; 
    uint public unitPriceUSD;
    uint public shareHoldersNumber;
    mapping (address => uint) shareHolderId;
    address[] public shareHolders;
    bool shareHolderDelete;
    address[10] public contractOwner;
    address[10] public operator;
    uint public ownerCounter;
    
    mapping(address => bool) public isOwner;
    mapping(address => bool) public isOperator;
    mapping(address => uint) public operatorsRights;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(uint => uint)) public saleOffersByAddress;
    mapping(uint => address) public saleOffersById;
    mapping(uint => uint) public saleOffersAmount;
    mapping(uint => uint) public saleOffersUnitPrice;
    mapping(address => uint) public sellersOfferCounter;
    uint public saleOffersCounter = 0;
    
    uint public buyBackAmount = 0;
    uint public buyBackPrice = 0;
    
    mapping(address => mapping(address => uint)) public approvedTransfers;
    
    address[] serverAddress;
    mapping (address => bool) isOurServer;
    uint serverAddressArrayLength;
    
    ContractCreator cc;
    address newContract;
    address[] public newContracts;
    uint public newContractsLength;

    modifier onlyOwner() {
        require(isOwner[msg.sender] == true);
        require(msg.sender != address(0));
        _;
    }  
    
    modifier onlyOperator() {
        require(isOperator[msg.sender] == true);
        require(msg.sender != address(0));
        _;
    }
    
    modifier onlyServer() {
        require(isOurServer[msg.sender] == true);
        require(msg.sender != address(0));
        _;
    }
    
    constructor (uint _initPriceETH, uint _initPriceUSD) public {
       contractOwner[0] = msg.sender;
       isOwner[msg.sender] = true;
       operator[0] = msg.sender;
       isOperator[msg.sender] = true;
       operatorsRights[msg.sender] = 100;
       balanceOf[address(this)] = supply;
       unitPriceETH = _initPriceETH;
       unitPriceUSD = _initPriceUSD;
       shareHoldersNumber = 0;
       shareHolderDelete = false;
       ownerCounter = 1;
    }
    
    function getContractOwner(uint _id) public view returns(address) {
        return(contractOwner[_id]);
    }
    
    function setDescription(bytes32 _txt) public onlyOwner {
        description = _txt;
        emit DescriptionChange(_txt);
    }
    
    function setServerAddress(address _serverAddress) public onlyOwner {
        serverAddressArrayLength = serverAddress.push(_serverAddress);
        isOurServer[_serverAddress] = true;
        emit NewServer(_serverAddress, serverAddressArrayLength - 1);
    }
    
    function modifyServer(uint _id, address _serverAddress) public onlyOwner {
        address oldServer = serverAddress[_id];
        isOurServer[serverAddress[_id]] = false;
        serverAddress[_id] = _serverAddress;
        isOurServer[_serverAddress] = true;
        emit ServerChanged(_serverAddress, oldServer, _id);
    }
    
    function getServerAddressLength() public view onlyOperator returns(uint) {
        return serverAddressArrayLength;
    }
    
    function getServerAddress(uint _num) public view onlyOperator returns(address) {
        return serverAddress[_num];
    }
    
    function checkServerAddress(address _addr) public view onlyOperator returns(bool) {
        return(isOurServer[_addr]);
    }
    
    function withdrawal(uint _sum, address _to) public onlyOperator {
        require(operatorsRights[msg.sender] * address(this).balance / 100 >= _sum);
        require(address(this).balance >= _sum);
        require(_to != address(0) && _sum > 0);
        address(_to).transfer(_sum);
        emit ETHWithdraw(_to, _sum);
    }
    
    function withdrawERC20(address _erc20Address, address _to, uint _amount) public onlyOperator {
        ERC20Interface ei = ERC20Interface(_erc20Address);
        require(operatorsRights[msg.sender] * ei.balanceOf(this) / 100 >= _amount);
        require(_erc20Address != address(0) && _to != address(0));
        ei.transfer(_to, _amount);
        emit ERC20Withdraw(_erc20Address, _to, _amount);
    }
    /*
    */
    function totalSupply() public view returns(uint) {
        return(supply);
    }
    
    function increaseSupply(uint _amount) public onlyOwner {
        supply += _amount;
        balanceOf[this] += _amount;
        emit SupplyIncreased(_amount, supply);
    }
    
    function _transfer(address _from, address _to, uint _sum) private {
        require(_from != address(0));
        require(_to != address(0));
        require(_from != _to);
        require(_sum > 0);
        require(balanceOf[_from] >= _sum);
        require(balanceOf[_to] + _sum >= _sum);
        if(balanceOf[_to] == 0) {
            shareHolderId[_to] = shareHoldersNumber;
            if(shareHolderDelete) {
                shareHolders[shareHoldersNumber] = _to;
                shareHolderDelete = false;
            } else {
                shareHolders.push(_to);    
            }
            shareHoldersNumber ++;
        }
        uint sumBalanceBeforeTx = balanceOf[_from] + balanceOf[_to]; 
        balanceOf[_from] -= _sum;
        balanceOf[_to] += _sum;
        if(balanceOf[_from] == 0) {
            shareHoldersNumber --;
            shareHolders[shareHolderId[_from]] = shareHolders[shareHoldersNumber];
            shareHolderId[shareHolders[shareHoldersNumber]] = shareHolderId[_from];
            delete shareHolders[shareHoldersNumber];
            shareHolderDelete = true;
        }
        assert(sumBalanceBeforeTx == balanceOf[_from] + balanceOf[_to]);
        emit Transfer(_from, _to, _sum);
    }
    
    function transfer(address _to, uint _sum) external returns(bool) {
        _transfer(msg.sender, _to, _sum);
        return(true);
    }
    
    function transferFromContractsBalance(address _to, uint _sum) public onlyOwner {
        require(_to != address(0));
        require(this != _to);
        require(_sum > 0);
        require(balanceOf[this] >= _sum);
        require(balanceOf[_to] + _sum >= _sum);
        if(balanceOf[_to] == 0) {
            shareHolderId[_to] = shareHoldersNumber;
            if(shareHolderDelete) {
                shareHolders[shareHoldersNumber] = _to;
                shareHolderDelete = false;
            } else {
                shareHolders.push(_to);    
            }   
            shareHoldersNumber ++;
        }
        uint sumBalanceBeforeTx = balanceOf[this] + balanceOf[_to]; 
        balanceOf[this] -= _sum;
        balanceOf[_to] += _sum;
        assert(sumBalanceBeforeTx == balanceOf[this] + balanceOf[_to]);
        emit Transfer(this, _to, _sum);
    }

    function setToSale(uint _amount, uint _unitPrice) public {
        require(balanceOf[msg.sender] >= _amount);
        require(_unitPrice > 0);
        saleOffersByAddress[msg.sender][sellersOfferCounter[msg.sender]] = saleOffersCounter;
        saleOffersById[saleOffersCounter] = msg.sender;
        saleOffersAmount[saleOffersCounter] = _amount;
        saleOffersUnitPrice[saleOffersCounter] = _unitPrice;
        emit NewSaleOffer(saleOffersCounter, _amount, _unitPrice);
        sellersOfferCounter[msg.sender] ++;
        saleOffersCounter ++;
    }
    
    function getSaleOffer(uint _id) public view returns(address, uint, uint) {
        return(saleOffersById[_id], saleOffersAmount[_id], saleOffersUnitPrice[_id]);
    }
    
    function buyFromSeller(uint _amount, uint _offerId) public payable {
        require(saleOffersAmount[_offerId] >= _amount);
        uint orderPrice = _amount * saleOffersUnitPrice[_offerId];
        require(msg.value == orderPrice);
        saleOffersAmount[_offerId] -= _amount;
        _transfer(saleOffersById[_offerId], msg.sender, _amount);
        uint sellersShare = orderPrice * 99 / 100;
        uint toSend = sellersShare;
        sellersShare = 0;
        saleOffersById[_offerId].transfer(toSend);
        emit TokenBoughtFromSeller(msg.sender, saleOffersById[_offerId], _amount, _offerId);
    }
    
    function setBuyBack(uint _amount, uint _price) public onlyOperator {
        buyBackAmount += _amount;
        buyBackPrice = _price;
        emit SetToBuyBack(_amount, _price);
    }

    function buyback(uint _amount) public {
        require(buyBackAmount >= _amount);
        buyBackAmount -= _amount;
        _transfer(msg.sender, this, _amount);
        msg.sender.transfer(_amount * buyBackPrice); 
        emit BuyBack(_amount, buyBackPrice);
    }
    
    function getETH(uint _amount) public payable {
        require(msg.value == _amount);
        //event?
    }
    
    //should be different function for set and modify owner and operator
    function setContractOwner(uint _id, address _newOwner) public onlyOwner {
        require(contractOwner[_id] == address(0) && !isOwner[_newOwner]);
        contractOwner[_id] = _newOwner;
        isOwner[_newOwner] = true;
        ownerCounter++;
        emit SetOwner(_id, _newOwner);
    }
    
    function modifyContractOwner(uint _id, address _newOwner) public onlyOwner {
        require(contractOwner[_id] != address(0) && contractOwner[_id] != _newOwner);
        address previousOwner = contractOwner[_id];
        isOwner[contractOwner[_id]] = false;
        contractOwner[_id] = _newOwner;
        isOwner[_newOwner] = true;
        emit OwnershipTransferred(previousOwner, _newOwner);
    }
    
    function deleteOwner(uint _id, address _addr) public onlyOwner {
        require(ownerCounter > 1);
        require(isOwner[_addr] && contractOwner[_id] == _addr);
        isOwner[_addr] = false;
        contractOwner[_id] = address(0);
        ownerCounter--;
        emit OwnerDeleted(_id, _addr);
    }
    
    function setOperatorsRight(address _operator, uint _txRight) public onlyOwner {
        require(_txRight <= 100 && isOperator[_operator]);
        operatorsRights[_operator] = _txRight;
        emit OperatorRightChanged(_operator, _txRight);
    }
    
    function setOperator(uint _id, address _newOperator, uint _txRight) public onlyOwner {
        require(_txRight <= 100 && operator[_id] == address(0) && !isOperator[_newOperator]);
        operator[_id] = _newOperator;
        operatorsRights[_newOperator] = _txRight;
        isOperator[_newOperator] = true;
        emit NewOperator(_id, _newOperator, _txRight);
    }
    
    function modifyOperator(uint _id, address _newOperator, uint _txRight) public onlyOwner {
        require(operator[_id] != address(0) && operator[_id] != _newOperator && _txRight < 100);
        address oldOperator = operator[_id];
        isOperator[operator[_id]] = false;
        operatorsRights[operator[_id]] = 0;
        isOperator[_newOperator] = true;
        operator[_id] = _newOperator;
        operatorsRights[_newOperator] = _txRight;
        emit OperatorChanged(_id, _newOperator, oldOperator, _txRight);
    }
    
    function deleteOperator(uint _id, address _operator) public onlyOwner {
        require(isOperator[_operator] && operator[_id] == _operator);
        isOperator[_operator] = false;
        operatorsRights[_operator] = 0;
        operator[_id] = address(0);
        emit DeleteOperator(_id, _operator);
    }

    function getShareNumber(address _addr) public view returns(uint) {
        return(balanceOf[_addr]);
    }

    function approve(address _to, uint _sum) public {
        approvedTransfers[msg.sender][_to] += _sum;
        emit Approval(msg.sender, _to, _sum);
    }
    
    function allowance(address _from, address _to) public view returns(uint) {
        return (approvedTransfers[_from][_to]);
    }
    
    function transferFrom(address _from, address _to, uint _sum) public { 
        require(approvedTransfers[_from][msg.sender] >= _sum);
        approvedTransfers[_from][msg.sender] -= _sum;
        _transfer(_from, _to, _sum); 
    }

    function changePriceByOwner(uint _priceETH, uint _priceUSD) public onlyOwner {
        require(_priceETH > 0 && _priceUSD > 0);
        unitPriceETH = _priceETH;
        unitPriceUSD = _priceUSD;
        emit OwnerChangedPrice(_priceETH, _priceUSD);
    }
    
    function changePriceByServer(uint _priceETH, uint _priceUSD) public onlyServer {
        require(_priceETH > 0 && _priceUSD > 0);
        unitPriceETH = _priceETH;
        unitPriceUSD = _priceUSD;
        emit ServerChangedPrice(_priceETH, _priceUSD);
    }
    
    function checkIsShareHolder() public view returns(bool){
        if(balanceOf[msg.sender] > 0) {
            return(true);
        } else {
            return(false);
        }
    } 
    
    function getShareHolderRegister() public view returns(address[] memory) {
        return(shareHolders);
    }
    
    function setNewContract(address _addr) public onlyOperator {
        cc = ContractCreator(_addr);
        newContract = cc.setContract();
        newContracts.push(newContract);
        newContractsLength ++;
        emit NewContract(_addr, newContractsLength);
    }
}