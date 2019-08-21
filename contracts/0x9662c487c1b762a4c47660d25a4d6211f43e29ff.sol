contract Owned {
    address public owner;
    address public newOwner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = 0x0;
    }

    event OwnerUpdate(address _prevOwner, address _newOwner);
}

interface XaurumInterface {
    function doMelt(uint256 _xaurAmount, uint256 _goldAmount) external returns (bool);
    function balanceOf(address _owner) external constant returns (uint256 balance);
    function totalSupply() external constant returns (uint256 supply);
    function totalGoldSupply() external constant returns (uint256 supply);
}

interface OldMeltingContractInterface {
    function XaurumAmountMelted() external constant returns (uint256 supply);
    function GoldAmountMelted() external constant returns (uint256 supply);
}

contract DestructionContract is Owned{
    address XaurumAddress;
    address BurningAddress;
    address OldMeltingContract;
    
    uint xaurumDestroyed;
    uint goldMelted;
    uint xaurumBurned;
    uint xaurumMelted;
    
    
    event MeltDone(uint xaurAmount, uint goldAmount);
    event BurnDone(uint xaurAmount);
    
    constructor() public {
        XaurumAddress = 0x4DF812F6064def1e5e029f1ca858777CC98D2D81;
        BurningAddress = 0xed3f8C4c63524a376833b0f687487182C9f9bbf8;
        OldMeltingContract = 0x6A25216f75d7ee83D06e5fC6B96bCD52233BC69b;
    }
    
    function XaurumBurned() public constant returns(uint){
        return xaurumBurned + XaurumInterface(XaurumAddress).balanceOf(BurningAddress);
    }
    
    function XaurumMelted() public constant returns(uint) {
        return xaurumMelted + OldMeltingContractInterface(OldMeltingContract).XaurumAmountMelted();
    }
    
    function FreeXaurum() public constant returns(uint) {
        return XaurumInterface(XaurumAddress).balanceOf(address(this)) - xaurumDestroyed;
    }
    
    function GoldMelted() public constant returns(uint) {
        return OldMeltingContractInterface(OldMeltingContract).GoldAmountMelted() + goldMelted;
    }
    
    function doMelt(uint256 _xaurAmount, uint256 _goldAmount) public onlyOwner returns (bool) {
        uint actualBalance = FreeXaurum();
        uint totalSupply = XaurumInterface(XaurumAddress).totalSupply();
        require(totalSupply >= _xaurAmount);
        require(actualBalance >= _xaurAmount);
        require(XaurumInterface(XaurumAddress).totalGoldSupply() >= _goldAmount);
        XaurumInterface(XaurumAddress).doMelt(_xaurAmount, _goldAmount);
        xaurumMelted += _xaurAmount;
        goldMelted += _goldAmount;
        xaurumDestroyed += _xaurAmount;
        emit MeltDone(_xaurAmount, _goldAmount);
    }
    
    function doBurn(uint256 _xaurAmount) public onlyOwner returns (bool) {
        uint actualBalance = FreeXaurum();
        uint totalSupply = XaurumInterface(XaurumAddress).totalSupply();
        require(totalSupply >= _xaurAmount);
        require(actualBalance >= _xaurAmount);
        XaurumInterface(XaurumAddress).doMelt(_xaurAmount, 0);
        xaurumBurned += _xaurAmount;
        xaurumDestroyed += _xaurAmount;
        emit BurnDone(_xaurAmount);
    }
}