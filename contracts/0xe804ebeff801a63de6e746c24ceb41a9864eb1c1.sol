/*
    The MIT License (MIT)

    Copyright 2018 - 2019, Autonomous Software.

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
pragma solidity ^0.4.25;


/**
 * Reference: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 *
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}
/* end SafeMath library */


/// @title Math operation when both numbers has decimal places.
/// @notice Use this contract when both numbers has 18 decimal places. 
contract FixedMath {
    
    using SafeMath for uint;
    uint constant internal METDECIMALS = 18;
    uint constant internal METDECMULT = 10 ** METDECIMALS;
    uint constant internal DECIMALS = 18;
    uint constant internal DECMULT = 10 ** DECIMALS;

    /// @notice Multiplication.
    function fMul(uint x, uint y) internal pure returns (uint) {
        return (x.mul(y)).div(DECMULT);
    }

    /// @notice Division.
    function fDiv(uint numerator, uint divisor) internal pure returns (uint) {
        return (numerator.mul(DECMULT)).div(divisor);
    }

    /// @notice Square root.
    /// @dev Reference: https://stackoverflow.com/questions/3766020/binary-search-to-compute-square-root-java
    function fSqrt(uint n) internal pure returns (uint) {
        if (n == 0) {
            return 0;
        }
        uint z = n * n;
        require(z / n == n);

        uint high = fAdd(n, DECMULT);
        uint low = 0;
        while (fSub(high, low) > 1) {
            uint mid = fAdd(low, high) / 2;
            if (fSqr(mid) <= n) {
                low = mid;
            } else {
                high = mid;
            }
        }
        return low;
    }

    /// @notice Square.
    function fSqr(uint n) internal pure returns (uint) {
        return fMul(n, n);
    }

    /// @notice Add.
    function fAdd(uint x, uint y) internal pure returns (uint) {
        return x.add(y);
    }

    /// @notice Sub.
    function fSub(uint x, uint y) internal pure returns (uint) {
        return x.sub(y);
    }
}


/// @title A formula contract for converter
contract Formula is FixedMath {

    /// @notice Trade in reserve(ETH/MET) and mint new smart tokens
    /// @param smartTokenSupply Total supply of smart token
    /// @param reserveTokensSent Amount of token sent by caller
    /// @param reserveTokenBalance Balance of reserve token in the contract
    /// @return Smart token minted
    function returnForMint(uint smartTokenSupply, uint reserveTokensSent, uint reserveTokenBalance) 
        internal pure returns (uint)
    {
        uint s = smartTokenSupply;
        uint e = reserveTokensSent;
        uint r = reserveTokenBalance;
        /// smartToken for mint(T) = S * (sqrt(1 + E/R) - 1)
        /// DECMULT is same as 1 for values with 18 decimal places
        return ((fMul(s, (fSub(fSqrt(fAdd(DECMULT, fDiv(e, r))), DECMULT)))).mul(METDECMULT)).div(DECMULT);
    }

    /// @notice Redeem smart tokens, get back reserve(ETH/MET) token
    /// @param smartTokenSupply Total supply of smart token
    /// @param smartTokensSent Smart token sent
    /// @param reserveTokenBalance Balance of reserve token in the contract
    /// @return Reserve token redeemed
    function returnForRedemption(uint smartTokenSupply, uint smartTokensSent, uint reserveTokenBalance)
        internal pure returns (uint)
    {
        uint s = smartTokenSupply;
        uint t = smartTokensSent;
        uint r = reserveTokenBalance;
        /// reserveToken (E) = R * (1 - (1 - T/S)**2)
        /// DECMULT is same as 1 for values with 18 decimal places
        return ((fMul(r, (fSub(DECMULT, fSqr(fSub(DECMULT, fDiv(t, s))))))).mul(METDECMULT)).div(DECMULT);
    }
}


/// @title Pricer contract to calculate descending price during auction.
contract Pricer {

    using SafeMath for uint;
    uint constant internal METDECIMALS = 18;
    uint constant internal METDECMULT = 10 ** METDECIMALS;
    uint public minimumPrice = 33*10**11;
    uint public minimumPriceInDailyAuction = 1;

    uint public tentimes;
    uint public hundredtimes;
    uint public thousandtimes;

    uint constant public MULTIPLIER = 1984320568*10**5;

    /// @notice Pricer constructor, calculate 10, 100 and 1000 times of 0.99.
    function initPricer() public {
        uint x = METDECMULT;
        uint i;
        
        /// Calculate 10 times of 0.99
        for (i = 0; i < 10; i++) {
            x = x.mul(99).div(100);
        }
        tentimes = x;
        x = METDECMULT;

        /// Calculate 100 times of 0.99 using tentimes calculated above.
        /// tentimes has 18 decimal places and due to this METDECMLT is
        /// used as divisor.
        for (i = 0; i < 10; i++) {
            x = x.mul(tentimes).div(METDECMULT);
        }
        hundredtimes = x;
        x = METDECMULT;

        /// Calculate 1000 times of 0.99 using hundredtimes calculated above.
        /// hundredtimes has 18 decimal places and due to this METDECMULT is
        /// used as divisor.
        for (i = 0; i < 10; i++) {
            x = x.mul(hundredtimes).div(METDECMULT);
        }
        thousandtimes = x;
    }

    /// @notice Price of MET at nth minute out during operational auction
    /// @param initialPrice The starting price ie last purchase price
    /// @param _n The number of minutes passed since last purchase
    /// @return The resulting price
    function priceAt(uint initialPrice, uint _n) public view returns (uint price) {
        uint mult = METDECMULT;
        uint i;
        uint n = _n;

        /// If quotient of n/1000 is greater than 0 then calculate multiplier by
        /// multiplying thousandtimes and mult in a loop which runs quotient times.
        /// Also assign new value to n which is remainder of n/1000.
        if (n / 1000 > 0) {
            for (i = 0; i < n / 1000; i++) {
                mult = mult.mul(thousandtimes).div(METDECMULT);
            }
            n = n % 1000;
        }

        /// If quotient of n/100 is greater than 0 then calculate multiplier by
        /// multiplying hundredtimes and mult in a loop which runs quotient times.
        /// Also assign new value to n which is remainder of n/100.
        if (n / 100 > 0) {
            for (i = 0; i < n / 100; i++) {
                mult = mult.mul(hundredtimes).div(METDECMULT);
            }
            n = n % 100;
        }

        /// If quotient of n/10 is greater than 0 then calculate multiplier by
        /// multiplying tentimes and mult in a loop which runs quotient times.
        /// Also assign new value to n which is remainder of n/10.
        if (n / 10 > 0) {
            for (i = 0; i < n / 10; i++) {
                mult = mult.mul(tentimes).div(METDECMULT);
            }
            n = n % 10;
        }

        /// Calculate multiplier by multiplying 0.99 and mult, repeat it n times.
        for (i = 0; i < n; i++) {
            mult = mult.mul(99).div(100);
        }

        /// price is calculated as initialPrice multiplied by 0.99 and that too _n times.
        /// Here mult is METDECMULT multiplied by 0.99 and that too _n times.
        price = initialPrice.mul(mult).div(METDECMULT);
        
        if (price < minimumPriceInDailyAuction) {
            price = minimumPriceInDailyAuction;
        }
    }

    /// @notice Price of MET at nth minute during initial auction.
    /// @param lastPurchasePrice The price of MET in last transaction
    /// @param numTicks The number of minutes passed since last purchase
    /// @return The resulting price
    function priceAtInitialAuction(uint lastPurchasePrice, uint numTicks) public view returns (uint price) {
        /// Price will decrease linearly every minute by the factor of MULTIPLIER.
        /// If lastPurchasePrice is greater than decrease in price then calculated the price.
        /// Return minimumPrice, if calculated price is less than minimumPrice.
        /// If decrease in price is more than lastPurchasePrice then simply return the minimumPrice.
        if (lastPurchasePrice > MULTIPLIER.mul(numTicks)) {
            price = lastPurchasePrice.sub(MULTIPLIER.mul(numTicks));
        }

        if (price < minimumPrice) {
            price = minimumPrice;
        }
    }
}


/// @dev Reference: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
/// @notice ERC20 standard interface
interface ERC20 {
    function totalSupply() public constant returns (uint256);
    function balanceOf(address _owner) public constant returns (uint256);
    function allowance(address _owner, address _spender) public constant returns (uint256);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    function approve(address _spender, uint256 _value) public returns (bool);
}


