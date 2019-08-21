pragma solidity ^0.4.18;

interface TokenConfigInterface {
    function admin() public returns(address);
    function claimAdmin() public;
    function transferAdminQuickly(address newAdmin) public;

    // network
    function listPairForReserve(address reserve, address src, address dest, bool add) public;

    // reserve
    function approveWithdrawAddress(address token, address addr, bool approve) public;

    // conversion rate
    function addToken(address token) public;
    function enableTokenTrade(address token) public;
    function setTokenControlInfo(
        address token,
        uint minimalRecordResolution,
        uint maxPerBlockImbalance,
        uint maxTotalImbalance
    ) public;
}


contract TokenAdder {
    TokenConfigInterface public network;
    TokenConfigInterface public reserve;
    TokenConfigInterface public conversionRate;
    address public withdrawAddress;
    address public ETH = 0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    address[] public newTokens = [
        0x00f0ee6b27b759c9893ce4f094b49ad28fd15a23e4,
        0x004156D3342D5c385a87D264F90653733592000581,
        0x001a7a8bd9106f2b8d977e08582dc7d24c723ab0db,
        0x00255aa6df07540cb5d3d297f0d0d4d84cb52bc8e6];

    function TokenAdder(TokenConfigInterface _network,
                        TokenConfigInterface _reserve,
                        TokenConfigInterface _conversionRate,
                        address              _withdrawAddress) public {

        network = _network;
        reserve = _reserve;
        conversionRate = _conversionRate;
        withdrawAddress = _withdrawAddress;
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

        for( uint i = 0 ; i < newTokens.length ; i++ ) {
            conversionRate.addToken(newTokens[i]);
            conversionRate.enableTokenTrade(newTokens[i]);
        }

        conversionRate.transferAdminQuickly(orgAdmin);
        require(orgAdmin == conversionRate.admin());
    }

    function setTokenControlInfos() public {
        address orgAdmin = conversionRate.admin();
        conversionRate.claimAdmin();

        conversionRate.setTokenControlInfo(
            0x00255aa6df07540cb5d3d297f0d0d4d84cb52bc8e6,
            1000000000000000,
            8000000000000000000000,
            8000000000000000000000 );

        conversionRate.setTokenControlInfo(
            0x001a7a8bd9106f2b8d977e08582dc7d24c723ab0db,
            100000000000000,
            24000000000000000000000,
            24000000000000000000000 );

        conversionRate.setTokenControlInfo(
            0x00f0ee6b27b759c9893ce4f094b49ad28fd15a23e4,
            10000,
            800000000000,
            800000000000 );

        conversionRate.setTokenControlInfo(
            0x004156D3342D5c385a87D264F90653733592000581,
            10000,
            800000000000,
            800000000000 );

        conversionRate.transferAdminQuickly(orgAdmin);
        require(orgAdmin == conversionRate.admin());
    }
}