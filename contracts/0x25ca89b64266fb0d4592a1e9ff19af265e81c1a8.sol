/** 
 * @notice Smartex Controller
 * @author Christopher Moore cmoore@smartex.io - Smartex.io Ltd. 2016 - https://smartex.io
 */

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

/** 
 * @notice Smartex Invoice
 * @author Christopher Moore cmoore@smartex.io - Smartex.io Ltd. 2016 - https://smartex.io
 */
contract SmartexInvoice is owned {

    address sfm;

    /** 
     * @notice Incoming transaction Event
     * @notice Logs : block number, sender, value, timestamp
     */
    event IncomingTx(
        uint indexed blockNumber,
        address sender,
        uint value,
        uint timestamp
    );

    /** 
     * @notice Refund Invoice Event
     * @notice Logs : invoice address, timestamp
     */
    event RefundInvoice(
        address invoiceAddress,
        uint timestamp
    );

    /**
     * @notice Invoice constructor
     */
    function SmartexInvoice(address target, address owner) {
        sfm = target;
        transferOwnership(owner);
    }


    /**
     * @notice Refund invoice  
     * @param recipient (address refunded)
     */
    function refund(address recipient) onlyOwner {
        RefundInvoice(address(this), now);
    }


    function sweep(address _to) payable onlyOwner {
            if (!_to.send(this.balance)) throw; 
    }
    
    function advSend(address _to, uint _value, bytes _data)  onlyOwner {
            _to.call.value(_value)(_data);
    }

    /**
     * @notice anonymous function
     * @notice Triggered by invalid function calls and incoming transactions
     */
    function() payable {
        IncomingTx(block.number, msg.sender, msg.value, now);
    }

}