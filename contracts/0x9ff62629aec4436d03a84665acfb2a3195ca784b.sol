pragma solidity ^0.4.17;
 
 /* New ERC23 contract interface */
 
contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint48);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint48 _supply);

  function transfer(address to, uint48 value) returns (bool ok);
  function transfer(address to, uint48 value, bytes data) returns (bool ok);
  function transfer(address to, uint48 value, bytes data, string custom_fallback) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint48 value, bytes indexed data);
}


 /*
 * Contract that is working with ERC223 tokens
 */
 
 contract ContractReceiver {
     
    struct TKN {
        address sender;
        uint48 value;
        bytes data;
        bytes4 sig;
    }
    
    
    function tokenFallback(address _from, uint48 _value, bytes _data){
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);
      
      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}

 /**
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
 /* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
contract SafeMath {
    uint48 constant public MAX_UINT48 =
    0xFFFFFFFFFFFF;

    function safeAdd(uint48 x, uint48 y) constant internal returns (uint48 z) {
       require(x <= MAX_UINT48 - y);
        return x + y;
    }

    function safeSub(uint48 x, uint48 y) constant internal returns (uint48 z) {
        require(x > y);
        return x - y;
    }

    function safeMul(uint48 x, uint48 y) constant internal returns (uint48 z) {
        if (y == 0) return 0;
        require(x <= MAX_UINT48 / y);
        return x * y;
    }
}
 
            

contract ERC223Token is ERC223, SafeMath {

  mapping(address => uint48) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint48 public totalSupply;
  
  function ERC223Token()
     public {
        totalSupply = 25907002099;
        balances[0x535fC82388b0FF37248B5100803C3FA00FF076cB]=129350000;
        balances[0x329504f7Cf737d583AB6AC3Cabd725ec1bF329a4]=7636000;
        balances[0xCC7E72c949a71044D7f22294c7d9aB0524cCAFf7]=1;
        balances[0xd590955D43bfbe93A3c51b2d6BAFc886C24a4B87]=110;
        balances[0x6B6d0B5842c61153d89743040B19C760DDA647B5]=388300;
        balances[0xcb9D6ad63a4487D28545F9Bd3c9d2B2Cf374803b]=1054000;
        balances[0xb700402053ac42638C83B9a791f03F4c9bF16854]=330000;
        balances[0xFBb1b73C4f0BDa4f67dcA266ce6Ef42f520fBB98]=1484598;
        balances[0x04f04c5F2e735A223FDEFe94c94978F77c344FB8]=1100000;
        balances[0xB66844cD7EC75b91FE62aB5A0E306132485C9527]=179391;
        balances[0xC4CE380FcfaD899F9A7aCF8F13690dbE387FB8db]=1185800;
        balances[0xe02E96193e84FCc63F2D488a7c9448B43aD904A4]=1140700;
        balances[0xA2fE32aA95f9771F596089CC171dD10cA3d5761C]=44000;
        balances[0xd6484a997129938709fAb588Fd6F55B0A684ab56]=21890000;
        balances[0x9a6F14cEaD3521142E678fD0fEe294881449D889]=2204925;
        balances[0xb3ce93Ef88d0ea70cafc029b4238CBa3b704354d]=1519400;
        balances[0x7eD1E469fCb3EE19C0366D829e291451bE638E59]=304722;
        balances[0xAAb8805f5626760b612812b83D77F96671E222e2]=1492589;
        balances[0x7205d8e2Ff6012392Ac4C0c9fb5125F8Abb3ef6d]=1100000;
        balances[0xEC348184cA6C85d12cA822Dc01FAbEb1d199e996]=1100000;
        balances[0xA56F95FC14bC4D2953a819c20c0C7078a08ef7Aa]=6600000;
        balances[0x5aD299927508d786E469AadDf34EEDDD4aCd96A5]=880000;
        balances[0xF46DBA0c3Cce9d3b2Ce371952b72e7F66b62BE95]=1100000;
        balances[0xd5f3b11b2E20fa1B7018e93128BF6faf5bda2BD7]=4894374;
        balances[0x3b1a8135E0b445097c83F780F0B068F21cEAa7b4]=1052381;
        balances[0xF27Fef813A7D7E17f7907a6043c52971a0b0209f]=769780;
        balances[0xf3cAD07CB033F68A35e388527e55F1E804f8704a]=2088246;
        balances[0x5B1286d898eD28d8a7A59b224Fc4c252461e0b64]=384957;
        balances[0xBb265B80c2eFe6f071432FBA0B1527Ab5Ba9F91F]=319985;
        balances[0x259DF6B527FB06757dB3295862aC8dc292466435]=98550;
        balances[0xeb62ae01812773BF3C270221a9b511c86AaC1546]=296120;
        balances[0x51A7016D90B58855D89efFC70c94e9808cabE680]=106012;
        balances[0x919612F15F7734cD59008B2E21ba7bAC435bB8A8]=258912;
        balances[0xDD6be4514A348FB2d422d176dEC81B8666B143dd]=34942;
        balances[0xf0660eFb282102dB8B57EaF39F883833E8b62821]=679598;
        balances[0x267C817c2Ea39C31C7075A5548d5356bcf205eFD]=186215;
        balances[0x863aACEbF0030e26e14F9ff552b654171Ff6372F]=295686;
        balances[0x14A1C2F56b7953aA4A93700C346740b9A25150F8]=148344;
        balances[0xFc8425A1B01d1d74c2281Da2975cB77422d4CEA3]=2961211;
        balances[0x4FdB2ee1EbEb1886976FA9aDAaA42a1c090335aD]=1124099;
        balances[0x019BDC7F3DDF5aD4A5695e16ACfe02a4d32aEA5f]=116046;
        balances[0xE11692E90dE2A2c4F220Fb0597CFdd22D5eFAcF1]=17767;
        balances[0x6f06F186C8dd8D0cAd3835946A857aed261C5652]=20038512;
        balances[0x24F7a01Fa083F8DB8A5b4dd46Fb003F1fd1C47d5]=3378741;
        balances[0x92D8bfD2d2559a25a5D43e84f4430915e38B980F]=264302;
        balances[0x8785816569941D86DFAE7adFdd92C2f50d3a5Ad6]=397479;
        balances[0x7B2C6cB5bE1a99118ce38e373d58adF04d8e6719]=290277;
        balances[0xa50da0F0940A852927740470e1A0a6016e9a3B65]=79800;
        balances[0x9d2C3aA31Ffb61180214Ca87296A2f4F8DDA6472]=1029302;
        balances[0x93A1B766A75DaeCa4a05E08ee5d7781f3d6D72B1]=7279842;
        balances[0x96BD54Caefd00EeFe1e836677319B6631C0f67E0]=525000;
        balances[0x0072e4Fd215f7B992D0A19fAdC58DBfAC568CE4a]=1155000;
        balances[0xF9eE68058FA43a79834897793B7B34d0135b98BB]=11500;
        balances[0x2A9c9a5475A6E24A530ccf5527A045F4dBf3E78e]=1138500;
        balances[0x995C6B0d4F3cca7d0081f18d4b48faa135eA47b3]=38755;
        balances[0x679d24F2F5AAf0E7bB6dd49e45B41CCff0779564]=459493;
        balances[0x9235881033C4B57be38B1d28921451F90bd7744d]=114493;
        balances[0xDf61cA237F6E782df0E090f58c8534e8794bAE64]=271231;
        balances[0xEDdb1aBC1e37953F91ca6E3a11611Be79719fF5d]=46000;
        balances[0xdf15A49e50Fa9f2D71B922Ae325a5AFB381A31f1]=1150000;
        balances[0x269E20e3dA89481d6F0De3408c5448AE44a313B8]=250534;
        balances[0x8D1F338F8abd714fd09ec13C100A0d7dF693cd5D]=282900;
        balances[0xb703CE71557095b9566348928bBFD4a991456936]=207000;
        balances[0x3877d21b3f1ffDF602840366aDf2350b8E1F8210]=298492;
        balances[0x9A77E0910034A3B809687f8340b5BD2a184ED5bb]=345000;
        balances[0x8861fd090e71D72A7ca0Aa0B24dD5D664b52cF03]=1150000;
        balances[0x0098C71bCA3EBD977147928A4dA574fd138571AC]=465750;
        balances[0x7131f3FCc9177F1176378635efD30A9109cF3cdE]=1682450;
        balances[0x90FcD92B396CFD6951d8DdCd0Cdd2654436C2840]=1150000;
        balances[0x5Bd46d1744B2AAAd591B01D23786336bF7faC094]=2961897;
        balances[0x0C95959EB2056d86552baa4B859288C84D74a7e9]=3450000;
        balances[0x8755A5619E2D2FC56e263FcBE26116250941d477]=23407;
        balances[0xfDbe03a53aF5e4509AEBD9D148B41eEc34776B7c]=1137993;
        balances[0x72a63625144327FC6A58867699107934E7F0B609]=438399;
        balances[0x4EE354582a9Cc60Eb086CAEB514234c1EfE14D9F]=115000;
        balances[0xBF0A1d55528EEd2990F752A6bccd24dd772421f5]=1725000;
        balances[0x670226836D7Bf336bfd172086d682002a30D63e3]=1010850;
        balances[0xd8F83AF83B6334be21a166d203e84D9c4f6e33e0]=396243;
        balances[0xd175fb3b65eDC995DC9b2dAE705270448D8A5231]=328900;
        balances[0x86dE9262Aa13f1351C9009B6BC1B1a432C96f005]=274068;
        balances[0x08E004E3741052Fd00e49384088e2D6F81f97fd5]=1264492;
        balances[0xc1F81207791DDa997542625cb86CC0D8Af7dfAb4]=1138500;
        balances[0x913E5A823A614ad226c810e55154f3f385F647F0]=1150000;
        balances[0x7f4823876318faD7321FD813b7aBd4A7C60C12A5]=1150000;
        balances[0xcd9E6E0E63C5611ab1988e0569E3aD89b86086c6]=199299;
        balances[0xb1Dd23a37776c1d3E1F0c874d1F72589F3c59E44]=1138500;
        balances[0xfE2ceCCC914be290d49712d4715438268FC76359]=1150000;
        balances[0x3dd9cFE0D6eE68163aCd1EeB6De9f4D3A580839D]=505825;
        balances[0x9323D4704fB877CD090Ba715B11Da9A3eDFdA7Ef]=275000;
        balances[0x0c747c7EEdf05515425AdD4061911Ae9F039F4Df]=821160;
        balances[0x51a23f481037CA208086f42FE83D28B71c1EbC2c]=345000;
        balances[0x42E1Fb8EC1830DBe4e5Ed5Ce60Bd307D3AcBB5a1]=14950;
        balances[0x4fa531A7da9b0FA37cC60eb26eE7393B39c616B1]=945000;
        balances[0x9383D952e4aa5C33c86d11932877D1D523097702]=221958;
        balances[0xd5FECA4d252b298d7500c05766049210e2BD6C03]=600000;
        balances[0xf4e5DA75e054FE7373a8Db3B5aD4E2d35404b7F3]=1096;
        balances[0xA46BBC28cB381A6c383DAE0D3eAb39A78d9bd704]=342402;
        balances[0xc94AB3B27218b1E5C24Fdb7cE169EB8bD5a58060]=1922965;
        balances[0x7111B872B505992b2a61f5F3b7A31E6A589F9ba2]=2265500;
        balances[0x66D94665903a8c5A7e2E065e654610e4C0E3d510]=1155060;
        balances[0x180d932fbD59C12c180087085cDCDFa50f20C7DB]=1150000;
        balances[0x07ACDd672aB32251C38560F14bd3b325A3392a42]=8904900;
        balances[0x9b0Ae3d7A088101BbC027685B31020e88D776795]=101727;
        balances[0x9608D348627CcB2FEcd97ab2896DB2516dDCdD9F]=2000000;
        balances[0x82b9EedCAA518352BDb1aC80F5a214857f29a3fc]=260000;
        balances[0x26BD273Ad192046E4cE16f3c23f4D4A273176C6c]=400000;
        balances[0x3707D0B7EB1A3e70E2a892aAD4938be493b053Ef]=995000;
        balances[0x687Eab8387faFca0E894c7890571cb8885d06252]=100000;
        balances[0x29B41749C1b019624dB2Eca34852aAd1435E2FB2]=1150000;
        balances[0x985B1beC38e6402C9EE39b6f0c26518899026e4c]=1000000;
        balances[0x0674C588aB53256a0ef619CAfB459324Dc8Ea009]=1655620;
        balances[0x84A3A12B84C57E1Fe22fAB1CC3Ad40308cB53ecd]=3980559;
        balances[0x0B8a97a036bCc47707a11231362435e937f35536]=900000;
        balances[0x99DfCa33bAABC6812Ebe8C790EeD515D8B36B69E]=160000;
        balances[0xF85D5c4197caa5ec2fC97761b0D51A012F4BE84f]=11525;
        balances[0xbBb40eC9E24C6D387843dfEA84Baa5E8BD6Fd3e9]=2000000;
        balances[0x8df3185D971B5C657D0f2E9B53Dc0bBe5912F42e]=1000000;
        balances[0xa1ec5e1274A5FA126415453968c9929c3F91FEE7]=100000;
        balances[0x3607e4119Ef3E2a72E55D18B5feaA81c6140E85e]=200000;
        balances[0x26a74e056EB4E3607792DCd87070E468878d14E9]=70000;
        balances[0x517DB8116c84888Fa8013AB18B7E5F2f5e152508]=100000;
        balances[0x547376929E8A4abcC04c32268c43d4924f2Ac985]=1749903;
        balances[0xA6d8aD119eAC13Fe161BEff88be65FC9624C1340]=942438;
        balances[0xdb090dDaC7A159Eb6161c8591aED719d80875f37]=996417;
        balances[0x922D65456B8B1DeDC6F3EFcDB2981163144E96ee]=48300;
        balances[0x63235E4764A0072fE68Bdd32D1A16813E5fc9d49]=1457548;
        balances[0x68aD20aa347f5E719EF4476B25154B4d547a6275]=753951;
        balances[0x75393B6949157376f93C1e56220ACD5457323135]=1506758;
        balances[0x1796c3f4E9E877A79df5923bf8bE9aB925F7deD4]=200000;
        balances[0xF0ED57958dD75DBD20374D46F1547dED0D717b4b]=1000000;
        balances[0x1a2EB5ADf16aA5915AC70f6C530680945F5DAdF4]=132170;
        balances[0x5ec85d2f4891bB5034bE10BA9B3B0253cc394Cd9]=205299;
        balances[0x179278CB0659957675f9f3E7f949C3CcA283F153]=110000;
        balances[0xCA4bB096407E7c2b2c0E67D5173FD9BB8E452647]=100000;
        balances[0xdd8b17C94B097587108476bf1AC31Ce02cFa6c12]=181097;
        balances[0xA7b1a07AF73f52A9bcD22C6BF2122577bb4f7900]=130000;
        balances[0x38a6d1c82E8f3E04940FeA95E583Bdc24df964e4]=543404;
        balances[0x8A39dBa536919aB530E5b4dA9f4686A350eb2379]=1000000;
        balances[0x113b1501D2B6bf0f84D720Cec93928aD552749D2]=100000;
        balances[0xa028fAF0f1DC3176069F755AE643AbE13aA53E1b]=33596;
        balances[0x29D70Bb2FE698ae19cBD317fedaB4BcE3Cd3E85c]=490000;
        balances[0xb9aC6748E56a67D99F1869E701DedAB25A90cFC5]=100000;
        balances[0x90785Da382Cea9d3352D6ad8935816BADFFB3D73]=2167608;
        balances[0x8661C945bE98c81191BB4d6254bfe1B475AB86a5]=347154;
        balances[0x36bA740450a224E866b3C17B46C33CDB80a8e718]=2600365;
        balances[0x0DF2781a47a1fa23F3D73E79E089E5e178A72ba6]=67390;
        balances[0x1914D9FD18c6aC7cF2c2135be38E9D746aAa4743]=12095033;
        balances[0x2314401bDD5318A88A9a0c05FB07B800dae88ED8]=627865;
        balances[0x300bD3b89cBf26292bD58c99dB2851f14050a221]=345000;
        balances[0x23E2F1e5b874ac14039306804912aEb66713FCa2]=276181;
        balances[0xB365C8583B4fAc9C1352E3FFa2Bdb68C663C1A06]=78435;
        balances[0x0E9822f773e93d8C58255451f4f4Af78F5374353]=785839;
        balances[0xC006E4931AD1FD622B20bF66844C34676834A05f]=141365;
        balances[0x04a2209bB6fa3c8ae05A6133b27d628D18054853]=179713;
        balances[0x8bC1b34c9712Af6B891A12f9C6311b0D3B8CBfa8]=1280058;
        balances[0x38a548Ba2235245FD99c2116b9a1211AaD54B28D]=5014000;
        balances[0x55781922C48A3F51C38153365c795ca06383a177]=2415000;
        balances[0xB97559fe630EB888aEa2fBD6dB4a67909d7e5879]=407067;
        balances[0x83AB7422A347Ddb8957725F08a103107bb119328]=5510;
        balances[0x2D7dc7b96e9dFb393CFa466eAC6c494BDa28604a]=245000;
        balances[0xE804b632cd624Bd80a2a4DdBc9d0aD3984e54F93]=25000;
        balances[0x0CfB3a673d6E735c5b9E9a9A9Da032E960CD8CD4]=123049;
        balances[0x44344Dc9974706c34f53B92167275a34f4AB1EE8]=44753;
        balances[0x4C65118325dcd97E8724cd4E763703f7263f0DDF]=180000;
        balances[0x5Fc8f1D8B9Eeebf2Cf6a2eE5c20b3dEF6b2d10B5]=1044750;
        balances[0x0280EF5689728A8eD0eC93A49F700ea251eB64fB]=44275000;
        balances[0xc784a88c444cCB22eb744ffA3Dd37b78F9F29f9D]=187915;
        balances[0xCdc35eD04Cf4eeb74dD82eABe82cbB386Aa79D1c]=575000;
        balances[0xF53786FF94a25DB623A028B08B69aa875648986B]=10127000;
        balances[0x36621EA0B079CEDD13026e321BfC4924d55a6008]=8480114;
        balances[0xbE8a87EE71db2323515787Ae37A198cA898188Ae]=3453850;
        balances[0xB7237539824a984Cd095F6509E7D7bB710f3c6FA]=70000;
        balances[0x1b42dFB72B02fFB15F369C38F39E6753980B6a89]=51672;
        balances[0xb7FFb5174BF7382a1445C735166f49fdCa893884]=480386;
        balances[0x50DF172676De7d1769877fd1A4221F634bF9B9D7]=245000;
        balances[0x67E7e452a8671eFecb9284c483dE75C3fF1f02A9]=13168935;
        balances[0xBFa4d7beAcA87AaE890fe79C948Cc057B409156B]=38994;
        balances[0xD1c6ad2b3F196252629787D0CdCa69ED4d76a890]=111879;
        balances[0xBF6C51b740ee3dd7650aA9958a57A58caeaBF4d2]=1316666;
        balances[0x0056D18AEF3FF077826dd50c68cef9ddC84a6827]=108000;
        balances[0x4Bd6B497DE1a41bF4B29a4387DD4CD9030b583AA]=315392;
        balances[0xe38Bf41d25C21b411C406822f4eC682753E3a8b5]=6170363;
        balances[0x6EE0D8DE8829C0648B1f0682A04b89a13dD3Bb6d]=279361;
        balances[0x0e4d86cf3CbF43dBF588B9C7FF3cD29CE1a46e19]=101122;
        balances[0x1bD7DE6Ec470914663850bAa88E6a57B30E42e7C]=251945;
        balances[0x85478a6aD555Ef567B9ff2acdF0024DD643D16D6]=1990000;
        balances[0x1b84B3FD554d2338926D43A0cdd4D7aFD7d62E29]=10000000;
        balances[0x92844ad0530580F3ecc459f7B203a1853027bD01]=6900000;
        balances[0x2E87Eb67a51fD130Ab4d056f48c6256B201E2a96]=260792;
        balances[0x56D18AEf3Ff077826dD50c68cef9ddC84a6827ee]=6080000;
        balances[0x33c33E5F1C41477df3715575A8f0CC9E2330C3A8]=223228;
        balances[0x5765725f2a0e30DABcFc838701Ed01CaaB0564e8]=354161;
        balances[0x058dfCDB62C93a5f78e8C5D162911f46269aDB4c]=2500000;
        balances[0x826f679FBDCAC418352737dDf57dbddDE37C3603]=16100;
        balances[0xAFfb92c9bf7Fe534a38E29428a89dfFf91F06362]=65676;
        balances[0xd8A3B9456cB819f19Cf230bB5b31f1d88f6A128F]=140000;
        balances[0x47c0f4ADe7C8A071EA98DB4739F1fdEfFcb89bE0]=10350200;
        balances[0x3271bB92A304503Cb09a58e9f822DFD9C5187095]=279361;
        balances[0x5D4545ab1016039F2CA7f6038d2044069e4EF6a0]=5000000;
        balances[0x4F18A7fE4e3476191098453F973d93c120a5046b]=94817;
        balances[0x9157C680585718ffdb621031cC93b6EcC4cA763C]=320499;
        balances[0xF6eBf541d7cfBC0cB3ACeF0b2aeF70992db5abE4]=3720;
        balances[0x18556A2F95d86F4681420c97a2b3EcE70b07F54C]=29763;
        balances[0xA6189D516d88857583Af24A500Ae47E5326b2aBf]=529049;
        balances[0x211af5659bCec2cf14AcF7Ef3069C8be9c318D3C]=416667;
        balances[0xFbD1Db8B6F9B0c3f47a9f731200CA85725aADdD2]=124271;
        balances[0xB469C927e1a8485d8ae2F6e16b1654167Bb185D6]=416667;
        balances[0x8C00526818eeCA6b4BdA0fD534b8f1d53c78E200]=200000;
        balances[0x007aDfB8C0Fa143E9c0d4260172D88A3ef38F6e9]=365198;
        balances[0x6856f0FF9619bD151bD4E34cF8a9B613d3A0d161]=731882;
        balances[0x1C0576530BBB246d834F847b8EB634377CCC5eD2]=700065;
        balances[0x5106B0860475CdF3F74D1B3fdfc5619eE2C51Aa5]=141377;
        balances[0xc076c1C52BfDBb15507102AaDA4473a039963F4f]=25000000;
        balances[0x93970080A078980B8B121A556A60f3a114FB9169]=706889;
        balances[0x9FfDca13b7ea0ddE97Dce2a286E453518eF34C00]=744093;
        balances[0x65c6D15C2772B42c745c980dbcB5FB0f74974385]=26043;
        balances[0x961E7e3558F31C647fc4D39B0aC2544E786cCd3f]=333668;
        balances[0xA07b23625BD37378f24023bc7B55eB501F3cC4Ed]=96732;
        balances[0x73F15eBEBDe578024A60A4cDf626689efF2B9065]=372046;
        balances[0x9865F77f5A21595329f05A9D8a47F6Da966E0b38]=23029;
        balances[0x65c6f7A45A005CCC1979599473aA79Ca73D6efb0]=57317;
        balances[0xa0D2F4B648beAff668dDBa8e748Ac135c4c49F84]=369639;
        balances[0x9f8EdE9F051f946788211549b70CfEF5c81B447B]=1000000;
        balances[0xAbe5CCb78502727c8CF17CfA79b218e889DD62bB]=102004;
        balances[0xE6ba478c352DE046aa3D9279A61A43850F3a609c]=101008;
        balances[0xd889C102e974ef2bA128D3caa60C463A3ae8F989]=163700;
        balances[0x803CbCF07c4cFA1874dad6BCeD796aB5320b3d89]=4500;
        balances[0xe8621096d55C7B970bF88cc4e597f29dA4b55218]=170455;
        balances[0x4347da950003a9C0E477eC625CD1b57620B762DE]=1150000;
        balances[0x8Cf2Bef55EA9a7908029853CF6289356f24e332B]=210833;
        balances[0xC6B24D95E69D9F74eA90C419F4B4F71e6433b2EE]=13761;
        balances[0x9B1f1962b65deAA7c1C495a36767f48019f24205]=57500;
        balances[0x976d00C6aaf3E49E2615665D81B70080933D8623]=516488;
        balances[0xafCe1E95eB00824B0368E2574c81ea04252D09aA]=86071;
        balances[0x60995c4c4b7B9EA3D6dE08a7bf8AAf1188aF943B]=27523;
        balances[0xc50c9457a5b0849999e2b89db8dDeA23436f3c46]=61345;
        balances[0x042a3E1aB9eB9Aa7B06c63eaAfb99F0EEE37c9aC]=42000;
        balances[0x52437Ce5c02de9B0A5D933E6902a9509f33353B4]=86071;
        balances[0x6FBb288E14a37a94f69c18a0eD24FaC1145b9900]=522827500;
        balances[0x33C8d18e9b46872CeBb31384bFBEc53Cb32Ccf12]=24876206872;
        name = "GameCoin";
        symbol = "GMC";
        decimals = 2;
    }


  // Function to access name of token .
  function name() constant returns (string _name) {
      return name;
  }
  // Function to access symbol of token .
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  // Function to access decimals of token .
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  // Function to access total supply of tokens .
  function totalSupply() constant returns (uint48 _totalSupply) {
      return totalSupply;
  }
  
  
  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint48 _value, bytes _data, string _custom_fallback) returns (bool success) {
      
    if(isContract(_to)) {
        require(balanceOf(msg.sender) >= _value);
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint48 _value, bytes _data) returns (bool success) {
      
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}
  
  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address _to, uint48 _value) returns (bool success) {
      
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint48 _value, bytes _data) private returns (bool success) {
    require(balanceOf(msg.sender) >= _value);
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint48 _value, bytes _data) private returns (bool success) {
    require(balanceOf(msg.sender) >= _value);
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
}


  function balanceOf(address _owner) constant returns (uint48 balance) {
    return balances[_owner];
  }
}