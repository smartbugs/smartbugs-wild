contract squareRootPonzi {
    
    struct MasterCalculators {
        
        address ethereumAddress;
        string name;
        uint squareRoot;
        
    }
    MasterCalculators[] public masterCalculator;
    
    uint public calculatedTo = 0;
    
    
    function() {
        
        if (msg.value == 1 finney) {
            
            if (this.balance > 2 finney) {
            
                uint index = masterCalculator.length + 1;
                masterCalculator[index].ethereumAddress = msg.sender;
                masterCalculator[index].name = "masterly calculated: ";
                calculatedTo += 100 ether; // which is a shorter way to the number 100,000,000,000,000,000,000 or 1e+20
                masterCalculator[index].squareRoot = CalculateSqrt(calculatedTo);
                
                if (masterCalculator.length > 3) {
                
                    uint to = masterCalculator.length - 3;
                    masterCalculator[to].ethereumAddress.send(2 finney);
                    
                }
                
            }
            
        }
        
    }
    
    
    function CalculateSqrt(uint x) internal returns (uint y) {
        
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        
    }
    
    
    function sqrt(uint x) returns (uint) {
        
        if (x > masterCalculator.length + 1) return 0;
        else return masterCalculator[x].squareRoot;
        
    }
    
    
}