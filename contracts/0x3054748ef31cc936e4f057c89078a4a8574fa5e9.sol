pragma solidity ^0.5.8;

/*
 * 컨트랙트 개요
 * 1. 목적
 *  메인넷 운영이 시작되기 전까지 한시적인 운영을 목적으로 하고 있다.
 *  메인넷이 운영되면 컨트랙트의 거래는 모두 중단되며, 메인넷 코인트로 전환을 시작하며,
 *  전환 절차를 간단하게 수행할 수 있으며, 블록체인 내 기록을 통해 신뢰도를 얻을 수 있도록 설계 되었다.
 * 2. 용어 설명
 *  Owner : 컨트랙트를 생성한 컨트랙트의 주인
 *  Delegator : Owner의 Private Key를 매번 사용하기에는 보안적인 이슈가 발생할 수 있기 때문에 도입된
 *              일부 Owner 권한을 실행할 수 있도록 임명한 대행자
 *              특히, 컨트랙트의 거래가 중단된 상태에서 Delegator만 실행할 수 있는 전용 함수를 실행하여
 *              컨트랙트의 토큰을 회수하고, 메인넷의 코인으로 전환해주는 핵심적인 기능을 수행
 *  Holder : 토큰을 보유할 수 있는 Address를 가지고 있는 계정
 * 3. 운용
 *  3.1. TokenContainer Structure
 *   3.1.1 Charge Amount
 *    Charge Amount는 Holder가 구매하여 충전한 토큰량입니다.
 *    Owner의 경우에는 컨트랙트 전체에 충전된 토큰량. 즉, Total Supply와 같습니다.
 *   3.1.2 Unlock Amount
 *    기본적으로 모든 토큰은 Lock 상태인 것이 기본 상태이며, Owner 또는 Delegator가 Unlock 해준 만큼 Balance로 전환됩니다.
 *    Unlock Amount는 Charge Amount 중 Unlock 된 만큼만 표시합니다.
 *    Unlock Amount는 Charge Amount 보다 커질 수 없습니다.
 *   3.1.3 Balance
 *    ERC20의 Balance와 같으며, 기본적으로는 Charge Amount - Unlock Amount 값에서 부터 시작합니다.
 *    자유롭게 거래가 가능하므로 Balance는 더 크거나 작아질 수 있습니다.
 * 4. 토큰 -> 코인 전환 절차
 *  4.1. Owner 권한으로 컨트랙트의 거래를 완전히 중단 시킴(lock())
 *  4.2. 교환을 실행하기 위한 ExchangeContract를 생성
 *  4.3. ExchangeContract의 Address를 Owner의 권한으로 Delegator로 지정
 *  4.4. Holder가 ExchangeContract의 exchangeSYM()을 실행하여 잔액을 ExchangeHolder에게 모두 전달
 *  4.5. ExchangeHolder로의 입금을 확인
 *  4.6. 요청에 대응되는 메인넷의 계정으로 해당되는 양만큼 송금
 *  4.7. ExchangeContract의 withdraw()를 사용하여 Owner가 최종적으로 회수하는 것으로 전환절차 완료
 */
 /*
  *  * Contract Overview 
 * 1. Purpose
 *  It is intended to operate for a limited time until mainnet launch.
 *  When the mainnet is launched, all transactions of the contract will be suspended from that day on forward and will initiate the token swap to the mainnet.
 * 2. Key Definitions
 *  Owner : An entity from which smart contract is created
 *  Delegator : The appointed agent is created to prevent from using the contract owner's private key for every transaction made, since it can cause a serious security issue.  
 *              In particular, it performs core functons at the time of the token swap event, such as executing a dedicated, Delegator-specific function while contract transaction is under suspension and
 *              withdraw contract's tokens. 
 *  Holder : An account in which tokens can be stored (also referrs to all users of the contract: Owner, Delegator, Spender, ICO buyers, ect.)
 * 3. Operation
 *  3.1. TokenContainer Structure
 *   3.1.1 Charge Amount
 *    Charge Amount is the charged token amount purcahsed by Holder.
 *    In case for the Owner, the total charged amount in the contract equates to the Total Supply.
 *   3.1.2 Unlock Amount
 *    Generally, all tokens are under a locked state by default and balance appears according to the amount that Owner or Delegator Unlocks.
 *    Unlock Amount only displays tokens that are unlocked from the Charge Amount.
 *    Unlock Amount cannot be greater than the Charge Amount.
 *   3.1.3 Balance
 *     Similiar to the ERC20 Balance; It starts from Charged Amount - Unlock Amount value.
 *     You can send & receive tokens at will and it will offset the Balance amount accordingly.
 * 4. Token Swap Process
 *  4.1. Completely suspend trading operations from the contract address with owner privileges (lock ()).
 *  4.2. Create an ExchangeContract contract to execute the exchange.
 *  4.3. Owner appoints the ExchangeContract address to the Delegator.
 *  4.4. The Holder executes an exchangeSYM() embedded in the ExchangeContract to transfer all the Balance to ExchangeHolder
 *  4.5. Verify ExchangeHolder's deposit amount. 
 *  4.6. Remit an appropriate amount into the mainnet account that corresponds to the request.  
 *  4.7. By using the ExchangeContract's withdraw(), the token swap process completes as the Owner makes the final withdrawal.
  */

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /*
     * 운용상 Owner 변경은 사용하지 않으므로 권한 변경 함수 제거하였다.
     */
    /*
     * The privilege change function is removed since the Owner change isn't used during the operation.
     */
    /* not used
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    */
}