/// @title Ownable
contract Ownable {

    address public owner;
    event OwnershipChanged(address indexed prevOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param _newOwner ..
    /// @return true/false
    function changeOwnership(address _newOwner) public onlyOwner returns (bool) {
        require(_newOwner != address(0));
        require(_newOwner != owner);
        emit OwnershipChanged(owner, _newOwner);
        owner = _newOwner;
        return true;
    }
}


/// @title Owned
contract Owned is Ownable {

    address public newOwner;

    /// @notice Allows the current owner to transfer control of the contract to a newOwner.
    /// @param _newOwner ..
    /// @return true/false
    function changeOwnership(address _newOwner) public onlyOwner returns (bool) {
        require(_newOwner != owner);
        newOwner = _newOwner;
        return true;
    }

    /// @notice Allows the new owner to accept ownership of the contract.
    /// @return true/false
    function acceptOwnership() public returns (bool) {
        require(msg.sender == newOwner);

        emit OwnershipChanged(owner, newOwner);
        owner = newOwner;
        return true;
    }
}


/// @title Mintable contract to allow minting and destroy.
contract Mintable is Owned {

    using SafeMath for uint256;

    event Mint(address indexed _to, uint _value);
    event Destroy(address indexed _from, uint _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balanceOf;

    address public autonomousConverter;
    address public minter;
    ITokenPorter public tokenPorter;

    /// @notice init reference of other contract and initial supply
    /// @param _autonomousConverter ..
    /// @param _minter ..
    /// @param _initialSupply ..
    /// @param _decmult Decimal places
    function initMintable(address _autonomousConverter, address _minter, uint _initialSupply, 
        uint _decmult) public onlyOwner {
        require(autonomousConverter == 0x0 && _autonomousConverter != 0x0);
        require(minter == 0x0 && _minter != 0x0);
      
        autonomousConverter = _autonomousConverter;
        minter = _minter;
        _totalSupply = _initialSupply.mul(_decmult);
        _balanceOf[_autonomousConverter] = _totalSupply;
    }

    function totalSupply() public constant returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256) {
        return _balanceOf[_owner];
    }

    /// @notice set address of token porter
    /// @param _tokenPorter address of token porter
    function setTokenPorter(address _tokenPorter) public onlyOwner returns (bool) {
        require(_tokenPorter != 0x0);

        tokenPorter = ITokenPorter(_tokenPorter);
        return true;
    }

    /// @notice allow minter and tokenPorter to mint token and assign to address
    /// @param _to ..
    /// @param _value Amount to be minted  
    function mint(address _to, uint _value) public returns (bool) {
        require(msg.sender == minter || msg.sender == address(tokenPorter));
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _totalSupply = _totalSupply.add(_value);
        emit Mint(_to, _value);
        emit Transfer(0x0, _to, _value);
        return true;
    }

    /// @notice allow autonomousConverter and tokenPorter to mint token and assign to address
    /// @param _from ..
    /// @param _value Amount to be destroyed
    function destroy(address _from, uint _value) public returns (bool) {
        require(msg.sender == autonomousConverter || msg.sender == address(tokenPorter));
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Destroy(_from, _value);
        emit Transfer(_from, 0x0, _value);
        return true;
    }
}


/// @title Token contract
contract Token is ERC20, Mintable {
    mapping(address => mapping(address => uint256)) internal _allowance;

    function initToken(address _autonomousConverter, address _minter,
    uint _initialSupply, uint _decmult) public onlyOwner {
        initMintable(_autonomousConverter, _minter, _initialSupply, _decmult);
    }

    /// @notice Provide allowance information
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return _allowance[_owner][_spender];
    }

    /// @notice Transfer tokens from sender to the provided address.
    /// @param _to Receiver of the tokens
    /// @param _value Amount of token
    /// @return true/false
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_to != minter);
        require(_to != address(this));
        require(_to != autonomousConverter);
        Proceeds proceeds = Auctions(minter).proceeds();
        require((_to != address(proceeds)));

        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice Transfer tokens based on allowance.
    /// msg.sender must have allowance for spending the tokens from owner ie _from
    /// @param _from Owner of the tokens
    /// @param _to Receiver of the tokens
    /// @param _value Amount of tokens to transfer
    /// @return true/false
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) { 
        require(_to != address(0));       
        require(_to != minter && _from != minter);
        require(_to != address(this) && _from != address(this));
        Proceeds proceeds = Auctions(minter).proceeds();
        require(_to != address(proceeds) && _from != address(proceeds));
        //AC can accept MET via this function, needed for MetToEth conversion
        require(_from != autonomousConverter);
        require(_allowance[_from][msg.sender] >= _value);
        
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }

    /// @notice Approve spender to spend the tokens ie approve allowance
    /// @param _spender Spender of the tokens
    /// @param _value Amount of tokens that can be spent by spender
    /// @return true/false
    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_spender != address(this));
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @notice Transfer the tokens from sender to all the address provided in the array.
    /// @dev Left 160 bits are the recipient address and the right 96 bits are the token amount.
    /// @param bits array of uint
    /// @return true/false
    function multiTransfer(uint[] bits) public returns (bool) {
        for (uint i = 0; i < bits.length; i++) {
            address a = address(bits[i] >> 96);
            uint amount = bits[i] & ((1 << 96) - 1);
            if (!transfer(a, amount)) revert();
        }

        return true;
    }

    /// @notice Increase allowance of spender
    /// @param _spender Spender of the tokens
    /// @param _value Amount of tokens that can be spent by spender
    /// @return true/false
    function approveMore(address _spender, uint256 _value) public returns (bool) {
        uint previous = _allowance[msg.sender][_spender];
        uint newAllowance = previous.add(_value);
        _allowance[msg.sender][_spender] = newAllowance;
        emit Approval(msg.sender, _spender, newAllowance);
        return true;
    }

    /// @notice Decrease allowance of spender
    /// @param _spender Spender of the tokens
    /// @param _value Amount of tokens that can be spent by spender
    /// @return true/false
    function approveLess(address _spender, uint256 _value) public returns (bool) {
        uint previous = _allowance[msg.sender][_spender];
        uint newAllowance = previous.sub(_value);
        _allowance[msg.sender][_spender] = newAllowance;
        emit Approval(msg.sender, _spender, newAllowance);
        return true;
    }
}


/// @title  Smart tokens are an intermediate token generated during conversion of MET-ETH
contract SmartToken is Mintable {
    uint constant internal METDECIMALS = 18;
    uint constant internal METDECMULT = 10 ** METDECIMALS;

    function initSmartToken(address _autonomousConverter, address _minter, uint _initialSupply) public  onlyOwner {
        initMintable(_autonomousConverter, _minter, _initialSupply, METDECMULT); 
    }
}


/// @title ERC20 token. Metronome token 
contract METToken is Token {

    string public constant name = "Metronome";
    string public constant symbol = "MET";
    uint8 public constant decimals = 18;

    bool public transferAllowed;

    function initMETToken(address _autonomousConverter, address _minter, 
        uint _initialSupply, uint _decmult) public onlyOwner {
        initToken(_autonomousConverter, _minter, _initialSupply, _decmult);
    }
    
    /// @notice Transferable modifier to allow transfer only after initial auction ended.
    modifier transferable() {
        require(transferAllowed);
        _;
    }

    function enableMETTransfers() public returns (bool) {
        require(!transferAllowed && Auctions(minter).isInitialAuctionEnded());
        transferAllowed = true; 
        return true;
    }

    /// @notice Transfer tokens from caller to another address
    /// @param _to address The address which you want to transfer to
    /// @param _value uint256 the amout of tokens to be transfered
    function transfer(address _to, uint256 _value) public transferable returns (bool) {
        return super.transfer(_to, _value);
        
    }

    /// @notice Transfer tokens from one address to another
    /// @param _from address The address from which you want to transfer
    /// @param _to address The address which you want to transfer to
    /// @param _value uint256 the amout of tokens to be transfered
    function transferFrom(address _from, address _to, uint256 _value) public transferable returns (bool) {        
        return super.transferFrom(_from, _to, _value);
    }

    /// @notice Transfer the token from sender to all the addresses provided in array.
    /// @dev Left 160 bits are the recipient address and the right 96 bits are the token amount.
    /// @param bits array of uint
    /// @return true/false
    function multiTransfer(uint[] bits) public transferable returns (bool) {
        return super.multiTransfer(bits);
    }
    
    mapping (address => bytes32) public roots;

    function setRoot(bytes32 data) public {
        roots[msg.sender] = data;
    }

    function getRoot(address addr) public view returns (bytes32) {
        return roots[addr];
    }

    function rootsMatch(address a, address b) public view returns (bool) {
        return roots[a] == roots[b];
    }

    /// @notice import MET tokens from another chain to this chain.
    /// @param _destinationChain destination chain name
    /// @param _addresses _addresses[0] is destMetronomeAddr and _addresses[1] is recipientAddr
    /// @param _extraData extra information for import
    /// @param _burnHashes _burnHashes[0] is previous burnHash, _burnHashes[1] is current burnHash
    /// @param _supplyOnAllChains MET supply on all supported chains
    /// @param _importData _importData[0] is _blockTimestamp, _importData[1] is _amount, _importData[2] is _fee
    /// _importData[3] is _burnedAtTick, _importData[4] is _genesisTime, _importData[5] is _dailyMintable
    /// _importData[6] is _burnSequence, _importData[7] is _dailyAuctionStartTime
    /// @param _proof proof
    /// @return true/false
    function importMET(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData, 
        bytes32[] _burnHashes, uint[] _supplyOnAllChains, uint[] _importData, bytes _proof) public returns (bool)
    {
        require(address(tokenPorter) != 0x0);
        return tokenPorter.importMET(_originChain, _destinationChain, _addresses, _extraData, 
        _burnHashes, _supplyOnAllChains, _importData, _proof);
    }

    /// @notice export MET tokens from this chain to another chain.
    /// @param _destChain destination chain address
    /// @param _destMetronomeAddr address of Metronome contract on the destination chain 
    /// where this MET will be imported.
    /// @param _destRecipAddr address of account on destination chain
    /// @param _amount amount
    /// @param _extraData extra information for future expansion
    /// @return true/false
    function export(bytes8 _destChain, address _destMetronomeAddr, address _destRecipAddr, uint _amount, uint _fee, 
    bytes _extraData) public returns (bool)
    {
        require(address(tokenPorter) != 0x0);
        return tokenPorter.export(msg.sender, _destChain, _destMetronomeAddr,
        _destRecipAddr, _amount, _fee, _extraData);
    }

    struct Sub {
        uint startTime;      
        uint payPerWeek; 
        uint lastWithdrawTime;
    }

    event LogSubscription(address indexed subscriber, address indexed subscribesTo);
    event LogCancelSubscription(address indexed subscriber, address indexed subscribesTo);

    mapping (address => mapping (address => Sub)) public subs;

    /// @notice subscribe for a weekly recurring payment 
    /// @param _startTime Subscription start time.
    /// @param _payPerWeek weekly payment
    /// @param _recipient address of beneficiary
    /// @return true/false
    function subscribe(uint _startTime, uint _payPerWeek, address _recipient) public returns (bool) {
        require(_startTime >= block.timestamp);
        require(_payPerWeek != 0);
        require(_recipient != 0);

        subs[msg.sender][_recipient] = Sub(_startTime, _payPerWeek, _startTime);  
        
        emit LogSubscription(msg.sender, _recipient);
        return true;
    }

    /// @notice cancel a subcription. 
    /// @param _recipient address of beneficiary
    /// @return true/false
    function cancelSubscription(address _recipient) public returns (bool) {
        require(subs[msg.sender][_recipient].startTime != 0);
        require(subs[msg.sender][_recipient].payPerWeek != 0);

        subs[msg.sender][_recipient].startTime = 0;
        subs[msg.sender][_recipient].payPerWeek = 0;
        subs[msg.sender][_recipient].lastWithdrawTime = 0;

        emit LogCancelSubscription(msg.sender, _recipient);
        return true;
    }

    /// @notice get subcription details
    /// @param _owner ..
    /// @param _recipient ..
    /// @return startTime, payPerWeek, lastWithdrawTime
    function getSubscription(address _owner, address _recipient) public constant
        returns (uint startTime, uint payPerWeek, uint lastWithdrawTime) 
    {
        Sub storage sub = subs[_owner][_recipient];
        return (
            sub.startTime,
            sub.payPerWeek,
            sub.lastWithdrawTime
        );
    }

    /// @notice caller can withdraw the token from subscribers.
    /// @param _owner subcriber
    /// @return true/false
    function subWithdraw(address _owner) public transferable returns (bool) {
        require(subWithdrawFor(_owner, msg.sender));
        return true;
    }

    /// @notice Allow callers to withdraw token in one go from all of its subscribers
    /// @param _owners array of address of subscribers
    /// @return number of successful transfer done
    function multiSubWithdraw(address[] _owners) public returns (uint) {
        uint n = 0;
        for (uint i=0; i < _owners.length; i++) {
            if (subWithdrawFor(_owners[i], msg.sender)) {
                n++;
            } 
        }
        return n;
    }

    /// @notice Trigger MET token transfers for all pairs of subscribers and beneficiaries
    /// @dev address at i index in owners and recipients array is subcriber-beneficiary pair.
    /// @param _owners ..
    /// @param _recipients .. 
    /// @return number of successful transfer done
    function multiSubWithdrawFor(address[] _owners, address[] _recipients) public returns (uint) {
        // owners and recipients need 1-to-1 mapping, must be same length
        require(_owners.length == _recipients.length);

        uint n = 0;
        for (uint i = 0; i < _owners.length; i++) {
            if (subWithdrawFor(_owners[i], _recipients[i])) {
                n++;
            }
        }

        return n;
    }

    function subWithdrawFor(address _from, address _to) internal returns (bool) {
        Sub storage sub = subs[_from][_to];
        
        if (sub.startTime > 0 && sub.startTime < block.timestamp && sub.payPerWeek > 0) {
            uint weekElapsed = (now.sub(sub.lastWithdrawTime)).div(7 days);
            uint amount = weekElapsed.mul(sub.payPerWeek);
            if (weekElapsed > 0 && _balanceOf[_from] >= amount) {
                subs[_from][_to].lastWithdrawTime = block.timestamp;
                _balanceOf[_from] = _balanceOf[_from].sub(amount);
                _balanceOf[_to] = _balanceOf[_to].add(amount);
                emit Transfer(_from, _to, amount);
                return true;
            }
        }       
        return false;
    }
}


