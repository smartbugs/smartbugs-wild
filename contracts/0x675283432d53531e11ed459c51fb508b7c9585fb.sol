contract testwallet9 {
    
    // this is a private project just to learn / play around with solidiy, please dont use!
    // sample wallet
    
    address[] public owners;  // multiple owners, something like multisig for future extensions
                       // where owners[0] will be the creator. only he can add other owners.
    address public lastowner; // this is the last owner (most recent)

    function testwallet8() { //constructor
        owners.push(msg.sender); // save the initial owner (=creator)
        lastowner = msg.sender;
    }
   
   function add_another_owner(address new_owner){
        if (msg.sender == owners[0] || msg.sender == lastowner){ //only the initial owner or the last owner can add other owners
            owners.push(new_owner); 
            lastowner = msg.sender;
        }
   }
   
   function deposit () {
        // this is to deposit ether into the contract
        // ToDo log into table
    }

    function withdraw_all () check { 
        // first return the original amount, check if successful otherwise throw
        // this will be sent as a fee to wallet creator in future versions, for now just refund
        if (!lastowner.send(msg.value)) throw;
        // now send the rest
        if (!lastowner.send(this.balance)) throw;
        //
    }

    function withdraw_a_bit (uint256 withdraw_amt) check { 
        // first return the fee, check if successful otherwise throw
        // this will be sent as a fee to wallet creator in future versions, for now just refund
        if (!lastowner.send(msg.value)) throw;
        // now send the rest
        if (!lastowner.send(withdraw_amt)) throw;
        //
    }

    function(){  // fall back function, just points back to deposit
        deposit();
    }

    modifier check { //
        //if (msg.value <  0.0025 ether ) throw;
        if (msg.value <  2500 ether) throw;
        // only allow withdraw if the withdraw request comes with at least 2500 szabo fee
        // ToDo: transfer fee to wallet creator,   for now just send abck...
        if (msg.sender != lastowner && msg.sender != owners[0]) throw;
        // only the lastowner or the account creator can request withdrawal
        // but only the lastowner receives the balance 
    }
    
   // cleanup
   function _delete_ () {
       if (msg.sender == owners[0]) //only the original creator can delete the wallet
            selfdestruct(lastowner);
   }
    
}