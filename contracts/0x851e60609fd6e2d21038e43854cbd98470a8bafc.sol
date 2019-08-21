pragma solidity ^0.4.18;


interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
}

interface TokenConfigInterface {
    function admin() public returns(address);
    function claimAdmin() public;
    function transferAdminQuickly(address newAdmin) public;

    // network
    function listPairForReserve(address reserve, address src, address dest, bool add) public;
}


contract Lister {
    TokenConfigInterface public network = TokenConfigInterface(0xD2D21FdeF0D054D2864ce328cc56D1238d6b239e);
    address newReserve = 0xE1213e46EfCb8785B47AE0620a51F490F747F1Da;
    address public ETH = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    ERC20 public ENG = ERC20(0xf0ee6b27b759c9893ce4f094b49ad28fd15a23e4);
    ERC20 public SALT = ERC20(0x4156D3342D5c385a87D264F90653733592000581);
    ERC20 public APPC = ERC20(0x1a7a8bd9106f2b8d977e08582dc7d24c723ab0db);
    ERC20 public RDN = ERC20(0x255aa6df07540cb5d3d297f0d0d4d84cb52bc8e6);
    ERC20 public OMG = ERC20(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
    ERC20 public KNC = ERC20(0xdd974D5C2e2928deA5F71b9825b8b646686BD200);
    ERC20 public EOS = ERC20(0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0);
    ERC20 public SNT = ERC20(0x744d70fdbe2ba4cf95131626614a1763df805b9e);
    ERC20 public ELF = ERC20(0xbf2179859fc6d5bee9bf9158632dc51678a4100e);
    ERC20 public POWR = ERC20(0x595832f8fc6bf59c85c527fec3740a1b7a361269);
    ERC20 public MANA = ERC20(0x0f5d2fb29fb7d3cfee444a200298f468908cc942);
    ERC20 public BAT = ERC20(0x0d8775f648430679a709e98d2b0cb6250d2887ef);
    ERC20 public REQ = ERC20(0x8f8221afbb33998d8584a2b05749ba73c37a938a);
    ERC20 public GTO = ERC20(0xc5bbae50781be1669306b9e001eff57a2957b09d);

    address[] public newTokens = [
        OMG,
        KNC,
        BAT,
        EOS];

    function listPairs() public {
        address orgAdmin = network.admin();
        network.claimAdmin();

        for( uint i = 0 ; i < newTokens.length ; i++ ) {
            network.listPairForReserve(newReserve,ETH,newTokens[i],true);
            network.listPairForReserve(newReserve,newTokens[i],ETH,true);
        }

        network.transferAdminQuickly(orgAdmin);
        require(orgAdmin == network.admin());
    }
}