/// @title Autonomous Converter contract for MET <=> ETH exchange
contract AutonomousConverter is Formula, Owned {

    SmartToken public smartToken;
    METToken public reserveToken;
    Auctions public auctions;

    enum WhichToken { Eth, Met }
    bool internal initialized = false;

    event LogFundsIn(address indexed from, uint value);
    event ConvertEthToMet(address indexed from, uint eth, uint met);
    event ConvertMetToEth(address indexed from, uint eth, uint met);

    function init(address _reserveToken, address _smartToken, address _auctions) 
        public onlyOwner payable 
    {
        require(!initialized);
        auctions = Auctions(_auctions);
        reserveToken = METToken(_reserveToken);
        smartToken = SmartToken(_smartToken);
        initialized = true;
    }

    function handleFund() public payable {
        require(msg.sender == address(auctions.proceeds()));
        emit LogFundsIn(msg.sender, msg.value);
    }

    function getMetBalance() public view returns (uint) {
        return balanceOf(WhichToken.Met);
    }

    function getEthBalance() public view returns (uint) {
        return balanceOf(WhichToken.Eth);
    }

    /// @notice return the expected MET for ETH
    /// @param _depositAmount ETH.
    /// @return expected MET value for ETH
    function getMetForEthResult(uint _depositAmount) public view returns (uint256) {
        return convertingReturn(WhichToken.Eth, _depositAmount);
    }

    /// @notice return the expected ETH for MET
    /// @param _depositAmount MET.
    /// @return expected ETH value for MET
    function getEthForMetResult(uint _depositAmount) public view returns (uint256) {
        return convertingReturn(WhichToken.Met, _depositAmount);
    }

    /// @notice send ETH and get MET
    /// @param _mintReturn execute conversion only if return is equal or more than _mintReturn
    /// @return returnedMet MET retured after conversion
    function convertEthToMet(uint _mintReturn) public payable returns (uint returnedMet) {
        returnedMet = convert(WhichToken.Eth, _mintReturn, msg.value);
        emit ConvertEthToMet(msg.sender, msg.value, returnedMet);
    }

    /// @notice send MET and get ETH
    /// @dev Caller will be required to approve the AutonomousConverter to initiate the transfer
    /// @param _amount MET amount
    /// @param _mintReturn execute conversion only if return is equal or more than _mintReturn
    /// @return returnedEth ETh returned after conversion
    function convertMetToEth(uint _amount, uint _mintReturn) public returns (uint returnedEth) {
        returnedEth = convert(WhichToken.Met, _mintReturn, _amount);
        emit ConvertMetToEth(msg.sender, returnedEth, _amount);
    }

    function balanceOf(WhichToken which) internal view returns (uint) {
        if (which == WhichToken.Eth) return address(this).balance;
        if (which == WhichToken.Met) return reserveToken.balanceOf(this);
        revert();
    }

    function convertingReturn(WhichToken whichFrom, uint _depositAmount) internal view returns (uint256) {
        
        WhichToken to = WhichToken.Met;
        if (whichFrom == WhichToken.Met) {
            to = WhichToken.Eth;
        }

        uint reserveTokenBalanceFrom = balanceOf(whichFrom).add(_depositAmount);
        uint mintRet = returnForMint(smartToken.totalSupply(), _depositAmount, reserveTokenBalanceFrom);
        
        uint newSmartTokenSupply = smartToken.totalSupply().add(mintRet);
        uint reserveTokenBalanceTo = balanceOf(to);
        return returnForRedemption(
            newSmartTokenSupply,
            mintRet,
            reserveTokenBalanceTo);
    }

    function convert(WhichToken whichFrom, uint _minReturn, uint amnt) internal returns (uint) {
        WhichToken to = WhichToken.Met;
        if (whichFrom == WhichToken.Met) {
            to = WhichToken.Eth;
            require(reserveToken.transferFrom(msg.sender, this, amnt));
        }

        uint mintRet = mint(whichFrom, amnt, 1);
        
        return redeem(to, mintRet, _minReturn);
    }

    function mint(WhichToken which, uint _depositAmount, uint _minReturn) internal returns (uint256 amount) {
        require(_minReturn > 0);

        amount = mintingReturn(which, _depositAmount);
        require(amount >= _minReturn);
        require(smartToken.mint(msg.sender, amount));
    }

    function mintingReturn(WhichToken which, uint _depositAmount) internal view returns (uint256) {
        uint256 smartTokenSupply = smartToken.totalSupply();
        uint256 reserveBalance = balanceOf(which);
        return returnForMint(smartTokenSupply, _depositAmount, reserveBalance);
    }

    function redeem(WhichToken which, uint _amount, uint _minReturn) internal returns (uint redeemable) {
        require(_amount <= smartToken.balanceOf(msg.sender));
        require(_minReturn > 0);

        redeemable = redemptionReturn(which, _amount);
        require(redeemable >= _minReturn);

        uint256 reserveBalance = balanceOf(which);
        require(reserveBalance >= redeemable);

        uint256 tokenSupply = smartToken.totalSupply();
        require(_amount < tokenSupply);

        smartToken.destroy(msg.sender, _amount);
        if (which == WhichToken.Eth) {
            msg.sender.transfer(redeemable);
        } else {
            require(reserveToken.transfer(msg.sender, redeemable));
        }
    }

    function redemptionReturn(WhichToken which, uint smartTokensSent) internal view returns (uint256) {
        uint smartTokenSupply = smartToken.totalSupply();
        uint reserveTokenBalance = balanceOf(which);
        return returnForRedemption(
            smartTokenSupply,
            smartTokensSent,
            reserveTokenBalance);
    }
}


/// @title Proceeds contract
contract Proceeds is Owned {
    using SafeMath for uint256;

    AutonomousConverter public autonomousConverter;
    Auctions public auctions;
    event LogProceedsIn(address indexed from, uint value); 
    event LogClosedAuction(address indexed from, uint value);
    uint latestAuctionClosed;

    function initProceeds(address _autonomousConverter, address _auctions) public onlyOwner {
        require(address(auctions) == 0x0 && _auctions != 0x0);
        require(address(autonomousConverter) == 0x0 && _autonomousConverter != 0x0);

        autonomousConverter = AutonomousConverter(_autonomousConverter);
        auctions = Auctions(_auctions);
    }

    function handleFund() public payable {
        require(msg.sender == address(auctions));
        emit LogProceedsIn(msg.sender, msg.value);
    }

    /// @notice Forward 0.25% of total ETH balance of proceeds to AutonomousConverter contract
    function closeAuction() public {
        uint lastPurchaseTick = auctions.lastPurchaseTick();
        uint currentAuction = auctions.currentAuction();
        uint val = ((address(this).balance).mul(25)).div(10000); 
        if (val > 0 && (currentAuction > auctions.whichAuction(lastPurchaseTick)) 
            && (latestAuctionClosed < currentAuction)) {
            latestAuctionClosed = currentAuction;
            autonomousConverter.handleFund.value(val)();
            emit LogClosedAuction(msg.sender, val);
        }
    }
}


