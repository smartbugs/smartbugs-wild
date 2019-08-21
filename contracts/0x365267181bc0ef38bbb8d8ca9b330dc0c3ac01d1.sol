/* version metahash ETH multi sign wallet 0.1.5 RC */
pragma solidity ^0.4.18;

contract mhethkeeper {

    /* contract settings */

    /* dynamic data section */
    address public recipient;           /* recipient */
    uint256 public amountToTransfer;        /* quantity */


    /* static data section */
    bool public isFinalized;            /* settings are finalized */
    uint public minVotes;               /* minimum amount of votes */
    uint public curVotes;               /* current amount of votes */
    address public owner;               /* contract creator */
    uint public mgrCount;               /* number of managers */
    mapping (uint => bool) public mgrVotes;     /* managers votes */
    mapping (uint => address) public mgrAddress; /* managers address */

    /* constructor */
    function mhethkeeper() public{
        owner = msg.sender;
        isFinalized = false;
        curVotes = 0;
        mgrCount = 0;
        minVotes = 2;
    }

    /* add a wallet manager */
    function AddManager(address _manager) public{
        if (!isFinalized && (msg.sender == owner)){
            mgrCount = mgrCount + 1;
            mgrAddress[mgrCount] = _manager;
            mgrVotes[mgrCount] = false;
        } else {
            revert();
        }
    }

    /* finalize settings */
    function Finalize() public{
        if (!isFinalized && (msg.sender == owner)){
            isFinalized = true;
        } else {
            revert();
        }
    }

    /* set a new action and set a value of zero on a vote */
    function SetAction(address _recipient, uint256 _amountToTransfer) public{
        if (!isFinalized){
            revert();
        }

        if (IsManager(msg.sender)){
            if (this.balance < _amountToTransfer){
                revert();
            }
            recipient = _recipient;
            amountToTransfer = _amountToTransfer;
            
            for (uint i = 1; i <= mgrCount; i++) {
                mgrVotes[i] = false;
            }
            curVotes = 0;
        } else {
            revert();
        }
    }

    /* manager votes for the action */
    function Approve(address _recipient, uint256 _amountToTransfer) public{
        if (!isFinalized){
            revert();
        }
        if (!((recipient == _recipient) && (amountToTransfer == _amountToTransfer))){
            revert();
        }

        for (uint i = 1; i <= mgrCount; i++) {
            if (mgrAddress[i] == msg.sender){
                if (!mgrVotes[i]){
                    mgrVotes[i] = true;
                    curVotes = curVotes + 1;

                    if (curVotes >= minVotes){
                        recipient.transfer(amountToTransfer);
                        NullSettings();
                    } 
                } else {
                    revert();
                }
            }
        }
    }

    /* set a default payable function */
    function () public payable {}
    
    /* set default empty settings  */
    function NullSettings() private{
        recipient = address(0x0);
        amountToTransfer = 0;
        curVotes = 0;
        for (uint i = 1; i <= mgrCount; i++) {
            mgrVotes[i] = false;
        }

    }

    /* check that the sender is a manager */
    function IsManager(address _manager) private view returns(bool){
        for (uint i = 1; i <= mgrCount; i++) {
            if (mgrAddress[i] == _manager){
                return true;
            }
        }
        return false;
    }
}