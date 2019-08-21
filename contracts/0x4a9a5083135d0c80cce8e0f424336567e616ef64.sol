pragma solidity ^0.4.25;

/**
 * CONTRACT FOR EtherGold.Me   V2.0
 * 
 * What's is EtherGold
 *  - 1% advertisement and PR expenses FEE
 *  - You can refund anytime
 *  - GAIN 2% ~ 3% (up on your deposited value) PER 24 HOURS (every 5900 blocks)
 *  - 0 ~ 1 ether     2% 
 *  - 1 ~ 10 ether    2.5%
 *  - over 10 ether   3% 
 * 
 * Multi-level Referral Bonus
 *  - 5% for Direct 
 *  - 3% for Second Level
 *  - 1% for Third Level
 * 
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *  OR
 *  2c. view on website: https://EtherGold.Me
 * 
 * How to refund:
 *  - Send 0.002 ether to refund
 *  - 1% refund fee
 *  - refundValue = (depositedValue - withdrewValue - refundFee) * 99%
 *  
 *
 * RECOMMENDED GAS LIMIT: 70000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros!
**/



library SafeMath {
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        if (_a == 0) {
            return 0;
        }
        c = _a * _b;
        assert(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        return _a / _b;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        assert(_b <= _a);
        return _a - _b;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
        c = _a + _b;
        assert(c >= _a);
        return c;
    }
}

library Address {
    function toAddress(bytes bys) internal pure returns (address addr) {
        assembly { addr := mload(add(bys, 20)) }
        return addr;
    }
}

