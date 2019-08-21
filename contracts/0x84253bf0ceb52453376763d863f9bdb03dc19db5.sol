pragma solidity ^0.4.19;

/*
这是 Henter 的一次尝试，发布个人代币，代号 HTR

网站：http://henter.one
微信：henter
邮箱：henter@henter.me

v2ex 的发帖：
第一篇帖子，https://www.v2ex.com/t/422516
第二篇帖子，https://www.v2ex.com/t/429992

公众号文章地址:
https://mp.weixin.qq.com/s?__biz=MzIyOTUyNzM5Ng==&mid=2247483688&idx=1&sn=fcddae3d2a7d5ec8d0f6f38dc6168aa9&chksm=e8401b23df379235d2eac65e298d55e82d39f7914993ad1f0fd0e4ce0345bf4c3a7a46c3a367#rd

-----------------公众号文章全文 开始----------------------
Henter.ONE 大撒币
2018-01-10 Henter 亨特
声明：这是一次无聊的尝试！


鉴于最近“撒币”这个词比较火，于是取了这个标题，不忽悠，是真的撒。

为什么？


没有为什么，突然脑洞开了

脑洞过程？


昨天上午，在朋友圈看到有同学买了 .one 的域名，这段时间区块链行业火热，.one 域名也随之被广泛使用。

到了中午，突然想到，要不我也注册一个 henter.one ?

于是就注册了，顺便弄了个简单页面托管在 Github

下午快下班时，突然想起最近答题类应用撒币比较热，像冲顶大会 芝士超人等等，要不然我也撒币一次？基于以太坊 ERC20 ？对应新买的域名 henter.one ?

于是在下班路上构思了下方案

发币比较简单，但是代币要怎么撒出去比较合适呢？

方案：


方案一

做一个简单的网站，结合 MetaMask 做自助领取，类似于以太坊测试网络Ropsten 里的 MetaMask Ether Faucet

用户只要进来，点个按钮就能领取到代币，简单粗暴

但是随之马上否掉这个方案了，现在以太坊堵成狗，转账手续费大概需要 50 块人民币，来一千个人就得花掉五万块。。尝试的代价太高

方案二

通过智能合约控制自动发放，用户转一笔很小很小的 eth 到智能合约地址，然后合约会自动发放代币到用户钱包。

这个是最方便的，但是需要用户付出转账成本，有违初衷，也否掉了

于是有了方案三

人肉方案，先收集大家的钱包地址

然后我会将这些地址硬编码写入智能合约的 constructor

赋予其固定额度代币 每人一万枚，总量一千万

简称人肉撒币

最后


基于这个代币具体能做什么我还没想好

可能某天继续开了脑洞，会实现脑洞并赋予其特定意义

也有可能过段时间我就忘了这件事~ whatever~

代币符号还没定，可能是 HTR 或 HER，毕竟需对应 henter.one 这个域名

往小了说，这是一次无聊得蛋疼的尝试

往大了说，这是一次让你名留青史的尝试

并且未来可能给你带来意外收获

甚至你可以亲自参与到这次尝试，非常欢迎提供 idea！

或许哪天有时间我会将其实现出来

有兴趣的同学可以留言，留下你的以太坊钱包地址

收集满一千人，或者截止到2月14日，我会在以太坊主网上发行代币，每人一万枚，总量一千万

智能合约里会包含你的昵称和钱包地址

这篇文章的内容也会写进智能合约的注释

----------------文章结束--------------------


*/

contract ERC20 {
    uint256 public totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function allowance(address owner, address spender) public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
}


contract Ownable {
    address public owner;

    event OwnerChanged(address oldOwner, address newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != owner && newOwner != address(0x0));
        address oldOwner = owner;
        owner = newOwner;
        OwnerChanged(oldOwner, newOwner);
    }
}

