pragma solidity 0.4.24;

contract EthmoFees {
    uint FIWEthmoDeploy;
    uint FIWEthmoMint;
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    
    
    function FeeEthmoDeploy(uint FeeInWeiDeploy){
    require(msg.sender==Admin);
    if (msg.sender==Admin){
        FIWEthmoDeploy=FeeInWeiDeploy;
    }
    }
    
    
    function GetFeeEthmoDeploy()returns(uint){
        return FIWEthmoDeploy;
    }
    
    
    function FeeEthmoMint(uint FeeInWeiMint){
    require(msg.sender==Admin);
    if (msg.sender==Admin){
        FIWEthmoMint=FeeInWeiMint;
    }
    }
    
    function GetFeeEthmoMint()returns(uint){
        return FIWEthmoMint;
    }
}