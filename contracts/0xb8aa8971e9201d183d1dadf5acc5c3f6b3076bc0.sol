pragma solidity ^0.4.18;

contract HTLC {
////////////////
//Global VARS//////////////////////////////////////////////////////////////////////////
//////////////
    string public version;
    bytes32 public digest;
    address public dest;
    uint public timeOut;
    address issuer; 
/////////////
//MODIFIERS////////////////////////////////////////////////////////////////////
////////////
    modifier onlyIssuer {assert(msg.sender == issuer); _; }
//////////////
//Operations////////////////////////////////////////////////////////////////////////
//////////////
/*constructor */
    //require all fields to create the contract
    function HTLC(bytes32 _hash, address _dest, uint _timeLimit) public {
        assert(digest != 0 || _dest != 0 || _timeLimit != 0);
        digest = _hash;
        dest = _dest;
        timeOut = now + (_timeLimit * 1 hours);
        issuer = msg.sender; 
    }
 /* public */   
    //a string is subitted that is hash tested to the digest; If true the funds are sent to the dest address and destroys the contract    
    function claim(string _hash) public returns(bool result) {
       require(digest == sha256(_hash));
       selfdestruct(dest);
       return true;
       }
       //allow payments
    function () public payable {}

/* only issuer */
    //if the time expires; the issuer can reclaim funds and destroy the contract
    function refund() onlyIssuer public returns(bool result) {
        require(now >= timeOut);
        selfdestruct(issuer);
        return true;
    }
}


contract xcat {
    string public version = "v1";
    
    struct txLog{
        address issuer;
        address dest;
        string chain1;
        string chain2;
        uint amount1;
        uint amount2;
        uint timeout;
        address crtAddr;
        bytes32 hashedSecret; 
    }
    
    event newTrade(string onChain, string toChain, uint amount1, uint amount2);
    
    mapping(bytes32 => txLog) public ledger;
    
    function testHash(string yourSecretPhrase) public returns (bytes32 SecretHash) {return(sha256(yourSecretPhrase));}
    
    function newXcat(bytes32 _SecretHash, address _ReleaseFundsTo, string _chain1, uint _amount1, string _chain2, uint _amount2, uint _MaxTimeLimit) public returns (address newContract) {
        txLog storage tl = ledger[sha256(msg.sender,_ReleaseFundsTo,_SecretHash)];
    //make the contract
        HTLC h = new HTLC(_SecretHash, _ReleaseFundsTo, _MaxTimeLimit);
    
    //store info
        tl.issuer = msg.sender;
        tl.dest = _ReleaseFundsTo;
        tl.chain1 = _chain1;
        tl.chain2 = _chain2;
        tl.amount1 = _amount1;
        tl.amount2 = _amount2;
        tl.timeout = _MaxTimeLimit;
        tl.hashedSecret = _SecretHash; 
        tl.crtAddr = h;
        newTrade (tl.chain1, tl.chain2, tl.amount1, tl.amount2);
        return h;
    }

    //avoid taking funds
    function() public { assert(0>1);} 

    // allow actors to view their tx
    function viewXCAT(address _issuer, address _ReleaseFundsTo, bytes32 _SecretHash) public returns (address issuer, address receiver, uint amount1, string onChain, uint amount2, string toChain, uint atTime, address ContractAddress){
        txLog storage tl = ledger[sha256(_issuer,_ReleaseFundsTo,_SecretHash)];
        return (tl.issuer, tl.dest, tl.amount1, tl.chain1, tl.amount2, tl.chain2,tl.timeout, tl.crtAddr);
    }
}

/////////////////////////////////////////////////////////////////////////////
  // 88888b   d888b  88b  88 8 888888         _.-----._
  // 88   88 88   88 888b 88 P   88   \)|)_ ,'         `. _))|)
  // 88   88 88   88 88`8b88     88    );-'/             \`-:(
  // 88   88 88   88 88 `888     88   //  :               :  \\   .
  // 88888P   T888P  88  `88     88  //_,'; ,.         ,. |___\\
  //    .           __,...,--.       `---':(  `-.___.-'  );----'
  //              ,' :    |   \            \`. `'-'-'' ,'/
  //             :   |    ;   ::            `.`-.,-.-.','
  //     |    ,-.|   :  _//`. ;|              ``---\` :
  //   -(o)- (   \ .- \  `._// |    *               `.'       *
  //     |   |\   :   : _ |.-  :              .        .
  //     .   :\: -:  _|\_||  .-(    _..----..
  //         :_:  _\\_`.--'  _  \,-'      __ \
  //         .` \\_,)--'/ .'    (      ..'--`'          ,-.
  //         |.- `-'.-               ,'                (///)
  //         :  ,'     .            ;             *     `-'
  //   *     :         :           /
  //          \      ,'         _,'   88888b   888    88b  88 88  d888b  88
  //           `._       `-  ,-'      88   88 88 88   888b 88 88 88   `  88
  //            : `--..     :        *88888P 88   88  88`8b88 88 88      88
  //        .   |           |	        88    d8888888b 88 `888 88 88   ,  `"
  //            |           | 	      88    88     8b 88  `88 88  T888P  88
  /////////////////////////////////////////////////////////////////////////