/// @title Auction contract. Send ETH to the contract address and buy MET. 
contract Auctions is Pricer, Owned {

    using SafeMath for uint256;
    METToken public token;
    Proceeds public proceeds;
    address[] public founders;
    mapping(address => TokenLocker) public tokenLockers;
    uint internal constant DAY_IN_SECONDS = 86400;
    uint internal constant DAY_IN_MINUTES = 1440;
    uint public genesisTime;
    uint public lastPurchaseTick;
    uint public lastPurchasePrice;
    uint public constant INITIAL_GLOBAL_DAILY_SUPPLY = 2880 * METDECMULT;
    uint public INITIAL_FOUNDER_SUPPLY = 1999999 * METDECMULT;
    uint public INITIAL_AC_SUPPLY = 1 * METDECMULT;
    uint public totalMigratedOut = 0;
    uint public totalMigratedIn = 0;
    uint public timeScale = 1;
    uint public constant INITIAL_SUPPLY = 10000000 * METDECMULT;
    uint public mintable = INITIAL_SUPPLY;
    uint public initialAuctionDuration = 7 days;
    uint public initialAuctionEndTime;
    uint public dailyAuctionStartTime;
    uint public constant DAILY_PURCHASE_LIMIT = 1000 ether;
    mapping (address => uint) internal purchaseInTheAuction;
    mapping (address => uint) internal lastPurchaseAuction;
    bool public minted;
    bool public initialized;
    uint public globalSupplyAfterPercentageLogic = 52598080 * METDECMULT;
    uint public constant AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS = 14791;
    bytes8 public chain = "ETH";
    event LogAuctionFundsIn(address indexed sender, uint amount, uint tokens, uint purchasePrice, uint refund);

    constructor() public {
        mintable = INITIAL_SUPPLY - 2000000 * METDECMULT;
    }

    /// @notice Payable function to buy MET in descending price auction
    function () public payable running {
        require(msg.value > 0);
        
        uint amountForPurchase = msg.value;
        uint excessAmount;

        if (currentAuction() > whichAuction(lastPurchaseTick)) {
            proceeds.closeAuction();
            restartAuction();
        }

        if (isInitialAuctionEnded()) {
            require(now >= dailyAuctionStartTime);
            if (lastPurchaseAuction[msg.sender] < currentAuction()) {
                if (amountForPurchase > DAILY_PURCHASE_LIMIT) {
                    excessAmount = amountForPurchase.sub(DAILY_PURCHASE_LIMIT);
                    amountForPurchase = DAILY_PURCHASE_LIMIT;
                }           
                purchaseInTheAuction[msg.sender] = msg.value;
                lastPurchaseAuction[msg.sender] = currentAuction();
            } else {
                require(purchaseInTheAuction[msg.sender] < DAILY_PURCHASE_LIMIT);
                if (purchaseInTheAuction[msg.sender].add(amountForPurchase) > DAILY_PURCHASE_LIMIT) {
                    excessAmount = (purchaseInTheAuction[msg.sender].add(amountForPurchase)).sub(DAILY_PURCHASE_LIMIT);
                    amountForPurchase = amountForPurchase.sub(excessAmount);
                }
                purchaseInTheAuction[msg.sender] = purchaseInTheAuction[msg.sender].add(msg.value);
            }
        }

        uint _currentTick = currentTick();

        uint weiPerToken;
        uint tokens;
        uint refund;
        (weiPerToken, tokens, refund) = calcPurchase(amountForPurchase, _currentTick);
        require(tokens > 0);

        if (now < initialAuctionEndTime && (token.totalSupply()).add(tokens) >= INITIAL_SUPPLY) {
            initialAuctionEndTime = now;
            dailyAuctionStartTime = ((initialAuctionEndTime / 1 days) + 1) * 1 days;
        }

        lastPurchaseTick = _currentTick;
        lastPurchasePrice = weiPerToken;

        assert(tokens <= mintable);
        mintable = mintable.sub(tokens);

        assert(refund <= amountForPurchase);
        uint ethForProceeds = amountForPurchase.sub(refund);

        proceeds.handleFund.value(ethForProceeds)();

        require(token.mint(msg.sender, tokens));

        refund = refund.add(excessAmount);
        if (refund > 0) {
            if (purchaseInTheAuction[msg.sender] > 0) {
                purchaseInTheAuction[msg.sender] = purchaseInTheAuction[msg.sender].sub(refund);
            }
            msg.sender.transfer(refund);
        }
        emit LogAuctionFundsIn(msg.sender, ethForProceeds, tokens, lastPurchasePrice, refund);
    }

    modifier running() {
        require(isRunning());
        _;
    }

    function isRunning() public constant returns (bool) {
        return (block.timestamp >= genesisTime && genesisTime > 0);
    }

    /// @notice current tick(minute) of the metronome clock
    /// @return tick count
    function currentTick() public view returns(uint) {
        return whichTick(block.timestamp);
    }

    /// @notice current auction
    /// @return auction count 
    function currentAuction() public view returns(uint) {
        return whichAuction(currentTick());
    }

    /// @notice tick count at the timestamp t. 
    /// @param t timestamp
    /// @return tick count
    function whichTick(uint t) public view returns(uint) {
        if (genesisTime > t) { 
            revert(); 
        }
        return (t - genesisTime) * timeScale / 1 minutes;
    }

    /// @notice Auction count at given the timestamp t
    /// @param t timestamp
    /// @return Auction count
    function whichAuction(uint t) public view returns(uint) {
        if (whichTick(dailyAuctionStartTime) > t) {
            return 0;
        } else {
            return ((t - whichTick(dailyAuctionStartTime)) / DAY_IN_MINUTES) + 1;
        }
    }

    /// @notice one single function telling everything about Metronome Auction
    function heartbeat() public view returns (
        bytes8 _chain,
        address auctionAddr,
        address convertAddr,
        address tokenAddr,
        uint minting,
        uint totalMET,
        uint proceedsBal,
        uint currTick,
        uint currAuction,
        uint nextAuctionGMT,
        uint genesisGMT,
        uint currentAuctionPrice,
        uint _dailyMintable,
        uint _lastPurchasePrice) {
        _chain = chain;
        convertAddr = proceeds.autonomousConverter();
        tokenAddr = token;
        auctionAddr = this;
        totalMET = token.totalSupply();
        proceedsBal = address(proceeds).balance;

        currTick = currentTick();
        currAuction = currentAuction();
        if (currAuction == 0) {
            nextAuctionGMT = dailyAuctionStartTime;
        } else {
            nextAuctionGMT = (currAuction * DAY_IN_SECONDS) / timeScale + dailyAuctionStartTime;
        }
        genesisGMT = genesisTime;

        currentAuctionPrice = currentPrice();
        _dailyMintable = dailyMintable();
        minting = currentMintable();
        _lastPurchasePrice = lastPurchasePrice;
    }

    /// @notice Initialize Auctions parameters
    /// @param _startTime The block.timestamp when first auction starts
    /// @param _minimumPrice Nobody can buy tokens for less than this price
    /// @param _startingPrice Start price of MET when first auction starts
    /// @param _timeScale time scale factor for auction. will be always 1 in live environment
    function initAuctions(uint _startTime, uint _minimumPrice, uint _startingPrice, uint _timeScale) 
        public onlyOwner returns (bool) 
    {
        require(minted);
        require(!initialized);
        require(_timeScale != 0);
        initPricer();
        if (_startTime > 0) { 
            genesisTime = (_startTime / (1 minutes)) * (1 minutes) + 60;
        } else {
            genesisTime = block.timestamp + 60 - (block.timestamp % 60);
        }

        initialAuctionEndTime = genesisTime + initialAuctionDuration;

        // if initialAuctionEndTime is midnight, then daily auction will start immediately
        // after initial auction.
        if (initialAuctionEndTime == (initialAuctionEndTime / 1 days) * 1 days) {
            dailyAuctionStartTime = initialAuctionEndTime;
        } else {
            dailyAuctionStartTime = ((initialAuctionEndTime / 1 days) + 1) * 1 days;
        }

        lastPurchaseTick = 0;

        if (_minimumPrice > 0) {
            minimumPrice = _minimumPrice;
        }

        timeScale = _timeScale;

        if (_startingPrice > 0) {
            lastPurchasePrice = _startingPrice * 1 ether;
        } else {
            lastPurchasePrice = 2 ether;
        }

        for (uint i = 0; i < founders.length; i++) {
            TokenLocker tokenLocker = tokenLockers[founders[i]];
            tokenLocker.lockTokenLocker();
        }
        
        initialized = true;
        return true;
    }

    function createTokenLocker(address _founder, address _token) public onlyOwner {
        require(_token != 0x0);
        require(_founder != 0x0);
        founders.push(_founder);
        TokenLocker tokenLocker = new TokenLocker(address(this), _token);
        tokenLockers[_founder] = tokenLocker;
        tokenLocker.changeOwnership(_founder);
    }

    /// @notice Mint initial supply for founder and move to token locker
    /// @param _founders Left 160 bits are the founder address and the right 96 bits are the token amount.
    /// @param _token MET token contract address
    /// @param _proceeds Address of Proceeds contract
    function mintInitialSupply(uint[] _founders, address _token, 
        address _proceeds, address _autonomousConverter) public onlyOwner returns (bool) 
    {
        require(!minted);
        require(_founders.length != 0);
        require(address(token) == 0x0 && _token != 0x0);
        require(address(proceeds) == 0x0 && _proceeds != 0x0);
        require(_autonomousConverter != 0x0);

        token = METToken(_token);
        proceeds = Proceeds(_proceeds);

        // _founders will be minted into individual token lockers
        uint foundersTotal;
        for (uint i = 0; i < _founders.length; i++) {
            address addr = address(_founders[i] >> 96);
            require(addr != 0x0);
            uint amount = _founders[i] & ((1 << 96) - 1);
            require(amount > 0);
            TokenLocker tokenLocker = tokenLockers[addr];
            require(token.mint(address(tokenLocker), amount));
            tokenLocker.deposit(addr, amount);
            foundersTotal = foundersTotal.add(amount);
        }

        // reconcile minted total for founders
        require(foundersTotal == INITIAL_FOUNDER_SUPPLY);

        // mint a small amount to the AC
        require(token.mint(_autonomousConverter, INITIAL_AC_SUPPLY));

        minted = true;
        return true;
    }

    /// @notice Suspend auction if not started yet
    function stopEverything() public onlyOwner {
        if (genesisTime < block.timestamp) {
            revert(); 
        }
        genesisTime = genesisTime + (60 * 60 * 24 * 365 * 1000); // 1000 years
        initialAuctionEndTime = genesisTime;
        dailyAuctionStartTime = genesisTime;
    }

    /// @notice Return information about initial auction status.
    function isInitialAuctionEnded() public view returns (bool) {
        return (initialAuctionEndTime != 0 && 
            (now >= initialAuctionEndTime || token.totalSupply() >= INITIAL_SUPPLY));
    }

    /// @notice Global MET supply
    function globalMetSupply() public view returns (uint) {

        uint currAuc = currentAuction();
        if (currAuc > AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS) {
            return globalSupplyAfterPercentageLogic;
        } else {
            return INITIAL_SUPPLY.add(INITIAL_GLOBAL_DAILY_SUPPLY.mul(currAuc));
        }
    }

    /// @notice Global MET daily supply. Daily supply is greater of 1) 2880 2)2% of then outstanding supply per year.
    /// @dev 2% logic will kicks in at 14792th auction. 
    function globalDailySupply() public view returns (uint) {
        uint dailySupply = INITIAL_GLOBAL_DAILY_SUPPLY;
        uint thisAuction = currentAuction();

        if (thisAuction > AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS) {
            uint lastAuctionPurchase = whichAuction(lastPurchaseTick);
            uint recentAuction = AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS + 1;
            if (lastAuctionPurchase > recentAuction) {
                recentAuction = lastAuctionPurchase;
            }

            uint totalAuctions = thisAuction - recentAuction;
            if (totalAuctions > 1) {
                // derived formula to find close to accurate daily supply when some auction missed. 
                uint factor = 36525 + ((totalAuctions - 1) * 2);
                dailySupply = (globalSupplyAfterPercentageLogic.mul(2).mul(factor)).div(36525 ** 2);

            } else {
                dailySupply = globalSupplyAfterPercentageLogic.mul(2).div(36525);
            }

            if (dailySupply < INITIAL_GLOBAL_DAILY_SUPPLY) {
                dailySupply = INITIAL_GLOBAL_DAILY_SUPPLY; 
            }
        }

        return dailySupply;
    }

    /// @notice Current price of MET in current auction
    /// @return weiPerToken 
    function currentPrice() public constant returns (uint weiPerToken) {
        weiPerToken = calcPriceAt(currentTick());
    }

    /// @notice Daily mintable MET in current auction
    function dailyMintable() public constant returns (uint) {
        return nextAuctionSupply(0);
    }

    /// @notice Total tokens on this chain
    function tokensOnThisChain() public view returns (uint) {
        uint totalSupply = token.totalSupply();
        uint currMintable = currentMintable();
        return totalSupply.add(currMintable);
    }

    /// @notice Current mintable MET in auction
    function currentMintable() public view returns (uint) {
        uint currMintable = mintable;
        uint currAuction = currentAuction();
        uint totalAuctions = currAuction.sub(whichAuction(lastPurchaseTick));
        if (totalAuctions > 0) {
            currMintable = mintable.add(nextAuctionSupply(totalAuctions));
        }
        return currMintable;
    }

    /// @notice prepare auction when first import is done on a non ETH chain
    function prepareAuctionForNonOGChain() public {
        require(msg.sender == address(token.tokenPorter()) || msg.sender == address(token));
        require(token.totalSupply() == 0);
        require(chain != "ETH");
        lastPurchaseTick = currentTick();
    }

    /// @notice Find out what the results would be of a prospective purchase
    /// @param _wei Amount of wei the purchaser will pay
    /// @param _timestamp Prospective purchase timestamp
    /// @return weiPerToken expected MET token rate
    /// @return tokens Expected token for a prospective purchase
    /// @return refund Wei refund the purchaser will get if amount is excess and MET supply is less
    function whatWouldPurchaseDo(uint _wei, uint _timestamp) public constant
        returns (uint weiPerToken, uint tokens, uint refund)
    {
        weiPerToken = calcPriceAt(whichTick(_timestamp));
        uint calctokens = METDECMULT.mul(_wei).div(weiPerToken);
        tokens = calctokens;
        if (calctokens > mintable) {
            tokens = mintable;
            uint weiPaying = mintable.mul(weiPerToken).div(METDECMULT);
            refund = _wei.sub(weiPaying);
        }
    }

    /// @notice Return the information about the next auction
    /// @return _startTime Start time of next auction
    /// @return _startPrice Start price of MET in next auction
    /// @return _auctionTokens  MET supply in next auction
    function nextAuction() internal constant returns(uint _startTime, uint _startPrice, uint _auctionTokens) {
        if (block.timestamp < genesisTime) {
            _startTime = genesisTime;
            _startPrice = lastPurchasePrice;
            _auctionTokens = mintable;
            return;
        }

        uint recentAuction = whichAuction(lastPurchaseTick);
        uint currAuc = currentAuction();
        uint totalAuctions = currAuc - recentAuction;
        _startTime = dailyAuctionStartTime;
        if (currAuc > 1) {
            _startTime = auctionStartTime(currentTick());
        }

        _auctionTokens = nextAuctionSupply(totalAuctions);

        if (totalAuctions > 1) {
            _startPrice = lastPurchasePrice / 100 + 1;
        } else {
            if (mintable == 0 || totalAuctions == 0) {
                // Sold out scenario or someone querying projected start price of next auction
                _startPrice = (lastPurchasePrice * 2) + 1;   
            } else {
                // Timed out and all tokens not sold.
                if (currAuc == 1) {
                    // If initial auction timed out then price before start of new auction will touch floor price
                    _startPrice = minimumPrice * 2;
                } else {
                    // Descending price till end of auction and then multiply by 2
                    uint tickWhenAuctionEnded = whichTick(_startTime);
                    uint numTick = 0;
                    if (tickWhenAuctionEnded > lastPurchaseTick) {
                        numTick = tickWhenAuctionEnded - lastPurchaseTick;
                    }
                    _startPrice = priceAt(lastPurchasePrice, numTick) * 2;
                }
                
                
            }
        }
    }

    /// @notice Calculate results of a purchase
    /// @param _wei Amount of wei the purchaser will pay
    /// @param _t Prospective purchase tick
    /// @return weiPerToken expected MET token rate
    /// @return tokens Expected token for a prospective purchase
    /// @return refund Wei refund the purchaser will get if amount is excess and MET supply is less
    function calcPurchase(uint _wei, uint _t) internal view returns (uint weiPerToken, uint tokens, uint refund)
    {
        require(_t >= lastPurchaseTick);
        uint numTicks = _t - lastPurchaseTick;
        if (isInitialAuctionEnded()) {
            weiPerToken = priceAt(lastPurchasePrice, numTicks);
        } else {
            weiPerToken = priceAtInitialAuction(lastPurchasePrice, numTicks);
        }

        uint calctokens = METDECMULT.mul(_wei).div(weiPerToken);
        tokens = calctokens;
        if (calctokens > mintable) {
            tokens = mintable;
            uint ethPaying = mintable.mul(weiPerToken).div(METDECMULT);
            refund = _wei.sub(ethPaying);
        }
    }

    /// @notice MET supply for next Auction also considering  carry forward met.
    /// @param totalAuctionMissed auction count when no purchase done.
    function nextAuctionSupply(uint totalAuctionMissed) internal view returns (uint supply) {
        uint thisAuction = currentAuction();
        uint tokensHere = token.totalSupply().add(mintable);
        supply = INITIAL_GLOBAL_DAILY_SUPPLY;
        uint dailySupplyAtLastPurchase;
        if (thisAuction > AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS) {
            supply = globalDailySupply();
            if (totalAuctionMissed > 1) {
                dailySupplyAtLastPurchase = globalSupplyAfterPercentageLogic.mul(2).div(36525);
                supply = dailySupplyAtLastPurchase.add(supply).mul(totalAuctionMissed).div(2);
            } 
            supply = (supply.mul(tokensHere)).div(globalSupplyAfterPercentageLogic);
        } else {
            if (totalAuctionMissed > 1) {
                supply = supply.mul(totalAuctionMissed);
            }
            uint previousGlobalMetSupply = 
            INITIAL_SUPPLY.add(INITIAL_GLOBAL_DAILY_SUPPLY.mul(whichAuction(lastPurchaseTick)));
            supply = (supply.mul(tokensHere)).div(previousGlobalMetSupply);
        
        }
    }

    /// @notice price at a number of minutes out in Initial auction and daily auction
    /// @param _tick Metronome tick
    /// @return weiPerToken
    function calcPriceAt(uint _tick) internal constant returns (uint weiPerToken) {
        uint recentAuction = whichAuction(lastPurchaseTick);
        uint totalAuctions = whichAuction(_tick).sub(recentAuction);
        uint prevPrice;

        uint numTicks = 0;

        // Auction is sold out and metronome clock is in same auction
        if (mintable == 0 && totalAuctions == 0) {
            return lastPurchasePrice;
        }

        // Metronome has missed one auction ie no purchase in last auction
        if (totalAuctions > 1) {
            prevPrice = lastPurchasePrice / 100 + 1;
            numTicks = numTicksSinceAuctionStart(_tick);
        } else if (totalAuctions == 1) {
            // Metronome clock is in new auction, next auction
            // previous auction sold out
            if (mintable == 0) {
                prevPrice = lastPurchasePrice * 2;
            } else {
                // previous auctions timed out
                // first daily auction
                if (whichAuction(_tick) == 1) {
                    prevPrice = minimumPrice * 2;
                } else {
                    prevPrice = priceAt(lastPurchasePrice, numTicksTillAuctionStart(_tick)) * 2;
                }
            }
            numTicks = numTicksSinceAuctionStart(_tick);
        } else {
            //Auction is running
            prevPrice = lastPurchasePrice;
            numTicks = _tick - lastPurchaseTick;
        }

        require(numTicks >= 0);

        if (isInitialAuctionEnded()) {
            weiPerToken = priceAt(prevPrice, numTicks);
        } else {
            weiPerToken = priceAtInitialAuction(prevPrice, numTicks);
        }
    }

    /// @notice Calculate number of ticks elapsed between auction start time and given tick.
    /// @param _tick Given metronome tick
    function numTicksSinceAuctionStart(uint _tick) private view returns (uint ) {
        uint currentAuctionStartTime = auctionStartTime(_tick);
        return _tick - whichTick(currentAuctionStartTime);
    }
    
    /// @notice Calculate number of ticks elapsed between lastPurchaseTick and auctions start time of given tick.
    /// @param _tick Given metronome tick
    function numTicksTillAuctionStart(uint _tick) private view returns (uint) {
        uint currentAuctionStartTime = auctionStartTime(_tick);
        return whichTick(currentAuctionStartTime) - lastPurchaseTick;
    }

    /// @notice First calculate the auction which contains the given tick and then calculate
    /// auction start time of given tick.
    /// @param _tick Metronome tick
    function auctionStartTime(uint _tick) private view returns (uint) {
        return ((whichAuction(_tick)) * 1 days) / timeScale + dailyAuctionStartTime - 1 days;
    }

    /// @notice start the next day's auction
    function restartAuction() private {
        uint time;
        uint price;
        uint auctionTokens;
        (time, price, auctionTokens) = nextAuction();

        uint thisAuction = currentAuction();
        if (thisAuction > AUCTION_WHEN_PERCENTAGE_LOGIC_STARTS) {
            globalSupplyAfterPercentageLogic = globalSupplyAfterPercentageLogic.add(globalDailySupply());
        }

        mintable = mintable.add(auctionTokens);
        lastPurchasePrice = price;
        lastPurchaseTick = whichTick(time);
    }
}


