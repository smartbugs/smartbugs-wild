pragma solidity 0.4.24;

library SafeMathExt{
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function pow(uint256 a, uint256 b) internal pure returns (uint256) {
    if (b == 0){
      return 1;
    }
    if (b == 1){
      return a;
    }
    uint256 c = a;
    for(uint i = 1; i<b; i++){
      c = mul(c, a);
    }
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function roundUp(uint256 a, uint256 b) public pure returns(uint256){
    // ((a + b - 1) / b) * b
    uint256 c = (mul(div(sub(add(a, b), 1), b), b));
    return c;
  }
}

contract BadgeFactoryInterface{
	function _initBadges(address admin_, uint256 badgeBasePrice_, uint256 badgeStartMultiplier_, uint256 badgeStartQuantity_) external;
	function _createNewBadge(address owner_, uint256 price_) external;
	function _setOwner(uint256 badgeID_, address owner_) external;
	function getOwner(uint256 badgeID_) public view returns(address);
	function _increasePrice(uint256 badgeID_) external;
	function getPrice(uint256 badgeID_) public view returns(uint256);
	function _increaseTotalDivis(uint256 badgeID_, uint256 divis_) external;
	function getTotalDivis(uint256 badgeID_) public view returns(uint256);
	function _setBuyTime(uint256 badgeID_, uint32 timeStamp_) external;
	function getBuyTime(uint256 badgeID_) public view returns(uint32);
	function getCreationTime(uint256 badgeID_) public view returns(uint32);
	function getChainLength() public view returns(uint256);
	function getRandomBadge(uint256 max_, uint256 i_) external view returns(uint256);
    function getRandomFactor() external returns(uint256);
}

contract TeamAmberInterface{
    function distribute() public payable;
}

contract Amber{
	using SafeMathExt for uint256;
    /*===============================================================================
    =                      DATA SET                     DATA SET                    =
    ===============================================================================*/
    /*==============================
    =          INTERFACES          =
    ==============================*/
    BadgeFactoryInterface internal _badgeFactory;
    TeamAmberInterface internal _teamAmber;

    /*==============================
    =          CONSTANTS           =
    ==============================*/
    uint256 internal constant GWEI = 10**9;
    uint256 internal constant FINNEY = 10**15;
    uint256 internal constant ETH = 10**18;
    uint256 internal constant _badgeBasePrice = 25 * FINNEY;
    uint256 internal constant _luckyWinners = 5;
    uint256 internal constant _sharePreviousOwnerRatio = 50;
    uint256 internal constant _shareReferalRatio = 5;
    uint256 internal constant _shareDistributionRatio = 45;

    /*==============================
    =          VARIABLES           =
    ==============================*/
    address internal _contractOwner;
    address internal _admin;
    uint256 internal _startTime;
    uint256 internal _initCounter;

    /*==============================
    =            BADGES            =
    ==============================*/
    struct Badge{
        address owner;
        uint256 price;
        uint256 totalDivis;
    }

    Badge[] private badges;

    /*==============================
    =        USER MAPPINGS         =
    ==============================*/
    mapping(address => uint256) private _splitProfit;
    mapping(address => uint256) private _flipProfit;
    mapping(address => uint256) private _waypointProfit;
    mapping(address => address) private _referer;

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onContractStart(uint256 startTime_);
    event onRefererSet(address indexed user_, address indexed referer_);
    event onBadgeBuy(uint256 indexed badgeID_, address previousOwner_, address indexed buyer_, address indexed referer_, uint256 price_, uint256 newPrice_);
    event onWithdraw(address indexed receiver_, uint256 splitProfit_, uint256 flipProfit_, uint256 waypointProfit_);

    /*==============================
    =          MODIFIERS           =
    ==============================*/
    modifier onlyContractOwner(){
    	require(msg.sender == _contractOwner, 'Sender is not the contract owner.');
    	_;
    }
    modifier isNotAContract(){
        require (msg.sender == tx.origin, 'Contracts are not allowed to interact.');
        _;
    }
    modifier isRunning(){
    	require(_startTime != 0 && _startTime <= now, 'The contract is not running yet.');
    	_;
    }

    /*===============================================================================
    =                       PURE AMBER                       PURE AMBER             =
    ===============================================================================*/
    function isValidBuy(uint256 price_, uint256 msgValue_) public pure returns(bool){
        return (price_ == msgValue_);
    }

    function refererAllowed(address msgSender_, address currentReferer_, address newReferer_) public pure returns(bool){
        return (addressNotSet(currentReferer_) && isAddress(newReferer_) && isNotSelf(msgSender_, newReferer_));
    }

    function addressNotSet(address address_) public pure returns(bool){
        return (address_ == 0x0);
    }

    function isAddress(address address_) public pure returns(bool){
        return (address_ != 0x0);
    }

    function isNotSelf(address msgSender_, address compare_) public pure returns(bool){
        return (msgSender_ != compare_);
    }

    function isFirstBadgeEle(uint256 badgeID_) public pure returns(bool){
        return (badgeID_ == 0);
    }

    function isLastBadgeEle(uint256 badgeID_, uint256 badgeLength_) public pure returns(bool){
        assert(badgeID_ <= SafeMathExt.sub(badgeLength_, 1));
        return (badgeID_ == SafeMathExt.sub(badgeLength_, 1));
    }

    function calcShare(uint256 msgValue_, uint256 ratio_) public pure returns(uint256){
        assert(ratio_ <= 100 && msgValue_ >= 0);
        return (msgValue_ * ratio_) / 100;
    }

    /*===============================================================================
    =                     BADGE FACTORY                     BADGE FACTORY           =
    ===============================================================================*/
    function _initBadges(address[] owner_, uint256[] price_, uint256[] totalDivis_) internal{
        for (uint256 i = 0; i < owner_.length; i++) {
            badges.push(Badge(owner_[i], price_[i], totalDivis_[i]));
        }
    }

    function _createNewBadge(address owner_, uint256 price_) internal{
        badges.push(Badge(owner_, price_, 0));
    }

    function _setOwner(uint256 badgeID_, address owner_) internal{
        badges[badgeID_].owner = owner_;
    }

    function getOwner(uint256 badgeID_) public view returns(address){
        return badges[badgeID_].owner;
    }

    function _increasePrice(uint256 badgeID_) internal{
        uint256 newPrice = (badges[badgeID_].price * _badgeFactory.getRandomFactor()) / 100;
        badges[badgeID_].price = SafeMathExt.roundUp(newPrice, 10000 * GWEI);
    }

    function getPrice(uint256 badgeID_) public view returns(uint256){
        return badges[badgeID_].price;
    }

    function _increaseTotalDivis(uint256 badgeID_, uint256 divis_) internal{
        badges[badgeID_].totalDivis += divis_;
    }

    function getTotalDivis(uint256 badgeID_) public view returns(uint256){
        return badges[badgeID_].totalDivis;
    }

    function getChainLength() public view returns(uint256){
        return badges.length;
    }

    /*===============================================================================
    =                       FUNCTIONS                       FUNCTIONS               =
    ===============================================================================*/
    /*==============================
    =           OWNER ONLY         =
    ==============================*/
    constructor(address admin_, address teamAmberAddress_) public{
    	_contractOwner = msg.sender;
        _admin = admin_;
        _teamAmber = TeamAmberInterface(teamAmberAddress_);
    }

    function initGame(address badgesFactoryAddress_, address[] owner_, uint256[] price_, uint256[] totalDivis_) external onlyContractOwner{
        require(_startTime == 0);
        assert(owner_.length == price_.length && price_.length == totalDivis_.length);

        if(_badgeFactory == address(0x0)){
            _badgeFactory = BadgeFactoryInterface(badgesFactoryAddress_);
        }
        _initBadges(owner_, price_, totalDivis_);
    }

    function initReferrals(address[] refArray_) external onlyContractOwner{
        require(_startTime == 0);
        for (uint256 i = 0; i < refArray_.length; i+=2) {
            _refererUpdate(refArray_[i], refArray_[i+1]);
        }
    }

    function _startContract(uint256 delay_) external onlyContractOwner{
    	require(_startTime == 0);
        _startTime = now + delay_;

        emit onContractStart(_startTime);
    }

    /*==============================
    =             BUY              =
    ==============================*/
    //Hex Data: 0x7deb6025
    function buy(uint256 badgeID_, address newReferer_) public payable isNotAContract isRunning{
    	_refererUpdate(msg.sender, newReferer_);
    	_buy(badgeID_, newReferer_, msg.sender, msg.value);
    }

    function _buy(uint256 badgeID_, address newReferer_, address msgSender_, uint256 msgValue_) internal{
        address previousOwner = getOwner(badgeID_);
        require(isNotSelf(msgSender_, getOwner(badgeID_)), 'You can not buy from yourself.');
        require(isValidBuy(getPrice(badgeID_), msgValue_), 'It is not a valid buy.');        

        _diviSplit(badgeID_, previousOwner, msgSender_, msgValue_);
        _extendBadges(badgeID_, msgSender_, _badgeBasePrice);
        _badgeOwnerChange(badgeID_, msgSender_);
        _increasePrice(badgeID_);

        emit onBadgeBuy(badgeID_, previousOwner, msgSender_, newReferer_, msgValue_, getPrice(badgeID_));
    }

    function _refererUpdate(address user_, address newReferer_) internal{
    	if (refererAllowed(user_, _referer[user_], newReferer_)){
    		_referer[user_] = newReferer_;
    		emit onRefererSet(user_, newReferer_);
    	}
    }

    /*==============================
    =         BADGE SYSTEM         =
    ==============================*/
    function _extendBadges(uint256 badgeID_, address owner_, uint256 price_) internal{
        if (isLastBadgeEle(badgeID_, getChainLength())){
            _createNewBadge(owner_, price_);
        }
    }

    function _badgeOwnerChange(uint256 badgeID_, address newOwner_) internal{
        _setOwner(badgeID_, newOwner_);
    }

    /*==============================
    =          DIVI SPLIT          =
    ==============================*/
    function _diviSplit(uint256 badgeID_, address previousOwner_, address msgSender_, uint256 msgValue_) internal{
    	_shareToDistribution(badgeID_, msgValue_, _shareDistributionRatio);
        _shareToPreviousOwner(previousOwner_, msgValue_, _sharePreviousOwnerRatio);
    	_shareToReferer(_referer[msgSender_], msgValue_, _shareReferalRatio);
    }

    function _shareToDistribution(uint256 badgeID_, uint256 msgValue_, uint256 ratio_) internal{
        uint256 share = calcShare(msgValue_, ratio_) / _luckyWinners;
        uint256 idx;

        for(uint256 i = 0; i < _luckyWinners; i++){
            idx = _badgeFactory.getRandomBadge(badgeID_, i);
            _increaseTotalDivis(idx, share);
            _splitProfit[getOwner(idx)] += share;
        }
    }

    function _shareToPreviousOwner(address previousOwner_, uint256 msgValue_, uint256 ratio_) internal{
    	_flipProfit[previousOwner_] += calcShare(msgValue_, ratio_);
    }

    function _shareToReferer(address referer_, uint256 msgValue_, uint256 ratio_) internal{
    	if (addressNotSet(referer_)){
    		_waypointProfit[_admin] += calcShare(msgValue_, ratio_);
    	} else {
    		_waypointProfit[referer_] += calcShare(msgValue_, ratio_);
    	}
    }

    /*==============================
    =           WITHDRAW           =
    ==============================*/
    //Hex Data: 0x853828b6
    function withdrawAll() public isNotAContract{
        uint256 splitProfit = _splitProfit[msg.sender];
        _splitProfit[msg.sender] = 0;

        uint256 flipProfit = _flipProfit[msg.sender];
        _flipProfit[msg.sender] = 0;

        uint256 waypointProfit = _waypointProfit[msg.sender];
        _waypointProfit[msg.sender] = 0;

        _transferDivis(msg.sender, splitProfit + flipProfit + waypointProfit);
        emit onWithdraw(msg.sender, splitProfit, flipProfit, waypointProfit);
    }

    function _transferDivis(address msgSender_, uint256 payout_) internal{
        assert(address(this).balance >= payout_);
        if(msgSender_ == _admin){
            _teamAmber.distribute.value(payout_)();
        } else {
            msgSender_.transfer(payout_);       
        }
    }

    /*==============================
    =            HELPERS           =
    ==============================*/
    function getStartTime() public view returns (uint256){
        return _startTime;
    }

    function getSplitProfit(address user_) public view returns(uint256){
        return _splitProfit[user_];
    }

    function getFlipProfit(address user_) public view returns(uint256){
        return _flipProfit[user_];
    }

    function getWaypointProfit(address user_) public view returns(uint256){
        return _waypointProfit[user_];
    }

    function getReferer(address user_) public view returns(address){
    	return _referer[user_];
    }

    function getBalanceContract() public view returns(uint256){
    	return address(this).balance;
    }

    function getAllBadges() public view returns(address[], uint256[], uint256[]){
        uint256 chainLength = getChainLength();
        return (getBadges(0, chainLength-1));
    }

    function getBadges(uint256 _from, uint256 _to) public view returns(address[], uint256[], uint256[]){
        require(_from <= _to, 'Index FROM needs to be smaller or same than index TO');

        address[] memory owner = new address[](_to - _from + 1);
        uint256[] memory price = new uint256[](_to - _from + 1);
        uint256[] memory totalDivis = new uint256[](_to - _from + 1);

        for (uint256 i = _from; i <= _to; i++) {
            owner[i - _from] = getOwner(i);
            price[i - _from] = getPrice(i);
            totalDivis[i - _from] = getTotalDivis(i);
        }
        return (owner, price, totalDivis);
    }
}