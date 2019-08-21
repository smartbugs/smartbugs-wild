contract DAO {
    function balanceOf(address addr) returns (uint);
    function transferFrom(address from, address to, uint balance) returns (bool);
}


contract WithDrawChildDAO {

    struct SplitData {
        uint128 balance;
        uint128 totalSupply;
    }
    mapping (address => SplitData) childDAOs;

    function WithDrawPreForkChildDAO() {
        // set balance and totalSupply at time of split for ChildDAO. Malicious childDAO (did not burn the right amount of DAO tokens
        // at the time of split) are commented out with a "b" at the beginning of the comment. ChildDAOs which habe already executed a 
        // proposal are commented out witha "e" in the beginning of the comment. Both types of childDAO have been taken from:
        // https://github.com/dsystems-io/childDaoWithdraw. Thanks for the work!
        // Added by @ledgerwatch: childDAOs that are pre-attack and refunded on invidual basis, are commented out with a "p" in the beginning
        // of the comment
        
        // 1 e - childDAOs[0xd4fe7bc31cedb7bfb8a345f31e668033056b2728] = SplitData(11727766784716799192555572, 11727751591980739956782275);
        // 4 e - childDAOs[0x2c19c7f9ae8b751e37aeb2d93a699722395ae18f] = SplitData(11723955902593679358349542, 11723940714794427556781866);
        // 7 p - childDAOs[0x1975bd06d486162d5dc297798dfc41edd5d160a7] = SplitData(11652675906713000181862887, 11652660811253422556781866);
        // 8 e - childDAOs[0x319f70bab6845585f412ec7724b744fec6095c85] = SplitData(11727766774716786238037889, 11727751581980739956781866);
        // 10 p - childDAOs[0x5c8536898fbb74fc7445814902fd08422eac56d0] = SplitData(11652850906939704234171111, 11652835811253422556781866);
        // 13 e - childDAOs[0x779543a0491a837ca36ce8c635d6154e3c4911a6] = SplitData(11725766772225882912631930, 11725751582080739956781866);
        // 14 e - childDAOs[0x5c6e67ccd5849c0d29219c4f95f1a7a93b3f5dc5] = SplitData(11725266771578157048894147, 11725251582080739956781866);
        // 16 p - childDAOs[0x200450f06520bdd6c527622a273333384d870efb] = SplitData(11725205904212994017693999, 11725190714794427556781866);
        // 18 e - childDAOs[0x6b0c4d41ba9ab8d8cfb5d379c69a612f2ced8ecb] = SplitData(11723955004074335371421094, 11723939816276247556781866);
        // 19 e - childDAOs[0xd1ac8b1ef1b69ff51d1d401a476e7e612414f091] = SplitData(11689379967484102516657552, 11689364824476247556781866);
        // 20 p - childDAOs[0x51e0ddd9998364a2eb38588679f0d2c42653e4a6] = SplitData(11672514989096365433114202, 11672499867936247556781866);
        // 22 e - childDAOs[0xf0b1aa0eb660754448a7937c022e30aa692fe0c5] = SplitData(11672404990435687662718170, 11672389869418067556781866);
        // 23 p - childDAOs[0x9f27daea7aca0aa0446220b98d028715e3bc803d] = SplitData(11672504989083410915839447, 11672489867936247556781866);
        // 26 p - childDAOs[0xd9aef3a1e38a39c16b31d1ace71bca8ef58d315b] = SplitData(11657174904348740590804928, 11657159803060936256781866);
        // 27 p - childDAOs[0x6f6704e5a10332af6672e50b3d9754dc460dfa4d] = SplitData(11660273159043194987425803, 11660258053741756456781866);
        // 28 p - childDAOs[0x492ea3bb0f3315521c31f273e565b868fc090f17] = SplitData(11672394990422733145443415, 11672379869418067556781866);
        // 29 p - childDAOs[0x9ea779f907f0b315b364b0cfc39a0fde5b02a416] = SplitData(11651681905425321164752175, 11651666811253422556781866);
        // 31 p - childDAOs[0xcc34673c6c40e791051898567a1222daf90be287] = SplitData(11672027610039670010098830, 11672012489510927356781866);
        // 32 e - childDAOs[0xe308bd1ac5fda103967359b2712dd89deffb7973] = SplitData(11672027570039618192029731, 11672012449510927356781866);
        // 33 e - childDAOs[0xac1ecab32727358dba8962a0f3b261731aad9723] = SplitData(11671920519900940084603472, 11671905399510927356781866);
        // 34 p - childDAOs[0x440c59b325d2997a134c2c7c60a8c61611212bad] = SplitData(11660540013147733350301278, 11660524907500598656781866);
        // #35
        childDAOs[0x9c15b54878ba618f494b38f0ae7443db6af648ba] = SplitData(7913415994245080851884568, 11540303342793816418782834);
        // #36
        childDAOs[0x21c7fdb9ed8d291d79ffd82eb2c4356ec0d81241] = SplitData(7913416021673878030553201, 11540303382793816418782834); 
        // 37 p - childDAOs[0x1ca6abd14d30affe533b24d7a21bff4c2d5e1f3b] = SplitData(11658110148448064505365317, 11658095045948698156781866);
        // 39 p - childDAOs[0x6131c42fa982e56929107413a9d526fd99405560] = SplitData(11660231985697426974621503, 11660216880449326456781866);
        // 41 p - childDAOs[0x542a9515200d14b68e934e9830d91645a980dd7a] = SplitData(11655924902729425931460472, 11655909803060936256781866); 
        // 44 p - childDAOs[0x782495b7b3355efb2833d56ecb34dc22ad7dfcc4] = SplitData(11657074904219195418057372, 11657059803060936256781866);
        // 45 e - childDAOs[0x3ba4d81db016dc2890c81f3acec2454bff5aada5] = SplitData(11644042202973928247591111, 11644027118698882556781866);
        // 52 p - childDAOs[0xe4ae1efdfc53b73893af49113d8694a057b9c0d1] = SplitData(11651686905431798423389552, 11651671811253422556781866);
        // #53
        childDAOs[0x0737a6b837f97f46ebade41b9bc3e1c509c85c53] = SplitData(8285423727021618574288915, 11597611623386926056781866);
        // 54 p - childDAOs[0x52c5317c848ba20c7504cb2c8052abd1fde29d03] = SplitData(11640162228429435032712289, 11640147149180702556781865);
        // 56 p - childDAOs[0x5d2b2e6fcbe3b11d26b525e085ff818dae332479] = SplitData(11637045764389294338324695, 11637030689177785356781865);
        // 57 p - childDAOs[0x057b56736d32b86616a10f619859c6cd6f59092a] = SplitData(11632720959688545875602644, 11632705890079605356781865);
        // 59 b - childDAOs[0x304a554a310c7e546dfe434669c62820b7d83490]
        // 60 p - childDAOs[0x4deb0033bb26bc534b197e61d19e0733e5679784] = SplitData(11600333244558691014482582, 11600318216906417656781865);
        // 61 p - childDAOs[0x35a051a0010aba705c9008d7a7eff6fb88f6ea7b] = SplitData(11632720949788533050630542, 11632705880179605356781865);
        // #62
        childDAOs[0x9da397b9e80755301a3b32173283a91c0ef6c87e] = SplitData(7930699229747195847409685, 11562914862736318056781866);
        // 63 p - childDAOs[0x0101f3be8ebb4bbd39a2e3b9a3639d4259832fd9] = SplitData(11599337143263109741834269, 11599318116906417656781865);
        // 64 p - childDAOs[0xbcf899e6c7d9d5a215ab1e3444c86806fa854c76] = SplitData(11631034981160489608342812, 11631019913735650056781865);
        // 65 p - childDAOs[0xa2f1ccba9395d7fcb155bba8bc92db9bafaeade7] = SplitData(11600338244565168273119959, 11600323216906417656781865);
        // 66 p - childDAOs[0xd164b088bd9108b60d0ca3751da4bceb207b0782] = SplitData(11600333144558561469309835, 11600318116906417656781865);
        // #67
        childDAOs[0x1cba23d343a983e9b5cfd19496b9a9701ada385f] = SplitData(7929078466662085333989346, 11560551799275847356782634);
        // #68
        childDAOs[0x9fcd2deaff372a39cc679d5c5e4de7bafb0b1339] = SplitData(10112931316104865578090844, 11599318102767995456781865);
        // 69 b - childDAOs[0x0e0da70933f4c7849fc0d203f5d1d43b9ae4532d]
        // #70
        childDAOs[0xbc07118b9ac290e4622f5e77a0853539789effbe] = SplitData(7932411170508884080269057, 11565410862736318056781866);
        // #71
        childDAOs[0xacd87e28b0c9d1254e868b81cba4cc20d9a32225] = SplitData(7913413658817663126469710, 11540299982102102518782834);
        // #73
        childDAOs[0x5524c55fb03cf21f549444ccbecb664d0acad706] = SplitData(7920435670452017684678746, 11550426779375303418782834);
        // 74 b - childDAOs[0xfe24cdd8648121a43a7c86d289be4dd2951ed49f]
        // #76
        childDAOs[0x253488078a4edf4d6f42f113d1e62836a942cf1a] = SplitData(7913160958906206858622565, 11539990270685330718782834);
        // 78 b -childDAOs[0xb136707642a4ea12fb4bae820f03d2562ebff487]
        // 81 b - childDAOs[0xf14c14075d6c4ed84b86798af0956deef67365b5]
        // 85 b - childDAOs[0xaeeb8ff27288bdabc0fa5ebb731b6f409507516c]
        // #87
        childDAOs[0x6d87578288b6cb5549d5076a207456a1f6a63dc0] = SplitData(7912878490620133004657286, 11539954374724178476032701);
        // 94 b - childDAOs[0xaccc230e8a6e5be9160b8cdf2864dd2a001c28b6]
        // 98 b - childDAOs[0x4613f3bca5c44ea06337a9e439fbc6d42e501d0a]
        // 99 b - childDAOs[0x84ef4b2357079cd7a7c69fd7a37cd0609a679106]
        // 101 b - childDAOs[0xf4c64518ea10f995918a454158c6b61407ea345c]  
    }

    function withdraw(DAO _childDAO){
        uint balance = _childDAO.balanceOf(msg.sender);
        uint amount = balance * childDAOs[_childDAO].totalSupply / childDAOs[_childDAO].balance;
        if (!_childDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(amount))
            throw;
       }

    function checkMyWithdraw(DAO _childDAO, address _tokenHolder) constant returns(uint) {        
        return _childDAO.balanceOf(_tokenHolder) * childDAOs[_childDAO].totalSupply / childDAOs[_childDAO].balance;
    }

    address constant curator = 0xda4a4626d3e16e094de3225a751aab7128e96526;
    
    /**
    * Return funds back to the curator.
    */
    function clawback() external {
        if (msg.sender != curator) throw;
        if (!curator.send(this.balance)) throw;
    }
}