/// @title This contract serves as a locker for a founder's tokens
contract TokenLocker is Ownable {
    using SafeMath for uint;
    uint internal constant QUARTER = 91 days + 450 minutes;
  
    Auctions public auctions;
    METToken public token;
    bool public locked = false;
  
    uint public deposited;
    uint public lastWithdrawTime;
    uint public quarterlyWithdrawable;
    
    event Withdrawn(address indexed who, uint amount);
    event Deposited(address indexed who, uint amount);

    modifier onlyAuction() {
        require(msg.sender == address(auctions));
        _;
    }

    modifier preLock() { 
        require(!locked);
        _; 
    }

    modifier postLock() { 
        require(locked); 
        _; 
    }

    /// @notice Constructor to initialize TokenLocker contract.
    /// @param _auctions Address of auctions contract
    /// @param _token Address of METToken contract
    constructor(address _auctions, address _token) public {
        require(_auctions != 0x0);
        require(_token != 0x0);
        auctions = Auctions(_auctions);
        token = METToken(_token);
    }

    /// @notice If auctions is initialized, call to this function will result in
    /// locking of deposited tokens and further deposit of tokens will not be allowed.
    function lockTokenLocker() public onlyAuction {
        require(auctions.initialAuctionEndTime() != 0);
        require(auctions.initialAuctionEndTime() >= auctions.genesisTime()); 
        locked = true;
    }

    /// @notice It will deposit tokens into the locker for given beneficiary.
    /// @param beneficiary Address of the beneficiary, whose tokens are being locked.
    /// @param amount Amount of tokens being locked
    function deposit (address beneficiary, uint amount ) public onlyAuction preLock {
        uint totalBalance = token.balanceOf(this);
        require(totalBalance.sub(deposited) >= amount);
        deposited = deposited.add(amount);
        emit Deposited(beneficiary, amount);
    }

    /// @notice This function will allow token withdraw from locker.
    /// 25% of total deposited tokens can be withdrawn after initial auction end.
    /// Remaining 75% can be withdrawn in equal amount over 12 quarters.
    function withdraw() public onlyOwner postLock {
        require(deposited > 0);
        uint withdrawable = 0; 
        uint withdrawTime = auctions.initialAuctionEndTime();
        if (lastWithdrawTime == 0 && auctions.isInitialAuctionEnded()) {
            withdrawable = withdrawable.add((deposited.mul(25)).div(100));
            quarterlyWithdrawable = (deposited.sub(withdrawable)).div(12);
            lastWithdrawTime = withdrawTime;
        }

        require(lastWithdrawTime != 0);

        if (now >= lastWithdrawTime.add(QUARTER)) {
            uint daysSinceLastWithdraw = now.sub(lastWithdrawTime);
            uint totalQuarters = daysSinceLastWithdraw.div(QUARTER);

            require(totalQuarters > 0);
        
            withdrawable = withdrawable.add(quarterlyWithdrawable.mul(totalQuarters));

            if (now >= withdrawTime.add(QUARTER.mul(12))) {
                withdrawable = deposited;
            }

            lastWithdrawTime = lastWithdrawTime.add(totalQuarters.mul(QUARTER));
        }

        if (withdrawable > 0) {
            deposited = deposited.sub(withdrawable);
            token.transfer(msg.sender, withdrawable);
            emit Withdrawn(msg.sender, withdrawable);
        }
    }
}


