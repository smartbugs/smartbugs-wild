pragma solidity ^0.4.16;

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a / b;
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}


contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
}

contract Presale is owned {

    uint public presaleStart;
    uint public stage1Start;
    uint public stage2Start;
    uint public stage3Start;
    uint public stage4Start;
    uint public saleEnd;

    uint256 public presaleBonus;
    uint256 public stage1Bonus;
    uint256 public stage2Bonus;
    uint256 public stage3Bonus;
    uint256 public stage4Bonus;

    uint256 public buyingPrice;

    function Presale() {
        presaleStart = 1508112000; // 16 Oct
        stage1Start = 1511179200; // 20 Nov
        stage2Start = 1512043200; // 30 Nov
        stage3Start = 1512907200; // 10 Dec
        stage4Start = 1513771200; // 20 Dec
        saleEnd = 1514635200; // 30 Dec

        presaleBonus = 50;
        stage1Bonus = 25;
        stage2Bonus = 20;
        stage3Bonus = 15;
        stage4Bonus = 10;

        buyingPrice = 5000000000000000; // 1 ETH = 200 VLR
    }

    event EtherTransfer(address indexed _from,address indexed _to,uint256 _value);

    function changeTiming(uint _presaleStart,uint _stage1Start,uint _stage2Start,uint _stage3Start,uint _stage4Start,uint _saleEnd) onlyOwner {
        presaleStart = _presaleStart;
        stage1Start = _stage1Start;
        stage2Start = _stage2Start;
        stage3Start = _stage3Start;
        stage4Start = _stage4Start;
        saleEnd = _saleEnd;
    }

    function changeBonus(uint256 _presaleBonus,uint256 _stage1Bonus,uint256 _stage2Bonus,uint256 _stage3Bonus,uint256 _stage4Bonus) onlyOwner {
        presaleBonus = _presaleBonus;
        stage1Bonus = _stage1Bonus;
        stage2Bonus = _stage2Bonus;
        stage3Bonus = _stage3Bonus;
        stage4Bonus = _stage4Bonus;
    }

    function changeBuyingPrice(uint256 _buyingPrice) onlyOwner {
        buyingPrice = _buyingPrice;
    }

    function withdrawEther() onlyOwner payable returns (bool success) {
        require(owner.send(this.balance));

        EtherTransfer(this, msg.sender, this.balance);
        return true;
    }

    function destroyContract() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function () payable {
        uint256 tokens = msg.value / buyingPrice;

        if (presaleStart < now && stage1Start > now) {
            require(msg.value >= 30 ether);
        } else if (stage1Start < now && saleEnd > now) {
            require(tokens >= 20);
        } else {
            revert();
        }

        EtherTransfer(msg.sender, owner, msg.value);
    }

}