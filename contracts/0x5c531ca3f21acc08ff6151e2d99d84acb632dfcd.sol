pragma solidity ^0.4.24;

contract ConnectCapacity {

    address private controllerSystem;

    // struct AdaptionOrder
    struct AdaptionOrder {
        address vglNb;
        int256 cot;
        int256 pct;
        int256 tct;
        int256 ict;
    }

    // map address -> tokenclassId -> balance
    mapping(address => mapping(string => int256)) private capacityBalance;

    // map rc -> timestamp -> struct(AdaptionOrder)
    mapping(address => mapping( uint256 => AdaptionOrder)) private adaptionMap;

    event Transfer (address indexed from, address indexed to, string classId, int256 value, int256 balanceAfterTx);

    event Changed (address indexed rc, int256 tctValue, int256 ictValue,
    int256 balanceOfTCTGiveAfterTx, int256 balanceOfICTGiveAfterTx, int256 balanceOfCOTAfterTx);
 
    event AdaptionRequest (address indexed from, uint256 indexed time, int256 value);

    event AdaptionRelease (address indexed vglNbAddress, address indexed rcAddress, uint256 time);

    modifier onlySystem() {
        require(msg.sender == controllerSystem, "only System can invoke");
        _;
    }

    constructor() public {
        controllerSystem = msg.sender;
    }

    function transfer(address _from, address _to, string memory _classId, int256 _value) public onlySystem() {
        require(_value >= 0, "Negative amount");
        if (_value != 0) {
            capacityBalance[_to][_classId] = capacityBalance[_to][_classId] + _value;
            capacityBalance[_from][_classId] = capacityBalance[_from][_classId] - _value;
        }
        int256 balanceAfterTx = capacityBalance[_from][_classId];
        emit Transfer(_from, _to, _classId, _value, balanceAfterTx);
    }

    function interchange(address _from, address _to, int256 _valueTCT, int256 _valueICT) public onlySystem() {

        require(_valueTCT >= 0, "TCT can only be reduced");
        require(capacityBalance[_from]["TCT"] >= _valueTCT, "the TCT value is bigger than the current Balance");
        require(_valueICT >= 0 || _valueTCT >= -1 * _valueICT, "the increased ICT value is bigger than the given TCT");
        capacityBalance[_from]["TCT"] = capacityBalance[_from]["TCT"] - _valueTCT;
        capacityBalance[_from]["ICT"] = capacityBalance[_from]["ICT"] - _valueICT;
        capacityBalance[_from]["COT"] = capacityBalance[_from]["COT"] + _valueTCT + _valueICT;

        capacityBalance[_to]["TCT"] = capacityBalance[_to]["TCT"] + _valueTCT;
        capacityBalance[_to]["ICT"] = capacityBalance[_to]["ICT"] + _valueICT;
        capacityBalance[_to]["COT"] = capacityBalance[_to]["COT"] - _valueTCT - _valueICT;

        int256 balanceOfTCTGiveAfterTx = capacityBalance[_from]["TCT"];
        int256 balanceOfICTGiveAfterTx = capacityBalance[_from]["ICT"];
        int256 balanceOfCOTAfterTx = capacityBalance[_from]["COT"];
        emit Changed(_from, _valueTCT, _valueICT, balanceOfTCTGiveAfterTx, balanceOfICTGiveAfterTx, balanceOfCOTAfterTx);
    }

    function createAdaptionRequest(address _rc, address _vglNb, int256 _value, uint256 _timeOfChange) public onlySystem() {
        AdaptionOrder memory adaption = adaptionMap[_rc][_timeOfChange];
        // if Adaption already exist the value of COT will be replaced with the new one to allow Update.
        adaptionMap[_rc][_timeOfChange] = AdaptionOrder(_vglNb, _value, adaption.pct, adaption.tct, adaption.ict);
        emit AdaptionRequest(_rc, _timeOfChange, _value);
    }

    function changeAdaptionRequest(address _rc, address _vglNb, int256 _value, uint256 _timeOfChange,
        uint256 _oldTimeOfChange) public onlySystem() {
        delete adaptionMap[_rc][_oldTimeOfChange];
        createAdaptionRequest(_rc, _vglNb, _value, _timeOfChange);

    }

    function confirmAdaptionRequest(address _rc, int256 _valueOfPCT, int256 _valueOfTCT, int256 _valueOfICT, uint256 timeOfChange)
      public onlySystem() {
        AdaptionOrder storage adaption = adaptionMap[_rc][timeOfChange];
        require(adaption.vglNb != address(0), "there is no Adaption");
        adaption.pct = _valueOfPCT;
        adaption.tct = _valueOfTCT;
        adaption.ict = _valueOfICT;
    }

    function releaseAdaption(address _rc, uint256 timeOfChange) public onlySystem() {
        AdaptionOrder storage adaption = adaptionMap[_rc][timeOfChange];
        require(adaption.vglNb != address(0), "there is no Adaption");
        if (adaption.cot >= 0) {
            transfer(_rc, adaption.vglNb, "COT", adaption.cot);
        } else {
            transfer(adaption.vglNb, _rc, "COT", -1 * adaption.cot);
        }
        if (adaption.pct >= 0) {
            transfer(adaption.vglNb, _rc, "PCT", adaption.pct);
        } else {
            transfer(_rc, adaption.vglNb, "PCT", -1 * adaption.pct);
        }
        if (adaption.tct >= 0) {
            transfer(adaption.vglNb, _rc, "TCT", adaption.tct);
        } else {
            transfer(_rc, adaption.vglNb, "TCT", -1 * adaption.tct);
        }
        if (adaption.ict >= 0) {
            transfer(adaption.vglNb, _rc, "ICT", adaption.ict);
        } else {
            transfer(_rc, adaption.vglNb, "ICT", -1 * adaption.ict);
        }

        emit AdaptionRelease(adaption.vglNb, _rc, timeOfChange);
        delete adaptionMap[_rc][timeOfChange];
    }

    function balanceOf(address _address, string memory _classId) public view returns (int256) {
        return capacityBalance[_address][_classId];
    }

    function getAdaptionValues(address _rc, uint256 timeOfChange) public view returns (int256, int256, int256, int256) {
        AdaptionOrder storage adaption = adaptionMap[_rc][timeOfChange];
        return (adaption.cot, adaption.pct, adaption.tct, adaption.ict);
    }

    function getTotalBalance(address _address) public view returns(int256 currentBalance) {
        int256 balanceForCOT = balanceOf(_address, "COT");
        int256 balanceForPCT = balanceOf(_address, "PCT");
        int256 balanceForTCT = balanceOf(_address, "TCT");
        int256 balanceForICT = balanceOf(_address, "ICT");
        currentBalance = balanceForCOT + balanceForPCT + balanceForTCT + balanceForICT;
    }

    function () external payable {
        revert("not allowed function");
    }

}