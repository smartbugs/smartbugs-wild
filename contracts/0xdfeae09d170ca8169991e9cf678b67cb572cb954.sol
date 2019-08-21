pragma solidity ^0.4.25;

contract opterium {
    /*
 *   See: http://opterium.ru/
 * 
 *   No one can change this smart contract, including the community creators.  
 *   The profit is : (interest is accrued continuously).
 * Up to 100  ETH = 1.0 % in 36 hours of your invested amount
 * From 100   ETH = 1.5 % in 36 hours *
 * From 200   ETH = 1.8 % in 36 hours *
 * From 500   ETH = 2.0 % in 36 hours *
 * From 1000  ETH = 1.6 % in 36 hours *
 * From 3000  ETH = 1.4 % in 36 hours *
 * From 5000  ETH = 1.2 % in 36 hours *
 * From 7000  ETH = 1.0 % in 36 hours *
 * From 10000 ETH = 2.5 % in 36 hours *
 *   Minimum deposit is 0.011 ETH.
 *
 *  How to make a deposit:
 *   Send cryptocurrency from ETH wallet (at least 0.011 ETH) to the address
 *   of the smart contract - opterium
 *   It is not allowed to make transfers from cryptocurrency exchanges.
 *   Only personal ETH wallet with private keys is allowed.
 * 
 *   Recommended limits are 200000 ETH, check the current ETH rate at
 *   the following link: https://ethgasstation.info/
 * 
 * How to get paid:
 *   Request your profit by sending 0 ETH to the address of the smart contract.
 *
  */  
    
    mapping (address => uint256) public invested;
    mapping (address => uint256) public atBlock;
    address techSupport = 0x720497fce7D8f7D7B89FB27E5Ae48b7DA884f582;
    uint techSupportPercent = 2;
    address defaultReferrer = 0x720497fce7D8f7D7B89FB27E5Ae48b7DA884f582;
    uint refPercent = 2;
    uint refBack = 2;

    function calculateProfitPercent(uint bal) private pure returns (uint) {
        if (bal >= 1e22) {
            return 25;
        }
        if (bal >= 7e21) {
            return 10;
        }
        if (bal >= 5e21) {
            return 12;
        }
        if (bal >= 3e21) {
            return 14;
        }
        if (bal >= 1e21) {
            return 16;
        }
        if (bal >= 5e20) {
            return 20;
        }
        if (bal >= 2e20) {
            return 18;
        }
        if (bal >= 1e20) {
            return 15;
        } else {
            return 10;
        }
    }

    function transferDefaultPercentsOfInvested(uint value) private {
        techSupport.transfer(value * techSupportPercent / 100);
    }

    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }

    function transferRefPercents(uint value, address sender) private {
        if (msg.data.length != 0) {
            address referrer = bytesToAddress(msg.data);
            if(referrer != sender) {
                sender.transfer(value * refBack / 100);
                referrer.transfer(value * refPercent / 100);
            } else {
                defaultReferrer.transfer(value * refPercent / 100);
            }
        } else {
            defaultReferrer.transfer(value * refPercent / 100);
        }
    }

  
    function () external payable {
        if (invested[msg.sender] != 0) {
            
            uint thisBalance = address(this).balance;
            uint amount = invested[msg.sender] * calculateProfitPercent(thisBalance) / 1000 * (block.number - atBlock[msg.sender]) / 9150;

            address sender = msg.sender;
            sender.transfer(amount);
        }
        if (msg.value > 0) {
            transferDefaultPercentsOfInvested(msg.value);
            transferRefPercents(msg.value, msg.sender);
        }
        atBlock[msg.sender] = block.number;
        invested[msg.sender] += (msg.value);
    }
}