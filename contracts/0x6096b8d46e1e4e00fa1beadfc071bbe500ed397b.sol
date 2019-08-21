pragma solidity 0.4.24;

contract Fees {
    uint FIWDATM;
    uint FIWNTM;
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    
    
    function FeeDATM(uint FeeInWeiDATM){
    require(msg.sender==Admin);
    if (msg.sender==Admin){
        FIWDATM=FeeInWeiDATM;
    }
    }
    
    
    function GetFeeDATM()returns(uint){
        return FIWDATM;
    }
    
    
    function FeeNTM(uint FeeInWeiNTM){
    require(msg.sender==Admin);
    if (msg.sender==Admin){
        FIWNTM=FeeInWeiNTM;
    }
    }
    
    function GetFeeNTM()returns(uint){
        return FIWNTM;
    }
}