/// @title Interface for TokenPorter contract.
/// Define events and functions for TokenPorter contract
interface ITokenPorter {
    event ExportOnChainClaimedReceiptLog(address indexed destinationMetronomeAddr, 
        address indexed destinationRecipientAddr, uint amount);

    event ExportReceiptLog(bytes8 destinationChain, address destinationMetronomeAddr,
        address indexed destinationRecipientAddr, uint amountToBurn, uint fee, bytes extraData, uint currentTick,
        uint indexed burnSequence, bytes32 indexed currentBurnHash, bytes32 prevBurnHash, uint dailyMintable,
        uint[] supplyOnAllChains, uint genesisTime, uint blockTimestamp, uint dailyAuctionStartTime);

    event ImportReceiptLog(address indexed destinationRecipientAddr, uint amountImported, 
        uint fee, bytes extraData, uint currentTick, uint indexed importSequence, 
        bytes32 indexed currentHash, bytes32 prevHash, uint dailyMintable, uint blockTimestamp, address caller);

    function export(address tokenOwner, bytes8 _destChain, address _destMetronomeAddr, 
        address _destRecipAddr, uint _amount, uint _fee, bytes _extraData) public returns (bool);
    
    function importMET(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData, 
        bytes32[] _burnHashes, uint[] _supplyOnAllChains, uint[] _importData, bytes _proof) public returns (bool);

}


