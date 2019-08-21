pragma solidity ^0.4.18;


interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
}

interface TokenConfigInterface {
    function admin() public returns(address);
    function claimAdmin() public;
    function transferAdminQuickly(address newAdmin) public;

    // conversion rate
    function setTokenControlInfo(
        address token,
        uint minimalRecordResolution,
        uint maxPerBlockImbalance,
        uint maxTotalImbalance
    ) public;
}


contract UpdateConvRate {
    TokenConfigInterface public conversionRate;

//    address public ETH = 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    ERC20 public ENG = ERC20(0xf0Ee6b27b759C9893Ce4f094b49ad28fd15A23e4);
    ERC20 public SALT = ERC20(0x4156D3342D5c385a87D264F90653733592000581);
    ERC20 public APPC = ERC20(0x1a7a8BD9106F2B8D977E08582DC7d24c723ab0DB);
    ERC20 public RDN = ERC20(0x255Aa6DF07540Cb5d3d297f0D0D4D84cb52bc8e6);
    ERC20 public OMG = ERC20(0xd26114cd6EE289AccF82350c8d8487fedB8A0C07);
    ERC20 public KNC = ERC20(0xdd974D5C2e2928deA5F71b9825b8b646686BD200);
    ERC20 public EOS = ERC20(0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0);
    ERC20 public SNT = ERC20(0x744d70FDBE2Ba4CF95131626614a1763DF805B9E);
    ERC20 public ELF = ERC20(0xbf2179859fc6D5BEE9Bf9158632Dc51678a4100e);
    ERC20 public POWR = ERC20(0x595832F8FC6BF59c85C527fEC3740A1b7a361269);
    ERC20 public MANA = ERC20(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942);
    ERC20 public BAT = ERC20(0x0D8775F648430679A709E98d2b0Cb6250d2887EF);
    ERC20 public REQ = ERC20(0x8f8221aFbB33998d8584A2B05749bA73c37a938a);
    ERC20 public GTO = ERC20(0xC5bBaE50781Be1669306b9e001EFF57a2957b09d);

    function UpdateConvRate (TokenConfigInterface _conversionRate) public {
        conversionRate = _conversionRate;
    }

    function setTokensControlInfo() public {
        address orgAdmin = conversionRate.admin();
        conversionRate.claimAdmin();

        conversionRate.setTokenControlInfo(
            KNC,
            1000000000000000,
                3475912029567568052224,
                5709185508564730380288);
        conversionRate.setTokenControlInfo(
            OMG,
            1000000000000000,
                439794468212403470336,
                722362414038872621056);
        conversionRate.setTokenControlInfo(
            EOS,
            1000000000000000,
                938890140546807627776,
                1542127055848131526656);
        conversionRate.setTokenControlInfo(
            SNT,
            10000000000000000,
                43262133595415336976384,
                52109239915677776609280);
        conversionRate.setTokenControlInfo(
            GTO,
            10,
            1200696404,
            1200696404);
        conversionRate.setTokenControlInfo(
            REQ,
            1000000000000000,
                27470469074054960644096,
                33088179999699195920384);
        conversionRate.setTokenControlInfo(
            BAT,
            1000000000000000,
                13641944431813013274624,
                13641944431813013274624);
        conversionRate.setTokenControlInfo(
            MANA,
            1000000000000000,
                46289152908501773713408,
                46289152908501773713408);
        conversionRate.setTokenControlInfo(
            POWR,
            1000,
            7989613502,
            7989613502);
        conversionRate.setTokenControlInfo(
            ELF,
            1000000000000000,
                5906192156691986907136,
                7114008452735498715136);
        conversionRate.setTokenControlInfo(
            APPC,
            1000000000000000,
                10010270788085346205696,
                12057371164248796823552);
        conversionRate.setTokenControlInfo(
            ENG,
            10000,
            288970915691,
            348065467950);
        conversionRate.setTokenControlInfo(
            RDN,
            1000000000000000,
                2392730983766020325376,
                2882044469946171260928);
        conversionRate.setTokenControlInfo(
            SALT,
            10000,
            123819203326,
            123819203326);

        conversionRate.transferAdminQuickly(orgAdmin);
        require(orgAdmin == conversionRate.admin());
    }
}