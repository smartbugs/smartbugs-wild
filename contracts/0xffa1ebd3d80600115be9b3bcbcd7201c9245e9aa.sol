pragma solidity ^0.4.16;

/** @title owned. */
contract owned  {
  address owner;
  function owned() {
    owner = msg.sender;
  }
  function changeOwner(address newOwner) onlyOwner {
    owner = newOwner;
  }
  modifier onlyOwner() {
    if (msg.sender==owner) 
    _;
  }
}

/** @title mortal. */
contract mortal is owned() {
  function kill() onlyOwner {
    if (msg.sender == owner) selfdestruct(owner);
  }
}
 

// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD


Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

/** @title OraclizeI. */
contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasource) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
    function randomDS_getSessionPubKeyHash() returns(bytes32);
}
/** @title OraclizeAddrResolverI. */
contract OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}
/** @title usingOraclize. */
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0)) oraclize_setNetwork();
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        oraclize.useCoupon(code);
        _;
    }

    function oraclize_setNetwork() internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

   function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
       return oraclize.getPrice(datasource);
   }

   function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
       return oraclize.getPrice(datasource, gaslimit);
   }
   
	function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal { 
        return oraclize.setCustomGasPrice(gasPrice); 
	}     


    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }


    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }
        
    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }
    
    function oraclize_getNetworkName() internal returns (string) {
        return oraclize_network_name;
    }
        
}
// </ORACLIZE_API>

/** @title DSParser. */
contract DSParser{
    uint8 constant WAD_Dec=18;
    uint128 constant WAD = 10 ** 18;
    function parseInt128(string _a)  constant  returns (uint128) { 
		return cast(parseInt( _a, WAD_Dec));
    }
    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }
    function parseInt(string _a, uint _b)  
			constant 
			returns (uint) { 
		/** @dev Turns a string into a number with _b places
          * @param _a String to be processed, e.g. "0.002"
          * @param _b number of decimal places
          * @return uint of the decimal representation
        */
			bytes memory bresult = bytes(_a);
            uint mint = 0;
            bool decimals = false;
            for (uint i=0; i<bresult.length; i++){
                if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                    if (decimals){
                       if (_b == 0){
                        //Round up if next value is 5 or greater
                        if(uint(bresult[i])- 48>4){
                            mint = mint+1;
                        }    
                        break;
                       }
                       else _b--;
                    }
                    mint *= 10;
                    mint += uint(bresult[i]) - 48;
                } else if (bresult[i] == 46||bresult[i] == 44) { // cope with euro decimals using commas
                    decimals = true;
                }
            }
            if (_b > 0) mint *= 10**_b;
           return mint;
    }
	
}

