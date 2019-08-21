contract calc { 
    event ret(uint r);
    function multiply(uint a, uint b) returns(uint d) { 
        uint res = a * b;
        ret (res);
        return res; 
    } 
}