pragma solidity >=0.5.0;

// Letétszerződés. A letétbe helyezett ETH összeget csak a kedvezményezettnek lehet kifizetni.
contract Escrow {

    // Tulajdonos
    address owner;
    // Kedvezményezett
    address payable constant beneficiary = 0x168cF76582Cd7017058771Df6F623882E04FCf0F;

    // Szerződés létrehozása
    constructor() public {
        owner = msg.sender; // Tulajdonos beállítása
    }
    
    // Bizonyos dolgokat csak a tulajdonos kezdeményezhet.
    modifier ownerOnly {
        assert(msg.sender == owner);
        _;
    }
    
    // Csak a tulajdonos utalhat ki étert a szerződésből
    function transfer(uint256 amount) ownerOnly public {
        beneficiary.transfer(amount); // Csak a kezdvezményezettnek
    }
    
    // Csak a tulajdonos semmisítheti meg a szerződést
    function terminate() ownerOnly public {
        selfdestruct(beneficiary); // Minden befizetést megkap a kedvezményezett
    }
    
    // Bárki bármennyit befizethet a szerződésbe.
    function () payable external {}
}