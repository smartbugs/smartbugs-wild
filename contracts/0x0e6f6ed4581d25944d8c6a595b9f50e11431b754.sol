pragma solidity ^0.4.22;

contract Token  {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function decreaseApproval (address _spender, uint _subtractedValue)public returns (bool success);

}

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract EternalStorage {

    /**** Storage Types *******/

    address public owner;

    mapping(bytes32 => uint256)    private uIntStorage;
    mapping(bytes32 => uint8)      private uInt8Storage;
    mapping(bytes32 => string)     private stringStorage;
    mapping(bytes32 => address)    private addressStorage;
    mapping(bytes32 => bytes)      private bytesStorage;
    mapping(bytes32 => bool)       private boolStorage;
    mapping(bytes32 => int256)     private intStorage;
    mapping(bytes32 => bytes32)    private bytes32Storage;


    /*** Modifiers ************/

    /// @dev Only allow access from the latest version of a contract after deployment
    modifier onlyLatestContract() {
        require(addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] != 0x0 || msg.sender == owner);
        _;
    }

    /// @dev constructor
    constructor() public {
        owner = msg.sender;
        addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] = msg.sender;
    }

    function setOwner() public {
        require(msg.sender == owner);
        addressStorage[keccak256(abi.encodePacked("contract.address", owner))] = 0x0;
        owner = msg.sender;
        addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] = msg.sender;
    }

    /**** Get Methods ***********/

    /// @param _key The key for the record
    function getAddress(bytes32 _key) external view returns (address) {
        return addressStorage[_key];
    }

    /// @param _key The key for the record
    function getUint(bytes32 _key) external view returns (uint) {
        return uIntStorage[_key];
    }

    /// @param _key The key for the record
    function getUint8(bytes32 _key) external view returns (uint8) {
        return uInt8Storage[_key];
    }


    /// @param _key The key for the record
    function getString(bytes32 _key) external view returns (string) {
        return stringStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes(bytes32 _key) external view returns (bytes) {
        return bytesStorage[_key];
    }

    /// @param _key The key for the record
    function getBytes32(bytes32 _key) external view returns (bytes32) {
        return bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function getBool(bytes32 _key) external view returns (bool) {
        return boolStorage[_key];
    }

    /// @param _key The key for the record
    function getInt(bytes32 _key) external view returns (int) {
        return intStorage[_key];
    }

    /**** Set Methods ***********/

    /// @param _key The key for the record
    function setAddress(bytes32 _key, address _value) onlyLatestContract external {
        addressStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint(bytes32 _key, uint _value) onlyLatestContract external {
        uIntStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setUint8(bytes32 _key, uint8 _value) onlyLatestContract external {
        uInt8Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setString(bytes32 _key, string _value) onlyLatestContract external {
        stringStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes(bytes32 _key, bytes _value) onlyLatestContract external {
        bytesStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBytes32(bytes32 _key, bytes32 _value) onlyLatestContract external {
        bytes32Storage[_key] = _value;
    }

    /// @param _key The key for the record
    function setBool(bytes32 _key, bool _value) onlyLatestContract external {
        boolStorage[_key] = _value;
    }

    /// @param _key The key for the record
    function setInt(bytes32 _key, int _value) onlyLatestContract external {
        intStorage[_key] = _value;
    }

    /**** Delete Methods ***********/

    /// @param _key The key for the record
    function deleteAddress(bytes32 _key) onlyLatestContract external {
        delete addressStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint(bytes32 _key) onlyLatestContract external {
        delete uIntStorage[_key];
    }

    /// @param _key The key for the record
    function deleteUint8(bytes32 _key) onlyLatestContract external {
        delete uInt8Storage[_key];
    }

    /// @param _key The key for the record
    function deleteString(bytes32 _key) onlyLatestContract external {
        delete stringStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes(bytes32 _key) onlyLatestContract external {
        delete bytesStorage[_key];
    }

    /// @param _key The key for the record
    function deleteBytes32(bytes32 _key) onlyLatestContract external {
        delete bytes32Storage[_key];
    }

    /// @param _key The key for the record
    function deleteBool(bytes32 _key) onlyLatestContract external {
        delete boolStorage[_key];
    }

    /// @param _key The key for the record
    function deleteInt(bytes32 _key) onlyLatestContract external {
        delete intStorage[_key];
    }
}

library PaymentLib {

    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(addresses[0], addresses[1], addresses[2], deal, amount));
    }

    function createPayment(
        address storageAddress, bytes32 paymentId, uint8 fee, uint8 status
    ) public {
        setPaymentStatus(storageAddress, paymentId, status);
        setPaymentFee(storageAddress, paymentId, fee);
    }

    function isCancelRequested(address storageAddress, bytes32 paymentId, address party)
    public view returns(bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)));
    }

    function setCancelRequested(address storageAddress, bytes32 paymentId, address party, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.cance", paymentId, party)), value);
    }

    function getPaymentFee(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.fee", paymentId)));
    }

    function setPaymentFee(address storageAddress, bytes32 paymentId, uint8 value)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.fee", paymentId)), value);
    }

    function isFeePayed(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)));
    }

    function setFeePayed(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.fee.payed", paymentId)), value);
    }

    function isDeposited(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.deposited", paymentId)));
    }

    function setDeposited(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.deposited", paymentId)), value);
    }

    function isSigned(address storageAddress, bytes32 paymentId)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.signed", paymentId)));
    }

    function setSigned(address storageAddress, bytes32 paymentId, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.signed", paymentId)), value);
    }

    function getPaymentStatus(address storageAddress, bytes32 paymentId)
    public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("payment.status", paymentId)));
    }

    function setPaymentStatus(address storageAddress, bytes32 paymentId, uint8 status)
    public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("payment.status", paymentId)), status);
    }

    function getOfferAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)));
    }

    function setOfferAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.refund", paymentId, user)), amount);
    }

    function getWithdrawAmount(address storageAddress, bytes32 paymentId, address user)
    public view returns (uint256) {
        return EternalStorage(storageAddress).getUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)));
    }

    function setWithdrawAmount(address storageAddress, bytes32 paymentId, address user, uint256 amount)
    public {
        EternalStorage(storageAddress).setUint(keccak256(abi.encodePacked("payment.amount.withdraw", paymentId, user)), amount);
    }

    function isWithdrawn(address storageAddress, bytes32 paymentId, address user)
    public view returns (bool) {
        return EternalStorage(storageAddress).getBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)));
    }

    function setWithdrawn(address storageAddress, bytes32 paymentId, address user, bool value)
    public {
        EternalStorage(storageAddress).setBool(keccak256(abi.encodePacked("payment.withdrawed", paymentId, user)), value);
    }

    function getPayment(address storageAddress, bytes32 paymentId)
    public view returns(
        uint8 status, uint8 fee, bool feePayed, bool signed, bool deposited
    ) {
        status = uint8(getPaymentStatus(storageAddress, paymentId));
        fee = getPaymentFee(storageAddress, paymentId);
        feePayed = isFeePayed(storageAddress, paymentId);
        signed = isSigned(storageAddress, paymentId);
        deposited = isDeposited(storageAddress, paymentId);
    }

    function getPaymentOffers(address storageAddress, address depositor, address beneficiary, bytes32 paymentId)
    public view returns(uint256 depositorOffer, uint256 beneficiaryOffer) {
        depositorOffer = getOfferAmount(storageAddress, paymentId, depositor);
        beneficiaryOffer = getOfferAmount(storageAddress, paymentId, beneficiary);
    }
}

