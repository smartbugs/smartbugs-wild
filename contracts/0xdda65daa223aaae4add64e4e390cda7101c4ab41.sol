// This contract just saves in the blockchain the intention to withdraw dth
// A Bot will execute this operation in the ETC blockchain and will save
// the result back
contract Owned {
    /// Prevents methods from perfoming any value transfer
    modifier noEther() {if (msg.value > 0) throw; _}
    /// Allows only the owner to call a function
    modifier onlyOwner { if (msg.sender == owner) _ }

    function Owned() { owner = msg.sender;}
    address owner;


    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
    }

    function execute(address _dst, uint _value, bytes _data) onlyOwner {
        _dst.call.value(_value)(_data);
    }

    function getOwner() noEther constant returns (address) {
        return owner;
    }
}

contract CrossWhitehatWithdraw is Owned {
    address bot;
    uint price;

    Operation[] public operations;

    modifier onlyBot { if ((msg.sender == owner)||(msg.sender == bot)) _ }

    struct Operation {
        address dth;
        address etcBeneficiary;
        uint percentage;
        uint queryTime;

        uint answerTime;
        uint result;
        bytes32 dthTxHash;
    }

    function CrossWhitehatWithdraw(uint _price, address _bot) Owned() {
        price = _price;
        bot = _bot;
    }

    function withdraw(address _etcBeneficiary, uint _percentage) returns (uint) {
        if (_percentage > 100) throw;
        if (msg.value < price) throw;
        Operation op = operations[operations.length ++];
        op.dth = msg.sender;
        op.etcBeneficiary = _etcBeneficiary;
        op.percentage = _percentage;
        op.queryTime = now;
        Withdraw(op.dth, op.etcBeneficiary, op.percentage, operations.length -1);

        return operations.length -1;
    }

    function setResult(uint _idOperation, uint _result, bytes32 _dthTxHash) onlyBot noEther {
        Operation op = operations[_idOperation];
        if (op.dth == 0) throw;
        op.answerTime = now;
        op.result = _result;
        op.dthTxHash = _dthTxHash;
        WithdrawResult(_idOperation, _dthTxHash, _result);
    }

    function setBot(address _bot) onlyOwner noEther  {
        bot = _bot;
    }

    function getBot() noEther constant returns (address) {
        return bot;
    }

    function setPrice(uint _price) onlyOwner noEther  {
        price = _price;
    }

    function getPrice() noEther constant returns (uint) {
        return price;
    }

    function getOperation(uint _idOperation) noEther constant returns (address dth,
        address etcBeneficiary,
        uint percentage,
        uint queryTime,
        uint answerTime,
        uint result,
        bytes32 dthTxHash)
    {
        Operation op = operations[_idOperation];
        return (op.dth,
                op.etcBeneficiary,
                op.percentage,
                op.queryTime,
                op.answerTime,
                op.result,
                op.dthTxHash);
    }

    function getOperationsNumber() noEther constant returns (uint) {
        return operations.length;
    }

    function() {
        throw;
    }

    function kill() onlyOwner {
        uint i;
        for (i=0; i<operations.length; i++) {
            Operation op = operations[i];
            op.dth =0;
            op.etcBeneficiary =0;
            op.percentage=0;
            op.queryTime=0;
            op.answerTime=0;
            op.result=0;
            op.dthTxHash=0;
        }
        operations.length=0;
        bot=0;
        price=0;
        selfdestruct(owner);
    }

    event Withdraw(address indexed dth, address indexed beneficiary, uint percentage, uint proposal);
    event WithdrawResult(uint indexed proposal, bytes32 indexed hash, uint result);


}