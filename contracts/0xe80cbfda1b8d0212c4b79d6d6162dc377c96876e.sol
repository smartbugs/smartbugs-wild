pragma solidity 0.4.24;

contract VIPs {
    address[] VIP;
    address constant private Admin = 0x92Bf51aB8C48B93a96F8dde8dF07A1504aA393fD;
    
    
    function AddVIP(address NewVIP){
    require(msg.sender==Admin);
    if (msg.sender==Admin){
        VIP.push(NewVIP);
    }
    }
    
    
    function RemoveVIP(address RemoveAddress){
        require (msg.sender==Admin);
        if (msg.sender==Admin){
        uint L=VIP.length;
        for (uint k=0; k<L; k++){
            if (VIP[k]==RemoveAddress){
                delete VIP[k];
            }
        }
        }
    }
         
         
    function IsVIP(address Address)returns(uint Multiplier){
        uint L=VIP.length;
        uint count=0;
        for (uint k=0; k<L; k++){
            if (VIP[k]==Address){
                count=1;
            }
        }
        if (count==0){
            Multiplier=1;
        }else{
            Multiplier=0;
        }
    }
    
    
}