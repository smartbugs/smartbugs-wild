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

    // reserve
    function approveWithdrawAddress(address token, address addr, bool approve) public;
    function withdrawToken(address token, uint amount, address sendTo) external;
    function withdrawEther(uint amount, address sendTo) external;

    // conversion rate
    function addToken(address token) public;
    function enableTokenTrade(address token) public;
    function setTokenControlInfo(
        address token,
        uint minimalRecordResolution,
        uint maxPerBlockImbalance,
        uint maxTotalImbalance
    ) public;
    function setQtyStepFunction(
        ERC20 token,
        int[] xBuy,
        int[] yBuy,
        int[] xSell,
        int[] ySell
    ) public;

    function setImbalanceStepFunction(
        ERC20 token,
        int[] xBuy,
        int[] yBuy,
        int[] xSell,
        int[] ySell
    ) public;
}


contract TokenAdder {
    TokenConfigInterface public network;
    TokenConfigInterface public reserve;
    TokenConfigInterface public conversionRate;
    address public multisigAddress;
    address public withdrawAddress;
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
        ENG,
        SALT,
        APPC,
        RDN];
    int[] zeroArray;

    function TokenAdder(TokenConfigInterface _network,
                        TokenConfigInterface _reserve,
                        TokenConfigInterface _conversionRate,
                        address              _withdrawAddress,
                        address              _multisigAddress) public {

        network = _network;
        reserve = _reserve;
        conversionRate = _conversionRate;
        withdrawAddress = _withdrawAddress;
        multisigAddress = _multisigAddress;
    }

    function listPairs() public {
        address orgAdmin = network.admin();
        network.claimAdmin();

        for( uint i = 0 ; i < newTokens.length ; i++ ) {
            network.listPairForReserve(reserve,ETH,newTokens[i],true);
            network.listPairForReserve(reserve,newTokens[i],ETH,true);
        }

        network.transferAdminQuickly(orgAdmin);
        require(orgAdmin == network.admin());
    }

    function approveWithdrawAddress() public {
        address orgAdmin = reserve.admin();
        reserve.claimAdmin();

        for( uint i = 0 ; i < newTokens.length ; i++ ) {
            reserve.approveWithdrawAddress(newTokens[i], withdrawAddress, true);
        }


        reserve.transferAdminQuickly(orgAdmin);
        require(orgAdmin == reserve.admin());
    }

    function addTokens() public {
        address orgAdmin = conversionRate.admin();
        conversionRate.claimAdmin();

        conversionRate.setTokenControlInfo(
            RDN,
            1000000000000000,
            2191833834271476809728,
            3001716436034787475456 );

        conversionRate.setTokenControlInfo(
            APPC,
            1000000000000000,
            8346369318913311768576,
            11430352782251779948544 );

        conversionRate.setTokenControlInfo(
            ENG,
            10000,
            245309013986,
            335950694654 );

        conversionRate.setTokenControlInfo(
            SALT,
            10000,
            117682709761,
            117682709761 );

        zeroArray.length = 0;
        zeroArray.push(int(0));
        for( uint i = 0 ; i < newTokens.length ; i++ ) {
            conversionRate.addToken(newTokens[i]);
            conversionRate.enableTokenTrade(newTokens[i]);
/*
            conversionRate.setQtyStepFunction(ERC20(newTokens[i]),
                                              zeroArray,
                                              zeroArray,
                                              zeroArray,
                                              zeroArray);

            conversionRate.setImbalanceStepFunction(ERC20(newTokens[i]),
                                              zeroArray,
                                              zeroArray,
                                              zeroArray,
                                              zeroArray);
*/                                              
        }

        conversionRate.transferAdminQuickly(orgAdmin);
        require(orgAdmin == conversionRate.admin());
    }

    function tranferToReserve() public {
        ENG.transferFrom(multisigAddress,reserve,790805150356);
        RDN.transferFrom(multisigAddress,reserve,5991690723304920842240);
        APPC.transferFrom(multisigAddress,reserve,28294946522551069704192);
        SALT.transferFrom(multisigAddress,reserve,512404807997);
    }

    function withdrawToMultisig() public {
        address orgAdmin = reserve.admin();
        reserve.claimAdmin();

        reserve.withdrawToken(OMG,579712353000204795904,multisigAddress);
        //reserve.withdrawToken(KNC,0,multisigAddress);
        reserve.withdrawToken(EOS,404333617684274479104,multisigAddress);
        //reserve.withdrawToken(SNT,0,multisigAddress);
        reserve.withdrawToken(ELF,2851672250969491505152,multisigAddress);
        //reserve.withdrawToken(POWR,0,multisigAddress);
        reserve.withdrawToken(MANA,18906283885644627312640,multisigAddress);
        reserve.withdrawToken(BAT,5034264918417995726848,multisigAddress);
        reserve.withdrawToken(REQ,6848892587322741096448,multisigAddress);
        reserve.withdrawToken(GTO,3232686829,multisigAddress);


        reserve.transferAdminQuickly(orgAdmin);
        require(orgAdmin == reserve.admin());
    }
}