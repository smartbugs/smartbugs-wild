pragma solidity ^0.4.13;

/* Functions from Kitten Coin main contract to be used by sale contract */
contract KittenCoin {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {}
    function allowance(address owner, address spender) public constant returns (uint256) {}
}

contract KittenSale {
    KittenCoin public _kittenContract;
    address public _kittenOwner;
    uint256 public totalContributions;
    uint256 public kittensSold;
    uint256 public kittensRemainingForSale;
    
    function KittenSale () {
        address c = 0xac2BD14654BBf22F9d8f20c7b3a70e376d3436B4; // set Kitten Coin contract address
        _kittenContract = KittenCoin(c); 
        _kittenOwner = msg.sender;
        totalContributions = 0;
        kittensSold = 0;
        kittensRemainingForSale = 0; // set to 0 first as allowance to contract can't be set yet
    }
    
    /* Every time ether is sent to the contract, Kitten Coin will be issued with following rules
    ** Amount sent < 0.1 ETH - 1 KITTEN for 0.000001 ETH (for example, 0.05 ETH = 50 000 KITTEN)
    ** 0.1 ETH <= amount sent < 1 ETH - +20% bonus 1.2 KITTEN for 0.000001 ETH (for example, 0.5 ETH = 600 000 KITTEN)
    ** Amount sent >= 1 ETH - +50% bonus 1.5 KITTEN for 0.000001 ETH (for example, 1.5 ETH = 1 800 000 KITTEN)
    **
    ** If not enough KITTEN remaining to sale, transaction will be cancelled.
    */ 
    function () payable {
        require(msg.value > 0);
        uint256 contribution = msg.value;
        if (msg.value >= 100 finney) {
            if (msg.value >= 1 ether) {
                contribution /= 6666;
            } else {
                contribution /= 8333;
            }
        } else {
            contribution /= 10000;
        }
        require(kittensRemainingForSale >= contribution);
        totalContributions += msg.value;
        kittensSold += contribution;
        _kittenContract.transferFrom(_kittenOwner, msg.sender, contribution);
        _kittenOwner.transfer(msg.value);
        updateKittensRemainingForSale();
    }
    
    function updateKittensRemainingForSale () {
        kittensRemainingForSale = _kittenContract.allowance(_kittenOwner, this);
    }
    
}