contract Withdrawable is Ownable {
    function withdrawEth(uint value) external onlyOwner {
        require(address(this).balance >= value);
        msg.sender.transfer(value);
    }

    function withdrawToken(address token, uint value) external onlyOwner {
        require(Token(token).balanceOf(address(this)) >= value, "Not enough tokens");
        require(Token(token).transfer(msg.sender, value));
    }
}

contract IEscrow is Withdrawable {

    /*----------------------PAYMENT STATUSES----------------------*/

    //SIGNED status kept for backward compatibility
    enum PaymentStatus {NONE/*code=0*/, CREATED/*code=1*/, SIGNED/*code=2*/, CONFIRMED/*code=3*/, RELEASED/*code=4*/, RELEASED_BY_DISPUTE /*code=5*/, CLOSED/*code=6*/, CANCELED/*code=7*/}
    
    /*----------------------EVENTS----------------------*/

    event PaymentCreated(bytes32 paymentId, address depositor, address beneficiary, address token, bytes32 deal, uint256 amount, uint8 fee);
    event PaymentSigned(bytes32 paymentId, bool confirmed);
    event PaymentDeposited(bytes32 paymentId, uint256 depositedAmount, bool feePayed, bool confirmed);
    event PaymentReleased(bytes32 paymentId);
    event PaymentOffer(bytes32 paymentId, uint256 offerAmount);
    event PaymentOfferCanceled(bytes32 paymentId);
    event PaymentOwnOfferCanceled(bytes32 paymentId);
    event PaymentOfferAccepted(bytes32 paymentId, uint256 releaseToBeneficiary, uint256 refundToDepositor);
    event PaymentWithdrawn(bytes32 paymentId, uint256 amount);
    event PaymentWithdrawnByDispute(bytes32 paymentId, uint256 amount, bytes32 dispute);
    event PaymentCanceled(bytes32 paymentId);
    event PaymentClosed(bytes32 paymentId);
    event PaymentClosedByDispute(bytes32 paymentId, bytes32 dispute);

    /*----------------------PUBLIC STATE----------------------*/

    address public lib;
    address public courtAddress;
    address public paymentHolder;


    /*----------------------CONFIGURATION METHODS (only owner) ----------------------*/
    function setStorageAddress(address _storageAddress) external;

    function setCourtAddress(address _courtAddress) external;

    /*----------------------PUBLIC USER METHODS----------------------*/
    /** @dev Depositor creates escrow payment. Set token as 0x0 in case of ETH amount.
      * @param addresses [depositor, beneficiary, token]
      */
    function createPayment(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Beneficiary signs escrow payment as consent for taking part.
      * @param addresses [depositor, beneficiary, token]
      */
    function sign(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor deposits payment amount only after it was signed by beneficiary.
      * @param addresses [depositor, beneficiary, token]
      * @param payFee If true, depositor have to send (amount + (amount * fee) / 100).
      */
    function deposit(address[3] addresses, bytes32 deal, uint256 amount, bool payFee) external payable;

    /** @dev Depositor or Beneficiary requests payment cancellation after payment was signed by beneficiary.
      *      Payment is closed, if depositor and beneficiary both request cancellation.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancel(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor close payment though transfer payment amount to another party.
      * @param addresses [depositor, beneficiary, token]
      */
    function release(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary offers partial closing payment with offerAmount.
      * @param addresses [depositor, beneficiary, token]
      * @param offerAmount Amount of partial closing offer in currency of payment (ETH or token).
      */
    function offer(address[3] addresses, bytes32 deal, uint256 amount, uint256 offerAmount) external;

    /** @dev Depositor or beneficiary canceles another party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary cancels own offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOwnOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or beneficiary accepts opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function acceptOffer(address[3] addresses, bytes32 deal, uint256 amount) external;

   
    /** @dev Depositor or beneficiary withdraw amounts.
      * @param addresses [depositor, beneficiary, token]
      */
    function withdraw(address[3] addresses, bytes32 deal, uint256 amount) external;

    /** @dev Depositor or Beneficiary withdraw amounts according dispute verdict.
      * @dev Have to use fucking arrays due to "stack too deep" issue.
      * @param addresses [depositor, beneficiary, token]
      * @param disputeParties [applicant, respondent]
      * @param uints [paymentAmount, disputeAmount, disputeCreatedAt]
      * @param byts [deal, disputeTitle]
      */
    function withdrawByDispute(address[3] addresses, address[2] disputeParties, uint256[3] uints, bytes32[2] byts) external;
}

contract PaymentHolder is Ownable {

    modifier onlyAllowed() {
        require(allowed[msg.sender]);
        _;
    }

    modifier onlyUpdater() {
        require(msg.sender == updater);
        _;
    }

    mapping(address => bool) public allowed;
    address public updater;

    /*-----------------MAINTAIN METHODS------------------*/

    function setUpdater(address _updater)
    external onlyOwner {
        updater = _updater;
    }

    function migrate(address newHolder, address[] tokens, address[] _allowed)
    external onlyOwner {
        require(PaymentHolder(newHolder).update.value(address(this).balance)(_allowed));
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            uint256 balance = Token(token).balanceOf(this);
            if (balance > 0) {
                require(Token(token).transfer(newHolder, balance));
            }
        }
    }

    function update(address[] _allowed)
    external payable onlyUpdater returns(bool) {
        for (uint256 i = 0; i < _allowed.length; i++) {
            allowed[_allowed[i]] = true;
        }
        return true;
    }

    /*-----------------OWNER FLOW------------------*/

    function allow(address to) 
    external onlyOwner { allowed[to] = true; }

    function prohibit(address to)
    external onlyOwner { allowed[to] = false; }

    /*-----------------ALLOWED FLOW------------------*/

    function depositEth()
    public payable onlyAllowed returns (bool) {
        //Default function to receive eth
        return true;
    }

    function withdrawEth(address to, uint256 amount)
    public onlyAllowed returns(bool) {
        require(address(this).balance >= amount, "Not enough ETH balance");
        to.transfer(amount);
        return true;
    }

    function withdrawToken(address to, uint256 amount, address token)
    public onlyAllowed returns(bool) {
        require(Token(token).balanceOf(this) >= amount, "Not enough token balance");
        require(Token(token).transfer(to, amount));
        return true;
    }

}
contract EscrowConfig is Ownable {

    using EscrowConfigLib for address;

    address public config;

    constructor(address storageAddress) public {
        config = storageAddress;
    }

    function resetValuesToDefault() external onlyOwner {
        config.setPaymentFee(2);//%
    }

    function setStorageAddress(address storageAddress) external onlyOwner {
        config = storageAddress;
    }

    function getPaymentFee() external view returns (uint8) {
        return config.getPaymentFee();
    }

    //value - % of payment amount
    function setPaymentFee(uint8 value) external onlyOwner {
        require(value >= 0 && value < 100, "Fee in % of payment amount must be >= 0 and < 100");
        config.setPaymentFee(value);
    }
}
library EscrowConfigLib {

    function getPaymentFee(address storageAddress) public view returns (uint8) {
        return EternalStorage(storageAddress).getUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")));
    }

    function setPaymentFee(address storageAddress, uint8 value) public {
        EternalStorage(storageAddress).setUint8(keccak256(abi.encodePacked("escrow.config.payment.fee")), value);
    }

}
contract ICourt is Ownable {

    function getCaseId(address applicant, address respondent, bytes32 deal, uint256 date, bytes32 title, uint256 amount) 
        public pure returns(bytes32);

    function getCaseStatus(bytes32 caseId) public view returns(uint8);

    function getCaseVerdict(bytes32 caseId) public view returns(bool);
}

contract Escrow is IEscrow {
    using PaymentLib for address;
    using EscrowConfigLib for address;

    constructor(address storageAddress, address _paymentHolder, address _courtAddress) public {
        lib = storageAddress;
        courtAddress = _courtAddress;
        paymentHolder = _paymentHolder;
    }

    /*----------------------CONFIGURATION METHODS----------------------*/

    function setStorageAddress(address _storageAddress) external onlyOwner {
        lib = _storageAddress;
    }

    function setPaymentHolder(address _paymentHolder) external onlyOwner {
        paymentHolder = _paymentHolder;
    }

    function setCourtAddress(address _courtAddress) external onlyOwner {
        courtAddress = _courtAddress;
    }

    /*----------------------PUBLIC USER METHODS----------------------*/

    /** @dev Depositor creates escrow payment. Set token as 0x0 in case of ETH amount.
      * @param addresses [depositor, beneficiary, token]
      */
    function createPayment(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        require(addresses[0] != address(0));
        require(addresses[1] != address(0));
        require(addresses[0] != addresses[1], "Depositor and beneficiary can not be the same");
        require(deal != 0x0, "deal can not be 0x0");
        require(amount != 0, "amount can not be 0");
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.NONE);
        uint8 fee = lib.getPaymentFee();
        lib.createPayment(paymentId, fee, uint8(PaymentStatus.CREATED));
        emit PaymentCreated(paymentId, addresses[0], addresses[1], addresses[2], deal, amount, fee);
    }

    /** @dev Beneficiary signs escrow payment as consent for taking part.
      * @param addresses [depositor, beneficiary, token]
      */
    function sign(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyBeneficiary(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CREATED);
        lib.setSigned(paymentId, true);
        bool confirmed = lib.isDeposited(paymentId);
        if (confirmed) {
            setPaymentStatus(paymentId, PaymentStatus.CONFIRMED);
        }
        emit PaymentSigned(paymentId, confirmed);
    }

    /** @dev Depositor deposits payment amount only after it was signed by beneficiary
      * @param addresses [depositor, beneficiary, token]
      * @param payFee If true, depositor have to send (amount + (amount * fee) / 100).
      */
    function deposit(address[3] addresses, bytes32 deal, uint256 amount, bool payFee)
    external payable {
        onlyDepositor(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        PaymentStatus status = getPaymentStatus(paymentId);
        require(status == PaymentStatus.CREATED || status == PaymentStatus.SIGNED);
        uint256 depositAmount = amount;
        if (payFee) {
            depositAmount = amount + calcFee(amount, lib.getPaymentFee(paymentId));
            lib.setFeePayed(paymentId, true);
        }
        address token = getToken(addresses);
        if (token == address(0)) {
            require(msg.value == depositAmount, "ETH amount must be equal amount");
            require(PaymentHolder(paymentHolder).depositEth.value(msg.value)());
        } else {
            require(msg.value == 0, "ETH amount must be 0 for token transfer");
            require(Token(token).allowance(msg.sender, address(this)) >= depositAmount);
            require(Token(token).balanceOf(msg.sender) >= depositAmount);
            require(Token(token).transferFrom(msg.sender, paymentHolder, depositAmount));
        }
        lib.setDeposited(paymentId, true);
        bool confirmed = lib.isSigned(paymentId);
        if (confirmed) {
            setPaymentStatus(paymentId, PaymentStatus.CONFIRMED);
        }
        emit PaymentDeposited(paymentId, depositAmount, payFee, confirmed);
    }

    /** @dev Depositor or Beneficiary requests payment cancellation after payment was signed by beneficiary.
      *      Payment is closed, if depositor and beneficiary both request cancellation.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancel(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CREATED);
        setPaymentStatus(paymentId, PaymentStatus.CANCELED);
        if (lib.isDeposited(paymentId)) {
            uint256 amountToRefund = amount;
            if (lib.isFeePayed(paymentId)) {
                amountToRefund = amount + calcFee(amount, lib.getPaymentFee(paymentId));
            }
            transfer(getDepositor(addresses), amountToRefund, getToken(addresses));
        }
        setPaymentStatus(paymentId, PaymentStatus.CANCELED);
        emit PaymentCanceled(paymentId);
        emit PaymentCanceled(paymentId);
    }

    /** @dev Depositor close payment though transfer payment amount to another party.
      * @param addresses [depositor, beneficiary, token]
      */
    function release(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyDepositor(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        doRelease(addresses, [amount, 0], paymentId);
        emit PaymentReleased(paymentId);
    }

    /** @dev Depositor or beneficiary offers partial closing payment with offerAmount.
      * @param addresses [depositor, beneficiary, token]
      * @param offerAmount Amount of partial closing offer in currency of payment (ETH or token).
      */
    function offer(address[3] addresses, bytes32 deal, uint256 amount, uint256 offerAmount)
    external {
        onlyParties(addresses);
        require(offerAmount >= 0 && offerAmount <= amount, "Offer amount must be >= 0 and <= payment amount");
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        uint256 anotherOfferAmount = lib.getOfferAmount(paymentId, getAnotherParty(addresses));
        require(anotherOfferAmount == 0, "Sender can not make offer if another party has done the same before");
        lib.setOfferAmount(paymentId, msg.sender, offerAmount);
        emit PaymentOffer(paymentId, offerAmount);
    }

    /** @dev Depositor or beneficiary cancels opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function cancelOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        bytes32 paymentId = doCancelOffer(addresses, deal, amount, getAnotherParty(addresses));
        emit PaymentOfferCanceled(paymentId);
    }

    /** @dev Depositor or beneficiary cancels own offer.
    * @param addresses [depositor, beneficiary, token]
    */
    function cancelOwnOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        bytes32 paymentId = doCancelOffer(addresses, deal, amount, msg.sender);
        emit PaymentOwnOfferCanceled(paymentId);
    }

    /** @dev Depositor or beneficiary accepts opposite party offer.
      * @param addresses [depositor, beneficiary, token]
      */
    function acceptOffer(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        uint256 offerAmount = lib.getOfferAmount(paymentId, getAnotherParty(addresses));
        require(offerAmount != 0, "Sender can not accept another party offer of 0");
        uint256 toBeneficiary = offerAmount;
        uint256 toDepositor = amount - offerAmount;
        //if sender is beneficiary
        if (msg.sender == addresses[1]) {
            toBeneficiary = amount - offerAmount;
            toDepositor = offerAmount;
        }
        doRelease(addresses, [toBeneficiary, toDepositor], paymentId);
        emit PaymentOfferAccepted(paymentId, toBeneficiary, toDepositor);
    }

    /** @dev Depositor or beneficiary withdraw amounts.
      * @param addresses [depositor, beneficiary, token]
      */
    function withdraw(address[3] addresses, bytes32 deal, uint256 amount)
    external {
        onlyParties(addresses);
        bytes32 paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.RELEASED);
        require(!lib.isWithdrawn(paymentId, msg.sender), "User can not withdraw twice.");
        uint256 withdrawAmount = lib.getWithdrawAmount(paymentId, msg.sender);
        withdrawAmount = transferWithFee(msg.sender, withdrawAmount, addresses[2], paymentId);
        emit PaymentWithdrawn(paymentId, withdrawAmount);
        lib.setWithdrawn(paymentId, msg.sender, true);
        address anotherParty = getAnotherParty(addresses);
        if (lib.getWithdrawAmount(paymentId, anotherParty) == 0 || lib.isWithdrawn(paymentId, anotherParty)) {
            setPaymentStatus(paymentId, PaymentStatus.CLOSED);
            emit PaymentClosed(paymentId);
        }
    }

    /** @dev Depositor or Beneficiary withdraw amounts according dispute verdict.
      * @dev Have to use fucking arrays due to "stack too deep" issue.
      * @param addresses [depositor, beneficiary, token]
      * @param disputeParties [applicant, respondent]
      * @param uints [paymentAmount, disputeAmount, disputeCreatedAt]
      * @param byts [deal, disputeTitle]
      */
    function withdrawByDispute(address[3] addresses, address[2] disputeParties, uint256[3] uints, bytes32[2] byts)
    external {
        onlyParties(addresses);
        require(
            addresses[0] == disputeParties[0] && addresses[1] == disputeParties[1] || addresses[0] == disputeParties[1] && addresses[1] == disputeParties[0],
            "Depositor and beneficiary must be dispute parties"
        );
        bytes32 paymentId = getPaymentId(addresses, byts[0], uints[0]);
        PaymentStatus paymentStatus = getPaymentStatus(paymentId);
        require(paymentStatus == PaymentStatus.CONFIRMED || paymentStatus == PaymentStatus.RELEASED_BY_DISPUTE);
        require(!lib.isWithdrawn(paymentId, msg.sender), "User can not withdraw twice.");
        bytes32 dispute = ICourt(courtAddress).getCaseId(
            disputeParties[0] /*applicant*/, disputeParties[1]/*respondent*/,
            paymentId/*deal*/, uints[2]/*disputeCreatedAt*/,
            byts[1]/*disputeTitle*/, uints[1]/*disputeAmount*/
        );
        require(ICourt(courtAddress).getCaseStatus(dispute) == 3, "Case must be closed");
        /*[releaseAmount, refundAmount]*/
        uint256[2] memory withdrawAmounts = [uint256(0), 0];
        bool won = ICourt(courtAddress).getCaseVerdict(dispute);
        //depositor == applicant
        if (won) {
            //use paymentAmount if disputeAmount is greater
            withdrawAmounts[0] = uints[1] > uints[0] ? uints[0] : uints[1];
            withdrawAmounts[1] = uints[0] - withdrawAmounts[0];
        } else {
            //make full release
            withdrawAmounts[1] = uints[0];
        }
        if (msg.sender != disputeParties[0]) {
            withdrawAmounts[0] = withdrawAmounts[0] + withdrawAmounts[1];
            withdrawAmounts[1] = withdrawAmounts[0] - withdrawAmounts[1];
            withdrawAmounts[0] = withdrawAmounts[0] - withdrawAmounts[1];
        }
        address anotherParty = getAnotherParty(addresses);
        //if sender is depositor
        withdrawAmounts[0] = transferWithFee(msg.sender, withdrawAmounts[0], addresses[2], paymentId);
        emit PaymentWithdrawnByDispute(paymentId, withdrawAmounts[0], dispute);
        lib.setWithdrawn(paymentId, msg.sender, true);
        if (withdrawAmounts[1] == 0 || lib.isWithdrawn(paymentId, anotherParty)) {
            setPaymentStatus(paymentId, PaymentStatus.CLOSED);
            emit PaymentClosedByDispute(paymentId, dispute);
        } else {
            //need to prevent withdraw by another flow, e.g. simple release or offer accepting
            setPaymentStatus(paymentId, PaymentStatus.RELEASED_BY_DISPUTE);
        }
    }
    
    /*------------------PRIVATE METHODS----------------------*/
    function getPaymentId(address[3] addresses, bytes32 deal, uint256 amount)
    public pure returns (bytes32) {return PaymentLib.getPaymentId(addresses, deal, amount);}

    function getDepositor(address[3] addresses) private pure returns (address) {return addresses[0];}

    function getBeneficiary(address[3] addresses) private pure returns (address) {return addresses[1];}

    function getToken(address[3] addresses) private pure returns (address) {return addresses[2];}

    function getAnotherParty(address[3] addresses) private view returns (address) {
        return msg.sender == addresses[0] ? addresses[1] : addresses[0];
    }

    function onlyParties(address[3] addresses) private view {require(msg.sender == addresses[0] || msg.sender == addresses[1]);}

    function onlyDepositor(address[3] addresses) private view {require(msg.sender == addresses[0]);}

    function onlyBeneficiary(address[3] addresses) private view {require(msg.sender == addresses[1]);}

    function getPaymentStatus(bytes32 paymentId)
    private view returns (PaymentStatus) {
        return PaymentStatus(lib.getPaymentStatus(paymentId));
    }

    function setPaymentStatus(bytes32 paymentId, PaymentStatus status)
    private {
        lib.setPaymentStatus(paymentId, uint8(status));
    }

    function checkStatus(bytes32 paymentId, PaymentStatus status)
    private view {
        require(lib.getPaymentStatus(paymentId) == uint8(status), "Required status does not match actual one");
    }

    function doCancelOffer(address[3] addresses, bytes32 deal, uint256 amount, address from)
    private returns(bytes32 paymentId) {
        onlyParties(addresses);
        paymentId = getPaymentId(addresses, deal, amount);
        checkStatus(paymentId, PaymentStatus.CONFIRMED);
        uint256 offerAmount = lib.getOfferAmount(paymentId, from);
        require(offerAmount != 0, "Sender can not cancel offer of 0");
        lib.setOfferAmount(paymentId, from, 0);
    }

    /** @param addresses [depositor, beneficiary, token]
      * @param amounts [releaseAmount, refundAmount]
      */
    function doRelease(address[3] addresses, uint256[2] amounts, bytes32 paymentId)
    private {
        setPaymentStatus(paymentId, PaymentStatus.RELEASED);
        lib.setWithdrawAmount(paymentId, getBeneficiary(addresses), amounts[0]);
        lib.setWithdrawAmount(paymentId, getDepositor(addresses), amounts[1]);
    }

    function transferWithFee(address to, uint256 amount, address token, bytes32 paymentId)
    private returns (uint256 amountMinusFee) {
        require(amount != 0, "There is sense to invoke this method if withdraw amount is 0.");
        uint8 fee = 0;
        if (!lib.isFeePayed(paymentId)) {
            fee = lib.getPaymentFee(paymentId);
        }
        amountMinusFee = amount - calcFee(amount, fee);
        transfer(to, amountMinusFee, token);
    }   

    function transfer(address to, uint256 amount, address token)
    private {
        if (amount == 0) {
            return;
        }
        if (token == address(0)) {
            require(PaymentHolder(paymentHolder).withdrawEth(to, amount));
        } else {
            require(PaymentHolder(paymentHolder).withdrawToken(to, amount, token));
        }
    }

    function calcFee(uint amount, uint fee)
    private pure returns (uint256) {
        return ((amount * fee) / 100);
    }
}