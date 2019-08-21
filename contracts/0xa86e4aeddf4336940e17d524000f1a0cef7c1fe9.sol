contract TestRevert {
    
    function revertMe() {
        require(false);
    }
    
    function throwMe() {
        throw;
    }
}