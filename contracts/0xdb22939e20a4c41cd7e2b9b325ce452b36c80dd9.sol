contract AlwaysFail {

    function AlwaysFail() {
    }
    
    function() {
        enter();
    }
    
    function enter() {
        throw;
    }
}