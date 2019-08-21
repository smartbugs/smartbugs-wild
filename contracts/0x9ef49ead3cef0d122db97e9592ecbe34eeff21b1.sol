pragma solidity ^0.4.16;

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

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract GexCryptoPresale is owned {

    uint public presaleStart;
    uint public saleEnd;
    uint256 public presaleBonus;
    uint256 public buyingPrice;
    uint256 public totalInvestors;

    function GexCryptoPresale() {
        presaleStart = 1508011200; 
        saleEnd = 1512972000;
        presaleBonus = 30;
        buyingPrice = 350877190000000;
    }

    event EtherTransfer(address indexed _from,address indexed _to,uint256 _value);

    function changeTiming(uint _presaleStart,uint _saleEnd) onlyOwner {
        presaleStart = _presaleStart;
        saleEnd = _saleEnd;
    }

    function changeBonus(uint256 _presaleBonus) onlyOwner {
        presaleBonus = _presaleBonus;
    }

    function changeBuyingPrice(uint256 _buyingPrice) onlyOwner {
        buyingPrice = _buyingPrice;
    }

    function withdrawEther(address _account) onlyOwner payable returns (bool success) {
        require(_account.send(this.balance));

        EtherTransfer(this, _account, this.balance);
        return true;
    }

    function destroyContract() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }

    function () payable {
        uint256 tokens = msg.value / buyingPrice;
        totalInvestors = totalInvestors + 1;
        if (presaleStart < now && saleEnd > now) {
            require(msg.value >= 1 ether);
        } else {
            revert();
        }
    }

}