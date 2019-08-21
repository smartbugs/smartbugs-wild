pragma solidity 0.5.4;

contract ProofOfFomo {
    
    IFomo public constant fomoLong = IFomo(0xA62142888ABa8370742bE823c1782D17A0389Da1);
    IDivies public constant doNotPush = IDivies(0xc7029Ed9EBa97A096e72607f4340c34049C7AF48);
    uint256 public constant ROUND_THAT_NEVER_ENDS = 9;
    
    mapping(address => uint256) public etherPledged;
    mapping(address => uint256) public etherSpentInRound;
    
    modifier isRound9
    {
        require(fomoLong.rID_() == ROUND_THAT_NEVER_ENDS);
        _;
    }
    
    modifier round9Ended
    {
        require(fomoLong.rID_() > ROUND_THAT_NEVER_ENDS);
        _;
    }
    
    function()
        external
        payable
        isRound9
    {
        lock(msg.sender);
    }
    
    function pledge()
        external
        payable
        isRound9
    {
        lock(msg.sender);
    }
    
    function gift(address _to)
        external
        payable
        isRound9
    {
        lock(_to);
    }
    
    function loot()
        external
        round9Ended
    {
        doNotPush.deposit.value(address(this).balance)();
    }
    
    function lock(address _player)
        private
    {
        require(msg.value > 0 ether);
        require(etherPledged[_player] == 0);
        
        etherPledged[_player] = msg.value;
        etherSpentInRound[_player] = getEtherSpentInRound(_player);
    }
    
    function unlock()
        external
        isRound9
    {
        uint256 etherSpentInRoundOld = etherSpentInRound[msg.sender];
        uint256 etherSpentInRoundNew = getEtherSpentInRound(msg.sender);
        
        require(etherSpentInRoundNew > etherSpentInRoundOld);
        
        uint256 difference = etherSpentInRoundNew - etherSpentInRoundOld;
        uint256 etherPledgedOld = etherPledged[msg.sender];
        
        uint256 etherUnlocked = difference > etherPledgedOld ? etherPledgedOld : difference;
        
        uint256 etherPledgedNew = etherPledgedOld - etherUnlocked;
        
        etherPledged[msg.sender] = etherPledgedNew;
        etherSpentInRound[msg.sender] = etherSpentInRoundNew;
        
        msg.sender.transfer(etherUnlocked);
    }
    
    function getEtherSpentInRound(address _player)
        private
        returns(uint256)
    {
        uint256 pID = fomoLong.pIDxAddr_(_player);
        return fomoLong.plyrRnds_(pID, ROUND_THAT_NEVER_ENDS);
    }
}
    
interface IFomo {
	function rID_() external returns(uint256);
	function pIDxAddr_(address player) external returns(uint256);
	function plyrRnds_(uint256 pID, uint256 rID) external returns(uint256);
}

interface IDivies {
    function deposit() external payable;
}