contract EthGold {
    using SafeMath for uint256;
    using Address for *;
    address private devAddr;
    address private depositedLock;
    
    struct Investor {
        uint256 deposited;
        uint256 withdrew;
        address referrer;
        uint256 m_1_refCount;
        uint256 m_1_refValue;
        uint256 m_2_refCount;
        uint256 m_2_refValue;
        uint256 m_3_refCount;
        uint256 m_3_refValue;
        uint256 blockNumber;
        uint256 wallet;
    }
    
    mapping (address => Investor) private investors;
    uint256 public totalDepositedWei = 0;
    uint256 public totalWithdrewWei = 0;
    
    constructor() public {
        devAddr = msg.sender;
        depositedLock = msg.sender;
    }

    function getUserDeposited(address _address) public view returns(uint256) {
        return investors[_address].deposited;
    }
    
    function getUserWithdrew(address _address) public view returns(uint256) {
        return investors[_address].withdrew;
    }
    
    function userDividendsWei(address _address) public view returns (uint256) {
        uint256 userDeposited = investors[_address].deposited;
        
        // 0-1 ETH can dividend 2% every days;
        if ( userDeposited > 0 ether && userDeposited <= 1 ether) {
            return userDeposited.mul(2).div(100).mul(block.number-investors[_address].blockNumber).div(5900);
        }
        
        // 1-10 ETH can dividend 2.5% every days;
        if ( userDeposited > 1 ether && userDeposited <= 10 ether) {
            return userDeposited.mul(5).div(200).mul(block.number-investors[_address].blockNumber).div(5900);
        }
        
        // more than 10 ETH can dividend 3% every days;
        if ( userDeposited > 10 ether ) {
            return userDeposited.mul(3).div(100).mul(block.number-investors[_address].blockNumber).div(5900);
        }
		
    }
    
    function() public payable {
        if ( msg.value == 0 ether ) {
            withdraw();
        } else if ( msg.value == 0.002 ether) {
            refund(msg.sender);
        } else {
            doInvest(msg.data.toAddress(), msg.value);    
        }
    }
    
    function getBalance() public view returns(uint256){
        return address(this).balance;
    }
    
    function getUserInfo(address _addr) public view returns(uint256 deposited, 
            uint256 withdrew,
            address referrer,
            uint256 m_1_refCount,
            uint256 m_1_refValue,
            uint256 m_2_refCount,
            uint256 m_2_refValue,
            uint256 m_3_refCount,
            uint256 m_3_refValue,
            uint256 wallet) {
        deposited = investors[_addr].deposited;
        withdrew = investors[_addr].withdrew;
        referrer = investors[_addr].referrer;
        m_1_refCount = investors[_addr].m_1_refCount;
        m_1_refValue = investors[_addr].m_1_refValue;
        m_2_refCount = investors[_addr].m_2_refCount;
        m_2_refValue = investors[_addr].m_2_refValue;
        m_3_refCount = investors[_addr].m_3_refCount;
        m_3_refValue = investors[_addr].m_3_refValue;
        wallet = investors[_addr].wallet;
    }
    
    function transferMoney(address _address, uint256 _value) private {
        uint256 contractBalance = getBalance();
        if (contractBalance < _value) {
            _address.transfer(contractBalance);    
        } else {
            _address.transfer(_value);    
        }
    }
    
    function withdraw() public {
        if (investors[msg.sender].deposited != 0 && block.number > investors[msg.sender].blockNumber) {
            uint256 depositsPercents = userDividendsWei(msg.sender);
            uint256 walletAmount = investors[msg.sender].wallet;
            investors[msg.sender].wallet = 0;
            investors[msg.sender].withdrew += (depositsPercents + walletAmount);
            transferMoney(msg.sender, depositsPercents + walletAmount);
            totalWithdrewWei = totalWithdrewWei.add(depositsPercents + walletAmount);
        }
    }
    
    function doInvest(address referrer, uint256 value) internal {
        // 1% for dev fee.
        investors[devAddr].wallet += value.mul(1).div(100); 
        if (referrer > 0x0 && referrer != msg.sender && investors[msg.sender].referrer == 0x0){
            investors[msg.sender].referrer = referrer;
        }
        
        uint256 m1ref;
        uint256 m2ref;
        uint256 m3ref;
        address m1refAddr = investors[msg.sender].referrer;
        address m2refAddr = investors[m1refAddr].referrer;
        address m3refAddr = investors[m2refAddr].referrer;
        
        // 5% for Direct 
        if ( m1refAddr > 0x0 ) {
            
            uint256 m1refDeposited = investors[m1refAddr].deposited;
            
            if ( m1refDeposited > value ) {
                m1ref = value.mul(5).div(100);
            } else {
                m1ref = m1refDeposited.mul(5).div(100);
            }
            
            investors[m1refAddr].wallet += m1ref;
            investors[m1refAddr].m_1_refValue += m1ref;
            investors[m1refAddr].m_1_refCount += 1;
            
            //  3% for Second Level
            if( m2refAddr > 0x0 && m2refAddr != msg.sender && m2refAddr != m1refAddr){
                
                uint256 m2refDeposited = investors[m2refAddr].deposited;
                
                if ( m2refDeposited > value ) {
                    m2ref = value.mul(3).div(100);
                } else {
                    m2ref = m2refDeposited.mul(3).div(100);
                }
                
                investors[m2refAddr].wallet += m2ref;
                investors[m2refAddr].m_2_refValue += m2ref;
                investors[m2refAddr].m_2_refCount += 1;
                
                //  1% for Third Level
                if( m3refAddr > 0x0 && m3refAddr != msg.sender && m3refAddr != m1refAddr && m3refAddr != m2refAddr){
                    
                    uint256 m3refDeposited = investors[m3refAddr].deposited;
                    
                    if ( m3refDeposited > value ) {
                        m3ref = value.mul(1).div(100);
                    } else {
                        m3ref = m3refDeposited.mul(1).div(100);
                    }
                    
                    investors[m3refAddr].wallet += m3ref;
                    investors[m3refAddr].m_3_refValue += m3ref;
                    investors[m3refAddr].m_3_refCount += 1;
                }
            }
        }

        investors[msg.sender].deposited += value;
        investors[msg.sender].blockNumber = block.number;
        totalDepositedWei = totalDepositedWei.add(value);
    }
    
    function reIvest() public {
        uint256 wallet = investors[msg.sender].wallet;
        uint256 dividends = userDividendsWei(msg.sender);
        uint256 reinvestment = wallet + dividends;
        investors[msg.sender].wallet = 0;
        investors[msg.sender].blockNumber = block.number;
        investors[msg.sender].withdrew += reinvestment;
        totalWithdrewWei += reinvestment;
        doInvest(investors[msg.sender].referrer, reinvestment);
    }
    
    function newInvest(address referrer) payable public{
        doInvest(referrer, msg.value);
    }
    
    function refund(address _exitUser) internal {
        uint256 refundValue = (investors[_exitUser].deposited - investors[_exitUser].withdrew).mul(90).div(100);
        
        // refund need 1% fee.
        if ( _exitUser != devAddr ) {
            uint256 refundDevFee = refundValue.mul(1).div(100);
            refundValue -= refundDevFee;
            investors[devAddr].wallet += refundDevFee;
            investors[depositedLock].wallet = totalDepositedWei - refundDevFee;   
        }
        
        if ( refundValue > 0 ) {
            transferMoney(_exitUser, refundValue);
            totalDepositedWei -= refundValue;
            investors[_exitUser].deposited = 0;
            investors[_exitUser].withdrew = 0;    
        }
    }
}