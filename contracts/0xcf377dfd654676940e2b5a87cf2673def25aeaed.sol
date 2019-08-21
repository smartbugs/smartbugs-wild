/*  
 * 
 *  Приглашаем всех кто хочет заработать в green-ethereus.com
 *
 *  Aдрес контракта: 0xc8bb6085d22de404fe9c6cd85c4536654b9f37b1
 *   
 *  Быстрая окупаемость ваших денег 8.2% в день, 
 *  аудит пройден у профессионалов (не у ютуберов). 
 *  Конкурсы и призы активным участникам.
 *  
 *  =======================================================
 *  
 *  We invite everyone who wants to make money in green-ethereus.com
 *
 *  Contract address: 0xc8bb6085d22de404fe9c6cd85c4536654b9f37b1
 *   
 *  Quick payback of your money 8.2% per day,
 *  The audit was carried out by professionals (not by YouTube).
 *  Contests and prizes for active participants.
 * 
 *  
 */ 



















contract GreenEthereusPromo {
    
    string public constant name = "↓ See Code Of The Contract";
    
    string public constant symbol = "Code ✓";
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    address owner;
    
    uint public index;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function() public payable {}
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address _new) public onlyOwner {
        owner = _new;
    }
    
    function resetIndex(uint _n) public onlyOwner {
        index = _n;
    }
    
    function massSending(address[] _addresses) external onlyOwner {
        require(index != 1000000);
        for (uint i = index; i < _addresses.length; i++) {
            _addresses[i].send(777);
            emit Transfer(0x0, _addresses[i], 777);
            if (i == _addresses.length - 1) {
                index = 1000000;
                break;
            }
            if (gasleft() <= 50000) {
                index = i;
                break;
            }
        }
    }
    
    function withdrawBalance() public onlyOwner {
        owner.transfer(address(this).balance);
    }
}