/*
 * Owner의 권한 중 일부를 대신 행사할 수 있도록 대행자를 지정/해제 할 수 있는 인터페이스를 정의하고 있다.
 */
 /*
 * It defines an interface where the Owner can appoint / dismiss an agent that can partially excercize privileges in lieu of the Owner's 
 */
contract Delegable is Ownable {
    address private _delegator;
    
    event DelegateAppointed(address indexed previousDelegator, address indexed newDelegator);
    
    constructor () internal {
        _delegator = address(0);
    }
    
    /*
     * delegator를 가져옴
     */
    /*
     * Call-up Delegator
     */
    function delegator() public view returns (address) {
        return _delegator;
    }
    
    /*
     * delegator만 실행 가능하도록 지정하는 접근 제한
     */
    /*
     * Access restriction in which only appointed delegator is executable
     */
    modifier onlyDelegator() {
        require(isDelegator());
        _;
    }
    
    /*
     * owner 또는 delegator가 실행 가능하도록 지정하는 접근 제한
     */
    /*
     * Access restriction in which only appointed delegator or Owner are executable
     */
    modifier ownerOrDelegator() {
        require(isOwner() || isDelegator());
        _;
    }
    
    function isDelegator() public view returns (bool) {
        return msg.sender == _delegator;
    }
    
    /*
     * delegator를 임명
     */
    /*
     * Appoint the delegator
     */
    function appointDelegator(address delegator) public onlyOwner returns (bool) {
        require(delegator != address(0));
        require(delegator != owner());
        return _appointDelegator(delegator);
    }
    
    /*
     * 지정된 delegator를 해임
     */
    /*
     * Dimiss the appointed delegator
     */
    function dissmissDelegator() public onlyOwner returns (bool) {
        require(_delegator != address(0));
        return _appointDelegator(address(0));
    }
    
    /*
     * delegator를 변경하는 내부 함수
     */
    /*
     * An internal function that allows delegator changes 
     */
    function _appointDelegator(address delegator) private returns (bool) {
        require(_delegator != delegator);
        emit DelegateAppointed(_delegator, delegator);
        _delegator = delegator;
        return true;
    }
}

/*
 * ERC20의 기본 인터페이스는 유지하여 일반적인 토큰 전송이 가능하면서,
 * 일부 추가 관리 기능을 구현하기 위한 Struct 및 함수가 추가되어 있습니다.
 * 특히, 토큰 -> 코인 교환을 위한 Delegator 임명은 Owner가 직접 수행할 컨트랙트의 주소를 임명하기 때문에
 * 외부에서 임의로 권한을 획득하기 매우 어려운 구조를 가집니다.
 * 또한, exchange() 함수의 실행은 ExchangeContract에서 Holder가 직접 exchangeSYM() 함수를
 * 실행한 것이 트리거가 되기 때문에 임의의 사용자가 다른 사람의 토큰을 탈취할 수 없습니다.
 */
 /*
 * The basic interface of ERC20 is remained untouched therefore basic functions like token transactions will be available. 
 * On top of that, Structs and functions have been added to implement some additional management functions.
 * In particular, we created an additional Delegator agent to initiate the token swap so that the swap is performed by the delegator but directly from the Owner's contract address.
 * By implementing an additional agent, it has built a difficult structure to acquire rights arbitrarily from the outside.
 * In addition, the execution of exchange() cannot be taken by any other Holders' because the exchangeSYM() is triggered directly by the Holder's execution 
 */
