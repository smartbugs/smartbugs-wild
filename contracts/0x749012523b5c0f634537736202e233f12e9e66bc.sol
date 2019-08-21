// CryptoGods Copyright (c) 2018. All rights reserved.

pragma solidity ^0.4.20;

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }
}
contract Owned {
    address public ceoAddress;
    address public cooAddress;
    address private newCeoAddress;
    address private newCooAddress;
    function Owned() public {
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
    }
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    modifier onlyCLevel() {
        require(
            msg.sender == ceoAddress ||
            msg.sender == cooAddress
        );
        _;
    }
    function setCEO(address _newCEO) public onlyCEO {
        require(_newCEO != address(0));
        newCeoAddress = _newCEO;
    }
    function setCOO(address _newCOO) public onlyCEO {
        require(_newCOO != address(0));
        newCooAddress = _newCOO;
    }
    function acceptCeoOwnership() public {
        require(msg.sender == newCeoAddress);
        require(address(0) != newCeoAddress);
        ceoAddress = newCeoAddress;
        newCeoAddress = address(0);
    }
    function acceptCooOwnership() public {
        require(msg.sender == newCooAddress);
        require(address(0) != newCooAddress);
        cooAddress = newCooAddress;
        newCooAddress = address(0);
    }
}
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
contract ERC20 is ERC20Interface, Owned {
    using SafeMath for uint;

    string public constant symbol = "GPC";
    string public constant name = "God Power Coin";
    uint8 public constant decimals = 18;
    uint constant WAD = 10 ** 18;
    uint public _totalSupply = (10 ** 9) * WAD;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
    function () public payable {
        revert();
    }
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyCLevel returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(ceoAddress, tokens);
    }
    
    // Payout
    function payout(uint amount) public onlyCLevel {
        if (amount > this.balance)
            amount = this.balance;
        ceoAddress.transfer(amount);
    }
}

contract ERC721 is ERC20 {

    function _addressNotNull(address _to) private pure returns(bool) {
        return _to != address(0);
    }
    function _approved(address _to, uint _tokenId) private view returns(bool) {
        return token[_tokenId].approved == _to;
    }
    function _ownsToken(address user, uint _tokenId) public view returns(bool) {
        return user == token[_tokenId].owner;
    }
    function _transferToken(address _from, address _to, uint _tokenId) internal {
        token[_tokenId].owner = _to;
        token[_tokenId].approved = address(0);
        TransferToken(_from, _to, _tokenId);
    }

    uint[] public tokenList;
    
    struct TOKEN {
        
        address owner;
        address approved;
        
        uint price;
        uint lastPrice;
        
        uint mSpeed;

        uint mLastPayoutBlock;
    }

    mapping(uint => TOKEN) public token;
    
    event Birth(uint indexed tokenId, uint startPrice);
    event TokenSold(uint indexed tokenId, uint price, address indexed prevOwner, address indexed winner);
    event TransferToken(address indexed from, address indexed to, uint indexed tokenId);
    event ApprovalToken(address indexed owner, address indexed approved, uint indexed tokenId);
    
    function approveToken(address _to, uint _tokenId) public {
        require(_ownsToken(msg.sender, _tokenId));
        token[_tokenId].approved = _to;
        ApprovalToken(msg.sender, _to, _tokenId);
    }
    function getTotalTokenSupply() public view returns(uint) {
        return tokenList.length;
    }
    function ownerOf(uint _tokenId) public view returns (address owner) {
        owner = token[_tokenId].owner;
    }
    function priceOf(uint _tokenId) public view returns (uint price) {
        price = token[_tokenId].price;
    }
    function takeOwnership(uint _tokenId) public {
        address newOwner = msg.sender;
        address oldOwner = token[_tokenId].owner;

        require(_addressNotNull(newOwner));
        require(_approved(newOwner, _tokenId));

        _transferToken(oldOwner, newOwner, _tokenId);
    }
    function transferToken(address _to, uint _tokenId) public {
        require(_ownsToken(msg.sender, _tokenId));
        require(_addressNotNull(_to));
        _transferToken(msg.sender, _to, _tokenId);
    }
    function transferTokenFrom(address _from, address _to, uint _tokenId) public {
        require(_ownsToken(_from, _tokenId));
        require(_approved(_to, _tokenId));
        require(_addressNotNull(_to));
        _transferToken(_from, _to, _tokenId);
    }
    function tokenBalanceOf(address _owner) public view returns(uint result) {
        uint totalTokens = tokenList.length;
        uint tokenIndex;
        uint tokenId;
        result = 0;
        for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
            tokenId = tokenList[tokenIndex];
            if (token[tokenId].owner == _owner) {
                result = result.add(1);
            }
        }
        return result;
    }
    function tokensOfOwner(address _owner) public view returns(uint[] ownerTokens) {
        uint tokenCount = tokenBalanceOf(_owner);
        
        if (tokenCount == 0) return new uint[](0);

        uint[] memory result = new uint[](tokenCount);
        uint totalTokens = tokenList.length;
        uint resultIndex = 0;
        uint tokenIndex;
        uint tokenId;
        
        for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
            tokenId = tokenList[tokenIndex];
            if (token[tokenId].owner == _owner) {
                result[resultIndex] = tokenId;
                resultIndex = resultIndex.add(1);
            }
        }
        return result;
    }
    function getTokenIds() public view returns(uint[]) {
        return tokenList;
    }

    // MIN(A * PRICE, MAX(B * PRICE, 100*PRICE + C)) / 100
    
    uint public priceFactorA = 200;
    uint public priceFactorB = 120;
    uint public priceFactorC = 16 * (10**18);
    
    function changePriceFactor(uint a_, uint b_, uint c_) public onlyCLevel {
        priceFactorA = a_;
        priceFactorB = b_;
        priceFactorC = c_;
    }
    
    function getMaxPrice(uint _tokenId) public view returns (uint) {
        uint price = token[_tokenId].lastPrice.mul(priceFactorB);
        uint priceLow = token[_tokenId].lastPrice.mul(100).add(priceFactorC);
        uint priceHigh = token[_tokenId].lastPrice.mul(priceFactorA);
        if (price < priceLow)
            price = priceLow;
        if (price > priceHigh)
            price = priceHigh;
            
        price = price / (10**18);
        price = price.mul(10**16); // round to x.xx ETH
        
        return price;
    }
    
    function changeTokenPrice(uint newPrice, uint _tokenId) public {
        require(
            (_ownsToken(msg.sender, _tokenId))
            || 
            ((_ownsToken(address(0), _tokenId)) && ((msg.sender == ceoAddress) || (msg.sender == cooAddress)))
        );
        
        newPrice = newPrice / (10**16);
        newPrice = newPrice.mul(10**16); // round to x.xx ETH
        
        require(newPrice > 0);

        require(newPrice <= getMaxPrice(_tokenId));
        token[_tokenId].price = newPrice;
    }
}

