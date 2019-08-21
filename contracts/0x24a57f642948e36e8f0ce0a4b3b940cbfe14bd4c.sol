pragma solidity ^0.4.8;


// 'interface':
//  this is expected from another contract,
//  where tokens (ERC20) are managed
contract Erc20TokensContract {
    function transfer(address _to, uint256 _value);
    // returns (bool success); // not in CoinOffering Corporation.sol
    function balanceOf(address acc) returns (uint);
}


contract ICO {

    Erc20TokensContract erc20TokensContract;

    address public erc20TokensContractAddress;

    bool erc20TokensContractSet = false;

    // address public erc20TokensContractAddress;
    // bool erc20TokensContractAddressSet = false;

    uint public priceToBuyInFinney; // price in finney (0.001 ETH)
    uint priceToBuyInWei; // --> to reduce gas in buyTokens

    address public owner;

    mapping (address => bool) public isManager; // holds managers

    // for price chart:
    mapping (uint => uint[3]) public priceChange;
    // number of change => [priceToBuyInFinney, block.number, block.timestamp]
    uint public currentPriceChangeNumber = 0;

    // for deals chart:
    mapping (uint => uint[4]) public deals;
    // number of change => [priceInFinney, quantity, block.number, block.timestamp]
    uint public dealsNumber = 0;

    /* ---- Creates contract */
    function ICO() {// - truffle compiles only no args Constructor
        owner = msg.sender;
        isManager[msg.sender] = true;
        priceToBuyInFinney = 0;
        // with price 0 tokens sale stopped
        priceToBuyInWei = finneyToWei(priceToBuyInFinney);
        priceChange[0] = [priceToBuyInFinney, block.number, block.timestamp];
    }

    function setErc20TokensContract(address _erc20TokensContractAddress) returns (bool){
        if (msg.sender != owner) {throw;}
        if (erc20TokensContractSet) {throw;}
        erc20TokensContract = Erc20TokensContract(_erc20TokensContractAddress);
        erc20TokensContractAddress = _erc20TokensContractAddress;
        erc20TokensContractSet = true;
        TokensContractAddressSet(_erc20TokensContractAddress, msg.sender);
        return true;
    }

    event TokensContractAddressSet(address tokensContractAddress, address setBy);

    /* ------- Utilities:  */
    //    function weiToEther(uint _wei) internal returns (uint){
    //        return _wei / 1000000000000000000;
    //    }
    //
    //    function etherToWei(uint _ether) internal returns (uint){
    //        return _ether * 1000000000000000000;
    //    }

    function weiToFinney(uint _wei) internal returns (uint){
        return _wei / (1000000000000000000 * 1000);
    }

    function finneyToWei(uint _finney) internal returns (uint){
        return _finney * (1000000000000000000 / 1000);
    }

    /* --- universal Event */
    event Result(address transactionInitiatedBy, string message);

    /* administrative functions */
    // change owner:
    function changeOwner(address _newOwner) returns (bool){
        if (msg.sender != owner) {throw;}
        owner = _newOwner;
        isManager[_newOwner] = true;
        OwnerChanged(msg.sender, owner);
        return true;
    }

    event OwnerChanged(address oldOwner, address newOwner);

    // --- set managers
    function setManager(address _newManager) returns (bool){
        if (msg.sender == owner) {
            isManager[_newManager] = true;
            ManagersChanged("manager added", _newManager);
            return true;
        }
        else throw;
    }

    // remove managers
    function removeManager(address _manager) returns (bool){
        if (msg.sender == owner) {
            isManager[_manager] = false;
            ManagersChanged("manager removed", _manager);
            return true;
        }
        else throw;
    }

    event ManagersChanged(string change, address manager);

    // set new price for tokens:
    function setNewPriceInFinney(uint _priceToBuyInFinney) returns (bool){

        if (msg.sender != owner || !isManager[msg.sender]) {throw;}

        priceToBuyInFinney = _priceToBuyInFinney;
        priceToBuyInWei = finneyToWei(priceToBuyInFinney);
        currentPriceChangeNumber++;
        priceChange[currentPriceChangeNumber] = [priceToBuyInFinney, block.number, block.timestamp];
        PriceChanged(priceToBuyInFinney, msg.sender);
        return true;
    }

    event PriceChanged(uint newPriceToBuyInFinney, address changedBy);

    function getPriceChange(uint _index) constant returns (uint[3]){
        return priceChange[_index];
        // array
    }

    // ---- buy tokens:
    // if you get message:
    // "It seems this transaction will fail. If you submit it, it may consume
    // all the gas you send",
    // or
    // "The contract won't allow this transaction to be executed"
    // that may be means that price has changed, just wait a few minutes
    // and repeat transaction
    function buyTokens(uint _quantity, uint _priceToBuyInFinney) payable returns (bool){

        if (priceToBuyInFinney <= 0) {throw;}
        // if priceToBuy == 0 selling stops;

        // if (_priceToBuyInFinney <= 0) {throw;}
        // if (_quantity <= 0) {throw;}

        if (priceToBuyInFinney != _priceToBuyInFinney) {
            //    Result(msg.sender, "transaction failed: price already changed");
            throw;
        }

        if (
        (msg.value / priceToBuyInWei) != _quantity
        ) {
            // Result(msg.sender, "provided sum is not correct for this amount of tokens");
            throw;
        }
        // if everything is O.K. make transfer (~ 37046 gas):
        // check balance in token contract:
        uint currentBalance = erc20TokensContract.balanceOf(this);
        if (erc20TokensContract.balanceOf(this) < _quantity) {throw;}
        else {
            // make transfer
            erc20TokensContract.transfer(msg.sender, _quantity);
            // check if tx changed erc20TokensContract:
            if (currentBalance == erc20TokensContract.balanceOf(this)) {
                throw;
            }
            // record this :
            dealsNumber = dealsNumber + 1;
            deals[dealsNumber] = [_priceToBuyInFinney, _quantity, block.number, block.timestamp];
            // event
            Deal(msg.sender, _priceToBuyInFinney, _quantity);
            return true;
        }
    }

    // event BuyTokensError(address transactionFrom, string error); // if throw - no events

    event Deal(address to, uint priceInFinney, uint quantity);

    function transferTokensTo(address _to, uint _quantity) returns (bool) {

        if (msg.sender != owner) {throw;}
        if (_quantity <= 0) {throw;}

        // check balance in token contract:
        if (erc20TokensContract.balanceOf(this) < _quantity) {
            throw;

        }
        else {
            // make transfer
            erc20TokensContract.transfer(_to, _quantity);
            // event:
            TokensTransfer(msg.sender, _to, _quantity);
            return true;
        }
    }

    function transferAllTokensToOwner() returns (bool) {
        return transferTokensTo(owner, erc20TokensContract.balanceOf(this));
    }

    event TokensTransfer (address from, address to, uint quantity);

    function transferTokensToContractOwner(uint _quantity) returns (bool) {
        return transferTokensTo(msg.sender, _quantity);
    }

    /* --- functions for ETH */
    function withdraw(uint _sumToWithdrawInFinney) returns (bool) {
        if (msg.sender != owner) {throw;}
        if (_sumToWithdrawInFinney <= 0) {throw;}
        if (this.balance < finneyToWei(_sumToWithdrawInFinney)) {
            throw;
        }

        if (msg.sender == owner) {// double check

            if (!msg.sender.send(finneyToWei(_sumToWithdrawInFinney))) {// makes withdrawal and returns true or false
                //  Withdrawal(msg.sender, _sumToWithdrawInFinney, "withdrawal: failed");
                return false;
            }
            else {
                Withdrawal(msg.sender, _sumToWithdrawInFinney, "withdrawal: success");
                return true;
            }
        }
    }

    function withdrawAllToOwner() returns (bool) {
        return withdraw(this.balance);
    }

    event Withdrawal(address to, uint sumToWithdrawInFinney, string message);

}