/// @title This contract will provide export functionality for tokens.
contract TokenPorter is ITokenPorter, Owned {
    using SafeMath for uint;
    Auctions public auctions;
    METToken public token;
    Validator public validator;

    uint public burnSequence = 1;
    uint public importSequence = 1;
    uint public chainHopStartTime = now + (2*60*60*24);
    // This is flat fee and must be in 18 decimal value
    uint public minimumExportFee = 1 * (10 ** 12);
    // export fee per 10,000 MET. 1 means 0.01% or 1 met as fee for export of 10,000 met
    uint public exportFee = 50;
    bytes32[] public exportedBurns;
    uint[] public supplyOnAllChains = new uint[](6);
    mapping (bytes32 => bytes32) public merkleRoots;
    mapping (bytes32 => bytes32) public mintHashes;
    // store burn hashes and burnSequence to find burn hash exist or not. 
    // Burn sequence may be used to find chain of burn hashes
    mapping (bytes32 => uint) public burnHashes;
    /// @notice mapping that tracks valid destination chains for export
    mapping(bytes8 => address) public destinationChains;

    event LogExportReceipt(bytes8 destinationChain, address destinationMetronomeAddr,
        address indexed destinationRecipientAddr, uint amountToBurn, uint fee, bytes extraData, uint currentTick,
        uint burnSequence, bytes32 indexed currentBurnHash, bytes32 prevBurnHash, uint dailyMintable,
        uint[] supplyOnAllChains, uint blockTimestamp, address indexed exporter);

    event LogImportRequest(bytes8 originChain, bytes32 indexed currentBurnHash, bytes32 prevHash,
        address indexed destinationRecipientAddr, uint amountToImport, uint fee, uint exportTimeStamp,
        uint burnSequence, bytes extraData);
    
    event LogImport(bytes8 originChain, address indexed destinationRecipientAddr, uint amountImported, uint fee,
    bytes extraData, uint indexed importSequence, bytes32 indexed currentHash);
    
    /// @notice Initialize TokenPorter contract.
    /// @param _tokenAddr Address of metToken contract
    /// @param _auctionsAddr Address of auctions contract
    function initTokenPorter(address _tokenAddr, address _auctionsAddr) public onlyOwner {
        require(_tokenAddr != 0x0);
        require(_auctionsAddr != 0x0);
        auctions = Auctions(_auctionsAddr);
        token = METToken(_tokenAddr);
    }

    /// @notice set minimum export fee. Minimum flat fee applicable for export-import 
    /// @param _minimumExportFee minimum export fee
    function setMinimumExportFee(uint _minimumExportFee) public onlyOwner returns (bool) {
        require(_minimumExportFee > 0);
        minimumExportFee = _minimumExportFee;
        return true;
    }

    /// @notice set export fee in percentage. 
    /// @param _exportFee fee amount per 10,000 met
    function setExportFeePerTenThousand(uint _exportFee) public onlyOwner returns (bool) {
        exportFee = _exportFee;
        return true;
    }

    /// @notice set chain hop start time. Also, useful if owner want to suspend chain hop 
    // until given time in case anything goes wrong
    /// @param _startTime fee amount per 10,000 met
    function setChainHopStartTime(uint _startTime) public onlyOwner returns (bool) {
        require(_startTime >= block.timestamp);
        chainHopStartTime = _startTime;
        return true;
    }

    /// @notice set address of validator contract
    /// @param _validator address of validator contract
    function setValidator(address _validator) public onlyOwner returns (bool) {
        require(_validator != 0x0);
        validator = Validator(_validator);
        return true;
    }

    /// @notice only owner can add destination chains
    /// @param _chainName string of destination blockchain name
    /// @param _contractAddress address of destination MET token to import to
    function addDestinationChain(bytes8 _chainName, address _contractAddress) public onlyOwner returns (bool) {
        require(_chainName != 0 && _contractAddress != address(0));
        destinationChains[_chainName] = _contractAddress;
        return true;
    }

    /// @notice only owner can remove destination chains
    /// @param _chainName string of destination blockchain name
    function removeDestinationChain(bytes8 _chainName) public onlyOwner returns (bool) {
        require(_chainName != 0);
        require(destinationChains[_chainName] != address(0));
        destinationChains[_chainName] = address(0);
        return true;   
    }

    /// @notice holds claims from users that have exported on-chain
    /// @param key is address of destination MET token contract
    /// @param subKey is address of users account that burned their original MET token
    mapping (address  => mapping(address => uint)) public claimables;

    /// @notice destination MET token contract calls claimReceivables to record burned 
    /// tokens have been minted in new chain 
    /// @param recipients array of addresses of each user that has exported from
    /// original chain.  These can be generated by LogExportReceipt
    function claimReceivables(address[] recipients) public returns (uint) {
        require(recipients.length > 0);

        uint total;
        for (uint i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint amountBurned = claimables[msg.sender][recipient];
            if (amountBurned > 0) {
                claimables[msg.sender][recipient] = 0;
                emit ExportOnChainClaimedReceiptLog(msg.sender, recipient, amountBurned);
                total = total.add(1);
            }
        }
        return total;
    }

    /// @notice Request for import MET tokens from another chain to this chain. 
    /// Minting will be done once off chain validators validate import request.
    /// @param _originChain source chain name
    /// @param _destinationChain destination chain name
    /// @param _addresses _addresses[0] is destMetronomeAddr and _addresses[1] is recipientAddr
    /// @param _extraData extra information for import
    /// @param _burnHashes _burnHashes[0] is previous burnHash, _burnHashes[1] is current burnHash
    /// @param _supplyOnAllChains MET supply on all supported chains
    /// @param _importData _importData[0] is _blockTimestamp, _importData[1] is _amount, _importData[2] is _fee
    /// _importData[3] is _burnedAtTick, _importData[4] is _genesisTime, _importData[5] is _dailyMintable
    /// _importData[6] is _burnSequence, _importData[7] is _dailyAuctionStartTime
    /// @param _proof merkle root
    /// @return true/false
    function importMET(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData, 
        bytes32[] _burnHashes, uint[] _supplyOnAllChains, uint[] _importData, bytes _proof) public returns (bool)
    {
        
        require(msg.sender == address(token));
        require(now >= chainHopStartTime);
        require(_importData.length == 8);
        require(_addresses.length == 2);
        require(_burnHashes.length == 2);
        require(!validator.hashClaimed(_burnHashes[1]));
        require(isReceiptValid(_originChain, _destinationChain, _addresses, _extraData, _burnHashes, 
        _supplyOnAllChains, _importData));
        require(_destinationChain == auctions.chain());
        require(_addresses[0] == address(token));
        require(_importData[1] != 0);
        
        // We do not want to change already deployed interface, hence accepting '_proof' 
        // as bytes and converting into bytes32. Here _proof is merkle root.
        merkleRoots[_burnHashes[1]] = bytesToBytes32(_proof);

        // mint hash is used for further validation before minting and after attestation by off chain validators. 
        mintHashes[_burnHashes[1]] = keccak256(abi.encodePacked(_originChain, 
        _addresses[1], _importData[1], _importData[2]));
        
        emit LogImportRequest(_originChain, _burnHashes[1], _burnHashes[0], _addresses[1], _importData[1],
            _importData[2], _importData[0], _importData[6], _extraData);
        return true;
    }

    /// @notice Export MET tokens from this chain to another chain.
    /// @param tokenOwner Owner of the token, whose tokens are being exported.
    /// @param _destChain Destination chain for exported tokens
    /// @param _destMetronomeAddr Metronome address on destination chain
    /// @param _destRecipAddr Recipient address on the destination chain
    /// @param _amount Amount of token being exported
    /// @param _extraData Extra data for this export
    /// @return boolean true/false based on the outcome of export
    function export(address tokenOwner, bytes8 _destChain, address _destMetronomeAddr,
        address _destRecipAddr, uint _amount, uint _fee, bytes _extraData) public returns (bool) {
        require(msg.sender == address(token));
        require(now >= chainHopStartTime);
        require(_destChain != 0x0 && _destMetronomeAddr != 0x0 && _destRecipAddr != 0x0 && _amount != 0);
        require(destinationChains[_destChain] == _destMetronomeAddr);
        
        require(token.balanceOf(tokenOwner) >= _amount.add(_fee));
        require(_fee >= minimumExportFee && _fee >= (_amount.mul(exportFee).div(10000)));
        token.destroy(tokenOwner, _amount.add(_fee));

        uint dailyMintable = auctions.dailyMintable();
        uint currentTick = auctions.currentTick();
       
       
        if (burnSequence == 1) {
            exportedBurns.push(keccak256(abi.encodePacked(uint8(0))));
        }

        if (_destChain == auctions.chain()) {
            claimables[_destMetronomeAddr][_destRecipAddr] = 
                claimables[_destMetronomeAddr][_destRecipAddr].add(_amount);
        }
        uint blockTime = block.timestamp;
        bytes32 currentBurn = keccak256(abi.encodePacked(
            blockTime, 
            auctions.chain(),
            _destChain, 
            _destMetronomeAddr, 
            _destRecipAddr, 
            _amount,
            _fee,
            currentTick,
            auctions.genesisTime(),
            dailyMintable,
            _extraData,
            exportedBurns[burnSequence - 1]));
       
        exportedBurns.push(currentBurn);
        burnHashes[currentBurn] = burnSequence;
        supplyOnAllChains[0] = token.totalSupply();
        
        emit LogExportReceipt(_destChain, _destMetronomeAddr, _destRecipAddr, _amount, _fee, _extraData, 
            currentTick, burnSequence, currentBurn, exportedBurns[burnSequence - 1], dailyMintable,
            supplyOnAllChains, blockTime, tokenOwner);

        burnSequence = burnSequence + 1;
        return true;
    }

    /// @notice mintToken will be called by validator contract only and that too only after hash attestation.
    /// @param originChain origin chain from where these token burnt.
    /// @param recipientAddress tokens will be minted for this address.
    /// @param amount amount being imported/minted
    /// @param fee fee paid during export
    /// @param extraData any extra data related to export-import process.
    /// @param currentHash current export hash from source/origin chain.
    /// @param validators validators
    /// @return true/false indicating minting was successful or not
    function mintToken(bytes8 originChain, address recipientAddress, uint amount, 
        uint fee, bytes extraData, bytes32 currentHash, uint globalSupplyInOtherChains, 
        address[] validators) public returns (bool) {
        require(msg.sender == address(validator));
        require(originChain != 0x0);
        require(recipientAddress != 0x0);
        require(amount > 0);
        require(currentHash != 0x0);

        //Validate that mint data is same as the data received during import request.
        require(mintHashes[currentHash] == keccak256(abi.encodePacked(originChain, recipientAddress, amount, fee)));

        require(isGlobalSupplyValid(amount, fee, globalSupplyInOtherChains));
        
        if (importSequence == 1 && token.totalSupply() == 0) {
            auctions.prepareAuctionForNonOGChain();
        }
        
        require(token.mint(recipientAddress, amount));
        // fee amount has already been validated during export and its part of burn hash
        // so we may not need to calculate it again.
        uint feeToDistribute =  fee.div(validators.length);
        for (uint i = 0; i < validators.length; i++) {
            token.mint(validators[i], feeToDistribute);
        }
        emit LogImport(originChain, recipientAddress, amount, fee, extraData, importSequence, currentHash);
        importSequence++;
        return true;
    }

    /// @notice Convert bytes to bytes32
    function bytesToBytes32(bytes b) private pure returns (bytes32) {
        bytes32 out;

        for (uint i = 0; i < 32; i++) {
            out |= bytes32(b[i] & 0xFF) >> (i * 8);
        }
        return out;
    }

    /// @notice Check global supply is still valid with current import amount and fee
    function isGlobalSupplyValid(uint amount, uint fee, uint globalSupplyInOtherChains) private view returns (bool) {
        uint amountToImport = amount.add(fee);
        uint currentGlobalSupply = globalSupplyInOtherChains.add(token.totalSupply());
        return (amountToImport.add(currentGlobalSupply) <= auctions.globalMetSupply());
    }

    /// @notice validate the export receipt
    function isReceiptValid(bytes8 _originChain, bytes8 _destinationChain, address[] _addresses, bytes _extraData, 
        bytes32[] _burnHashes, uint[] _supplyOnAllChain, uint[] _importData) private pure returns(bool) {

        // Due to stack too deep error and limitation in using number of local 
        // variables we had to use array here.
        // _importData[0] is _blockTimestamp, _importData[1] is _amount, _importData[2] is _fee,
        // _importData[3] is _burnedAtTick, _importData[4] is _genesisTime,
        // _importData[5] is _dailyMintable, _importData[6] is _burnSequence,
        // _addresses[0] is _destMetronomeAddr and _addresses[1] is _recipAddr
        // _burnHashes[0] is previous burnHash, _burnHashes[1] is current burnHash

        if (_burnHashes[1] == keccak256(abi.encodePacked(_importData[0], _originChain,
            _destinationChain, _addresses[0], _addresses[1], _importData[1], _importData[2], 
            _importData[3], _importData[4], _importData[5], _extraData, _burnHashes[0]))) {
            return true;
        }
        
        return false;
    }
}    


