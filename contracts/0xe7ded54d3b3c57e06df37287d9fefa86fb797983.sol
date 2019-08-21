pragma solidity ^0.4.24;

contract Ownable {}
contract AddressesFilterFeature is Ownable {}
contract ERC20Basic {}
contract BasicToken is ERC20Basic {}
contract ERC20 {}
contract StandardToken is ERC20, BasicToken {}
contract MintableToken is AddressesFilterFeature, StandardToken {}

contract Token is MintableToken {
  function mint(address, uint256) public returns (bool);
}

contract FifthBountyWPTpayoutPart01 {
  //storage
  address public owner;
  Token public company_token;
  address[] public addressOfBountyMembers;
  mapping(address => uint256) bountyMembersAmounts;
  uint currentBatch;
  uint addrPerStep;

  //modifiers
  modifier onlyOwner
  {
    require(owner == msg.sender);
    _;
  }
  
  
  //Events
  event Transfer(address indexed to, uint indexed value);
  event OwnerChanged(address indexed owner);


  //constructor
  constructor (Token _company_token) public {
    owner = msg.sender;
    company_token = _company_token;
    currentBatch = 0;
    addrPerStep = 25;
    setBountyAddresses();
    setBountyAmounts();
  }


  /// @dev Fallback function: don't accept ETH
  function()
    public
    payable
  {
    revert();
  }

  function setCountPerStep(uint _newValue) public onlyOwner {
	addrPerStep = _newValue;
  }

  function setOwner(address _owner) 
    public 
    onlyOwner 
  {
    require(_owner != 0);
    
    owner = _owner;
    emit OwnerChanged(owner);
  }

  
  
  function makePayout() public onlyOwner {
    uint startIndex = currentBatch * addrPerStep;
    uint endIndex = (currentBatch + 1 ) * addrPerStep;
    for (uint i = startIndex; (i < endIndex && i < addressOfBountyMembers.length); i++)
    {
      company_token.mint(addressOfBountyMembers[i], bountyMembersAmounts[addressOfBountyMembers[i]]);
    }
    currentBatch++;
  }

  function setBountyAddresses() internal {
    addressOfBountyMembers.push(0xfd5f3f3ad276e48D3728C72C26727c177D1aA09b);
    addressOfBountyMembers.push(0xFD4a4Ea486c8294E89207Ecf4cf21a3886de37e1);
    addressOfBountyMembers.push(0xFc7a64183f49f71A1D604496E62c08f20aF5b5d6);
    addressOfBountyMembers.push(0xfbd40d775c29c36f56f7c340891c1484fd4b9944);
    addressOfBountyMembers.push(0xfb86Ef5E076e37f723A2e65a0113BC66e7dA5e12);
    addressOfBountyMembers.push(0xf9c4292AE2944452c7F56e8bb4fB63ddF830f034);
    addressOfBountyMembers.push(0xF7e0AeE36D0170AB5f66e5d76515ae4B147c64dd);
    addressOfBountyMembers.push(0xF7De64DeC2e3c8CEF47836A2FB904bE979139D8a);
    addressOfBountyMembers.push(0xf72736881fb6bbafbbceb9cdc3ecd600fdb0a7a1);
    addressOfBountyMembers.push(0xf6583Aab5d48903F6308157155c11ed087831C57);
    addressOfBountyMembers.push(0xF62c52F593eF801594d7280b9f31F5127d57d682);
    addressOfBountyMembers.push(0xF6168297046Ca6fa514834c30168e63A47256AF4);
    addressOfBountyMembers.push(0xf5FA944b459b308B01f7ce2D350Dcc1F522d5a7c);
    addressOfBountyMembers.push(0xf551395d6bBA0b984C3d91F476E32558c88Ba3a7);
    addressOfBountyMembers.push(0xf53430F1cc2F899D29eAe1bC2E52b4192c0Ea4de);
    addressOfBountyMembers.push(0xf431662d1Cd14c96b80eaaB5aF242fC1be7E4b62);
    addressOfBountyMembers.push(0xF37955134Dda37eaC7380f5eb42bce10796bD224);
    addressOfBountyMembers.push(0xF360ABbDEA1283d342AD9CB3770e10597217d4b2);
    addressOfBountyMembers.push(0xf24eC0497d02eb793A946e3fa51297FA1Aec329f);
    addressOfBountyMembers.push(0xf2418654Dd2e239EcBCF00aA2BC18aD8AF9bad52);
    addressOfBountyMembers.push(0xf13f88cC201bffc81DC9a280790Ad567d99ff6FD);
    addressOfBountyMembers.push(0xf117a07F02Da56696E8875F63b2c3BF906df0EEE);
    addressOfBountyMembers.push(0xF0E7E4BD129d30440A695333A32DA777a7D948b9);
    addressOfBountyMembers.push(0xF0d708b4A342A2F18e513BF8145A0c1454bc2108);
    addressOfBountyMembers.push(0xf0593428298Db8F92818DF6F4FEEB639d84D6C9E);
    addressOfBountyMembers.push(0xf04E88adbc5BC328135Fc20038b962b0201FFB27);
    addressOfBountyMembers.push(0xeEf3DE554EF8DCf34b4DF193572EEA6D75622b21);
    addressOfBountyMembers.push(0xEd6E237B32e15d27A4FBF6502099F765F18353f9);
    addressOfBountyMembers.push(0xEd55F63701b023696Ac92bE695Ef1421a7095D9A);
    addressOfBountyMembers.push(0xecB40E29C0Ce2108305890BBdD6082D47a9Ddb5F);
    addressOfBountyMembers.push(0xEB057C509CF30cc45b0f52c8e507Ac3Cf8E78777);
    addressOfBountyMembers.push(0xe8B400c93B829d2B46d2fe8B730412373a4822Bf);
    addressOfBountyMembers.push(0xe8a718296Edcd56132A2de6045965dDDA8f7176B);
    addressOfBountyMembers.push(0xE798b74f193A942a6d5dFAC9dD3816ee45B434BC);
    addressOfBountyMembers.push(0xe7195DEc1D02cDC2180feaD59bC8E61cab343E13);
    addressOfBountyMembers.push(0xE6F9b6bB035e3F982a484091496cF7B43ea0e7De);
    addressOfBountyMembers.push(0xe64643E2f0340c9e7C2E01fdb99667f6f55200DA);
    addressOfBountyMembers.push(0xe60A9ab929514848d5100a67677BebA09b9E0dA7);
    addressOfBountyMembers.push(0xe54AbAADd0FDbF41cC1EB7da616AdAB517b372d1);
    addressOfBountyMembers.push(0xe53Dc4cb2209C244eb6C62Cf1F9901359233f690);
    addressOfBountyMembers.push(0xe47bd26318de067366eeda3ce62a475829907d40);
    addressOfBountyMembers.push(0xE27C464Cec75CEeFD49485ed77C177D5e225362a);
    addressOfBountyMembers.push(0xe0293D2cFa95C5362F678F347e09a59FB6fa802c);
    addressOfBountyMembers.push(0xdd8804E408a21dc344e2A480DD207dEa38F325Ce);
    addressOfBountyMembers.push(0xdC935D60137AA8Dfd513Ad790217cD5faDF9101a);
    addressOfBountyMembers.push(0xda76c50E43912fB5A764b966915c270B9a637487);
    addressOfBountyMembers.push(0xD93b45FfBF6Dc05A588f97230cd7F52595888308);
    addressOfBountyMembers.push(0xd92bed42045a01e2fe1ab91751e0d3aa615642cf);
    addressOfBountyMembers.push(0xD902cCb411E6B576Ed567159e8e32e0dd7902488);
    addressOfBountyMembers.push(0xd8A321513f1fdf6EE58f599159f3C2ea80349243);
    addressOfBountyMembers.push(0xD86BaD70373083e842faa85Bc0ed9812fEDc8875);
    addressOfBountyMembers.push(0xD6DD581efeabff08bfaf6abF4A621e5263b93794);
    addressOfBountyMembers.push(0xd5ccf1c632d7448cd9335cf78F2448e23b0003bF);
    addressOfBountyMembers.push(0xd568cA92ee7fF3AbEef1E32ca31931843bed4758);
    addressOfBountyMembers.push(0xD4709f13192EC20D65883981F52CFe0543756E19);
    addressOfBountyMembers.push(0xD3e7C204D9Fa3A6E195c3B1216a77BB60923f945);
    addressOfBountyMembers.push(0xd3dE61685BAa88Ed9b9dd6d96d1Ac4E6209669D5);
    addressOfBountyMembers.push(0xD384FF0dC552e89a9729974AB1CcA3d580DBA30f);
    addressOfBountyMembers.push(0xd193466c05aae45f1C341447e8ee95BdBEa8297e);
    addressOfBountyMembers.push(0xd0000Ec17F5A68ee862b5673Fe32C39C600A138E);
    addressOfBountyMembers.push(0xCF62a5497A642ab55E139ca05CBbC67076b51685);
    addressOfBountyMembers.push(0xCe091A4D706c333bC6651B20A3Cae1686890CdE8);
    addressOfBountyMembers.push(0xcCFA388A36C36a8Bd4ad504236dDa9A3536583aB);
    addressOfBountyMembers.push(0xCcD74647cD44758d892D607FAeA791460A239039);
    addressOfBountyMembers.push(0xcc023e9f32b4CbED3d57aa53C706cd9c692AB8cd);
    addressOfBountyMembers.push(0xcb74E4cc30fdEbBE93E30410989C2e053cbC5dF9);
    addressOfBountyMembers.push(0xC9214510BE987d18A53ea329Bc6E1f4310097E99);
    addressOfBountyMembers.push(0xc8200a3e8576E5f779E845D7e168FD2463b7CeD1);
    addressOfBountyMembers.push(0xc6934E0Cc0e6c97F7Fadb37A6428C84CF8dfA3BD);
    addressOfBountyMembers.push(0xC68AD4fdbb11891e1E3C28c24dED3fC2D3724669);
    addressOfBountyMembers.push(0xC64C17A136f9faa600a111ad10f59Cb6574f4396);
    addressOfBountyMembers.push(0xc6375c620dF0b0D20B92f6652460fbDacAb5Ad28);
    addressOfBountyMembers.push(0xc604563839f0e5D890FFc3BbfDBa6062d8D3b58D);
    addressOfBountyMembers.push(0xC4f8e336911da71Fb49bF754F27A4D1bCceA0BB0);
    addressOfBountyMembers.push(0xC4acD6308Fab3077d19FE4457191A15E44d131e3);
    addressOfBountyMembers.push(0xc44F60af8Bf4F4F4c13C1Ba3e12F637956c69935);
    addressOfBountyMembers.push(0xc3C2bB09D094579dCFe705971f8Fbf164A6523B5);
    addressOfBountyMembers.push(0xc2C6869Ff474C656a56e7E0ed9dCfE6BEB6999A3);
    addressOfBountyMembers.push(0xC18f70cf0fE4d22C3725159b899DF987846D1AA7);
    addressOfBountyMembers.push(0xbFeEB695Eda630CA27534ecFbe7B915F500378C2);
    addressOfBountyMembers.push(0xBF98422620fB97C5DB514F2eE2c33765C226E8eC);
    addressOfBountyMembers.push(0xbF81C43910e09C9A5339B2C15C59A7844DE36eAa);
    addressOfBountyMembers.push(0xBF2bf97b7fBD319c849D4cB6540fA9974b7c578e);
    addressOfBountyMembers.push(0xbF1FdaC65b7D366b6Cb9BDE7d9ebf338A11D5EA0);
    addressOfBountyMembers.push(0xBF1593D47c094efc32e39BBA951dE5B9902eEaA5);
    addressOfBountyMembers.push(0xbeD4AD5d3dAF23a4567fedD66174849ba9Ee374d);
    addressOfBountyMembers.push(0xBEd0868BE655d244292A2945f6c1C82af97628dD);
    addressOfBountyMembers.push(0xbea37D67eF2979942fcd5e8715892F98901427ba);
    addressOfBountyMembers.push(0xBE96BACe8f6fa27a1441902E805CF5B026F7ea7d);
    addressOfBountyMembers.push(0xBD46eAccfF870A03CC541b13af90157feFd77243);
    addressOfBountyMembers.push(0xBC5a08fd609fBEaeF15DC36860052B01fE889Def);
    addressOfBountyMembers.push(0xbb04b1fff91E930F18675759ffE650cff9B15605);
    addressOfBountyMembers.push(0xb9ae7Be5d750A85AfedDc2732EBe88540c5BF9F3);
    addressOfBountyMembers.push(0xb94229396B9166ED549a080c3103c36D2bCA63e1);
    addressOfBountyMembers.push(0xb929d51980d4018b7b3fF84BEE63fAf8B3eABce6);
    addressOfBountyMembers.push(0xB73F5d6fED57ef3b6A624c918882010B38d6FeF5);
    addressOfBountyMembers.push(0xB632265DEFd4e8B84Bf4fD78DACbc6c26DF3314e);
    addressOfBountyMembers.push(0xb4Bfc94095dCcD357680eDCc0144768B2E98BAd2);
    addressOfBountyMembers.push(0xb465Df34B5B13a52F696236e836922Aee4B358E9);
    addressOfBountyMembers.push(0xb1887D27105647d2860DFc19A587007359278604);
  }

  function setBountyAmounts() internal { 
    bountyMembersAmounts[0xfd5f3f3ad276e48D3728C72C26727c177D1aA09b] =   116000000000000000000;
    bountyMembersAmounts[0xFD4a4Ea486c8294E89207Ecf4cf21a3886de37e1] =  3100000000000000000000;
    bountyMembersAmounts[0xFc7a64183f49f71A1D604496E62c08f20aF5b5d6] =   130000000000000000000;
    bountyMembersAmounts[0xfbd40d775c29c36f56f7c340891c1484fd4b9944] =   123000000000000000000;
    bountyMembersAmounts[0xfb86Ef5E076e37f723A2e65a0113BC66e7dA5e12] =   128000000000000000000;
    bountyMembersAmounts[0xf9c4292AE2944452c7F56e8bb4fB63ddF830f034] =   115000000000000000000;
    bountyMembersAmounts[0xF7e0AeE36D0170AB5f66e5d76515ae4B147c64dd] =   164000000000000000000;
    bountyMembersAmounts[0xF7De64DeC2e3c8CEF47836A2FB904bE979139D8a] =   101000000000000000000;
    bountyMembersAmounts[0xf72736881fb6bbafbbceb9cdc3ecd600fdb0a7a1] =   100000000000000000000;
    bountyMembersAmounts[0xf6583Aab5d48903F6308157155c11ed087831C57] =   104000000000000000000;
    bountyMembersAmounts[0xF62c52F593eF801594d7280b9f31F5127d57d682] =   243000000000000000000;
    bountyMembersAmounts[0xF6168297046Ca6fa514834c30168e63A47256AF4] =   160000000000000000000;
    bountyMembersAmounts[0xf5FA944b459b308B01f7ce2D350Dcc1F522d5a7c] =   159000000000000000000;
    bountyMembersAmounts[0xf551395d6bBA0b984C3d91F476E32558c88Ba3a7] =   972000000000000000000;
    bountyMembersAmounts[0xf53430F1cc2F899D29eAe1bC2E52b4192c0Ea4de] =   114000000000000000000;
    bountyMembersAmounts[0xf431662d1Cd14c96b80eaaB5aF242fC1be7E4b62] =   104000000000000000000;
    bountyMembersAmounts[0xF37955134Dda37eaC7380f5eb42bce10796bD224] =   100000000000000000000;
    bountyMembersAmounts[0xF360ABbDEA1283d342AD9CB3770e10597217d4b2] =   371000000000000000000;
    bountyMembersAmounts[0xf24eC0497d02eb793A946e3fa51297FA1Aec329f] =   101000000000000000000;
    bountyMembersAmounts[0xf2418654Dd2e239EcBCF00aA2BC18aD8AF9bad52] =  2000000000000000000000;
    bountyMembersAmounts[0xf13f88cC201bffc81DC9a280790Ad567d99ff6FD] =   120000000000000000000;
    bountyMembersAmounts[0xf117a07F02Da56696E8875F63b2c3BF906df0EEE] =   217000000000000000000;
    bountyMembersAmounts[0xF0E7E4BD129d30440A695333A32DA777a7D948b9] =   200000000000000000000;
    bountyMembersAmounts[0xF0d708b4A342A2F18e513BF8145A0c1454bc2108] =  1712000000000000000000;
    bountyMembersAmounts[0xf0593428298Db8F92818DF6F4FEEB639d84D6C9E] =   217000000000000000000;
    bountyMembersAmounts[0xf04E88adbc5BC328135Fc20038b962b0201FFB27] =   102000000000000000000;
    bountyMembersAmounts[0xeEf3DE554EF8DCf34b4DF193572EEA6D75622b21] =   154000000000000000000;
    bountyMembersAmounts[0xEd6E237B32e15d27A4FBF6502099F765F18353f9] =   216000000000000000000;
    bountyMembersAmounts[0xEd55F63701b023696Ac92bE695Ef1421a7095D9A] =   102000000000000000000;
    bountyMembersAmounts[0xecB40E29C0Ce2108305890BBdD6082D47a9Ddb5F] =   115000000000000000000;
    bountyMembersAmounts[0xEB057C509CF30cc45b0f52c8e507Ac3Cf8E78777] =   102000000000000000000;
    bountyMembersAmounts[0xe8B400c93B829d2B46d2fe8B730412373a4822Bf] =   157000000000000000000;
    bountyMembersAmounts[0xe8a718296Edcd56132A2de6045965dDDA8f7176B] =   100000000000000000000;
    bountyMembersAmounts[0xE798b74f193A942a6d5dFAC9dD3816ee45B434BC] =   140000000000000000000;
    bountyMembersAmounts[0xe7195DEc1D02cDC2180feaD59bC8E61cab343E13] =   121000000000000000000;
    bountyMembersAmounts[0xE6F9b6bB035e3F982a484091496cF7B43ea0e7De] =   199000000000000000000;
    bountyMembersAmounts[0xe64643E2f0340c9e7C2E01fdb99667f6f55200DA] =   245000000000000000000;
    bountyMembersAmounts[0xe60A9ab929514848d5100a67677BebA09b9E0dA7] =   229000000000000000000;
    bountyMembersAmounts[0xe54AbAADd0FDbF41cC1EB7da616AdAB517b372d1] =   116000000000000000000;
    bountyMembersAmounts[0xe53Dc4cb2209C244eb6C62Cf1F9901359233f690] =   182000000000000000000;
    bountyMembersAmounts[0xe47bd26318de067366eeda3ce62a475829907d40] =   105000000000000000000;
    bountyMembersAmounts[0xE27C464Cec75CEeFD49485ed77C177D5e225362a] =   618000000000000000000;
    bountyMembersAmounts[0xe0293D2cFa95C5362F678F347e09a59FB6fa802c] =   187000000000000000000;
    bountyMembersAmounts[0xdd8804E408a21dc344e2A480DD207dEa38F325Ce] =   124000000000000000000;
    bountyMembersAmounts[0xdC935D60137AA8Dfd513Ad790217cD5faDF9101a] =   143000000000000000000;
    bountyMembersAmounts[0xda76c50E43912fB5A764b966915c270B9a637487] =   124000000000000000000;
    bountyMembersAmounts[0xD93b45FfBF6Dc05A588f97230cd7F52595888308] =   180000000000000000000;
    bountyMembersAmounts[0xd92bed42045a01e2fe1ab91751e0d3aa615642cf] =   100000000000000000000;
    bountyMembersAmounts[0xD902cCb411E6B576Ed567159e8e32e0dd7902488] =   113000000000000000000;
    bountyMembersAmounts[0xd8A321513f1fdf6EE58f599159f3C2ea80349243] =   107000000000000000000;
    bountyMembersAmounts[0xD86BaD70373083e842faa85Bc0ed9812fEDc8875] =   122000000000000000000;
    bountyMembersAmounts[0xD6DD581efeabff08bfaf6abF4A621e5263b93794] =   110000000000000000000;
    bountyMembersAmounts[0xd5ccf1c632d7448cd9335cf78F2448e23b0003bF] =   126000000000000000000;
    bountyMembersAmounts[0xd568cA92ee7fF3AbEef1E32ca31931843bed4758] =   140000000000000000000;
    bountyMembersAmounts[0xD4709f13192EC20D65883981F52CFe0543756E19] =   103000000000000000000;
    bountyMembersAmounts[0xD3e7C204D9Fa3A6E195c3B1216a77BB60923f945] =   275000000000000000000;
    bountyMembersAmounts[0xd3dE61685BAa88Ed9b9dd6d96d1Ac4E6209669D5] =   178000000000000000000;
    bountyMembersAmounts[0xD384FF0dC552e89a9729974AB1CcA3d580DBA30f] =   230000000000000000000;
    bountyMembersAmounts[0xd193466c05aae45f1C341447e8ee95BdBEa8297e] =   102000000000000000000;
    bountyMembersAmounts[0xd0000Ec17F5A68ee862b5673Fe32C39C600A138E] =   100000000000000000000;
    bountyMembersAmounts[0xCF62a5497A642ab55E139ca05CBbC67076b51685] =   128000000000000000000;
    bountyMembersAmounts[0xCe091A4D706c333bC6651B20A3Cae1686890CdE8] =   151000000000000000000;
    bountyMembersAmounts[0xcCFA388A36C36a8Bd4ad504236dDa9A3536583aB] =   198000000000000000000;
    bountyMembersAmounts[0xCcD74647cD44758d892D607FAeA791460A239039] =   536000000000000000000;
    bountyMembersAmounts[0xcc023e9f32b4CbED3d57aa53C706cd9c692AB8cd] =   246000000000000000000;
    bountyMembersAmounts[0xcb74E4cc30fdEbBE93E30410989C2e053cbC5dF9] =   150000000000000000000;
    bountyMembersAmounts[0xC9214510BE987d18A53ea329Bc6E1f4310097E99] =   112000000000000000000;
    bountyMembersAmounts[0xc8200a3e8576E5f779E845D7e168FD2463b7CeD1] =   104000000000000000000;
    bountyMembersAmounts[0xc6934E0Cc0e6c97F7Fadb37A6428C84CF8dfA3BD] =   193000000000000000000;
    bountyMembersAmounts[0xC68AD4fdbb11891e1E3C28c24dED3fC2D3724669] =   194000000000000000000;
    bountyMembersAmounts[0xC64C17A136f9faa600a111ad10f59Cb6574f4396] =   144000000000000000000;
    bountyMembersAmounts[0xc6375c620dF0b0D20B92f6652460fbDacAb5Ad28] =   130000000000000000000;
    bountyMembersAmounts[0xc604563839f0e5D890FFc3BbfDBa6062d8D3b58D] =   156000000000000000000;
    bountyMembersAmounts[0xC4f8e336911da71Fb49bF754F27A4D1bCceA0BB0] =   444000000000000000000;
    bountyMembersAmounts[0xC4acD6308Fab3077d19FE4457191A15E44d131e3] =   195000000000000000000;
    bountyMembersAmounts[0xc44F60af8Bf4F4F4c13C1Ba3e12F637956c69935] =   102000000000000000000;
    bountyMembersAmounts[0xc3C2bB09D094579dCFe705971f8Fbf164A6523B5] =   103000000000000000000;
    bountyMembersAmounts[0xc2C6869Ff474C656a56e7E0ed9dCfE6BEB6999A3] =   110000000000000000000;
    bountyMembersAmounts[0xC18f70cf0fE4d22C3725159b899DF987846D1AA7] =   104000000000000000000;
    bountyMembersAmounts[0xbFeEB695Eda630CA27534ecFbe7B915F500378C2] =   128000000000000000000;
    bountyMembersAmounts[0xBF98422620fB97C5DB514F2eE2c33765C226E8eC] =   103000000000000000000;
    bountyMembersAmounts[0xbF81C43910e09C9A5339B2C15C59A7844DE36eAa] =   152000000000000000000;
    bountyMembersAmounts[0xBF2bf97b7fBD319c849D4cB6540fA9974b7c578e] =  1118000000000000000000;
    bountyMembersAmounts[0xbF1FdaC65b7D366b6Cb9BDE7d9ebf338A11D5EA0] =   112000000000000000000;
    bountyMembersAmounts[0xBF1593D47c094efc32e39BBA951dE5B9902eEaA5] =   362000000000000000000;
    bountyMembersAmounts[0xbeD4AD5d3dAF23a4567fedD66174849ba9Ee374d] =   103000000000000000000;
    bountyMembersAmounts[0xBEd0868BE655d244292A2945f6c1C82af97628dD] =   122000000000000000000;
    bountyMembersAmounts[0xbea37D67eF2979942fcd5e8715892F98901427ba] =   110000000000000000000;
    bountyMembersAmounts[0xBE96BACe8f6fa27a1441902E805CF5B026F7ea7d] =   171000000000000000000;
    bountyMembersAmounts[0xBD46eAccfF870A03CC541b13af90157feFd77243] =   100000000000000000000;
    bountyMembersAmounts[0xBC5a08fd609fBEaeF15DC36860052B01fE889Def] =   124000000000000000000;
    bountyMembersAmounts[0xbb04b1fff91E930F18675759ffE650cff9B15605] =   700000000000000000000;
    bountyMembersAmounts[0xb9ae7Be5d750A85AfedDc2732EBe88540c5BF9F3] =   228000000000000000000;
    bountyMembersAmounts[0xb94229396B9166ED549a080c3103c36D2bCA63e1] =   114000000000000000000;
    bountyMembersAmounts[0xb929d51980d4018b7b3fF84BEE63fAf8B3eABce6] =   120000000000000000000;
    bountyMembersAmounts[0xB73F5d6fED57ef3b6A624c918882010B38d6FeF5] =   115000000000000000000;
    bountyMembersAmounts[0xB632265DEFd4e8B84Bf4fD78DACbc6c26DF3314e] =   110000000000000000000;
    bountyMembersAmounts[0xb4Bfc94095dCcD357680eDCc0144768B2E98BAd2] =   101000000000000000000;
    bountyMembersAmounts[0xb465Df34B5B13a52F696236e836922Aee4B358E9] =   105000000000000000000;
    bountyMembersAmounts[0xb1887D27105647d2860DFc19A587007359278604] =   182000000000000000000;
  } 
}