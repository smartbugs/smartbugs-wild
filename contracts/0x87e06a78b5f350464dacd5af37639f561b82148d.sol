pragma solidity ^0.4.18;


contract Token {
    function balanceOf(address _account) public constant returns (uint balance);

    function transfer(address _to, uint _value) public returns (bool success);
}


contract CrowdSale {
    address owner;

    address BitcoinQuick = 0xD7AA94f17d60bE06414973a45FfA77efd6443f0F;

    uint public unitCost;

    function CrowdSale() public {
        owner = msg.sender;
    }

    function() public payable {
        // Init Bitcoin Quick contract
        Token BTCQ = Token(BitcoinQuick);
        // Get available supply for this account crowdsale
        uint CrowdSaleSupply = BTCQ.balanceOf(this);
        // Checkout requirements
        require(msg.value > 0 && CrowdSaleSupply > 0 && unitCost > 0);
        // Calculate and adjust required units
        uint units = msg.value / unitCost;
        units = CrowdSaleSupply < units ? CrowdSaleSupply : units;
        // Transfer funds
        require(units > 0 && BTCQ.transfer(msg.sender, units));
        // Calculate remaining ether amount
        uint remainEther = msg.value - (units * unitCost);
        // Return remaining ETH if above 0.001 ETH (TO SAVE INVESTOR GAS)
        if (remainEther >= 10 ** 15) {
            msg.sender.transfer(remainEther);
        }
    }

    function icoPrice(uint perEther) public returns (bool success) {
        require(msg.sender == owner);
        unitCost = 1 ether / (perEther * 10 ** 8);
        return true;
    }

    function withdrawFunds(address _token) public returns (bool success) {
        require(msg.sender == owner);
        if (_token == address(0)) {
            owner.transfer(this.balance);
        }
        else {
            Token ERC20 = Token(_token);
            ERC20.transfer(owner, ERC20.balanceOf(this));
        }
        return true;
    }
}