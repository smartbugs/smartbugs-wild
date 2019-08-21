pragma solidity ^0.4.13;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract VeRegistry is Ownable {

    //--- Definitions

    struct Asset {
        address addr;
        string meta;
    }

    //--- Storage

    mapping (string => Asset) assets;

    //--- Events

    event AssetCreated(
        address indexed addr
    );

    event AssetRegistered(
        address indexed addr,
        string symbol,
        string name,
        string description,
        uint256 decimals
    );

    event MetaUpdated(string symbol, string meta);

    //--- Public mutable functions

    function register(
        address addr,
        string symbol,
        string name,
        string description,
        uint256 decimals,
        string meta
    )
        public
        onlyOwner
    {
        assets[symbol].addr = addr;

        AssetRegistered(
            addr,
            symbol,
            name,
            description,
            decimals
        );

        updateMeta(symbol, meta);
    }

    function updateMeta(string symbol, string meta) public onlyOwner {
        assets[symbol].meta = meta;

        MetaUpdated(symbol, meta);
    }

    function getAsset(string symbol) public constant returns (address addr, string meta) {
        Asset storage asset = assets[symbol];
        addr = asset.addr;
        meta = asset.meta;
    }
}

contract VeTokenRegistry is VeRegistry {
}