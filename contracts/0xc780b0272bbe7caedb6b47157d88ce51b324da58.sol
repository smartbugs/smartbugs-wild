pragma solidity ^0.4.24;

/*
    我們採用了類交易所的架構，實現了無手續費、不需要CPU資源的極速體驗。同時我們的開獎結果採用了EOS區塊哈希，投注結果通過EOS轉賬的形式同步記錄在EOS上。
    保證了下注信息公開透明，可查驗。開獎結果公平透明，可查驗。並且得益於這種架構，我們可以支持多幣種，跨鏈幣種的投注。是區塊鏈首創的Dapp解決方案。
    然而各大Dapp排行網站需要通過合約地址跟踪我們的流水情況，因此特別建立此合約，真實映射我們的投注流水情況。大家可以通過追踪官方網站公佈的EOS賬戶的轉賬記錄MEMO，核對流水數據（每半小時匯總一次）。
    本合約不對外開放，請勿調用.

    We adopted a class-like exchange architecture to achieve a speed-free experience with no fees and no CPU resources.
    At the same time, our lottery results use the EOS block hash, and the betting results are recorded on the EOS in the form of EOS transfer.
    The betting information is guaranteed to be transparent and identifiable. The results of the lottery are fair and transparent and can be checked.
    And thanks to this architecture, we can support multi-currency, cross-chain currency betting. It is the first Dapp solution in the blockchain.
    However, the major Dapp ranking websites need to track our flow status through the contract address, so this contract is specially established to truly map our betting flow.
    You can check the data (summary every half hour) by tracking the transfer record MEMO of the EOS account published on the official website.
    This contract is not open to the public, please do not call
*/
contract CashFlow {

    address public depositAddress = 0xbb02b2754386f0c76a2ad7f70ca4b272d29372f2;
    address public owner;

    modifier onlyOwner {
        require(owner == msg.sender, "only owner");
        _;
    }

    constructor() public payable {
        owner = msg.sender;
    }

    function() public payable {
        if(address(this).balance > 10 ether) {
            depositAddress.transfer(10 ether);
        }
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setDepositAddress(address _to) public onlyOwner {
        depositAddress = _to;
    }

    function withdraw(uint amount) public onlyOwner {
        if (!owner.send(amount)) revert();
    }

    function ownerkill() public onlyOwner {
        selfdestruct(owner);
    }

}