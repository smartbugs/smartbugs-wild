pragma solidity ^0.4.11;

library SafeMath {
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC223Compliant {
    function tokenFallback(address _from, uint _value, bytes _data) {}
}

contract EtheraffleLOT is ERC223Compliant {
    using SafeMath for uint;

    string    public name;
    string    public symbol;
    bool      public frozen;
    uint8     public decimals;
    address[] public freezers;
    address   public etheraffle;
    uint      public totalSupply;

    mapping (address => uint) public balances;
    mapping (address => bool) public canFreeze;

    event LogFrozenStatus(bool status, uint atTime);
    event LogFreezerAddition(address newFreezer, uint atTime);
    event LogFreezerRemoval(address freezerRemoved, uint atTime);
    event LogEtheraffleChange(address prevER, address newER, uint atTime);
    event LogTransfer(address indexed from, address indexed to, uint value, bytes indexed data);

    /**
     * @dev   Modifier function to prepend to methods rendering them only callable
     *        by the Etheraffle MultiSig wallet.
     */
    modifier onlyEtheraffle() {
        require(msg.sender == etheraffle);
        _;
    }
    /**
     * @dev   Modifier function to prepend to methods rendering them only callable
     *        by address approved for freezing.
     */
    modifier onlyFreezers() {
        require(canFreeze[msg.sender]);
        _;
    }
    /**
     * @dev   Modifier function to prepend to methods to render them only callable
     *        when the frozen toggle is false
     */
    modifier onlyIfNotFrozen() {
        require(!frozen);
        _;
    }
    /**
     * @dev   Constructor: Sets the meta data for the token and gives the intial supply to the
     *        Etheraffle ICO.
     *
     * @param _etheraffle   Address of the Etheraffle's multisig wallet, the only
     *                      address via which the frozen/unfrozen state of the
     *                      token transfers can be toggled.
     * @param _supply       Total numner of LOT to mint on contract creation.

     */
    function EtheraffleLOT(address _etheraffle, uint _supply) {
        freezers.push(_etheraffle);
        name                   = "Etheraffle LOT";
        symbol                 = "LOT";
        decimals               = 6;
        etheraffle             = _etheraffle;
        totalSupply            = _supply * 10 ** uint256(decimals);
        balances[_etheraffle]  = totalSupply;
        canFreeze[_etheraffle] = true;
    }
    /**
     * ERC223 Standard functions:
     *
     * @dev Transfer the specified amount of LOT to the specified address.
     *      Invokes the `tokenFallback` function if the recipient is a contract.
     *      The token transfer fails if the recipient is a contract
     *      but does not implement the `tokenFallback` function
     *      or the fallback function to receive funds.
     *
     * @param _to     Receiver address.
     * @param _value  Amount of LOT to be transferred.
     * @param _data   Transaction metadata.
     */
    function transfer(address _to, uint _value, bytes _data) onlyIfNotFrozen external {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to]        = balances[_to].add(_value);
        if(codeLength > 0) {
            ERC223Compliant receiver = ERC223Compliant(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        LogTransfer(msg.sender, _to, _value, _data);
    }
    /**
     * @dev   Transfer the specified amount of LOT to the specified address.
     *        Standard function transfer similar to ERC20 transfer with no
     *        _data param. Added due to backwards compatibility reasons.
     *
     * @param _to     Receiver address.
     * @param _value  Amount of LOT to be transferred.
     */
    function transfer(address _to, uint _value) onlyIfNotFrozen external {
        uint codeLength;
        bytes memory empty;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to]        = balances[_to].add(_value);
        if(codeLength > 0) {
            ERC223Compliant receiver = ERC223Compliant(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        LogTransfer(msg.sender, _to, _value, empty);
    }
    /**
     * @dev     Returns balance of the `_owner`.
     * @param _owner    The address whose balance will be returned.
     * @return balance  Balance of the `_owner`.
     */
    function balanceOf(address _owner) constant external returns (uint balance) {
        return balances[_owner];
    }
    /**
     * @dev   Change the frozen status of the LOT token.
     *
     * @param _status   Desired status of the frozen bool
     */
    function setFrozen(bool _status) external onlyFreezers returns (bool) {
        frozen = _status;
        LogFrozenStatus(frozen, now);
        return frozen;
    }
    /**
     * @dev     Allow addition of freezers to allow future contracts to
     *          use the role.
     *
     * @param _new  New freezer address.
     */
    function addFreezer(address _new) external onlyEtheraffle {
        freezers.push(_new);
        canFreeze[_new] = true;
        LogFreezerAddition(_new, now);
    }
    /**
     * @dev     Remove a freezer should they no longer require or need the
     *          the privilege.
     *
     * @param _freezer    The desired address to be removed.
     */
    function removeFreezer(address _freezer) external onlyEtheraffle {
        require(canFreeze[_freezer]);
        canFreeze[_freezer] = false;
        for(uint i = 0; i < freezers.length - 1; i++)
            if(freezers[i] == _freezer) {
                freezers[i] = freezers[freezers.length - 1];
                break;
            }
        freezers.length--;
        LogFreezerRemoval(_freezer, now);
    }
    /**
     * @dev   Allow changing of contract ownership ready for future upgrades/
     *        changes in management structure.
     *
     * @param _new  New owner/controller address.
     */
    function setEtheraffle(address _new) external onlyEtheraffle {
        LogEtheraffleChange(etheraffle, _new, now);
        etheraffle = _new;
    }
    /**
     * @dev   Fallback in case of accidental ether transfer
     */
    function () external payable {
        revert();
    }
    /**
     * @dev   Housekeeping- called in the event this contract is no
     *        longer needed, after a LOT upgrade for example. Deletes
     *        the code from the blockchain. Only callable by the
     *        Etheraffle address.
     */
    function selfDestruct() external onlyEtheraffle {
        require(frozen);
        selfdestruct(etheraffle);
    }
}