/// @title Proposals intiated by validators.  
contract Proposals is Owned {
    uint public votingPeriod = 60 * 60 * 24 * 15;

    Validator public validator;
    mapping (address => uint) public valProposals;

    bytes32[] public actions;
    
    struct Proposal {
        uint proposalId;
        bytes32 action;
        uint expiry;
        address validator;
        uint newThreshold;
        uint supportCount;
        address[] voters;
        bool passed;
        mapping (address => bool) voted;

    }

    Proposal[] public proposals;

    event LogVoted(uint indexed proposalId, address indexed voter, bool support);

    event LogProposalCreated(uint indexed proposalId, address indexed newValidator, 
        uint newThreshold, address creator, uint expiry, bytes32 indexed action);

    event LogProposalClosed(uint indexed proposalId, address indexed newValidator, 
        uint newThreshold, bytes32 indexed action, uint expiry, uint supportCount, bool passed);

    /// @dev Throws if called by any account other than the validator.
    modifier onlyValidator() {
        require(validator.isValidator(msg.sender));
        _;
    }

    constructor() public {
        actions.push("addval");
        actions.push("removeval");
        actions.push("updatethreshold");
    }

    /// @notice set address of validator contract
    /// @param _validator address of validator contract
    function setValidator(address _validator) public onlyOwner returns (bool) {
        require(_validator != 0x0);
        validator = Validator(_validator);
        return true;
    }

    /// @notice set update voting period
    /// @param _t voting period
    function updateVotingPeriod(uint _t) public onlyOwner returns (bool) {
        require(_t != 0);
        votingPeriod = _t;
        return true;
    }

    /// @notice validator can initiate proposal for add new validator.
    /// @param _validator new validator address
    /// @param _newThreshold new threshold value. 0 if do not want to update it
    function proposeNewValidator(address _validator, uint _newThreshold) public onlyValidator returns (uint) {
        require(_validator != 0x0);
        require(!validator.isValidator(_validator));
        if (_newThreshold > 0) {
            uint valCount = validator.getValidatorsCount();
            require(validator.isNewThresholdValid(valCount + 1, _newThreshold));
        }
        return createNewProposal(_validator, msg.sender, actions[0], _newThreshold);
    }

    /// @notice validator can initiate proposal to remove bad actor or idle validators.
    /// validators can be removed if support count >= threshold or  support count == voting count.
    /// Later approach is to remove idle validator from system. 
    /// @param _validator new validator address
    /// @param _newThreshold new threshold value. 0 if do not want to update it
    function proposeRemoveValidator(address _validator, uint _newThreshold) public onlyValidator returns (uint) {
        require(_validator != 0x0);
        require(validator.isValidator(_validator));
        if (_newThreshold > 0) {
            uint valCount = validator.getValidatorsCount();
            require(validator.isNewThresholdValid(valCount - 1, _newThreshold));
        }
        return createNewProposal(_validator, msg.sender, actions[1], _newThreshold);
    }

    /// @notice validator can initiate proposal to update threshold value
    /// @param _newThreshold new threshold value. 0 if do not want to update it
    function proposeNewThreshold(uint _newThreshold) public onlyValidator returns (uint) {
        uint valCount = validator.getValidatorsCount();
        require(validator.isNewThresholdValid(valCount, _newThreshold));
        return createNewProposal(0x0, msg.sender, actions[2], _newThreshold);
    }

    /// @notice validator can vote for a proposal
    /// @param _proposalId ..
    /// @param _support true/false
    function voteForProposal(uint _proposalId, bool _support) public onlyValidator {
        require(proposals[_proposalId].expiry != 0);
        require(now < proposals[_proposalId].expiry);
        require(!proposals[_proposalId].passed);
        require(!(proposals[_proposalId]).voted[msg.sender]);
        proposals[_proposalId].voters.push(msg.sender);
        proposals[_proposalId].voted[msg.sender] = true;
        if (_support) {
            proposals[_proposalId].supportCount++;
        }
        emit LogVoted(_proposalId, msg.sender, _support);
    }
    
    /// @notice public function to close a proposal if expired or majority support received
    /// @param _proposalId ..
    function closeProposal(uint _proposalId) public {
        require(proposals[_proposalId].expiry != 0);
        if (proposals[_proposalId].supportCount >= validator.threshold()) {
            executeProposal(_proposalId, proposals[_proposalId].newThreshold);
        } else if (now > proposals[_proposalId].expiry) {
            // Proposal to remove idle validator if no one take objection
            if ((proposals[_proposalId].action == actions[1]) && 
                (proposals[_proposalId].voters.length == proposals[_proposalId].supportCount)) {
                executeProposal(_proposalId, proposals[_proposalId].newThreshold);
            }
        }   
    }

    /// @notice private function to update outcome of a proposal
    /// @param _proposalId ..
    /// @param _newThreshold ..
    function executeProposal(uint _proposalId, uint _newThreshold) private {
        if (proposals[_proposalId].action == actions[0]) {
            validator.addValidator(proposals[_proposalId].validator);
        } else if (proposals[_proposalId].action == actions[1]) {
            validator.removeValidator(proposals[_proposalId].validator);
        }
        if (_newThreshold != 0 && _newThreshold != validator.threshold()) {
            validator.updateThreshold(_newThreshold);
        }
        proposals[_proposalId].passed = true;
        emit LogProposalClosed(_proposalId, proposals[_proposalId].validator, 
            _newThreshold, proposals[_proposalId].action, proposals[_proposalId].expiry, 
            proposals[_proposalId].supportCount, true);
    }

    /// @notice private function to create a proposal
    /// @param _validator validator address
    /// @param _creator creator
    /// @param _action _action
    /// @param _newThreshold _newThreshold
    function createNewProposal(address _validator, address _creator, bytes32 _action, 
        uint _newThreshold) private returns (uint proposalId) {
        proposalId = proposals.length++;
        if (_validator != 0x0) {
            require((valProposals[_validator] == 0) || (now > proposals[valProposals[_validator]].expiry) 
            || (proposals[valProposals[_validator]].passed));
            valProposals[_validator] = proposalId;
        }
        uint expiry = now + votingPeriod;
        Proposal storage p = proposals[proposalId];
        p.proposalId = proposalId;
        p.action = _action;
        p.expiry = expiry;
        p.validator = _validator;
        p.newThreshold = _newThreshold;
        emit LogProposalCreated(proposalId, _validator, _newThreshold, _creator, expiry, _action);
    }
}


/// @title Validator contract for off chain validators to validate hash
contract Validator is Owned {

    using SafeMath for uint;

    /// @notice Mapping to store the attestation done by each offchain validator for a hash
    mapping (bytes32 => mapping (address => bool)) public hashAttestations;
    mapping (bytes32 => mapping (address => bool)) public hashRefutation;
    mapping (bytes32 => uint) public attestationCount;
    mapping (address => bool) public isValidator;
    address[] public validators;
    METToken public token;
    TokenPorter public tokenPorter;
    Auctions public auctions;
    Proposals public proposals;

    mapping (bytes32 => bool) public hashClaimed;

    // Miniumum quorum require for various voting like import, add new validators, add new chain
    uint public threshold = 2;

    event LogAttestation(bytes32 indexed hash, address indexed recipientAddr, bool isValid);
    event LogValidatorAdded(address indexed validator, address indexed caller, uint threshold);
    event LogValidatorRemoved(address indexed validator, address indexed caller, uint threshold);
  
    /// @dev Throws if called by any account other than the validator.
    modifier onlyValidator() {
        require(isValidator[msg.sender]);
        _;
    }

    /// @dev Throws if called by unauthorized account
    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == address(proposals));
        _;
    }

    /// @param _validator validator address
    function addValidator(address _validator) public onlyAuthorized {
        require(!isValidator[_validator]);
        validators.push(_validator);
        isValidator[_validator] = true;
        uint minThreshold = (validators.length / 2) + 1;
        if (threshold < minThreshold) {
            threshold = minThreshold;
        }
        emit LogValidatorAdded(_validator, msg.sender, threshold);
    }

    /// @param _validator validator address
    function removeValidator(address _validator) public onlyAuthorized {
        // Must add new validators before removing to maintain minimum one validator active
        require(validators.length > 1);
        delete isValidator[_validator];
        for (uint i = 0; i < (validators.length); i++) {
            if (validators[i] == _validator) {
                if (i != (validators.length - 1)) {
                    validators[i] = validators[validators.length - 1];
                }
                validators.length--; 
                break;
            }
        }

        if (threshold >= validators.length) {
            if (validators.length == 1) {
                threshold = 1;
            } else {
                threshold = validators.length - 1;
            }
        }
        emit LogValidatorRemoved(_validator, msg.sender, threshold);
    }

    /// @notice fetch count of validators
    function getValidatorsCount() public view returns (uint) { 
        return  validators.length;
    }

    /// @notice set threshold for validation and minting
    /// @param _threshold threshold count
    /// @return true/false
    function updateThreshold(uint _threshold) public onlyAuthorized returns (bool) {
        require(isNewThresholdValid(validators.length, _threshold));
        threshold = _threshold;
        return true;
    }

    /// @notice check valid threshold value. Common function for validator and proposal contract
    /// @param _valCount valicator count
    /// @param _threshold new threshold value
    /// @return true/false
    function isNewThresholdValid(uint _valCount, uint _threshold) public pure returns (bool) {
        if (_threshold == 1 && _valCount == 2) {
            return true;
        } else if (_threshold >= 1 && _threshold < _valCount && (_threshold > (_valCount / 2))) {
            return true;
        }
        return false;
    }

    /// @notice set address of Proposals contract
    /// @param _proposals address of token porter
    /// @return true/false
    function setProposalContract(address _proposals) public onlyOwner returns (bool) {
        require(_proposals != 0x0);
        proposals = Proposals(_proposals);
        return true;
    }

    /// @notice set address of token porter
    /// @param _tokenPorter address of token porter
    /// @return true/false
    function setTokenPorter(address _tokenPorter) public onlyOwner returns (bool) {
        require(_tokenPorter != 0x0);
        tokenPorter = TokenPorter(_tokenPorter);
        return true;
    }

    /// @notice set contract addresses in validator contract.
    /// @param _tokenAddr address of MetToken contract
    /// @param _auctionsAddr address of Auction contract
    /// @param _tokenPorterAddr address of TokenPorter contract
    function initValidator(address _tokenAddr, address _auctionsAddr, address _tokenPorterAddr) public onlyOwner {
        require(_tokenAddr != 0x0);
        require(_auctionsAddr != 0x0);
        require(_tokenPorterAddr != 0x0);
        tokenPorter = TokenPorter(_tokenPorterAddr);
        auctions = Auctions(_auctionsAddr);
        token = METToken(_tokenAddr);
    }

    /// @notice Off chain validator call this function to validate and attest the hash. 
    /// @param _burnHash current burnHash
    /// @param _originChain source chain
    /// @param _recipientAddr recipientAddr
    /// @param _amount amount to import
    /// @param _fee fee for import-export
    /// @param _proof proof
    /// @param _extraData extra information for import
    /// @param _globalSupplyInOtherChains total supply in all other chains except this chain
    function attestHash(bytes32 _burnHash, bytes8 _originChain, address _recipientAddr, 
        uint _amount, uint _fee, bytes32[] _proof, bytes _extraData,
        uint _globalSupplyInOtherChains) public onlyValidator {
        require(_burnHash != 0x0);
        require(!hashAttestations[_burnHash][msg.sender]);
        require(!hashRefutation[_burnHash][msg.sender]);
        require(verifyProof(tokenPorter.merkleRoots(_burnHash), _burnHash, _proof));
        hashAttestations[_burnHash][msg.sender] = true;
        attestationCount[_burnHash]++;
        emit LogAttestation(_burnHash, _recipientAddr, true);
        
        if (attestationCount[_burnHash] >= threshold && !hashClaimed[_burnHash]) {
            hashClaimed[_burnHash] = true;
            require(tokenPorter.mintToken(_originChain, _recipientAddr, _amount, _fee, 
                _extraData, _burnHash, _globalSupplyInOtherChains, validators));
        }
    }

    /// @notice off chain validator can refute hash, if given export hash is not verified in origin chain.
    /// @param _burnHash Burn hash
    function refuteHash(bytes32 _burnHash, address _recipientAddr) public onlyValidator {
        require(!hashAttestations[_burnHash][msg.sender]);
        require(!hashRefutation[_burnHash][msg.sender]);
        hashRefutation[_burnHash][msg.sender] = true;
        emit LogAttestation(_burnHash, _recipientAddr, false);
    }

    /// @notice verify that the given leaf is in merkle root.
    /// @param _root merkle root
    /// @param _leaf leaf node, current burn hash
    /// @param _proof merkle path
    /// @return true/false outcome of the verification.
    function verifyProof(bytes32 _root, bytes32 _leaf, bytes32[] _proof) private pure returns (bool) {
        require(_root != 0x0 && _leaf != 0x0 && _proof.length != 0);

        bytes32 _hash = _leaf;
        for (uint i = 0; i < _proof.length; i++) {
            _hash = sha256(_proof[i], _hash);
        } 
        return (_hash == _root);
    }

}