/** @title I_minter. */
contract I_minter { 
    event EventCreateStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemStatic(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventCreateRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventRedeemRisk(address indexed _from, uint128 _value, uint _transactionID, uint _Price); 
    event EventBankrupt();
	
    function Leverage() constant returns (uint128)  {}
    function RiskPrice(uint128 _currentPrice,uint128 _StaticTotal,uint128 _RiskTotal, uint128 _ETHTotal) constant returns (uint128 price)  {}
    function RiskPrice(uint128 _currentPrice) constant returns (uint128 price)  {}     
    function PriceReturn(uint _TransID,uint128 _Price) {}
    function NewStatic() external payable returns (uint _TransID)  {}
    function NewStaticAdr(address _Risk) external payable returns (uint _TransID)  {}
    function NewRisk() external payable returns (uint _TransID)  {}
    function NewRiskAdr(address _Risk) external payable returns (uint _TransID)  {}
    function RetRisk(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function RetStatic(uint128 _Quantity) external payable returns (uint _TransID)  {}
    function Strike() constant returns (uint128)  {}
}

/** @title I_Pricer. */
contract I_Pricer {
    uint128 public lastPrice;
    uint public constant DELAY = 1 days;// this needs to be a day on the mainnet
    I_minter public mint;
    string public sURL;//="json(https://api.kraken.com/0/public/Ticker?pair=ETHEUR).result.XETHZEUR.p.1";
    mapping (bytes32 => uint) RevTransaction;
    function setMinter(address _newAddress) {}
    function __callback(bytes32 myid, string result) {}
    function queryCost() constant returns (uint128 _value) {}
    function QuickPrice() payable {}
    function requestPrice(uint _actionID) payable returns (uint _TrasID){}
    function collectFee() returns(bool) {}
    function () {
        //if ether is sent to this address, send it back.
        revert();
    }
}

/** @title Pricer. */
contract Pricer is I_Pricer, 
	mortal, 
	usingOraclize, 
	DSParser {
	// <pair_name> = pair name
    // a = ask array(<price>, <whole lot volume>, <lot volume>),
    // b = bid array(<price>, <whole lot volume>, <lot volume>),
    // c = last trade closed array(<price>, <lot volume>),
    // v = volume array(<today>, <last 24 hours>),
    // p = volume weighted average price array(<today>, <last 24 hours>),
    // t = number of trades array(<today>, <last 24 hours>),
    // l = low array(<today>, <last 24 hours>),
    // h = high array(<today>, <last 24 hours>),
    // o = today's opening price
	
    function Pricer(string _URL) {
		/** @dev Constructor, allows the pricer URL to be set
          * @param _URL of the web query
          * @return nothing
        */
		oraclize_setNetwork();
		sURL=_URL;
    }

	function () {
        //if ether is sent to this address, send it back.
        revert();
    }

    function setMinter(address _newAddress) 
		onlyOwner {
		/** @dev Allows the address of the minter to be set
          * @param _newAddress Address of the minter
          * @return nothing
        */
        mint=I_minter(_newAddress);
    }

    function queryCost() 
		constant 
		returns (uint128 _value) {
		/** @dev ETH cost of calling the oraclize 
          * @param _newAddress Address of the minter
          * @return nothing
        */
		return cast(oraclize_getPrice("URL")); 
    }

    function QuickPrice() 
		payable {
		/** @dev Gets the latest price.  Be careful, All eth sent is kept by the contract.
          * @return nothing, but the new price will be stored in variable lastPrice
        */
        bytes32 TrasID =oraclize_query(1, "URL", sURL);
        RevTransaction[TrasID]=0;
    }
	
    function __callback(bytes32 myid, string result) {
		/** @dev ORACLIZE standard callback function-
          * @param myid Pricer transaction ID
		  * @param result Address of the minter
          * @return calls minter.PriceReturn() with the price
        */
        if (msg.sender != oraclize_cbAddress()) revert(); // Only oraclize
        bytes memory tempEmptyStringTest = bytes(result); // Array uses memory
        if (tempEmptyStringTest.length == 0) {
             lastPrice =  0;  //0 is taken to be an error by the minter contract
        } else {
            lastPrice =  parseInt128(result);  //convert the string into a 18 decimal place number
        }
        if(RevTransaction[myid]>0){  //if it's not from QuickPrice
            mint.PriceReturn(RevTransaction[myid],lastPrice);  //Call the minter
        }
        delete RevTransaction[myid]; // free up the memory
    }

	function setGas(uint gasPrice) 
		onlyOwner 
		returns(bool) {
		/** @dev Allows oraclize gas cost to be changed
          * @return True if sucessful
        */
		oraclize_setCustomGasPrice(gasPrice);
		return true;
    }
	
	function collectFee() 
		onlyOwner 
		returns(bool) {
		/** @dev Allows ETH to be removed from this contract (only this one, not the minter)
          * @return True if sucessful
        */
        return owner.send(this.balance);
		return true;
    }
	
	modifier onlyminter() {
      if (msg.sender==address(mint)) 
      _;
    }

    function requestPrice(uint _actionID) 
		payable 
		onlyminter 
		returns (uint _TrasID){
		/** @dev Minter only functuon.  Needs to be called with enough eth
          * @param _actionID Pricer transaction ID
          * @return calls minter.PriceReturn() with the price
        */
        // 
        bytes32 TrasID;
        TrasID=oraclize_query(DELAY, "URL", sURL);
        RevTransaction[TrasID]=_actionID;
		return _TrasID;
    }
}