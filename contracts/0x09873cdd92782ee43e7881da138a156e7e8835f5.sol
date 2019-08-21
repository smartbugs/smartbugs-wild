pragma solidity ^0.4.18;


library SafeMath {
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


    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


contract BurnableToken {
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool);

    function allowance(address _owner, address _spender) public view returns (uint256);

    function approve(address _spender, uint256 _value) public returns (bool);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function burn(uint256 _value) public;

    ArnaCrowdsale public  crowdsale;

    function increaseApproval(address _spender, uint _addedValue) public returns (bool);

    address public owner;

    function setCrowdsale(ArnaCrowdsale _crowdsale) public;

    function setTransferable(bool _transferable) public;

    uint256 public totalSupply;

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    function transferOwnership(address newOwner) public;

    bool public transferable;
}


contract ArnaToken is BurnableToken {
    string public constant name = "ArnaToken";
    string public constant symbol = "ARNA";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    function init() public;

}

//========================================



contract ArnaVault is Ownable {
    using SafeMath for uint256;
    ArnaToken token;

    uint256 amount;

    uint256 public withdrawn = 0;

    uint startTime;

    uint period;

    uint256 percent;

    address beneficiary;

    function ArnaVault(ArnaToken _token, uint _period, uint256 _percent, address _beneficiary) public {
        token = _token;
        period = _period;
        percent = _percent;
        // 2500 -> 2.5%
        beneficiary = _beneficiary;
    }

    function tokensInVault() public constant returns (uint256){
        return token.balanceOf(this);
    }

    function start() public onlyOwner {
        assert(token.balanceOf(this) > 0);
        amount = token.balanceOf(this);
        startTime = block.timestamp;
    }

    function tokensAvailable() public constant returns (uint256){
        return (((block.timestamp - startTime) / period + 1)
        * amount * percent / 100000)
        .sub(withdrawn);
    }

    function withdraw() public {
        assert(msg.sender == beneficiary || msg.sender == owner);
        assert(tokensAvailable() > 0);
        token.transfer(beneficiary, tokensAvailable());
        withdrawn = withdrawn.add(tokensAvailable());
    }

}


//========================================

contract ArnaCrowdsale is Ownable {
    using SafeMath for uint256;
    ArnaControl arnaControl;

    ArnaToken public token;

    uint256 public totalRise;


    function ArnaCrowdsale(ArnaControl _arnaControl, ArnaToken _token) public {
        arnaControl = _arnaControl;
        token = _token;
    }

    function tokensToSale() public view returns (uint256){
        return token.balanceOf(this);
    }

    function burnUnsold() public onlyOwner returns (uint256){
        uint256 unsold = token.balanceOf(this);
        token.burn(unsold);
        return unsold;
    }

    function price() public constant returns (uint256) {
        return arnaControl.getPrice();
    }

    function priceWithBonus() public constant returns (uint256) {
        return arnaControl.getPriceWithBonus();
    }

    function() public payable {
        uint256 amount = msg.value.mul(1 ether).div(priceWithBonus());
        assert(token.balanceOf(this) > amount);
        token.transfer(msg.sender, amount);
        totalRise = totalRise.add(msg.value);
    }

    function sendTokens(address beneficiary, uint256 amount) public onlyOwner {
        assert(token.balanceOf(this) > amount);
        token.transfer(beneficiary, amount);
        totalRise = totalRise.add(amount.mul(priceWithBonus()));
    }

    function withdraw() public onlyOwner returns (bool) {
        return arnaControl.send(this.balance);
    }

}


//========================================

contract ArnaControl is Ownable {
    using SafeMath for uint256;
    ArnaToken public token;

    ArnaCrowdsale public  crowdsale;

    ArnaVault public founders;

    ArnaVault public team;

    //    ArnaVault public partners;

    bool public isStarted;

    bool public isStoped;

    uint256 constant TO_SALE = 500000000 * (10 ** 18);

    uint256  price = 0.000266 ether;

    uint256  priceWithBonus = 0.000266 ether; //  15% => 0.000231304 ether;

    address public coldWallet;

    function init(ArnaToken _arnaToken) public onlyOwner {
        token = _arnaToken;
        token.init();
        coldWallet = msg.sender;
    }

    function SaleStop() public onlyOwner {
        assert(isStarted);
        assert(!isStoped);

        setTransferable(true);

        uint256 toBurn = crowdsale.burnUnsold();
        token.burn(toBurn);

        uint256 toFounders = thisContactsTokens().div(5);
        // 100 / 500
        uint256 toPartners = thisContactsTokens().div(2);
        // 250 / 500
        uint256 toTeam = thisContactsTokens().sub(toFounders).sub(toPartners);
        // 150 / 500


        founders = new ArnaVault(token, 360 days, 50000, address(0xC041CB562e4C398710dF38eAED539b943641f7b1));
        token.transfer(founders, toFounders);
        founders.start();

        team = new ArnaVault(token, 180 days, 16667, address(0x2ABfE4e1809659ab60eB0053cC799b316afCc556));
        token.transfer(team, toTeam);
        team.start();

        //        partners = new ArnaVault(token, 0, 100000,  0xd6496BBd13ae8C4Bdeea68799F678a1456B62f23);
        //        token.transfer(partners, thisContactsTokens().div(2));
        //        partners.start();

        token.transfer(address(0xd6496BBd13ae8C4Bdeea68799F678a1456B62f23), toPartners);


        isStarted = false;
        isStoped = true;
    }

    function SaleStart() public onlyOwner {
        assert(!isStarted);
        assert(!isStoped);
        crowdsale = new ArnaCrowdsale(this, token);
        token.setCrowdsale(crowdsale);
        token.transfer(crowdsale, TO_SALE);
        isStarted = true;
    }

    function thisContactsTokens() public constant returns (uint256){
        return token.balanceOf(this);
    }

    function getPrice() public constant returns (uint256){
        return price;
    }

    // _newPrice : 266 => 0.000266
    function setPrice(uint256 _newPrice) public onlyOwner {
        assert(_newPrice > 0);
        price = _newPrice * (10 ** 12);
    }

    function getPriceWithBonus() public constant returns (uint256){
        return priceWithBonus;
    }

    // _newPrice : 266 => 0.000266
    function setPriceWithBonus(uint256 _newPrice) public onlyOwner {
        assert(_newPrice > 0);
        assert(_newPrice * (10 ** 12) <= price);
        priceWithBonus = _newPrice * (10 ** 12);
    }


    function() public payable {
        // this for withdraw from ArnaCrowdsale
    }

    function setColdWallet(address _coldWallet) public onlyOwner {
        coldWallet = _coldWallet;
    }

    function withdraw() public onlyOwner returns (bool) {
        if (crowdsale.balance > 0)
            crowdsale.withdraw();
        return coldWallet.send(this.balance);
    }

    // amount : 12345000 => 12.345000 ARNA = 12345000000000000000;
    function sendTokens(address beneficiary, uint256 amount) public onlyOwner {
        crowdsale.sendTokens(beneficiary, amount * (10 ** 12));
    }

    function setTransferable(bool _transferable) public onlyOwner {
        token.setTransferable(_transferable);
    }

    //refund if the softcap is not reached
    function refund(address beneficiary, uint256 amount) public onlyOwner returns(bool){
        if (crowdsale.balance > 0)
            crowdsale.withdraw();
        assert(crowdsale.balance + this.balance >= amount);
        return beneficiary.send(amount);
    }
}