contract DFNTokens {
  // An identifying string, set by the constructor
  string public name;

  // mapping from address to balance
  mapping(address => uint) public balance;

  // set of addresses that are authorized to transfer
  mapping(address => bool) public authorizedToTransfer;

  // owner (authorized to do anything)
  address public owner;

  // list of notarizations
  bytes32[] public notarizationList;

  // frozen flag
  bool public frozen = false;

  // freeze requested at height
  uint public freezeHeight = 0;

  // For convenience of external contracts only (not used here)
  // list of addresses with balances
  address[] public addrList;
  // test if address has ever had a non-zero balance
  mapping(address => bool) public seen;
  // number of addresses that ever had a non-zero balance
  uint public nAddresses = 0;

  // Constructor
  function DFNTokens() public {
      name = "test";

      // set owner
      owner = msg.sender;

      // genesis balance
      balance[0x0] = 469213710;

      // first three accounts
      TransferDFN(0x0, 0x1, 44575302);
      TransferDFN(0x0, 0x2, 115986694);
      TransferDFN(0x0, 0x3, 308651714);
  }

  // Modifier
  modifier onlyowner {
      require(msg.sender == owner);
      _;
  }

  modifier onlyauthorized {
      require(msg.sender == owner || authorizedToTransfer[msg.sender] == true);
      _;
  }

  modifier alive {
      require(!frozen);
      _;
  }

  // Transfer DFN
  function TransferDFN(address from, address to, uint amt) onlyauthorized alive public {
    require(0 < amt && amt <= balance[from]);

    // transfer balance
    balance[to] += amt;
    balance[from] -= amt;

    // maintain records for convenience of external contracts
    if (!seen[to]) {
        addrList.push(to);
        seen[to] = true;
        nAddresses += 1;
    }
  }

// Authorize external contract to transfer 
function AuthorizeToTransfer(address newAddr) onlyowner alive public {
    authorizedToTransfer[newAddr] = true;
}

// Unauthorize external contract to transfer 
function UnauthorizeToTransfer(address addr) onlyowner alive public {
    authorizedToTransfer[addr] = false;
}

// Record notarization string (hash)
function Notarize(bytes32 hash) onlyowner alive public {
    notarizationList.push(hash);
}

// Freeze contract
function Freeze() onlyowner alive public {
    // Freeze if this is the second call within 20 blocks
    if (freezeHeight > 0 && block.number < freezeHeight + 20) { frozen = true; }

    // Otherwise set block number of latest freeze request
    freezeHeight = block.number;
}

// Empty out funds that accidentally end up on this contract
function emptyTo(address addr) onlyowner public {
    addr.transfer(address(this).balance);
}

}