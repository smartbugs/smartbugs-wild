contract BirthdayGift {
    
    address public owner = 0x770F34Fdd214b36f2494ed57bb827B4c319E5BaA;
    address public recipient = 0x6A93e96E999326eB02f759EaF5d4e71d0a8653e8;
    
    // 5 Apr 2023 00:00:00 PST | 5 Apr 2023 08:00:00 GMT
    uint256 public unlockTime = 1680681600; 
    
    function BirthdayGift () public {
    }
    
    function DaysTillUnlock () public constant returns (uint256 _days) {
        if (now > unlockTime) {
            return 0;
        }
        return (unlockTime - now) / 60 / 60 / 24;
    }
    
    function SetOwner (address _newOwner) public {
        require (msg.sender == owner);
        owner = _newOwner; 
    }  
    
    function SetUnlockTime (uint256 _time) public {
        require (msg.sender == owner);
        unlockTime = _time;
    }
    
    function SetRecipient (address _recipient) public {
        require (msg.sender == owner);
        recipient = _recipient;
    }
    
    function OpenGift () public {
        require (msg.sender == recipient);
        require (now >= unlockTime);
        selfdestruct (recipient);
    }
}