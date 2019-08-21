pragma solidity >=0.5.8;
/*
MMMMZ$..?ZOMMMMMMMMMMMMMMMMMOZ?~~IZMMMMM
MMMZ~.~~,..ZOMMMMMMMMMMMMMDZ~~~~~~+ZMMMM
MMDZ.~====~.:ZMMMMMMMMMMMO7~======~$8MMM
MMO.,=======.:7~.......+$=~=======~~OMMM
MMO.=====...............~~~~~~=====~ZMMM
MMZ.==~.................~~~~~~~~===~ZMMM
MMO.=~..................:~~~~~~~~~~~ZMMM
MMO......................~~~~~~~~~~~OMMM
MMMZ......................:~~~~~~~~OMMMM
MMO+........................~~~~~~~ZDMMM
MMO............................:~~~~ZMMM
MO~......:ZZ,.............ZZ:.......ZMMM
MO......+ZZZZ,...........ZZZZ+......7DMM
MDZ?7=...ZZZZ............OZZZ.......ZMMM
O+....Z==........ZZ~Z.......====.?ZZZ8MM
,....Z,$....................,==~.ZODMMMM
Z.O.=ZZ.......................7OZOZDMMMM
O.....:ZZZ~,................I$.....OMMMM
8=.....ZZI??ZZZOOOZZZZZOZZZ?O.Z.:~.ZZMMM
MZ.......+7Z7????$OZZI????Z~~ZOZZZZ~~$OM
MMZ...........IZO~~~~~ZZ?.$~~~~~~~~~~~ZM
MMMO7........==Z=~~~~~~O=+I~~IIIZ?II~~IN
MMMMMZ=.....:==Z~~~Z~~+$=+I~~ZZZZZZZ~~IN
MMMMDZ.+Z...====Z+~~~$Z==+I~~~~$Z+OZ~~IN
MMMMO....O=.=====~I$?====+I~~ZZ?+Z~~~~IN
MMMMZ.....Z~=============+I~~$$$Z$$$~~IN
MMMMZ......O.============OI~ZZZZZZZZZ~IN
MMMMZ,.....~7..,=======,.ZI~Z?~OZZ~IZ~IN
MMMZZZ......O...........7+$~~~~~~~~~~~ZM
MMZ,........ZI:.........$~$=~~~~~~~~~7OM
MMOZ,Z.,?$Z8MMMMND888DNMMNZZZZZZZZZOOMMM
MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMM

This is the generic Manek.io wager contract. With a standard end timer. Betting
can only be stared by the admin. Who sets an endtime and number of picks.
Bettingcan only be ended once the timer is over. Players must withdraw their
funds once betting is over. This can be done on Manek.io or via the abi which
will always be publicly available. There is a single jackpot winner which is
based off the hash of the block 200 before betting ends and will be valid for 6000
blocks (about 1 day). The jackpot winner must claim their prize or it will
go to the next winner.
*/

