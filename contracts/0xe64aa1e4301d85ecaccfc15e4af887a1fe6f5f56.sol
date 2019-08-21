pragma solidity ^0.4.11;

contract MiningRig {
    // 警告
    string public warning = "請各位要有耐心等候交易完成喔";
    
    // 合約部署者
    address public owner = 0x0;
    
    // 合約停止合資的區塊，初始 0 
    uint public closeBlock = 0;
    
    // 大家一起合資的總新台幣
    uint public totalNTD = 0;
    
    // 這個合約過去總共被提領過的 reward
    uint public totalWithdrew = 0;
    
    // 使用者各自合資的新台幣
    mapping(address => uint) public usersNTD;
    
    // 使用者提領過的 ether
    mapping(address => uint) public usersWithdrew;
    
    // 只能 owner 才行 的修飾子
    modifier onlyOwner () {
        assert(owner == msg.sender);
        _;
    }
    
    // 在關閉合資前才行 的修飾子
    modifier beforeCloseBlock () {
        assert(block.number <= closeBlock);
        _;
    }
    
    // 在關閉合資後才行 的修飾子
    modifier afterCloseBlock () {
        assert(block.number > closeBlock);
        _;
    }
    
    // 只有有合資過的人才行 的修飾子
    modifier onlyMember () {
        assert(usersNTD[msg.sender] != 0);
        _;
    }
    
    // 建構子
    function MiningRig () {
        owner = msg.sender;
        closeBlock = block.number + 5760; // 一天的 block 數
    }
    
    // 合資，由舉辦人註冊 (因為是合資新台幣，所以必須中心化)
    function Register (address theUser, uint NTD) onlyOwner beforeCloseBlock {
        usersNTD[theUser] += NTD;
        totalNTD += NTD;
    }
    
    // 反合資
    function Unregister (address theUser, uint NTD) onlyOwner beforeCloseBlock {
        assert(usersNTD[theUser] >= NTD);
        
        usersNTD[theUser] -= NTD;
        totalNTD -= NTD;
    }
    
    // 提領所分配之以太幣
    function Withdraw () onlyMember afterCloseBlock {
        // 這個合約曾經得到過的 ether 等於現有 balance + 曾經被提領過的
        uint everMined = this.balance + totalWithdrew;
        
        // 這個 user 總共終究可以領的
        uint totalUserCanWithdraw = everMined * usersNTD[msg.sender] / totalNTD;
        
        // 這個 user 現在還可以領的
        uint userCanWithdrawNow = totalUserCanWithdraw - usersWithdrew[msg.sender];
        
        // 防止 reentrance 攻擊，先改狀態
        totalWithdrew += userCanWithdrawNow;
        usersWithdrew[msg.sender] += userCanWithdrawNow;

        assert(userCanWithdrawNow > 0);
        
        msg.sender.transfer(userCanWithdrawNow);
    }
    
    // 貼現轉讓
    // 轉讓之前必須把能領的 ether 領完
    function Cashing (address targetAddress, uint permilleToCashing) onlyMember afterCloseBlock {
        //permilleToCashing 是千分比
        assert(permilleToCashing <= 1000);
        assert(permilleToCashing > 0);
        
        // 這個合約曾經得到過的 ether 等於現有 balance + 曾經被提領過的
        uint everMined = this.balance + totalWithdrew;
        
        // 這個要發起轉讓的 user 總共終究可以領的
        uint totalUserCanWithdraw = everMined * usersNTD[msg.sender] / totalNTD;
        
        // 這個要發起轉讓的 user 現在還可以領的
        uint userCanWithdrawNow = totalUserCanWithdraw - usersWithdrew[msg.sender];
        
        // 要接收轉讓的 user 總共終究可以領的
        uint totalTargetUserCanWithdraw = everMined * usersNTD[targetAddress] / totalNTD;
        
        // 要接收轉讓的 user 現在還可以領的
        uint targetUserCanWithdrawNow = totalTargetUserCanWithdraw - usersWithdrew[targetAddress];
        
        // 發起轉讓及接收轉讓之前，雙方皆需要淨空可提領 ether
        assert(userCanWithdrawNow == 0);
        assert(targetUserCanWithdrawNow == 0);
        
        uint NTDToTransfer = usersNTD[msg.sender] * permilleToCashing / 1000;
        uint WithdrewToTransfer = usersWithdrew[msg.sender] * permilleToCashing / 1000;
        
        usersNTD[msg.sender] -= NTDToTransfer;
        usersWithdrew[msg.sender] -= WithdrewToTransfer;
        
        usersNTD[targetAddress] += NTDToTransfer;
        usersWithdrew[targetAddress] += WithdrewToTransfer;
    }
    
    function ContractBalance () constant returns (uint) {
        return this.balance;
    }
    
    function ContractTotalMined() constant returns (uint) {
        return this.balance + totalWithdrew;
    }
    
    function MyTotalNTD () constant returns (uint) {
        return usersNTD[msg.sender];
    }
    
    function MyTotalWithdrew () constant returns (uint) {
        return usersWithdrew[msg.sender];
    }
 
    function () payable {}
}