pragma solidity ^0.4.15;

contract ThanahCoin {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    string public name;
    string public symbol;
    uint8 public decimals;

    uint public totalSupply;
    uint public availableSupply;
    mapping (address => uint256) public balanceOf;

    uint private lastBlock;    
    uint private coinsPerBlock;

    function ThanahCoin() {
        name = "ThanahCoin";
        symbol = "THC";
        decimals = 0;
        lastBlock = block.number;
        totalSupply = 0;
        availableSupply = 0;
        coinsPerBlock = 144;
    }

    function transfer(address _to, uint256 _value) {
        
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        Transfer(msg.sender, _to, _value);

    }

    function issue(address _to) {

        _mintCoins();

        uint issuedCoins = availableSupply / 100;

        availableSupply -= issuedCoins;
        balanceOf[_to] += issuedCoins;

        Transfer(0, _to, issuedCoins);

    }

    function _mintCoins() internal {

        uint elapsedBlocks = block.number - lastBlock;
        lastBlock = block.number;

        uint mintedCoins = elapsedBlocks * coinsPerBlock;

        totalSupply += mintedCoins;
        availableSupply += mintedCoins;

    }
}