contract HTRToken is ERC20, Ownable {
    string public name = "Henter.ONE";
    string public symbol = "HTR";
    uint8  public decimals = 18;
    uint256 public totalSupply = 10000000 * 10 ** uint256(decimals);

    mapping (address => mapping (address => uint256)) allowances;
    mapping (address => uint256) balances;

    uint256 public forGenesis = 10000 * 10 ** uint256(decimals);

    //感谢以下所有“创世”参与者
    address[] private genesis = [
        // 以下来自公众号：亨特

        0x128ceE70aDE62650175fdDB54FAca7CFF889E771, // 张超iKnowApp
        0xc00eDE6A3C3Af974038E13C72cE606dc7a5d19cd, // 王维
        0x9A885391e9ec3774f07c13BBc40F5a6a8dcE8FF4, // 任杰
        0x82d76b4D95159989C40fb321D9900c05223e8D18, // 胡子
        0x306c0C767fbDEC59d35fCc192d2E4673A38ed4B2, // 魔神
        0x3dd1B6c525246E45a9b772b518D54e394561E904, // 幻影明月
        0x5C9A2ff64A142f7F759bD6Da23Bf34ef17B98f8C, // 乐乐
        0x1B67dbec92033c5Af269f2bf256757d3Ba0A0981, // 有人与我把酒分
        0xfAF3f2bd980B414932cEEd92DA8F83069128B61e, // null0z
        0x316e7b272CA525A32464624Ac1310289B591D503, // 房涛
        0x20223226246d76c7a8c131cce0ea8ec8dcc31fb9, // 王建
        0xC1468F3BB75EE510C1c4f23c5a11C99cdac3b016, // 北方工业
        0xe0794451F52D097Aee80b93702Df87bc38918979, // GeekSu
        0xB38E680A06990639F25a92aFB5Acc1c8306b6231, // 不加糖的咖啡
        0x1B3b15aDEE5D3419FB6Fb1c68E55cAFD9764c85e, // deepSea
        0xb8A02E28602cb8B471b5932dcf2998dC81Fc06a8, // Y1
        0x39a79ABF7c6690ec6803aA31d543d2696fbAA49a, // wyfzzz
        0xF570BadF82133bb10079bCDE16D6ee859730c09c, // asier
        0x3eBe9d0572eCF73852c6496Ce2f17b6c9E82CCA2, // 阿克蒙德
        0x79807afD93e28c62a6c411edEef1Bef09aF98Df0, // 倪立强
        0x489404D2edC4721683D5e5442bEEe891d2D997B7, // http://wx.qlogo.cn/mmhead/Q3auHgzwzM5m74uHuWIoWfNyBZaqibblzawCQZUy7To2Uw1PHvC3NPg/132
        0x2D8cE8360fc132029349dba5D214dc60B47797cc, // 泙漫
        0x58DBfe9B6AB7a2Eb44e9eb7EbE28Fbfa0a68E5C1, // 万宝路烟燃
        0xc5f412382931C1fE4C156Db0808737b7BfD82599, // http://wx.qlogo.cn/mmhead/Q3auHgzwzM6P0Ricdpq1jAgMQTjYwwKUs3cXOcsN6wkiaGD6K8oJFasw/132
        0xd37e243d39fab6956f652c3b306f640768bd0336, // force
        0x407Db4EFc8F1e7764eb61989e8D35E57c8DBA374, // 超能小紫
        0x488d566Abc1910862E71D80786C614b235FF73c6, // 冉冉
        0xa3aB171fb528C33D52B8413174E7aBcbeFA4D411, // xianyun
        0xFBD8caaa7aA8c045a6c149bE62604655cbd6A475, // songyulong
        0x149b2A1e359A04b94Db27c8b90Ae1e7c5596774a, // gavinlee
        0xcDd371C959cc5f37cC54CaC669e5Cb0fc9B27a2C, // 孙晓龙
        0x860a53206d1f92A28F61bb80E4025242b53F4A93, // 慢半拍
        0x9BA567ef097df1628eB41564e13E4bcE41Fe168E, // 阿萨辛
        0xfe48012b57A02b31715e2b73718bD1dC3823B58d, // 一币一色魔
        0x9Ae98B7c2847C0d8C4C2993CD320Efa9AeCb68A4, // 行知
        0x1DE494FE4df057d078132DA62532369F5dEA0184, // 何处不青山
        0x71375ce37ce8494ec13cfecba4ef14876ec086d3, // Pt
        0x1Dab428691F8153584cCabF88CFeF9b8ef5b9B2d, // DDO
        0x34199d6AE4CcC572d869Ee0628d1495936Ec171d, // Instinct
        0x1d642F2426177191DA80d15Ea76c71544aad4eae, // http://wx.qlogo.cn/mmhead/fhicotyX5dAd4P0ibZoPWnvM0p8zJFSBHQriayaatsdxwToyEcFwvvHIQ/132
        0x937e6dA7F8750DC2ef6939EBC0025bBC99232602, // gogo
        0xe3429d8af1def8e1ec9b79ed67dafeb0adc9f4dd, // 枣庄辣子鸡
        0xe748a668D9697623969cB71A8e8D28285E819b45, // 桂小方
        0x2938BefC1845bEE6d8d02089fB467A781217c8ef, // 黄大侠
        0x20595ae705fDAa7C256AFd64A5150ABFf42E654e, // ODR
        0x87e216d09F855B4e8AA95a14F56583D84eC7af3C, // null
        0x6832FE33956cAeB4e96eCAa87f5650218c2618b9, // 逆光
        0xc40C6Ff9E4ACF876B22DAFeb2a5F643157E1aCA9, // 一然
        0xfa2355542c73B3501B715fA2Dc41f69aB9260322, // Aries.
        0x6a4130F6f5671811912da156c72420b101D9D0A6, // 刘春晓
        0x0eD51eD76536ed6e93d6F7735451cd0de0D9AFF1, // 南琦www.my2space.com
        0xe52fe0Dfe10b2D8FC300F09074c6CA0BAd2BfeA8, // Samuel
        0xC98506F6836684109Fa63e0b637dFCCBb0492707, // Miller
        0x54640F357199a4E9E1b12E249A7Df9B52BEEfd1a, // 谢符宝
        0xA56637FeE8543400cb194f2719dB5b29A5EBf5fe, // 瞬心
        0x98aEc03f4E7187bE7027B7E0252Be67d5948d26B, // 周小雪Snow
        0x33627397E2b4f60e33a1f5d6AE67f748366a1f76, // ALD
        0x9aDdA31fC7AD44729106DF337d9f5F640D647760, // SHUANGXI
        0x476a69456206334cC4E72D9d1cF69037B1Ca58a1, // 探索者
        0xfc6952469DFeaA1760f2D1Fb3Ed72ec2A814af06, // QSJia
        0x80496576ed1ddc31c6e229d5017b4701c5f25b3d, // 拾。
        0x8ce2126557b573CfC3c710f9477fd0c2e1B1050e, // 小智
        0x5997316B8518489D22ba22Fb86526f5Ed3067cBF, // 陈海天
        0xC18Be4BbB7ef3B8ce97193E5d76Db85EcD0301F3, // Mat
        0x3d5929Fc2a2d0e0Bb6B111DC5DCd9721f8F5F5f9, // 袁木习习木习习
        0x3492adcd9450E475d200A016216Bca26bED2aAED, // 正觉（朔）
        0xD69ec0676FEB526Dbe59962aa3E97Fe189B0D080, // 过去式
        0x2265e08a6b359fa214945bae509b9b5b303d730f, // 一壶酒
        0xdA7B9ee2CF2CeE941BdD747DCe7016ff803AB852, // 卫-AKI（圆弘）
        0x188987ae249407094b92fb78788fa9cbf6936e2f, // 王菲
        0xaf044c0876ee96a95281dae434a35ee55a97b1ee, // 富贵小白兔
        0x6e95307e28f7f7f64A7CA02f9bC5AF682d000EdF, // 兴
        0xD7846582Ed6522B04f820A4222936a672e075f2d, // 老北京
        0xD097407bE755FFB2d51803f650Db462d1D0CbB1B, // 舒赐麒
        0xAD73c0009E472B5867673465174B144A782D8ac2, // 勇往直前
        0x2635DB214a50ABE7F18F45Ad65492f9ffC1778f7, // Macro
        0x3EA6733144659beb00300Cd0789B3683095aE939, // 123
        0x558b0eb221ddbbd4c2688f90fe0e446ab93e703f, // HE
        0x5201BEbaC536B68Efe222Ea958Dd0d9Fb4F217f9, // 大奔
        0x17cf9c972ACFa11cA9c978A0db6EaF7b3Bf1BD05, // JetQe
        0xb35E2Ab1212621c874Cc814064fAff371A1f39e1, // 不周
        0x4ff54B0422e429b36e4AF292734B0c4230C6fA7E, // 高源Ken_萌果VR
        0x6A4b634C28e66F764EA553Cf396239CbD7a3F899, // 中国登报网
        0xDa384F18b8A6e83D45afa4731424f1bD08317d10, // Thorb姜岳
        0xBc381e9a37493f2AA499aB708b0F9f15B43018E0, // 木头
        0x36D15D03eCc18dfa2876328d9D84DDFD829CE048, // 桃花岛主
        0x75b25923Ff3aA9E1F901c1d275ae6378C4A972FE, // 晶
        0xDa1F4BD9DE3DBFAF9582701Bc655BE92E01220D9, // 大鱼
        0x6C4011fEa1b22a58B015823124903310764Ed87c, // Helen小布熊
        0x910f6Bc0402782BBe487FeB66Cd715f2dBc46F02, // 夏力维
        0xfb50333A9630A53416Ddbcf34f4AaE7DfABDdCC3, // 我本顽石
        0xC51C97344296209b2Ec28b483EADB5fD6522E32e, // 恶来。
        0x96442cb142b4e36C6bb410e4a4dE60AE49A25EFf, // 郝力航
        0x2576dcB9E8f26357f4f358C1c0344D6C4b14aC86, // 嗅一朵小花
        0x97BBb08186c79aC4c8A770c42bb21d7bf0B7de4d, // Gordon
        0xE1F3fAfa40074F17dF33B5aAF974AC418575df5C, // 番茄匠
        0x0BAbac86D9861A2a4b0Cb6B7b87424F38771535C // cyberstick

        // 受以太坊 gas 限制，来自 v2ex 的用户将由后续空投实现，不随同代币合约一起发布

        // 以下来自 v2ex 第一篇帖子，https://www.v2ex.com/t/422516

        // 0x0bba8969952D7BA3Dc6Deccff22807D246903158, // RaymondLew
        // 0x5997316B8518489D22ba22Fb86526f5Ed3067cBF, // chenhaitian
        // 0x32A99cC11A595Fa9BA6217D735C1d2Fc45C230F3, // snail01
        // 0xedea8fb2d22202ba18c32b0bf272aa9ca9539306, // keniusahdu
        // 0x84989c61FeaaB6364f8C89d158e27Cd33ee7A114, // jeffma
        // 0xbAc9E1Da19FF794Cf1037eC332558C7987C6c506, // sean233
        // 0x8025f90Ec2D8bE8CB3664A5b3c7b70D7Fe9F612f, // dage
        // 0x5a8BCCC4E737d100e90C99DFa38A136246d9F488, // diggerdu
        // 0x00A29736405FE3d52A2d3F6246911Ef1fDa90373, // davidqw
        // 0x607DF9c01c9887077F685a4DE1a60731d6d82b51, // Slengl
        // 0xb1B1Af358f4028a79d3c4Abc55534Ef44Ba8Cedd, // tudan
        // 0xD2f9E4bbBfaCFcfA1992CF654a5B328796480E91, // datou
        // 0x24f5fEf7E4aa91Fe3eF45ce7faD5bE67Ec0e65e7, // ittianyu
        // 0xbF68aB4d5C7BB8eDeC39Fe218320F00f1e9300d7, // hengxin196
        // 0xA617119A8833dFE7D550E9CEd961642Cb7F9B275, // fanazhe
        // 0x547d54D538be248Ca07eC00192A0264dDA8264A5, // 1097341596
        // 0xfe57Fe0383eB81271eAf7b843960f3A9BBf307C4, // widdy
        // 0x44af42b88fbaf22016970c3e434812222151fcfa, // n329291362
        // 0xB08Fa3fB455cA26fCBfaBb6Ea5777FBD68ff4C51, // dd0754
        // 0xFb7eBF844e900351b29e0484551aC5C96432E46c, // qfdk
        // 0x330A4a55e2D818F26eeeEA2250BCb7391567AF6c, // fireway456
        // 0xfca5d153de197eed947408df5d67bbdd5b213509, // leewangyang
        // 0xD88aC58a7e9456d9f41aFb22C56bbD2D0e7645fb, // a282810
        // 0x43cD2Cc3D44Aa4F180FC01823fc86f3FB784cb4F, // nomoon
        // 0xd83814b49082dc5afd760411148a796fea427d18, // alan7
        // 0x13401582C2FC1Ab0bf06c9dB9546b35Caf287eFe, // bitkwan
        // 0xA24063bF89B3F84fa76a97F2063c47F3fBAc0951, // yummybitcoin
        // 0x870a8aDD6cf3f93f1c1f50F8F0Bc2515E7F6A348, // kmdd33
        // 0xe3CD78A7EF1F93193Ee74a432Da561335116481E, // markx
        // 0xafe61ff4921e66b37db05cb64c13e7be2b26f919, // likuku
        // 0xF36E65bD1D172c2E347B35D1A430A55eA6389080, // wjm2038
        // 0x6004013c97947b89a64622719cb2158f0a457a4f, // fen
        // 0x304ce996063dbe310d7991ad7a73fe279f444177, // Kopei
        // 0xd0a342A974357dca0dB14a8EF5cD00b45461B0d9, // Gord3n
        // 0xb7FB5d9Ad4fEdD827ce11E28A0144e8C5515A05B, // zlfera
        // 0xf5fA3CFd807CBD3f25C8CfAFB68c86fBf1853626, // singer
        // 0xcE240347aFc1304167B22f205a79d3c4751eb593, // USOMOE
        // 0xf1dccFd40903E0eA7Ea83B24615A80B1cE77a61A, // Mingking
        // 0xF8C9fa4bC453C563Fb804Fb5391AF6394124Af3F, // cliaikie
        // 0xb32182D4560589e60487C8cD6B0D7dCB5f5613Fd, // saymoon
        // 0x7347bfb28f3f41d4c4cdd0304a69b8e23d40552a, // pkuphy
        // 0xa08008f800c88aefcf284729a3cc3a066f712da0, // chenggiant
        // 0x437d999830646ea93a738eec0f451f54ef05c78a, // viamcc
        // 0xf1e7ce5BB416bC6BebF951d719f5381B2fD540d9, // kiwiz
        // 0xcd0d6019d93c865c0ae41991c14e3bd7550d3ccf, // sheep3
        // 0x7e0A4bD6CC3377050aB978E42C49822046CC76CC, // cwcauc
        // 0xDe8A256C76F3C292d9F30120f4A0B6900B7BB52F, // WooYou
        // 0x94Ca7D4f437ED337B4d8955E499385bd45651F17, // EVAb00
        // 0xb2d7e0095bdf4584c3d5ffe7ee53389aba3e944f, // coordinate
        // 0x3b81A746c2a802a73ab0E4Ac04229258A5c61c92, // aragakiyuii
        // 0xa677b5B845d7623738db23eEFC89C5A1852cab53, // porwyn
        // 0xB2784a4C79074B055293A690538e09B2675c535B, // cugljd
        // 0x4FB793F32169569101700cD0A4F2FE08Da5f03c9, // jiangbin
        // 0xBc38cf61bc3cCE395814821B736DD314ccb1E011, // geyee
        // 0xf0D5f47e5ef25A134B33Bc9D32De39a97cd9D6cC, // watana
        // 0x53E3B3E1076131d59F84C00Cb325920d7a3A71Ae, // xiaobinkk
        // 0x9c90AeF0030F2681b3C7206bE35BB6698220F419, // vincenth520
        // 0x80496576ed1ddc31c6e229d5017b4701c5f25b3d, // fingerskey
        // 0xDA00002Da1Da849010d49eC606f6321d1628A98a, // lansinonmo
        // 0x642eF8b5fC34AB5f2CaFCe35345F979B0B55A59A, // kristol07
        // 0x62E4395C04F400b4482adF8Fdb83EDADf0b1942C, // sosu72
        // 0x51545728A9d7DDE4B129b50E5C96503D0a608f5a, // tabrisux
        // 0x757c1A59acbd8e9e707e02dD30235e0C87f2Ff75, // rosu
        // 0x0577e5E7eE191777C089355C90Bc510bc534EA77, // nisnaker
        // 0x0d0165e4Fd3D359AaA60ACd9fE21d87103639da6, // snailx
        // 0x476a69456206334cC4E72D9d1cF69037B1Ca58a1, // tanszhe
        // 0xE00a72aFb1890Bc4d0dcf2561aB26099cACEcD87, // stirlingx
        // 0xeAa379E91c342ADF4Fa21F146eF6297570641BEe, // weioyi
        // 0xC2FD317b567c45bE824D7EF2ddE169EAB50c7acC, // meeview
        // 0xb6c54f8C07E44cd6f8C28679c0F726cd9ed4ACC7, // daryl
        // 0x046a43c1d391b3C2C81784faFb55a17e2810c407, // zdt3476
        // 0x7DaaDd855F76F4C9582B4Ce604d5556eB568385e, // Zh1
        // 0x6577BF521B9Be5ca5F3B3E6E237d423b80A138dF, // YellowLittleDog
        // 0x82fb07b726775b98d3b0988114cb7fa36fdb9005, // Tangel
        // 0xd13e9c323491F3865e05774319096Def2807DA85, // ZEOH
        // 0x7EdAF1c24257ecEEEf976C57199e742bfFd4a642, // awing
        // 0xe03a7c0906c78c593a6b15b4a2193dcb000b4be1, // qixixian
        // 0x9aDdA31fC7AD44729106DF337d9f5F640D647760, // shuangxi
        // 0x454e429E6C6306c1B0472e97873931a4c30ce98C, // aerozzx
        // 0xF601E531D08Cee5D7453d91858b65C86Fd623183, // lin
        // 0x98C50977635C9C946599887cfa8B02F0FD6a379b, // starryforest
        // 0xB55C58A11BEd882aD6A1EE4A2B34Fb79F17eE7d0, // actar
        // 0x242df0066c1117a780bcbde64568aefca85bb729, // ariesjia
        // 0x7aCEf27c14bdf3281499b32081d80A8b753203a0, // yongd
        // 0xD4a0A9dB7db3F89F3E86Cc4E998ae108A11784E7, // Tompes
        // 0x2Da0F2236b7F1AA29C33e2DD0fe8CC060FA85d48, // iiusky
        // 0x4caA8F2333F6F060cB73CfD58a002aCd21Ada2bC, // yaoweilei
        // 0xe9A06048e602E8fD9bE27f1Ec4af661C68C7B887, // madadimy
        // 0x186dD2783759b8DDCEaBf3F16dA2A0F2Ad91aB7E, // poorcai

        // 0x1044F76C88e34F147CBbf9F6e7FD8479c7bfa867, // key1088
        // 0x598292B3162930f5E55093624A82817a7De4CeB1, // odirus
        // 0xcB8DcFFe246bD6a7dd8fb5b4cbB53e12065716F9, // zzWinD
        // 0xe3b78896b699851be5560a4f88491eef881ee7f4, // vanir
        // 0x0eD51eD76536ed6e93d6F7735451cd0de0D9AFF1, // nanqi
        // 0xe86173c8776602446788a057d6871249100DF87d, // mizuki
        // 0xDBa62E0CD4AC4C2F46271B89318201821F804836, // mhtt
        // 0x6356c20a45503ada8e208e0b7b9a1335830f7d1d, // ray8888
        // 0x35d2bb3a5b613278f7f2f991bf8136d20d08351f, // chotony
        // 0x916Aa06110D9db9e0D1bd3C6619D646CA01AC36D, // stayreal
        // 0x250B83161De934Bd8875E9DC87DE256e24B3e4ED, // chocotan
        // 0x6fBca5F9Ce173e0022310301bCab7f7bF2148Dcb, // ylcx123
        // 0x61B2560158eb4B62Db19282964F21e978120dfe3, // Gimini
        // 0xc8e084d3fc8f427c541239a62802b7b8eb333f61, // holajamc
        // 0xFcf5ff03e546fB17649e7Cb3442E644fC2cbFfbf, // lidonghao
        // 0x2f491d5B178Af0F69Ffa5d96b0c8d19365362007, // dreamwar
        // 0x414AD534476c046133814b1fBF9D5EDafF94AA4f, // Four
        // 0x2f207CCaD4A5a2EdD94af2D8337f26A7f86Ee186, // IC0ZB
        // 0xCc6985ce596abb45B247b7f67CD98B393f312b29, // wysnylc
        // 0x8d8eDA80C6A081B0e372d300C9292B01f13e6d87, // wendao86
        // 0x6796496087D750B455a593F929f94FAF58Db3F8b, // BooksE
        // 0x11b958700c621ca184c519607f5c90c8492b6c72, // sundaydx
        // 0x50E2FF4270Fb371616673a27a0F9BE24fA8f5b17, // Bigears
        // 0x1f5A66b598F342eBf198CaDBb94EB41C75a51c4a, // olaloong
        // 0x2BCEA3b0C93d36719f215D4cfE4FB7D851E9202C, // kiudou
        // 0xe29293a440bc08d1d9157c8ae80e32aaed637d34, // Sixzeroo
        // 0x12B09cA481eA952a341b9D3Da0D04D24b86D81A0, // anthow
        // 0x9181fa5088af9fd6a05adbf6362741e9a8008891 // files


        // 以下来自 v2ex 第二篇帖子，https://www.v2ex.com/t/429992

        // 0x88a4e7054b85142FFEaC8B6c421C335682cAe9a6, // panyanyany
        // 0xE5Cd9E5DeA09BC2BCEdf798925856b455394199E, // laoyur
        // 0x6fBca5F9Ce173e0022310301bCab7f7bF2148Dcb, // ylcx123
        // 0x6Ef9A78274DC272354d90DDf469DEaf3ECbff117, // miss1123
        // 0x3dd1B6c525246E45a9b772b518D54e394561E904, // anying
        // 0x046a43c1d391b3C2C81784faFb55a17e2810c407, // zdt3476
        // 0x7051B5ce7520765005D45Ed0Fb4F21Cfee38123B, // iStar
        // 0x5196B9C4cb1CF1f739929dF6Bb2E929A32749FA9, // Nan7Huang
        // 0xB478669e09b37e050e2EA9B270AE2D02651A6b7C, // vmos
        // 0xd38b9f6819ca43318d15e4dcd6b043b7dc0f247c, // gongpeione
        // 0x9bd009142873fcae820fd5b34dc71426eea286e8, // onevcat
        // 0xcEb10ef238095898A62E163991D8551974d7AafE, // ovear
        // 0xabdbcde2a067a76f5d6b560b5bee2562e42b1c40, // Twofyw
        // 0x7bdE831d0A24eb9fEa05740346d9A0062B7a8fB0, // Dionysus12
        // 0xd9b8c9d85038e12e0a426C333892CB97e6E3B821, // wwdyy
        // 0x3d7ff693574fc6d7fa64e16634a0dd867af77158, // beakey
        // 0x94c94426b9E151857bBe25c880267977AAC26faF, // laughingsir
        // 0xfb25EDf3f3a30Fc480F191a426357ed5cfB523e7, // bitbegin
        // 0x404dd8c21bc8e52a6aea42d9dd05a79e298c2bdc, // fang320
        // 0x43D361928BF8f0a58c977b152dabfF47f68c6767, // wangjie
        // 0x5cab931a11319303485fB396960F927a524C4E1d, // ke1e
        // 0x1281A40c0acd2851179beBD4b7849685E001a4d7, // walleL
        // 0x2b17bb011c5d8bda61a6dbe065e950bb0456f361, // qq976739120
        // 0x5028B120A46A4708D725bB6017E9dBF0A537A3A1, // wangt21
        // 0x63CA54C41184Fea0220AC1dA03E02c3f70C24c31, // Magician7
        // 0x83ec1AEA7526407b6705fb187ae15A56e41EaCad, // jint
        // 0x8fe32d188FbE99A9D6bC664e777795f3f50FA967, // runcelim
        // 0xC95A5f832e0ceF68697d1b08159ee7d5E7b68346, // jkeylu
        // 0x7a156f0AF22FE83b4e7946C2D9b3995538107d25, // cozof
        // 0x7ac649f42899078467b6370ccf2ca07d3ad7ac86, // lanpong
        // 0xDcb535c0625D03BeBCf474FA119cB673F9E90494, // lxrmido
        // 0x1A7911F6109b0Db71d2888432687a2a90D110C76, // Robinson
        // 0x8025f90Ec2D8bE8CB3664A5b3c7b70D7Fe9F612f, // dage
        // 0x61B2560158eb4B62Db19282964F21e978120dfe3, // Gimini
        // 0x4caebeab130b1fee4749661da0f2774d51423d1e, // iburu
        // 0x8275FF1577D98D920Aaf3354Cb33C54b7e631F89, // broadroad
        // 0xda29fc4019fec6aa36841ab3864fcb3182684299, // krzover
        // 0xFcf5ff03e546fB17649e7Cb3442E644fC2cbFfbf, // lidonghao
        // 0x12D220FbDA92a9c8f281eA02871aFA70DfDe81e9, // idisreg
        // 0x04555ccEF029896D981E2B1c9b43b1a834F8b1F8, // qhxin
        // 0xe4C9de1DFF5DCce7a713d409a4945221c1e96074, // that
        // 0x2f491d5B178Af0F69Ffa5d96b0c8d19365362007, // dreamwar
        // 0x0c6CE5f8a09fa6DcB0FC82fb4a5A3Df4f4d34C27, // cmlz
        // 0x15B380AdF2c6bAD582F031300eE0FF1667f2902b, // 233
        // 0xB0b7eC6c6372976845e78a74B5313C2b00D4a319, // eeeagle
        // 0x549600Ca5663EC033D6a05B065FCfF02B13D8879, // keniusahdu
        // 0x7ab2887287820E7b027b8Bc0220732269727d202, // twor
        // 0xDAa64E2D147415181882e98Bd6c43e1f3d33969c, // xiaoer
        // 0x49d81942a0c208B2522fc9a0c52Bc46B0152395E, // Elephant696
        // 0x6cAc8B3dE387E3ab435aD67E8F57e1877d1C0513, // slwl
        // 0x3cce190E537d7b5Dd740BeA3C87f695778AFe28C, // iaoiand
        // 0x2f207CCaD4A5a2EdD94af2D8337f26A7f86Ee186, // IC0ZB
        // 0x828cAdB448BD62eD845C140eaCadc46c5f27e8B6, // kidteaing
        // 0x84a661ba770dcb13a71e2660b519cc04a0357be2, // interstate42
        // 0x2D4866782783224076ca939687D6f62c2c247F17, // geekcorn
        // 0x05528EF27751D8958201E23C6754Cc862262E784, // liuser
        // 0x590f8122915f4e0600846741f7d2f95170491bdb, // ps
        // 0x0975f97B21E6804b65EF58CCC60C2Cfb466d0B23, // oidsix
        // 0x4DB4e980e57B32fc03626eDB70Ff6020a96d9cf0, // aaronzheng
        // 0x1DE494FE4df057d078132DA62532369F5dEA0184, // asaxing
        // 0x69324767dbd2af4b6552a698dc2231c5c32bea04, // cokepro
        // 0xe07720797Ba7F1fcd0611E3e53beFe876Cf2DC17, // actar
        // 0xbCD3f1B62Cd9219C30203EA27e0c87f96a780Bb2, // sw0rd3n
        // 0x0C7d780D1Ab2192663A4A75447Cb9dF75c962a3b, // septem0080
        // 0x2e0ae4230918c7174034b0D6Df4087BF0Bc7DB1b, // xiaoliang
        // 0x8e9dAF8b2e95eb2B408bf3bC6486fd0758e09909, // z0011k
        // 0x38158659aaaaa6221373cfe0045fb9f01d2260bc, // miaoweining
        // 0xf0caafcc9f0806bd26aaed56448e77e75754df96, // retanoj
        // 0x9f719729ae080b27077d19d58375d284bd15b120, // seanxu
        // 0xFe14d81188D14E2536167163d34BF67d780d7eC9, // AA0
        // 0x028f443dc671303a9533ae0b7ba8de5ec8ad773c, // JoyNeop
        // 0x571CA54EF09d7c671B80E18319AE05bE6647be45, // lynnX
        // 0x22652a7A224Cd2f72eF286aDD27C1cfA2C242e4d, // satgi
        // 0x06548563cc243cFBe20D9Fb279c217D2A11D7F99, // mushan099
        // 0xB6541EFf031414a16BEEFffdf212Cbe02E926967, // vxcn
        // 0x8d8eDA80C6A081B0e372d300C9292B01f13e6d87, // wendao86
        // 0x460014168c88Dff13B0dc009A1C492bf2fCD0e2C, // Hyeongo
        // 0x6BE610763C40e33653AEA21FAaAd446E2fD41f27, // sdlearn
        // 0xbdf8DAfcE378918FeB32B97f695368243e5390B9, // fao931013
        // 0x7C7ddeBDe4ECa5A1aB6671cB774c7498393F324d, // mimzy
        // 0xe934e258ec1552b1b87cf9163337cd717e314c8f, // laurivers
        // 0xFB16B22f5b78E27B7896D7af7C3B8FF6907Ab38D, // tzdk
        // 0xe9C7252b5f199fA34A75E31685e3B9f8E33944aA, // afterain
        // 0x13104989e2609963Bfb1c3fDFC93271Efb5DE032, // newbook
        // 0xE4727f9f8d1DDaEb7033530FaB38bA248a013717, // qq64350633
        // 0x66aeDC64803F8b23e46f0dc55c048F715C253733, // suanyu
        // 0x94893a4388389923a770f82c34146563b4ce8d80, // jiezhi
        // 0x61f81F7aEC93d4fc86135b534cB129b4Cf6FA345, // SuT2i
        // 0xB242EDE861FCFdb43E8FA437A455194609b37175, // dengyutongcn
        // 0x444e177AEFbBF041fDc0485520009cDE79feEcB6, // hxdhttk
        // 0xcDd371C959cc5f37cC54CaC669e5Cb0fc9B27a2C, // qiuai
        // 0x9a1Db6caF46dCea4DA85DD30B75FDfc4Bee41ed0, // Solerer
        // 0x81459E97F16dc8D72AfCF8D674951b5f34C410Fe, // mccoymir
        // 0x67Fafb0DC6c00a6fFE3538854086E8D83F269a07, // frankwei
        // 0x941f0C5cC37F825f1AAB6e4A49Ce08b1a3D06F40, // lwrless
        // 0xc49b6AB3ffeC66898EDBcFC943947B2E965738DB, // autulin

        // 0x46668e0E5E171F24deC89446Dbeec87dDbbd5fC8, // qk3z
        // 0xD259e20805b40BD5Ac76a6Ae250668F572E0d5b7, // lizhenda
        // 0x3DA2e503162CA825E0241E27eB44654454C22862, // lixin147741
        // 0x3E2EaF79980B3c056d4c980864583a488a83aA84, // 306145445
        // 0xcb57cDCa1b60BBAe251157D576ED02C00B585ADB, // zhijiansha
        // 0x6813c574f992b7b7d35fe8ecf18c39ae7879409a, // 243205964
        // 0xA891c1c12e72b990F371f354BD9D530690b4836D, // arfaWong
        // 0x2cB1603eB2Eee3e5dC8652ED745Ea58f1a60E60A, // a3587556
        // 0xf1dccFd40903E0eA7Ea83B24615A80B1cE77a61A, // mingking0526
        // 0x00Fbd4509e8e77Fdd6105AF3EFF61BE8f265b484, // wingoo
        // 0x59ACe3edAedDFBD8Ad1334f7cf6b2F195F08135E, // cnwtex
        // 0x8d36dB8227d5c0bDF501cD0972e7FE3387dEAC4B, // thejack
        // 0x488d566Abc1910862E71D80786C614b235FF73c6, // tanranran
        // 0x3ad3b1d1571be5ea25b94d2bb13469836f792236, // jsonmess
        // 0xf2F7bde2e3aF7aa35AB1e1C63bE30C279F79aaf9, // Antidictator
        // 0xe4596d79492cc0049031743d4a0fde5ab7b3625d, // yuerxx
        // 0x149519a5468ca03eceeb798a15672c203d4eca7e, // HULKSUN
        // 0x0d914e2767Fe4abc1a2E3a5F839bcca08339eD77, // lxsunbin
        // 0x6FEF02a122fF81ED892CbDe5Dc142E89aCc3d326, // chanssl
        // 0xF1a9694b280E8670726CA707f4e30b03511De232, // god
        // 0x302c17daB9D2e679b0Da39223616eA16a1D7645d, // iiji86
        // 0x8Ce60aA2FE2e28f3dA150214B176a4036477f12A, // t0mato
        // 0x88339f4308D5E3CeD16e0B491A3f7f8b069db7DA, // DWD
        // 0x759b63EA96910F28679E52e41240CE5eB968dD70, // TriangleSquare
        // 0x4f2499bfD5919A5442BA54536ddad5dDD285a35e, // ucmp88888
        // 0x1a01F9A191bca9b7fc165e3C41f4C138752b1508, // 0nlyy0u
        // 0x1bD4B4eb464a3Cb3aAfbb2bC061720ab627aF859, // paragon
        // 0xA578F89D4dA879d97aa4d58D69163c5d063a93D4, // hakim
        // 0x67154d1fA78B2DaCBd8a25d044a232DD461C832B, // gamelyking
        // 0x141FE7b3c9aFB57cE4500e61d9F8aE7b1dfeb321, // az0ne
        // 0x2ec3bbc4bce2aa0171a62672916c48af1d69ae0e, // TylerHu
        // 0xbe425d115dA1A4e072b9Fd47d7C12e2Ee0E0d9A8, // barbery
        // 0x3Bd7481c7B9e4b269D24478dBC9F03d96229eCc1, // si
        // 0x31f3333dfb1ae3670fa5891ecfda2881e366c721, // v2pxpx
        // 0x813E95eEBaa8cAeC92aE4444125a1A4aEa29F7a4, // endoffight
        // 0xF356bce6cA04152Fa93B325551f8BF5673C7CeD1, // bngzoo
        // 0xd7dbd23003ef1c2ebde42030b28e11cb5def7059, // saran
        // 0xDf1016624D6829A4fe75003A6d090a01d36A4F37, // luohaihao
        // 0x4017FF85e1eC03F881CeB29b2b3d8F3F1b82e3A5, // oiuyufeng
        // 0x50912886c2994cc5b2b781b4857596e0b5db628a, // balckz
        // 0x17B7565d6653718ecB7b32Ec9FB0D293b6749545, // 19tj
        // 0x1273e44cffb0232a6befca1e411fc1f0e64f5eb2, // zwj
        // 0x06d62ce39f678edeba08bd36e0973631b79df316, // huai
        // 0xab601879d64d97ebcf2fc565d78b9af9a9c793d5, // johnny23
        // 0x2629A73a6914f70526bfAFFc60Ee74d545b9Fccd, // boxz
        // 0x2e9a69858523F2C0d9cFfeCEbd3d00854f4D2FD5, // iPhone8
        // 0xa5248aC3cd572e00892a65E69764dbea96Fc60b2, // azh7138m
        // 0x8221953419B8EFdEd6d1e3c5F808DD0743E7e760, // malusama
        // 0x136fC6a45FB7E2af5c3d314d2756190a0c091e44, // dexter
        // 0x0b57CD1e96eE90bfDF8adBCE8b2E4482e5D726CF, // STillSB
        // 0xA8A82226635C3008F98BA504563231c3F4Ad9a76, // samlee123
        // 0x6796496087D750B455a593F929f94FAF58Db3F8b, // BooksE
        // 0x634a07992bF6720c0E9762eBB2C31c04d7854BA2, // cw35
        // 0xf7cb0A64F976D0e695f46fda968a8F2e0Aa2b447, // kaifang
        // 0x73e3bA6CE7CF5edb4e312d3A81CB8CacdDb05495, // feibilanceon
        // 0x2036c77c26e2c07797c57Ef29f11945589E86614, // xuyl
        // 0x997159c836A8Fd8e9E26405037471ee9A64cFab7, // Jevan
        // 0x1adC6aaA4c8942a9aEA109B81aBe6675a6eE0D4E, // mushiiii
        // 0xdbE69A1d42d302d55513E2158740F02ACc10867E, // he15hiss
        // 0x94eFa751Ab1Ff32b7139bb33016B12E0f81140f4, // kesu
        // 0x0944D75058e60A431697C37A09181640Bd8d1E1f, // Troevil
        // 0x0435643e3b7bf6e99d1ce2b4d37d38d3a542b0be, // bluewinger
        // 0x3d12323ed8cc62321cf720e4f058921cc184e5a6, // bitbegin
        // 0xcE8A3885d2E388E8716B7D7048a445E5530EC600, // Velip
        // 0xdbEDfC37730D1c369e67968A81Cc4dE176bb8217, // faae226
        // 0x50E2FF4270Fb371616673a27a0F9BE24fA8f5b17, // Bigears
        // 0x5dda02e7e27cb5252a6d516aa973eb6abd28605c, // izzacat
        // 0x58DBfe9B6AB7a2Eb44e9eb7EbE28Fbfa0a68E5C1, // marlboros
        // 0xb3099A44e08597A255e991797c57459E796593dF, // bomb77
        // 0xdeb805b7ce030a21306c7bcbd76d273d4de1ed7d, // JohnSmith
        // 0xB08Fa3fB455cA26fCBfaBb6Ea5777FBD68ff4C51, // dd0754
        // 0x0B3da0ba68a0F0B4e70A66a4c9EC051E7328B34a, // Jonydddddd
        // 0xb2c41211962b600a919ffbde3e8fd8d250e162df, // byron
        // 0xe2a0dcebb6696e6cd5f082ba915897df889592ac, // caoqin
        // 0xE2092890d2975b20bF27062084c5eE318Acd4B3d, // Athrob
        // 0x5461842b0B75beAD70bc1d7E76CDDAa2eD0cDAC8, // ipoh
        // 0x607B8517923A9fe10985c9A23D189F81461d9D54, // type
        // 0xa6aC0B8dF312041597a2E25A70f4e2F1BCef9aD0, // gsz2015
        // 0x26945b0C38bB40CD6c9a372ed505fA2d74fE28D1, // cdyrhh
        // 0xbb4003bfe914f58101ce8a5abf75c54e4a4f9bbe, // l30n
        // 0x7A654157ED711C868e5290b8Ae0b7D040087C4a1, // flowtensor
        // 0x7149278F24DfB1D1f57D916C508CAB9432B4cb34, // ZPPP
        // 0x3F616Db57a32126f3e736f2649771F3866585A6c, // hitfm
        // 0x3639447296d9CE02BBdBe16459f76F3485AdEDB7, // zhanlan621
        // 0x17FC25Fb1b2FC8b72244c6958A51d07173df04D6, // DT27
        // 0xbe7F318ADf3C65313f3cF34a8fc44C3E7e70E30E, // FuNn1esT
        // 0xcEe79fF33952bD4D4f56B2438573F525BEaFf21A, // redtea
        // 0xCbACabd112Cd9B55A5d7b0BEE0853AD9D07E1FB6, // alphabet666
        // 0xb3b0ddb062936e68199ea1bdea4ffa99e1f40d4b, // xiahei
        // 0x872F54968BAFCDC1bE90292d0A308153F7E84CEE, // Alexisused
        // 0xfAF3f2bd980B414932cEEd92DA8F83069128B61e, // nullzz
        // 0xf36ae61022be1ce3b38f95254937a4a01fb8e29a, // Dotpy
        // 0x54b4e68047d8361b0e82634b47dcf62eb2d1d28e, // bibicall
        // 0x3eBe9d0572eCF73852c6496Ce2f17b6c9E82CCA2, // anyuzhe
        // 0x0D355092C63fd4BBb79513b8626A3314e9A64b4D, // voyager

        // 0x2172c66Fb70617EFFeCC46432580D139f6f2EDF9, // findbrick
        // 0x2bbBF16D57B25FF4781B66c2821a9E041aDEf4d5, // wvc
        // 0xb32182D4560589e60487C8cD6B0D7dCB5f5613Fd, // saymoon
        // 0x637ea79ed3a523173f145d67c56092175a413ea1, // furusuna
        // 0x64af2D23359C5A0fBd941CCb640732dC7C542842, // 4396NeverBeSlave
        // 0x041b368b22335051B5A287E97Dd740A422f235B5, // wkcoder
        // 0xDA3ce5870Cd87041690276EE08aD676483F6f273, // wonderfulpain
        // 0xcF07f8F541cA26560AE548b29bACDAD2668d35C3, // nikubenki
        // 0xef0030760f3f9ce9a39b2e21ef8bad56fa8080ba, // kisama12
        // 0x447a78452FC454e004e9148850b09210A9c1B760, // andyiac
        // 0x09dE6D07d2C1Be563Dd6c6E907DD93206F51eBDd, // benwwchen
        // 0xb7FB5d9Ad4fEdD827ce11E28A0144e8C5515A05B, // zlfera
        // 0x6b720480417aaf0663ee98ba7de893a3bc782edd, // lyztonny
        // 0x6aca4e01682fbb671f7a7b31ec0957f8ad17cb83, // friendly63
        // 0x6E06f3432dFe553EFecFF12702D9576459f8b30c, // airmour
        // 0xe3Aaa94008be5EE1988E492B63D52C40330E16F3, // ericdeng
        // 0x1f5A66b598F342eBf198CaDBb94EB41C75a51c4a, // olaloong
        // 0xB7B2cA0aAAab4171d8B6BC848245947f3B449D86, // snail00
        // 0x2e4d298821375decaD534d67e464AEAc3950d6A1, // brand0n
        // 0x2281C2F22eFFebFc083F2871FE9a49b7F1D87EF0, // Coda
        // 0x7504fcA050a7B1adC50Cc625Df4Ec506C8C1f1DF, // yzyun08
        // 0xAc0b049462675312B0Eb5D02Bc446465db86Ce3C, // bitbegin
        // 0x87BD7EcB556817273c3adA560659fB6cb475aE1b, // kingsleydon
        // 0xad370474e1d82C661cE1926599A9eC3eA00B6913, // chrysalis2h
        // 0xCA6Aae19d8A39eFDAFCD03FFB6D9b62f1E17C2B8, // Cyron
        // 0xF942Ab4d52Cb4c8CF75012Bb22a18E47fB883e27, // darfux
        // 0x1364aa9daBa9c4b28F5E03cC392C45D1907b6A53, // gutu
        // 0xE3212e7AAb5D913b4d3e568789A697dc2f1C80Cd, // jason94
        // 0x176f235d56640E9C4FbA6E9d2E94c6C3B0Dd2cB0, // fuyufjh
        // 0x7219f767037604229621016154366c6bb706ad2d, // wZuck
        // 0x639A2996c665049a6b6615d56A01424d33A3C822, // Gratuito
        // 0xA21aB6a10260862EBb364dFd7Ff5D3745959E402, // mlhorizon
        // 0x07ad683CB44E5aCb8EB124DC986C699A02c5F370, // xspoco
        // 0xf4f8f42891ea8e4271e7da7d6346ae29eaf11253, // mosliu
        // 0x8716596a3587a9275234c39533832a63cf31b4c6, // lx0319
        // 0x0a8632F43550837098f9f53664477800680308E2, // bounty
        // 0xb2e02c9836e325fdf3f818dbd52e76977c587edf, // 002jnm
        // 0x607DF9c01c9887077F685a4DE1a60731d6d82b51, // Slengl
        // 0xb8638C4468d7356b54378165900944c9a23Da306, // ngn999
        // 0xb9d3486bc46c9d0d249bdc515dcd48a5bf55fbcb, // aixiaoge
        // 0xA3039829E46216416F4448f580955FD3eC8Cd877, // sudri
        // 0x12FD4C71597444C32410881626B288F6386e9Be8, // iFlicker
        // 0xe1adfe7d914d886c004225a25e86b87f38cb3bb5, // Rubbly
        // 0x6f4a351274769491ca8aa4149350c0297921f4be, // ch4in
        // 0xCaf967cd23ed4Fd9813440F9f0367f802D788698, // aizhet
        // 0x94Ca7D4f437ED337B4d8955E499385bd45651F17, // EVAb00
        // 0xb2d4119da08a4837f73c1e5e161f2581e5c263d3, // zgc123
        // 0xC1E3bE3B4C9f24941F14986dA505265aab57eA61, // aptx4689
        // 0xb2D4119da08A4837f73C1e5e161F2581e5C263d3, // zgc123
        // 0xfec1c3d209eade6e432cb6161561be1916e2a34f, // chenstack
        // 0x249ae8d1726793af8e20765b169fb12bb9144f19, // a453957718
        // 0x57A2a7475915136041B3c8485FF6270b7A532204, // jellybool
        // 0x15946668C2624E80C0eBcc1B8848fa2259Eeb538, // jianleer
        // 0x6BFa8429eb8e3159b9e2e011D7B708d640378D6d, // woodylin
        // 0x1B3b15aDEE5D3419FB6Fb1c68E55cAFD9764c85e, // deepSeaCode
        // 0xc4dd56beb695298127ec6f7ac586fd508b0c31dc, // marccc
        // 0xC34B5955dbe39c7b3C3EAe81cf2b7E348E3B2093, // mattx
        // 0xD30eDf8E569D5903F5A227c90C55Efb5794fc56C, // flowerdance
        // 0x2642cd1Ac24e7B497e0Ebf1161A5ff8bD1034bbE, // binary3141
        // 0xe7254a50b2c40c4175bea69041801b475fd81cd8, // viso1998
        // 0xF36E65bD1D172c2E347B35D1A430A55eA6389080, // wjm2038
        // 0x642921326f7d4f2a7e822b2107b30bed48256968, // comcuter
        // 0xfAf4c7dbD32412Fd811622C74F9540d6A1D847F7, // shiny
        // 0xee73a1a83b4a7db72d8a363d540916070d28905f, // char1998
        // 0x940df7806a41265817835490d828961d5f092563, // goophy
        // 0xC2E6AE8a6bD9F1B1EE18EF94e18BeAdE25Ae5883, // rade
        // 0x8834425276200135B6f860c39da2Bf36DC6bd457, // number
        // 0x186d6992b50CE598f793B23AF9Ddb4e97f91c904, // demonjudy
        // 0x66a8eE0cF1484188BDd9B0738C0236a1dB758A7d, // heart4lor
        // 0xDe564DC4c428034590c60cd4d2Ea01Fa793Fd53A, // QiaoRan
        // 0xEe722194580E26bFDF1cC5814E691378A5E168D4, // lvyao
        // 0xb53F3aF723AB1d8f5C3d69C6e7D670B59875039f, // tianrking
        // 0x0c4d3855a52ccea1604e4921d2212cc520e5822e, // evefree2
        // 0xd147e93efd250b469f9eb1c94fda0c59e02c97c1, // brucewzp
        // 0x8A1C15aCE2Bcf7e312aEE80685235E392Df33d28, // nellace
        // 0xd8c21296741528E68A546f8dbD492bE3433376d6, // why1gz
        // 0xE844b9Cd8A7dB9fC227839F83c479Ae1a2Cc02e8, // lopetver
        // 0x762a1f2dedf77a526322fa153c833c194a26c182, // zhaiblog
        // 0x7266A4911623eAaF280c688D68878ba765bCc06F, // qakam0z
        // 0x3D755F4f20245Efb435A3C70B743cF6F91A4EA83, // tty1
        // 0xA1a0524dE44d94d4F3Ca63987B2804940A8Dc711, // zhgg0
        // 0x7E3aEdaccA20a606cc76e2Bb50C33A1048c6F576, // iOran
        // 0xfCd642e0d94309d754F07316200b5b3aF68Fbac5, // sillyBoy
        // 0x9bD6609B203508Cd17438B1FeC0C47C98E543d7A, // wlh233
        // 0xDD5d477d75c96B9F41A5f4BCaA246940793ddab4, // Abirdcfly
        // 0x4b0dbc089d6fd1322947e8ac8f8153d46b70840d, // JRay
        // 0x666a12119ebc3B602BF9a81D60436a4d19eC641d, // stevezz
        // 0x4483147Bc1bFF9eF96EC9D661d972D86676C66bA, // stevezz
        // 0x47DdFb07E045B8b3476b2604910bD39622196A51, // myexcite
        // 0x8bcDB4F5cFe366cE99Cf5C125F3664863f143760, // bwael
        // 0xfF87Aa1A999efAC8eFB6cb5440C89b8c4ef14514, // eric1202
        // 0x4939ab84c163ac832b8ce359d29d57fa957591a9, // chromie
        // 0x12B09cA481eA952a341b9D3Da0D04D24b86D81A0, // anthow
        // 0x7B6F535fB4B0e5475A7c6D497FAa43218da3e3eC, // dangge
        // 0x74BC8110f24d2cF283f44B9d35A04EF7A141e1ce, // kosgug
        // 0x8cB01627083a6f7581f0ED9BD2146bd00dD1e37F, // hwb900501

        // 0x5771D9a67b5977C0F3f33B37f455c7F98D4f95e5, // Herry001
        // 0xDE5841eA4787A2e8ecF01416A9268d5410ce9B1B, // viosey
        // 0x6f44414ba630c1af14c8ac356bbaaa2347979782, // cclouds
        // 0x9460bF50aA12905D5C3272B1Abc7cD2fAe02b900, // utoyuri
        // 0x9c25eee753a70b07faebf37e6228f56b871b7d3b, // Jbys
        // 0x726eb97363ce2F163e16134c8Deb57C5a06c8c49, // Wolfsin
        // 0x2BA147ecAa038bD743e963B24ce2Bf435f3E760B, // oneFan
        // 0x8F29Fb2E755B3B0833BC603E3818603e9ba0d468, // cnfeat
        // 0x8aBA09586C26bd75Bb8BC09cD51adF7789CFBB1f, // EyreFree
        // 0x29706784d73f69d54D090642e3e8e14C25D16957, // Comdex
        // 0x9e9d212d02795cadcdf643162e08177c57622628, // gogogogogo
        // 0x41c15958A8b4789990A0102A252CD014AE755F13, // jiuyetongxue
        // 0x579FD9F605Da93177dE596E0579ECcCf3465c06a, // SingeeKing
        // 0x93de8Db6B83e0227A1ffb000f48c5F4E892C44Af, // oldgun
        // 0x79b83d21b5d793974f9f69e08b0b45609922f92a, // keller
        // 0x783F4f4200DE3294A0aC3AEB1b1F36ebffAA2120, // lylewong
        // 0x28C5cB5b3647540C2780FfCB0174F86B86DBFC18, // FanYiTao
        // 0x619F409aa4571e7E4F9E76Fdf7A26Ed32F6d5ed3, // ecnelises
        // 0xD2d4a1FD3dbc9F981D0Ef7495c3Ce611d0E5F57B, // myrobotech
        // 0xD1C34b0993a807588bb880dD15796eD2e08A8727, // lxiange
        // 0x11Cbb0a4fb22094e17F7Ce7BBa871D1dD591B391, // yesvods
        // 0x220248B52e5F677Cd6faDceCd7C420ca38e19e45, // qiutc
        // 0xcca077795144cf9fdd9b5fd90bd758755dd5cd12, // yhx5768
        // 0x699d8D31C6c66E0378990f0C850d54524C593dA1, // ghostinthewild
        // 0xd24b8c2ee7aa2329187b843b75c6f71dfdfa0d06, // tifosibest
        // 0x321083Ea87d3eCcE5955c799925D10f53A9aD861, // earther01
        // 0xd2f240b5f064b91cbfd8946ec44b0fe0b160bda7, // luruitao
        // 0x6cB93f9Fb72357A78016dE851ac21Dd5eB70d9c3, // ittianyu
        // 0x392faA7403134012cdc19421fD72aC7bB25536E5, // ittianyu
        // 0x39D53e186C656A09934afF5d6C5A26b5c9eaA6Ab, // ittianyu
        // 0x044Dc1C239C6870a8D12A9b85ba92a365fe3A9Ea, // ittianyu
        // 0xb14dc9964701ca8ffddc3d5de5dab8cbd4b19e5d, // y524032
        // 0x17cc8a8356a4e9176571eb38ed85a7b5a50236fb, // boboliu
        // 0x84fc6c88b8c1552458d228611d4f584d46694a47, // y524032
        // 0x023dFcc7b9c03DE053AcB7B2A319Bc8c3179B171, // liuxu
        // 0xde4d39d8b6bd5eaa2325b842779c28efdd442777, // kisnows
        // 0x4E24C18B29Db1213F27D3325B4756647C2B7A108, // Slengl
        // 0xac80e53bee8e8a5ab405e324c3365a345bff3402, // byenow
        // 0x43c08ad11e9662da63f6ef962bb1147a06be20ef, // fermiz
        // 0x4055d25202728E45CA30859273B5c4cD3A15187E, // cz21ok
        // 0x388f366c29a3dbf423b89b732e827e259b4e29a6, // deepzz
        // 0xe74cC6B81C068270A2fc1Ad094FfBE78096c95C7, // iThink
        // 0x8548F909d482B4f8Fd7F3bE6544a6894eB79F54A, // faywong8888
        // 0xffeb7D98DeD1684023faB3547Fb0762C3B5d4646, // xoxo419
        // 0x19634C40675fFF111a477867E2EA549564b1A5e3, // l404864087
        // 0xD9eD7c0725fC4947F7F3dEe7B56841e2e10d099d, // hugebug
        // 0x36Eb2ae9FB839a8a6566B3298F413CFe05B0E64E, // solove
        // 0xC78abf3b3a2B1f92f7361896C44466a3F0192bc6, // allotory
        // 0x2DE12E54A4B5d43210e0BDd90F305E3f3a9f0403, // mingyun
        // 0x39cae4D2d74cA4dB3D5754473359B488455FBf7d, // jnds
        // 0xC0cAf86F20d9312aDed19f75971c4e35cFbcd610, // coymail
        // 0xf5C090E690C9c79cA7f60d8D45E0B69B81Aa593b, // winterohhh
        // 0x93987d6B9451fE62dDB2C8ba278a1Da26d2C541e // lovepandac
    ];

    uint256 public forOwner = totalSupply - forGenesis * genesis.length;
    function HTRToken() public {
        //for gensis users, thank you all for your participation
        for (uint i = 0; i < genesis.length; i++) {
            balances[genesis[i]] = forGenesis;
        }

        //for owner Henter
        balances[msg.sender] = forOwner;
    }

    function thanksAllGenesisUsers() public view returns(address[]) {
        return genesis;
    }

    function airdropForGenesisUsers(address[] _addresses) public onlyOwner {
        require(balances[msg.sender] > forGenesis * _addresses.length);

        for (uint i = 0; i < _addresses.length; i++) {
            balances[_addresses[i]] = forGenesis;
            genesis.push(_addresses[i]);
        }
        balances[msg.sender] -= forGenesis * _addresses.length;
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowances[_owner][_spender];
    }

    function _transfer(address _from, address _to, uint _value) internal returns(bool) {
        require(_to != 0x0);
        require(balances[_from] >= _value);
        require(balances[_to] + _value > balances[_to]);
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns(bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        return _transfer(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public returns(bool) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
}