contract ERC20Like is IERC20, Delegable {
    using SafeMath for uint256;

    uint256 internal _totalSupply;  // 총 발행량 // Total Supply
    bool isLock = false;  // 계약 잠금 플래그 // Contract Lock Flag

    /*
     * 토큰 정보(충전량, 해금량, 가용잔액) 및 Spender 정보를 저장하는 구조체
     */
    /*
     * Structure that stores token information (charge, unlock, balance) as well as Spender information
     */
    struct TokenContainer {
        uint256 chargeAmount; // 충전량 // charge amount
        uint256 unlockAmount; // 해금량 // unlock amount
        uint256 balance;  // 가용잔액 // available balance
        mapping (address => uint256) allowed; // Spender
    }

    mapping (address => TokenContainer) internal _tokenContainers;
    
    event ChangeCirculation(uint256 circulationAmount);
    event Charge(address indexed holder, uint256 chargeAmount, uint256 unlockAmount);
    event IncreaseUnlockAmount(address indexed holder, uint256 unlockAmount);
    event DecreaseUnlockAmount(address indexed holder, uint256 unlockAmount);
    event Exchange(address indexed holder, address indexed exchangeHolder, uint256 amount);
    event Withdraw(address indexed holder, uint256 amount);

    // 총 발행량 
    // Total token supply 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // 가용잔액 가져오기
    // Call-up available balance
    function balanceOf(address holder) public view returns (uint256) {
        return _tokenContainers[holder].balance;
    }

    // Spender의 남은 잔액 가져오기
    // Call-up Spender's remaining balance
    function allowance(address holder, address spender) public view returns (uint256) {
        return _tokenContainers[holder].allowed[spender];
    }

    // 토큰송금
    // Transfer token
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    // Spender 지정 및 금액 지정
    // Appoint a Spender and set an amount 
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    // Spender 토큰송금
    // Transfer token via Spender 
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _tokenContainers[from].allowed[msg.sender].sub(value));
        return true;
    }

    // Spender가 할당 받은 양 증가
    // Increase a Spender amount alloted by the Owner/Delegator
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(!isLock);
        uint256 value = _tokenContainers[msg.sender].allowed[spender].add(addedValue);
        if (msg.sender == owner()) {  // Sender가 계약 소유자인 경우 전체 발행량 조절
            require(_tokenContainers[msg.sender].chargeAmount >= _tokenContainers[msg.sender].unlockAmount.add(addedValue));
            _tokenContainers[msg.sender].unlockAmount = _tokenContainers[msg.sender].unlockAmount.add(addedValue);
            _tokenContainers[msg.sender].balance = _tokenContainers[msg.sender].balance.add(addedValue);
        }
        _approve(msg.sender, spender, value);
        return true;
    }

    // Spender가 할당 받은 양 감소
    // Decrease a Spender amount alloted by the Owner/Delegator
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(!isLock);
        // 기존에 할당된 금액의 잔액보다 더 많은 금액을 줄이려고 하는 경우 할당액이 0이 되도록 처리
        //// If you reduce more than the alloted amount in the balance, we made sure the alloted amount is set to zero instead of minus
        if (_tokenContainers[msg.sender].allowed[spender] < subtractedValue) {
            subtractedValue = _tokenContainers[msg.sender].allowed[spender];
        }
        
        uint256 value = _tokenContainers[msg.sender].allowed[spender].sub(subtractedValue);
        if (msg.sender == owner()) {  // Sender가 계약 소유자인 경우 전체 발행량 조절 // // Adjust the total circulation amount if the Sender equals the contract owner
            _tokenContainers[msg.sender].unlockAmount = _tokenContainers[msg.sender].unlockAmount.sub(subtractedValue);
            _tokenContainers[msg.sender].balance = _tokenContainers[msg.sender].balance.sub(subtractedValue);
        }
        _approve(msg.sender, spender, value);
        return true;
    }

    // 토큰송금 내부 실행 함수 
    // An internal execution function for troken transfer
    function _transfer(address from, address to, uint256 value) private {
        require(!isLock);
        // 3.1. Known vulnerabilities of ERC-20 token
        // 현재 컨트랙트로는 송금할 수 없도록 예외 처리 // Exceptions were added to not allow deposits to be made in the current contract . 
        require(to != address(this));
        require(to != address(0));

        _tokenContainers[from].balance = _tokenContainers[from].balance.sub(value);
        _tokenContainers[to].balance = _tokenContainers[to].balance.add(value);
        emit Transfer(from, to, value);
    }

    // Spender 지정 내부 실행 함수
    // Internal execution function for assigning a Spender
    function _approve(address holder, address spender, uint256 value) private {
        require(!isLock);
        require(spender != address(0));
        require(holder != address(0));

        _tokenContainers[holder].allowed[spender] = value;
        emit Approval(holder, spender, value);
    }

    /* extension */
    /**
     * 충전량 
     */
    /**
     * Charge Amount 
     */
    function chargeAmountOf(address holder) external view returns (uint256) {
        return _tokenContainers[holder].chargeAmount;
    }

    /**
     * 해금량
     */
    /**
     * Unlock Amount
     */
    function unlockAmountOf(address holder) external view returns (uint256) {
        return _tokenContainers[holder].unlockAmount;
    }

    /**
     * 가용잔액
     */
    /**
     * Available amount in the balance
     */
    function availableBalanceOf(address holder) external view returns (uint256) {
        return _tokenContainers[holder].balance;
    }

    /**
     * Holder의 계정 잔액 요약 출력(JSON 포맷)
     */
    /**
     * An output of Holder's account balance summary (JSON format)
     */
    function receiptAccountOf(address holder) external view returns (string memory) {
        bytes memory blockStart = bytes("{");
        bytes memory chargeLabel = bytes("\"chargeAmount\" : \"");
        bytes memory charge = bytes(uint2str(_tokenContainers[holder].chargeAmount));
        bytes memory unlockLabel = bytes("\", \"unlockAmount\" : \"");
        bytes memory unlock = bytes(uint2str(_tokenContainers[holder].unlockAmount));
        bytes memory balanceLabel = bytes("\", \"availableBalance\" : \"");
        bytes memory balance = bytes(uint2str(_tokenContainers[holder].balance));
        bytes memory blockEnd = bytes("\"}");

        string memory receipt = new string(blockStart.length + chargeLabel.length + charge.length + unlockLabel.length + unlock.length + balanceLabel.length + balance.length + blockEnd.length);
        bytes memory receiptBytes = bytes(receipt);

        uint readIndex = 0;
        uint writeIndex = 0;

        for (readIndex = 0; readIndex < blockStart.length; readIndex++) {
            receiptBytes[writeIndex++] = blockStart[readIndex];
        }
        for (readIndex = 0; readIndex < chargeLabel.length; readIndex++) {
            receiptBytes[writeIndex++] = chargeLabel[readIndex];
        }
        for (readIndex = 0; readIndex < charge.length; readIndex++) {
            receiptBytes[writeIndex++] = charge[readIndex];
        }
        for (readIndex = 0; readIndex < unlockLabel.length; readIndex++) {
            receiptBytes[writeIndex++] = unlockLabel[readIndex];
        }
        for (readIndex = 0; readIndex < unlock.length; readIndex++) {
            receiptBytes[writeIndex++] = unlock[readIndex];
        }
        for (readIndex = 0; readIndex < balanceLabel.length; readIndex++) {
            receiptBytes[writeIndex++] = balanceLabel[readIndex];
        }
        for (readIndex = 0; readIndex < balance.length; readIndex++) {
            receiptBytes[writeIndex++] = balance[readIndex];
        }
        for (readIndex = 0; readIndex < blockEnd.length; readIndex++) {
            receiptBytes[writeIndex++] = blockEnd[readIndex];
        }

        return string(receiptBytes);
    }

    // uint 값을 string 으로 변환하는 내부 함수
    // An internal function that converts an uint value to a string
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    // 전체 유통량 - Owner의 unlockAmount
    // Total circulation supply, or the unlockAmount of the Owner's
    function circulationAmount() external view returns (uint256) {
        return _tokenContainers[owner()].unlockAmount;
    }

    // 전체 유통량 증가
    // Increase the token's total circulation supply 
    /*
     * 컨트랙트 상에 유통되는 토큰량을 증가 시킵니다.
     * Owner가 보유한 전체 토큰량에서 Unlock 된 양 만큼이 현재 유통량이므로,
     * Unlock Amount와 Balance 가 증가하며, Charge Amount는 변동되지 않습니다.
     */
    /*
     * This function increases the amount of circulated tokens that are distributed on the contract.
     * The circulated token is referring to the Unlock tokens out of the contract Owner's total supply, so the Charge Amount is not affected (refer back to the Balance definition above).
     * This function increases in the Unlock Amount as well as in the Balance.
     */
    function increaseCirculation(uint256 amount) external onlyOwner returns (uint256) {
        require(!isLock);
        require(_tokenContainers[msg.sender].chargeAmount >= _tokenContainers[msg.sender].unlockAmount.add(amount));
        _tokenContainers[msg.sender].unlockAmount = _tokenContainers[msg.sender].unlockAmount.add(amount);
        _tokenContainers[msg.sender].balance = _tokenContainers[msg.sender].balance.add(amount);
        emit ChangeCirculation(_tokenContainers[msg.sender].unlockAmount);
        return _tokenContainers[msg.sender].unlockAmount;
    }

    // 전체 유통량 감소
    // Reduction of the token's total supply
    /*
     * 컨트랙트 상에 유통되는 토큰량을 감소 시킵니다.
     * Owner가 보유한 전체 토큰량에서 Unlock 된 양 만큼이 현재 유통량이므로,
     * Unlock Amount와 Balance 가 감소하며, Charge Amount는 변동되지 않습니다.
     * Owner만 실행할 수 있으며, 정책적인 계획에 맞추어 실행되어야하므로 0보다 작아지는 값이 입력되는 경우 실행을 중단합니다.
     */
    /*
     * This function decreases the amount of circulated tokens that are distributed on the contract.
     * The circulated token is referring to the Unlock tokens out of the contract Owner's total supply, so the Charge Amount is not affected (refer back to the Balance definition above).
     * This function decreases in the Unlock Amount as well as in the Balance.
     */
    function decreaseCirculation(uint256 amount) external onlyOwner returns (uint256) {
        require(!isLock);
        _tokenContainers[msg.sender].unlockAmount = _tokenContainers[msg.sender].unlockAmount.sub(amount);
        _tokenContainers[msg.sender].balance = _tokenContainers[msg.sender].balance.sub(amount);
        emit ChangeCirculation(_tokenContainers[msg.sender].unlockAmount);
        return _tokenContainers[msg.sender].unlockAmount;
    }

    /*
     * 특정 사용자(ICO, PreSale 구매자)가 구매한 금액 만큼의 충전량을 직접 입력할 때 사용합니다.
     * 컨트랙트 내 토큰의 유통량에 맞추어 동작하므로, Owner의 Balance가 부족하면 실행을 중단힙니다.
     * 충전한 토큰은 lock인 상태로 시작되며, charge() 함수는 충전과 동시에 Unlock하는 양을 지정하여
     * increaseUnlockAmount() 함수의 실행 횟수를 줄일 수 있다.
     */
    /*
     * This function is used to directly input the token amount that is purchased by particular Holders (ICO, Pre-sale buyers). It can be performed by the Owner or the Delegator.
     * Since the contract operates in concurrent to the tokens in circulation, the function will fail to execute when Owner's balance is insuffient. 
     * All charged tokens are locked amount. 
     */
    function charge(address holder, uint256 chargeAmount, uint256 unlockAmount) external ownerOrDelegator {
        require(!isLock);
        require(holder != address(0));
        require(holder != owner());
        require(chargeAmount > 0);
        require(chargeAmount >= unlockAmount);
        require(_tokenContainers[owner()].balance >= chargeAmount);

        _tokenContainers[owner()].balance = _tokenContainers[owner()].balance.sub(chargeAmount);

        _tokenContainers[holder].chargeAmount = _tokenContainers[holder].chargeAmount.add(chargeAmount);
        _tokenContainers[holder].unlockAmount = _tokenContainers[holder].unlockAmount.add(unlockAmount);
        _tokenContainers[holder].balance = _tokenContainers[holder].balance.add(unlockAmount);
        
        emit Charge(holder, chargeAmount, unlockAmount);
    }
    
    /*
     * 특정 사용자(ICO, PreSale 구매자)가 구매한 금액 안에서 해금량을 변경할 때 사용합니다.
     * 총 충전량 안에서 변화가 일어나므로 Unlock Amount가 Charge Amount보다 커질 수 없습니다.
     */
    /*
     * This function is used to change the Unlock Amount of tokens that is purchased by particular Holders (ICO, Pre-sale buyers).
     * Unlock Amount cannot be larger than Charge Amount because changes occur within the total charge amount.
     */
    function increaseUnlockAmount(address holder, uint256 unlockAmount) external ownerOrDelegator {
        require(!isLock);
        require(holder != address(0));
        require(holder != owner());
        require(_tokenContainers[holder].chargeAmount >= _tokenContainers[holder].unlockAmount.add(unlockAmount));

        _tokenContainers[holder].unlockAmount = _tokenContainers[holder].unlockAmount.add(unlockAmount);
        _tokenContainers[holder].balance = _tokenContainers[holder].balance.add(unlockAmount);
        
        emit IncreaseUnlockAmount(holder, unlockAmount);
    }
    
    /*
     * 특정 사용자(ICO, PreSale 구매자)가 구매한 금액 안에서 해금량을 변경할 때 사용합니다.
     * Balance를 Lock 상태로 전환하는 것이므로 Lock Amount의 값은 Balance보다 커질 수 없습니다.
     */
    /*
     * This function is used to change the Unlock Amount of tokens that is purchased by particular Holders (ICO, Pre-sale buyers).
     * Since the Balance starts from a locked state, the number of locked tokens cannot be greater than the Balance.
     */
    function decreaseUnlockAmount(address holder, uint256 lockAmount) external ownerOrDelegator {
        require(!isLock);
        require(holder != address(0));
        require(holder != owner());
        require(_tokenContainers[holder].balance >= lockAmount);

        _tokenContainers[holder].unlockAmount = _tokenContainers[holder].unlockAmount.sub(lockAmount);
        _tokenContainers[holder].balance = _tokenContainers[holder].balance.sub(lockAmount);
        
        emit DecreaseUnlockAmount(holder, lockAmount);
    }

    /*
     * 특정 사용자(ICO, PreSale 구매자)가 구매한 금액 안에서 전체를 해금할 때 사용합니다.
     * Charge Amount 중 Unlock Amount 량을 제외한 나머지 만큼을 일괄적으로 해제합니다.
     */
    /*
     * This function is used to change the Unlock Amount of tokens that is purchased by particular Holders (ICO, Pre-sale buyers).
     * It unlocks all locked tokens in the Charge Amount, other than tokens already unlocked. 
     */
    function unlockAmountAll(address holder) external ownerOrDelegator {
        require(!isLock);
        require(holder != address(0));
        require(holder != owner());

        uint256 unlockAmount = _tokenContainers[holder].chargeAmount.sub(_tokenContainers[holder].unlockAmount);

        require(unlockAmount > 0);
        
        _tokenContainers[holder].unlockAmount = _tokenContainers[holder].unlockAmount.add(unlockAmount);
        _tokenContainers[holder].balance = _tokenContainers[holder].balance.add(unlockAmount);
    }

    /*
     * 계약 잠금
     * 계약이 잠기면 컨트랙트의 거래가 중단된 상태가 되며,
     * 거래가 중단된 상태에서는 Owner와 Delegator를 포함한 모든 Holder는 거래를 할 수 없게 된다.
     * 모든 거래가 중단된 상태에서 모든 Holder의 상태가 변경되지 않게 만든 후에
     * 토큰 -> 코인 전환 절차를 진행하기 위함이다.
     * 단, 이 상태에서는 Exchange Contract를 Owner가 직접 Delegator로 임명하여
     * Holder의 요청을 처리하도록 하며, 이때는 토큰 -> 코인 교환회수를 위한 exchange(), withdraw() 함수 실행만 허용이 된다.
     */
    /*
     * Contract lock
     * If the contract is locked, all transactions will be suspended.
     * All Holders including Owner and Delegator will not be able to make transaction during suspension.
     * After all transactions have been stopped and all Holders have not changed their status
     * This function is created primarily for the token swap event. 
     * In this process, it's important to note that the Owner of the Exchange contract should directly appoint a delegator when handling Holders' requests.
     * Only the exchange () and withdraw () are allowed to be executed for token swap.
     */
    function lock() external onlyOwner returns (bool) {
        isLock = true;
        return isLock;
    }

    /*
     * 계약 잠금 해제
     * 잠긴 계약을 해제할 때 사용된다.
     */
    /*
     * Release contract lock
     * The function is used to revert a locked contract to a normal state. 
     */
    function unlock() external onlyOwner returns (bool) {
        isLock = false;
        return isLock;
    }
    
    /*
     * 토큰 교환 처리용 외부 호출 함수
     * 계약 전체가 잠긴 상태일 때(교환 처리 중 계약 중단),
     * 외부에서만 호출 가능하며, Delegator이면서 Contract인 경우에만 호출 가능하다.
     */
    /*
     * It is an external call function for token exchange processing
     * This function is used when the entire contract is locked (contract lock during the token swap),
     * It can be called only externally. Also, it can be only called when the agent is both Delegator and Contract.
     */
    function exchange(address holder) external onlyDelegator returns (bool) {
        require(isLock);    // lock state only
        require((delegator() == msg.sender) && isContract(msg.sender));    // contract delegator only
        
        uint256 balance = _tokenContainers[holder].balance;
        _tokenContainers[holder].balance = 0;
        _tokenContainers[msg.sender].balance = _tokenContainers[msg.sender].balance.add(balance);
        
        emit Exchange(holder, msg.sender, balance);
        return true;
    }
    
    /*
     * 토큰 교환 처리 후 회수된 토큰을 Owner한테 돌려주는 함수
     * 계약 전체가 잠긴 상태일 때(교환 처리 중 계약 중단),
     * 외부에서만 호출 가능하며, Delegator이면서 Contract인 경우에만 호출 가능하다.
     */
    /*
     * This is a function in which the Delegator returns tokens to the Owner after the token swap process
     * This function is used when the entire contract is locked (contract lock during the token swap),
     * It can be called only externally. Also, it can be only called when the agent is both Delegator and Contract Owner.
     */
    function withdraw() external onlyDelegator returns (bool) {
        require(isLock);    // lock state only
        require((delegator() == msg.sender) && isContract(msg.sender));    // contract delegator only
        
        uint256 balance = _tokenContainers[msg.sender].balance;
        _tokenContainers[msg.sender].balance = 0;
        _tokenContainers[owner()].balance = _tokenContainers[owner()].balance.add(balance);
        
        emit Withdraw(msg.sender, balance);
    }
    
    /*
     * 현재의 주소가 엔진내에 차지하고 있는 코드의 크기를 계산하여 컨트랙트인지 확인하는 도구
     * 컨트랙트인 경우에만 저장된 코드의 크기가 존재하므로 코드의 크기가 존재한다면
     * 컨트랙트로 판단할 수있다.
     */
    /*
     * This is a tool used for confirming a contract. It determines the size of code that the current address occupies within the blockchain network.
     * Since the size of a stored code exists only in the case of a contract, it is can be used as a validation tool.
     */
    function isContract(address addr) private returns (bool) {
      uint size;
      assembly { size := extcodesize(addr) }
      return size > 0;
    }
}

contract SymToken is ERC20Like {
    string public name = "SymVerse";
    string public symbol = "SYM";
    uint256 public decimals = 18;

    constructor () public {
        _totalSupply = 900000000 * (10 ** decimals);
        _tokenContainers[msg.sender].chargeAmount = _totalSupply;
        emit Charge(msg.sender, _tokenContainers[msg.sender].chargeAmount, _tokenContainers[msg.sender].unlockAmount);
    }
}