contract GodPowerCoin is ERC721 {
    
    function GodPowerCoin() public {
        balances[msg.sender] = _totalSupply;
        Transfer(address(0), msg.sender, _totalSupply);
    }
    
    uint public divCutPool = 0;
    uint public divCutMaster = 10; // to master card
    uint public divCutAdmin = 30;
    
    uint public divPoolAmt = 0;
    uint public divMasterAmt = 0;
    
    mapping(address => uint) public dividend;
    
    function withdrawDividend() public {
        require(dividend[msg.sender] > 0);
        msg.sender.transfer(dividend[msg.sender]);
        dividend[msg.sender] = 0;
    }
    
    function setCut(uint admin_, uint pool_, uint master_) public onlyCLevel {
        divCutAdmin = admin_;
        divCutPool = pool_;
        divCutMaster = master_;
    }
    
    function purchase(uint _tokenId, uint _newPrice) public payable {
        address oldOwner = token[_tokenId].owner;
        uint sellingPrice = token[_tokenId].price;
        
        require(oldOwner != msg.sender);
        require(msg.sender != address(0));

        require(sellingPrice > 0); // can't purchase unreleased token

        require(msg.value >= sellingPrice);
        uint purchaseExcess = msg.value.sub(sellingPrice);

        payoutMining(_tokenId); // must happen before owner change!!

        uint payment = sellingPrice.mul(1000 - divCutPool - divCutAdmin - divCutMaster) / 1000;
        if (divCutPool > 0)
            divPoolAmt = divPoolAmt.add(sellingPrice.mul(divCutPool) / 1000);
        
        divMasterAmt = divMasterAmt.add(sellingPrice.mul(divCutMaster) / 1000);
        
        token[_tokenId].lastPrice = sellingPrice;

        uint maxPrice = getMaxPrice(_tokenId);
        if ((_newPrice > maxPrice) || (_newPrice == 0))
            _newPrice = maxPrice;
            
        token[_tokenId].price = _newPrice;

        _transferToken(oldOwner, msg.sender, _tokenId);
        
        if (_tokenId % 10000 > 0) {
            address MASTER = token[(_tokenId / 10000).mul(10000)].owner;
            dividend[MASTER] = dividend[MASTER].add(sellingPrice.mul(divCutMaster) / 1000);
        }
        
        oldOwner.transfer(payment);

        if (purchaseExcess > 0)
            msg.sender.transfer(purchaseExcess);

        TokenSold(_tokenId, sellingPrice, oldOwner, msg.sender);
    }
    
    function _createToken(uint tokenId, uint _price, address _owner, uint _mBaseSpeed) internal {
        
        token[tokenId].owner = _owner;
        token[tokenId].price = _price;
        token[tokenId].lastPrice = _price;
        
        token[tokenId].mSpeed = _mBaseSpeed;

        token[tokenId].mLastPayoutBlock = block.number;
        
        mSumRawSpeed = mSumRawSpeed.add(getMiningRawSpeed(tokenId));
        
        Birth(tokenId, _price);
        tokenList.push(tokenId);
    }
    function createToken(uint tokenId, uint _price, address _owner, uint _mBaseSpeed) public onlyCLevel {
        require(_price != 0);
        if (_owner == address(0))
            _owner = ceoAddress;

        require(token[tokenId].price == 0);
        _createToken(tokenId, _price, _owner, _mBaseSpeed);
        TransferToken(0, _owner, tokenId);
    }
    function createSimilarTokens(uint[] tokenId, uint _price, address _owner, uint _mBaseSpeed) public onlyCLevel {
        require(_price != 0);
        if (_owner == address(0))
            _owner = ceoAddress;

        for (uint i = 0; i < tokenId.length; i++) {
            require(token[tokenId[i]].price == 0);
            _createToken(tokenId[i], _price, _owner, _mBaseSpeed);
            TransferToken(0, _owner, tokenId[i]);
        }
    }
    function createMultipleTokens(uint[] tokenId, uint[] _price, address _owner, uint[] _mBaseSpeed) public onlyCLevel {
        if (_owner == address(0))
            _owner = ceoAddress;

        for (uint i = 0; i < tokenId.length; i++) {
            require(_price[i] != 0);
            require(token[tokenId[i]].price == 0);
            _createToken(tokenId[i], _price[i], _owner, _mBaseSpeed[i]);
            TransferToken(0, _owner, tokenId[i]);
        }
    }
    
    event MiningUpgrade(address indexed sender, uint indexed token, uint newLevelSpeed);

    // ETH: 6000 blocks per day, 5 ETH per block
    
    uint public mSumRawSpeed = 0;

    uint public mCoinPerBlock = 50;
    
    uint public mUpgradeCostFactor = mCoinPerBlock * 6000 * WAD;
    uint public mUpgradeSpeedup = 1040; // = * 1.04
    
    function adminSetMining(uint mCoinPerBlock_, uint mUpgradeCostFactor_, uint mUpgradeSpeedup_) public onlyCLevel {
        mCoinPerBlock = mCoinPerBlock_;
        mUpgradeCostFactor = mUpgradeCostFactor_;
        mUpgradeSpeedup = mUpgradeSpeedup_;
    }
    
    function getMiningRawSpeed(uint id) public view returns (uint) {
        return token[id].mSpeed;
    }
    function getMiningRealSpeed(uint id) public view returns (uint) {
        return getMiningRawSpeed(id).mul(mCoinPerBlock) / mSumRawSpeed;
    }
    function getMiningUpgradeCost(uint id) public view returns (uint) {
        return getMiningRawSpeed(id).mul(mUpgradeCostFactor) / mSumRawSpeed;
    }
    function upgradeMining(uint id) public {
        uint cost = getMiningUpgradeCost(id);
        balances[msg.sender] = balances[msg.sender].sub(cost);
        _totalSupply = _totalSupply.sub(cost);
        
        mSumRawSpeed = mSumRawSpeed.sub(getMiningRawSpeed(id));
        token[id].mSpeed = token[id].mSpeed.mul(mUpgradeSpeedup) / 1000;
        mSumRawSpeed = mSumRawSpeed.add(getMiningRawSpeed(id));
        
        MiningUpgrade(msg.sender, id, token[id].mSpeed);
    }
    function upgradeMiningMultipleTimes(uint id, uint n) public {
        for (uint i = 0; i < n; i++) {
            uint cost = getMiningUpgradeCost(id);
            balances[msg.sender] = balances[msg.sender].sub(cost);
            _totalSupply = _totalSupply.sub(cost);
        
            mSumRawSpeed = mSumRawSpeed.sub(getMiningRawSpeed(id));
            token[id].mSpeed = token[id].mSpeed.mul(mUpgradeSpeedup) / 1000;
            mSumRawSpeed = mSumRawSpeed.add(getMiningRawSpeed(id));
        }
        MiningUpgrade(msg.sender, id, token[id].mSpeed);
    }
    function payoutMiningAll(address owner, uint[] list) public {
        uint sum = 0;
        for (uint i = 0; i < list.length; i++) {
            uint id = list[i];
            require(token[id].owner == owner);
            uint blocks = block.number.sub(token[id].mLastPayoutBlock);
            token[id].mLastPayoutBlock = block.number;
            sum = sum.add(getMiningRawSpeed(id).mul(mCoinPerBlock).mul(blocks).mul(WAD) / mSumRawSpeed); // mul WAD !
        }
        balances[owner] = balances[owner].add(sum);
        _totalSupply = _totalSupply.add(sum);
    }
    function payoutMining(uint id) public {
        require(token[id].mLastPayoutBlock > 0);
        uint blocks = block.number.sub(token[id].mLastPayoutBlock);
        token[id].mLastPayoutBlock = block.number;
        address owner = token[id].owner;
        uint coinsMined = getMiningRawSpeed(id).mul(mCoinPerBlock).mul(blocks).mul(WAD) / mSumRawSpeed; // mul WAD !
        
        balances[owner] = balances[owner].add(coinsMined);
        _totalSupply = _totalSupply.add(coinsMined);
    }
}