contract manekio {

  //EVENTS
  event playerBet (
    address indexed playerAddress,
    uint256 pick,
    uint256 eth
    );
    //MODIFIERS
    modifier onlyAdministrator(){
      address _playerAddress = msg.sender;
      require(_playerAddress == admin);
      _;
    }
    //STRUCTURES
    struct playerJBook {
      uint256 sShare;
      uint256 eShare;
    }
    struct playerBook {
      uint256 share;
      bool paid;
    }
    struct pickBook {
      uint256 share; //number of shares in each
      uint256 nBet; //number of player bets (ID)
    }

    //DATASETS
    mapping(address => mapping(uint256 => playerJBook)) internal plyrJBk; //[addr][bet#] = playerJBook addr => bet num => plyrJBk
    mapping(address => mapping(uint256 => playerBook)) internal pAddrxBk; //pAddrxBk[addr][pick ID] = shares   address => pick => shares
    mapping(uint256 => pickBook) internal pBk; //total number of N bets & shares
    uint256 internal tShare = 0;
    uint256 internal pot = 0;
    uint256 internal comm = 0;
    uint256 internal commrate = 25;
    uint256 internal commPaid = 0;
    uint256 internal jackpot = 0;
    uint256 internal jpotrate = 25;
    uint256 internal jpotinterval = 6000;
    bool internal ended = false;
    address payable internal admin = 0xe7Cef4D90BdA19A6e2A20F12A1A6C394230d2924;
    //set by admin when starting betting
    uint256 internal endtime = 0;
    bool internal started = false;
    uint256 internal pcknum; //number of picks 0 to x
    //end of game values
    uint256 internal wPck = 999; //winning pick is initialized as 999
    uint256 internal shareval = 0;
    uint256 internal endblock = 0; //block number that betting is ended on
    uint256 internal jendblock = 0;
    uint256 internal endblockhash = 0;
    address payable internal jPotWinner;
    bool internal jPotclaimed = false;

    //FALLBACK FUNCTION
    //all eth sent to contract without proper message will dump into pot, comm, and jackpot
    function() external payable {
      require(msg.value > 0);
      playerPick(pcknum + 1);
    }
    //PUBLIC FUNCTIONS
    //this is where players place their bets
    function playerPick(uint256 _pck) public payable {
      address payable _pAddr = msg.sender;
      uint256 _eth = msg.value;
      require(_eth > 0 && _pck >= 0 && _pck < 999);
      //minimum bet entry is .01 eth & player chose a valid pick
      if (_eth >= 1e16 && !checkTime() && !ended && _pck <= pcknum && started) {
        //get my fucking money
        uint256 _commEth = _eth / commrate;
        uint256 _jpEth = _eth / jpotrate;
        comm += _commEth;
        jackpot += _jpEth;
        uint256 _potEth = _eth - _commEth - _jpEth;
        //inc pot
        pot += _potEth;
        //calc shares (each share is .00001 eth)
        uint256 _share = _potEth / 1e13;
        //update books
        pBk[_pck].nBet += 1;
        pBk[_pck].share += _share;
        //update plyrJBk
        for(uint256 i = 0; true; i++) {
          if(plyrJBk[_pAddr][i].eShare == 0){
            plyrJBk[_pAddr][i].sShare = tShare;
            plyrJBk[_pAddr][i].eShare = tShare + _share - 1;
            break;
          }
        }
        //update total shares
        tShare += _share;
        //update pAddrxBk
        pAddrxBk[_pAddr][_pck].share += _share;
        //fire event
        emit playerBet(_pAddr, _pck, _potEth);
      }
      //you go here if you didn't send enough eth, didn't choose a valid pick, or the betting hasnt started yet
      else if (!started || !ended) {
        uint256 _commEth = _eth / commrate;
        uint256 _jpEth = _eth / jpotrate;
        comm += _commEth;
        jackpot += _jpEth;
        uint256 _potEth = _eth - _commEth - _jpEth;
        pot += _potEth;
      }
      //if you really goof. send too little eth or betting is over it goes to admin
      else {
        comm += _eth;
      }
    }

    function claimJackpot() public {
      address payable _pAddr = msg.sender;
      uint256 _jackpot = jackpot;
      require(ended == true && checkJPotWinner(_pAddr) && !jPotclaimed);
      _pAddr.transfer(_jackpot);
      jPotclaimed = true;
      jPotWinner = _pAddr;
    }

    function payMeBitch(uint256 _pck) public {
      address payable _pAddr = msg.sender;
      require(_pck >= 0 && _pck < 998);
      require(ended == true && pAddrxBk[_pAddr][_pck].paid == false && pAddrxBk[_pAddr][_pck].share > 0 && wPck == _pck);
      _pAddr.transfer(pAddrxBk[_pAddr][_pck].share * shareval);
      pAddrxBk[_pAddr][_pck].paid = true;
    }

    //VIEW FUNCTIONS
    function checkJPotWinner(address payable _pAddr) public view returns(bool){
      uint256 _endblockhash = endblockhash;
      uint256 _tShare = tShare;
      uint256 _nend = nextJPot();
      uint256 _wnum;
      require(plyrJBk[_pAddr][0].eShare != 0);
      if (jPotclaimed == true) {
        return(false);
      }
      _endblockhash = uint256(keccak256(abi.encodePacked(_endblockhash + _nend)));
      _wnum = (_endblockhash % _tShare);
      for(uint256 i = 0; true; i++) {
        if(plyrJBk[_pAddr][i].eShare == 0){
          break;
        }
        else {
          if (plyrJBk[_pAddr][i].sShare <= _wnum && plyrJBk[_pAddr][i].eShare >= _wnum ){
            return(true);
          }
        }
      }
      return(false);
    }

    function nextJPot() public view returns(uint256) {
      uint256 _cblock = block.number;
      uint256 _jendblock = jendblock;
      uint256 _tmp = (_cblock - _jendblock);
      uint256 _nend = _jendblock + jpotinterval;
      uint256 _c = 0;
      if (jPotclaimed == true) {
        return(0);
      }
      while(_tmp > ((_c + 1) * jpotinterval)) {
        _c += 1;
      }
      _nend += jpotinterval * _c;
      return(_nend);
    }

    //to view postitions on bet for specific address
    function addressPicks(address _pAddr, uint256 _pck) public view returns(uint256) {
      return(pAddrxBk[_pAddr][_pck].share);
    }
    //checks if an address has been paid
    function addressPaid(address _pAddr, uint256 _pck) public view returns(bool) {
      return(pAddrxBk[_pAddr][_pck].paid);
    }
    //get shares in pot for specified pick
    function pickPot(uint256 _pck) public view returns(uint256) {
      return(pBk[_pck].share);
    }
    //get number of bets for speficied pick
    function pickPlyr(uint256 _pck) public view returns(uint256) {
      return(pBk[_pck].nBet);
    }
    //gets the total pot
    function getPot() public view returns(uint256) {
      return(pot);
    }
    //gets the total jackpot
    function getJPot() public view returns(uint256) {
      return(jackpot);
    }
    //gets winning pick set by admin. Will return 999 prior to
    function getWPck() public view returns(uint256) {
      return(wPck);
    }
    function viewJPotclaimed() public view returns(bool) {
      return(jPotclaimed);
    }
    function viewJPotWinner() public view returns(address) {
      return(jPotWinner);
    }
    //grab the time betting is over
    function getEndtime() public view returns(uint256) {
      return(endtime);
    }
    //how much do they owe me?
    function getComm() public view returns(uint256) {
      return(comm);
    }
    function hasStarted() public view returns(bool) {
      return(started);
    }
    function isOver() public view returns(bool) {
      return(ended);
    }
    function pickRatio(uint256 _pck) public view returns(uint256) {
      return(pot / pBk[_pck].share);
    }
    function checkTime() public view returns(bool) {
      uint256 _now = now;
      if (_now < endtime) {
        return(false);
      }
      else {
        return(true);
      }
    }

    function testView(address _pAddr, uint256 _n) public view returns(uint256 sShare, uint256 eShare) {
      return(plyrJBk[_pAddr][_n].sShare, plyrJBk[_pAddr][_n].eShare);
    }

    //ADMIN ONLY FUNCTIONS
    function startYourEngines(uint256 _pcknum, uint256 _endtime) onlyAdministrator() public returns(bool){
      require(!started);
      pcknum = _pcknum;
      endtime = _endtime;
      started = true;
      return(true);
    }
    function adminWinner(uint256 _wPck) onlyAdministrator() public {
      require(_wPck <= pcknum && checkTime() && ended == false);
      ended = true;
      wPck = _wPck;
      shareval = pot / pBk[_wPck].share;
      endblock = block.number;
      uint256 _jendblock = block.number;
      jendblock = _jendblock;
      endblockhash = uint256(keccak256(abi.encodePacked(blockhash(_jendblock - 200))));
    }
    function fuckYouPayMe() onlyAdministrator() public {
      uint256 _commDue = comm - commPaid;
      if (_commDue > 0) {
        admin.transfer(_commDue);
        commPaid += _commDue;
      }
    }
  }