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

contract FifthBountyWPTpayoutPart03 {
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
    addressOfBountyMembers.push(0x6A5CdFa535005CcEC5AeDf71a96a7b8fb66902fD);
    addressOfBountyMembers.push(0x686Bb20c8825b166FaDA080A92dC29DA518994B3);
    addressOfBountyMembers.push(0x675758B664cEFdfAf0f7438d2ac2B85D65bd7724);
    addressOfBountyMembers.push(0x64b4764c0D40c7654C75756c3A441202d4504BD9);
    addressOfBountyMembers.push(0x6371a1CbC462124CdA569f3397e034b0BBa5EbAc);
    addressOfBountyMembers.push(0x632cD9607C0673F023660B50C81F3930616fE473);
    addressOfBountyMembers.push(0x632243f7D558294E9f7aD6350920D1212637Dd34);
    addressOfBountyMembers.push(0x62BC9E5e33380C2635F62FE5AC049d9730b7869b);
    addressOfBountyMembers.push(0x60De9293FAEe42508ABecBC6B9C7D07D082383B5);
    addressOfBountyMembers.push(0x60cf7c40148370579133Fcf4e2bAe9Deec18ffb2);
    addressOfBountyMembers.push(0x60aBFd98dE69Ef7A269c78170984571Cf9F18fB7);
    addressOfBountyMembers.push(0x601612AE87fF46bE328F015C4AE7EE81d7350095);
    addressOfBountyMembers.push(0x5FF1084C4AC881a86AE8CdfFF08FF0a846e56489);
    addressOfBountyMembers.push(0x5f8120695272c6Deba876a46D0849A26df68E431);
    addressOfBountyMembers.push(0x5cC19cfF6D3030303118925576Df83D4AA7A602C);
    addressOfBountyMembers.push(0x5c50564cEEEb5B85CFeeC31572A748cC1185356c);
    addressOfBountyMembers.push(0x5af629491ee37d07CbA091d95B3067a4Bb5458a8);
    addressOfBountyMembers.push(0x59ff3Ed085Cf74bAf6eA3F8428e8a6AAcE2dc1b1);
    addressOfBountyMembers.push(0x58b44E1b59aa0333255c62734f4E691937DAE911);
    addressOfBountyMembers.push(0x58a97804C16983dB7387B154293373A43a720F9e);
    addressOfBountyMembers.push(0x55fcE2d3Fe2aD2334048A35fCD71c0E40C3b65b9);
    addressOfBountyMembers.push(0x55d3ea5Bd27a9e711Fe835e075Ef53978AE4075A);
    addressOfBountyMembers.push(0x549a5ba4455464DA27E1dc1Bff945911a0551B6d);
    addressOfBountyMembers.push(0x530AF50b7365d0601D7D49aE5BBE2C6F071f7A0E);
    addressOfBountyMembers.push(0x530aa0cdc05c15ab90ec036b6214c90775252d7c);
    addressOfBountyMembers.push(0x52F30d8A23640013795A60F51B28B3A32B7696aB);
    addressOfBountyMembers.push(0x5284dEF102eBd3A2728b974693cb7E297b2902A6);
    addressOfBountyMembers.push(0x51AbF4Ce540AD1ba654eBC6794Fa9503F2E9f4f3);
    addressOfBountyMembers.push(0x4F4FD3Ec92256af13d33287470b6a55324b5a9D8);
    addressOfBountyMembers.push(0x4F259A3E497c559FB15Eb4dB424D9a1ce938C81f);
    addressOfBountyMembers.push(0x4EeCcAAAe00d3E9329476e6e43d40E5895ec8497);
    addressOfBountyMembers.push(0x4EBD22101a7429Fee577eBF6f846e44f450ad71E);
    addressOfBountyMembers.push(0x4e31bddae0e65caa3ca21f310225318db7b7b2bd);
    addressOfBountyMembers.push(0x4bA3e896CDE8D19Da3286E92aB167E1b37d008dD);
    addressOfBountyMembers.push(0x4b939A9e76d67F31C4cA416BD21d74CfDaBA01e0);
    addressOfBountyMembers.push(0x4B678c63032B0d67A182D49d0d59d58289215016);
    addressOfBountyMembers.push(0x4B1069DCED9887B9bc58c34E835c302d3e0F1A9a);
    addressOfBountyMembers.push(0x4aD816D1Fd5030141f689Ac6e8d1017babD55856);
    addressOfBountyMembers.push(0x4A60F7156061EC5AeBbe7979B69b86Dd7420C3ee);
    addressOfBountyMembers.push(0x4995Ad627b80330c3C166a08372fEbd463f37A23);
    addressOfBountyMembers.push(0x48Ec399b6AF069614a326dc4D5CbdE560B099892);
    addressOfBountyMembers.push(0x465aC963EF750A86af0F51b773489eCDcab260FB);
    addressOfBountyMembers.push(0x460BAA28e768d0C9D1BFc885ad91B253C3373048);
    addressOfBountyMembers.push(0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF);
    addressOfBountyMembers.push(0x457b2E4c61F1961B5EC496a675925216E9BaA6B1);
    addressOfBountyMembers.push(0x452c72e0010239e8aE3B53113E1d3E76FA6b3165);
    addressOfBountyMembers.push(0x447b98986465fbB708ed688aD9Bb1b877409Eac2);
    addressOfBountyMembers.push(0x444a1EdB468FaB568Bf11216a29CBe0a5f67f4aB);
    addressOfBountyMembers.push(0x43212e86F82AfAfE230cAf01edD63D163272E29B);
    addressOfBountyMembers.push(0x41Ed3fd888601EbCE021d98D1100E8c7f10c1224);
    addressOfBountyMembers.push(0x41Da203383a9f3D707455fE7Ef92252D97E548F5);
    addressOfBountyMembers.push(0x40C64fA06830630a5f4baa4818e5FCf4c854D98D);
    addressOfBountyMembers.push(0x3e8b987Eaa6aa6d088C43b6f399Ee12b66a9Bc57);
    addressOfBountyMembers.push(0x3e0388D1DdBB6fE3ea9aDBC26411C3740009beb5);
    addressOfBountyMembers.push(0x3DCdaCff244119756108E8282F2ed0dD1eeCD281);
    addressOfBountyMembers.push(0x3c9F2E77C5B7AD87Ae13D8f855ceD9317a1Cd452);
    addressOfBountyMembers.push(0x3C6180ca425dd4C5BE6681E43160f7263948F2C4);
    addressOfBountyMembers.push(0x3C04Cb67ADc95a92A7BA5e55a601bF079BE4a18c);
    addressOfBountyMembers.push(0x39afB1f083361f41e89F93bb75886383a70B5d46);
    addressOfBountyMembers.push(0x38Cf170539129E299DCC0981c8594B4bd4fb05C1);
    addressOfBountyMembers.push(0x374ac09231f62ad153f7f8de2c4017bacaacfca2);
    addressOfBountyMembers.push(0x36e45c1670a201d32c50fe49bad9c3afd365a750);
    addressOfBountyMembers.push(0x36C808f055D30596C13866135F19ebC2fA8d25c6);
    addressOfBountyMembers.push(0x366AdC50dfea3F19AC3F7C14871a0c9b095D0179);
    addressOfBountyMembers.push(0x3394ab2b7AE68BE879DCefb703eD8B255435BfbD);
    addressOfBountyMembers.push(0x33001f29822567f6391E1FF4d8580AcAe865b8e5);
    addressOfBountyMembers.push(0x32E267a416DbaEE7C3Dc32EB644731Fa98b4e9ec);
    addressOfBountyMembers.push(0x30Db51F26bE5252feEcF6e1E217203de52e4BDE5);
    addressOfBountyMembers.push(0x30B9892b4B2f66A42F4A223D9d9eDB190921Ec74);
    addressOfBountyMembers.push(0x3077D925F4399514a3349b6e812e290CBD0a2154);
    addressOfBountyMembers.push(0x2f8bEf1bC2e15308806CB9119DEE344aDe62DFac);
    addressOfBountyMembers.push(0x2f112648C408e10e771eAc16eABAf143a6D1965c);
    addressOfBountyMembers.push(0x2D375a25A80747de74AE9AAE665B2D647cfA4884);
    addressOfBountyMembers.push(0x2cf1147632faa66362D82431cbDE0a04E99770C9);
    addressOfBountyMembers.push(0x2cDcc7b82949B90cCe3C2c29E2D8d7d33dd398f6);
    addressOfBountyMembers.push(0x2C6e11E0F63317ea2e339116ED604Fb5655EA72C);
    addressOfBountyMembers.push(0x2c2B778389E2ca9658cd376Ea12031724116c159);
    addressOfBountyMembers.push(0x2aB0802e51C044EfE76C7e156Faf619f801DA5CA);
    addressOfBountyMembers.push(0x2aAdDdFfAf4dC686D0E4ABD2cC9F12ed409FE8BC);
    addressOfBountyMembers.push(0x2a6C91ED927b4DaBeb8cA926FB1BeEc6bDeBD573);
    addressOfBountyMembers.push(0x29fEdAFF8B5e61B5e7A0905c78BCe2F61A226F32);
    addressOfBountyMembers.push(0x298Bf086b08B96Ee94be7b142097a153C9A96eB5);
    addressOfBountyMembers.push(0x2874409f109068ED7151cD194e6F90894e3C3a88);
    addressOfBountyMembers.push(0x26be2cA7f14080f5C4796a250b5cf34eB3bd6a56);
    addressOfBountyMembers.push(0x266144D330385e02eDca4c5119Fa3277AF233912);
    addressOfBountyMembers.push(0x25C6Cd0B76c1d4D971BBCb841c8844793aDe036A);
    addressOfBountyMembers.push(0x24Fe640F8D311ecD88cD84b7d3c781547a98aB75);
    addressOfBountyMembers.push(0x24F099933cB4Ef332855d3b8f23cb6F0e5564828);
    addressOfBountyMembers.push(0x249686691F1a0AB9AFDD46801275B1309d8fcE36);
    addressOfBountyMembers.push(0x22e658A43C8567Da2Ad66A755873f900475910B8);
    addressOfBountyMembers.push(0x2082b12cFFfd4197a63Bd623dce360514Bb3d26B);
    addressOfBountyMembers.push(0x1f377f157e1b7872B414392EF05eF601637b3A47);
    addressOfBountyMembers.push(0x1f1F5af44803527257758784380E212cDe0A19CF);
    addressOfBountyMembers.push(0x1ba038fC3bbB8cefC943749228491251dAb2E35a);
    addressOfBountyMembers.push(0x1ae5FB280706dabc49CC3022e73e52132A155a07);
    addressOfBountyMembers.push(0x1a1a398DD3e21Dd154C9Bd806CF3eBDaC88473ee);
    addressOfBountyMembers.push(0x182883Fb404976fC4299461371c174264dEd5831);
    addressOfBountyMembers.push(0x17DF42ce8F06281E76bF1f0dcf009701F737E424);
    addressOfBountyMembers.push(0x17B2824ea0b15E1c71ad27988bB4Df996b0f9bA0);
    addressOfBountyMembers.push(0x17828cD18aD9784d3711688fEc4B6D30E16BC407);
    addressOfBountyMembers.push(0x17303918fF12fD503961EBa5db01848De658729d);
    addressOfBountyMembers.push(0x15EbA2c1C584c5c991cEC88e4bD6337aE35C3CFF);
    addressOfBountyMembers.push(0x145DC5922F66bDaad017F5B1Ad2c114899BA57ed);
    addressOfBountyMembers.push(0x1241D156a9a774C72bA4b7DACbE717094D3D0D02);
    addressOfBountyMembers.push(0x12116576b04e4FD9b59623507D1FcB01a2e039Db);
    addressOfBountyMembers.push(0x112a571cE71E55376c7F9F115b5A7B4a2194E61E);
    addressOfBountyMembers.push(0x110D5d6a4B51001e115bc51Fa24392Bc52dD1146);
    addressOfBountyMembers.push(0x110495A92101e36EdA70a581E38b6cc81e173A7d);
    addressOfBountyMembers.push(0x103ef778B280E3275f21c3490286b1616aB60f7F);
    addressOfBountyMembers.push(0x1018a89AD01b2C4431a98987c180cFdE5a0d94D1);
    addressOfBountyMembers.push(0x0f7F641627DA51b800064417f85997ce0062e24E);
    addressOfBountyMembers.push(0x0e8F19b34D69b19B52891Fa65e582d253a3d66ea);
    addressOfBountyMembers.push(0x0Dd1266e2F1A38CB7D253eF8631b675A5879b9cF);
    addressOfBountyMembers.push(0x0cd414EeA730c8711651b501481b4F475A28e62e);
    addressOfBountyMembers.push(0x0ccB97Ca490F1FFE39ee5390331FFd40a758825d);
    addressOfBountyMembers.push(0x0c3DD6a74295C947EDFb4eA35a9302152d61Fc60);
    addressOfBountyMembers.push(0x0b9ac492a2fDcf27f4287502199694BbABcDf230);
    addressOfBountyMembers.push(0x0B4dD179AfCF1D1fA2ccE2079aC5460943eC8256);
    addressOfBountyMembers.push(0x0Af4F84505b50E5159f23cAbB6E45dbee0CFB6E2);
    addressOfBountyMembers.push(0x08d8b5a44AE4CE1f7a8490f1A9a176d28C4649f5);
    addressOfBountyMembers.push(0x08c4E05BF08E83882649a43b5dc7D9D6aF27F166);
    addressOfBountyMembers.push(0x07A0CBe5C6f2A666336225F8b0f4Bfa93E690787);
    addressOfBountyMembers.push(0x05be421368D776A8311960eb66C3B149B80E2248);
    addressOfBountyMembers.push(0x059E0f0BA6FDF3a3140bF35eBDF9bb15f2D17638);
    addressOfBountyMembers.push(0x0417b0aB5E76d9985EB952B0A1d238c6b8767a1b);
    addressOfBountyMembers.push(0x040E1e2981B05507578cA4ef4392237190a1E4f3);
    addressOfBountyMembers.push(0x038E7ec314e3418E900B5D2EC14fC1a35D3c5C0a);
    addressOfBountyMembers.push(0x02C61453DBf830e852892Cf9cd3a035B012a3F60);
    addressOfBountyMembers.push(0x00B1f2289Ed59454e6907F2B07d749E539c0aFB7);
    addressOfBountyMembers.push(0x00ab57F0c2ee803990D73E28De22b2EdBb174CCa);
    addressOfBountyMembers.push(0x00741018314ebd4ba1e4e453b985a156e57102f6);
    addressOfBountyMembers.push(0xe47bd26318de067366eeda3ce62a475829907d40);
  }

  function setBountyAmounts() internal { 
    bountyMembersAmounts[0x6A5CdFa535005CcEC5AeDf71a96a7b8fb66902fD] =   116000000000000000000;
    bountyMembersAmounts[0x686Bb20c8825b166FaDA080A92dC29DA518994B3] =   121000000000000000000;
    bountyMembersAmounts[0x675758B664cEFdfAf0f7438d2ac2B85D65bd7724] =   136000000000000000000;
    bountyMembersAmounts[0x64b4764c0D40c7654C75756c3A441202d4504BD9] =   122000000000000000000;
    bountyMembersAmounts[0x6371a1CbC462124CdA569f3397e034b0BBa5EbAc] =   164000000000000000000;
    bountyMembersAmounts[0x632cD9607C0673F023660B50C81F3930616fE473] =   126000000000000000000;
    bountyMembersAmounts[0x632243f7D558294E9f7aD6350920D1212637Dd34] =   285000000000000000000;
    bountyMembersAmounts[0x62BC9E5e33380C2635F62FE5AC049d9730b7869b] =   918000000000000000000;
    bountyMembersAmounts[0x60De9293FAEe42508ABecBC6B9C7D07D082383B5] =   105000000000000000000;
    bountyMembersAmounts[0x60cf7c40148370579133Fcf4e2bAe9Deec18ffb2] =   113000000000000000000;
    bountyMembersAmounts[0x60aBFd98dE69Ef7A269c78170984571Cf9F18fB7] =   110000000000000000000;
    bountyMembersAmounts[0x601612AE87fF46bE328F015C4AE7EE81d7350095] =   100000000000000000000;
    bountyMembersAmounts[0x5FF1084C4AC881a86AE8CdfFF08FF0a846e56489] =   228000000000000000000;
    bountyMembersAmounts[0x5f8120695272c6Deba876a46D0849A26df68E431] =   198000000000000000000;
    bountyMembersAmounts[0x5cC19cfF6D3030303118925576Df83D4AA7A602C] =   372000000000000000000;
    bountyMembersAmounts[0x5c50564cEEEb5B85CFeeC31572A748cC1185356c] =   102000000000000000000;
    bountyMembersAmounts[0x5af629491ee37d07CbA091d95B3067a4Bb5458a8] =   102000000000000000000;
    bountyMembersAmounts[0x59ff3Ed085Cf74bAf6eA3F8428e8a6AAcE2dc1b1] =   380000000000000000000;
    bountyMembersAmounts[0x58b44E1b59aa0333255c62734f4E691937DAE911] =   101000000000000000000;
    bountyMembersAmounts[0x58a97804C16983dB7387B154293373A43a720F9e] =   508000000000000000000;
    bountyMembersAmounts[0x55fcE2d3Fe2aD2334048A35fCD71c0E40C3b65b9] =   106000000000000000000;
    bountyMembersAmounts[0x55d3ea5Bd27a9e711Fe835e075Ef53978AE4075A] =   252000000000000000000;
    bountyMembersAmounts[0x549a5ba4455464DA27E1dc1Bff945911a0551B6d] =   164000000000000000000;
    bountyMembersAmounts[0x530AF50b7365d0601D7D49aE5BBE2C6F071f7A0E] =   159000000000000000000;
    bountyMembersAmounts[0x530aa0cdc05c15ab90ec036b6214c90775252d7c] =   167000000000000000000;
    bountyMembersAmounts[0x52F30d8A23640013795A60F51B28B3A32B7696aB] =   104000000000000000000;
    bountyMembersAmounts[0x5284dEF102eBd3A2728b974693cb7E297b2902A6] =   126000000000000000000;
    bountyMembersAmounts[0x51AbF4Ce540AD1ba654eBC6794Fa9503F2E9f4f3] =   149000000000000000000;
    bountyMembersAmounts[0x4F4FD3Ec92256af13d33287470b6a55324b5a9D8] =   113000000000000000000;
    bountyMembersAmounts[0x4F259A3E497c559FB15Eb4dB424D9a1ce938C81f] =   100000000000000000000;
    bountyMembersAmounts[0x4EeCcAAAe00d3E9329476e6e43d40E5895ec8497] =   120000000000000000000;
    bountyMembersAmounts[0x4EBD22101a7429Fee577eBF6f846e44f450ad71E] =   110000000000000000000;
    bountyMembersAmounts[0x4e31bddae0e65caa3ca21f310225318db7b7b2bd] =   212000000000000000000;
    bountyMembersAmounts[0x4bA3e896CDE8D19Da3286E92aB167E1b37d008dD] =   179000000000000000000;
    bountyMembersAmounts[0x4b939A9e76d67F31C4cA416BD21d74CfDaBA01e0] =   207000000000000000000;
    bountyMembersAmounts[0x4B678c63032B0d67A182D49d0d59d58289215016] =   170000000000000000000;
    bountyMembersAmounts[0x4B1069DCED9887B9bc58c34E835c302d3e0F1A9a] =   121000000000000000000;
    bountyMembersAmounts[0x4aD816D1Fd5030141f689Ac6e8d1017babD55856] =   107000000000000000000;
    bountyMembersAmounts[0x4A60F7156061EC5AeBbe7979B69b86Dd7420C3ee] =   100000000000000000000;
    bountyMembersAmounts[0x4995Ad627b80330c3C166a08372fEbd463f37A23] =   108000000000000000000;
    bountyMembersAmounts[0x48Ec399b6AF069614a326dc4D5CbdE560B099892] =   422000000000000000000;
    bountyMembersAmounts[0x465aC963EF750A86af0F51b773489eCDcab260FB] =   450000000000000000000;
    bountyMembersAmounts[0x460BAA28e768d0C9D1BFc885ad91B253C3373048] =  3540000000000000000000;
    bountyMembersAmounts[0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF] =  1435000000000000000000;
    bountyMembersAmounts[0x457b2E4c61F1961B5EC496a675925216E9BaA6B1] =   136000000000000000000;
    bountyMembersAmounts[0x452c72e0010239e8aE3B53113E1d3E76FA6b3165] =   176000000000000000000;
    bountyMembersAmounts[0x447b98986465fbB708ed688aD9Bb1b877409Eac2] =   121000000000000000000;
    bountyMembersAmounts[0x444a1EdB468FaB568Bf11216a29CBe0a5f67f4aB] =   150000000000000000000;
    bountyMembersAmounts[0x43212e86F82AfAfE230cAf01edD63D163272E29B] =   122000000000000000000;
    bountyMembersAmounts[0x41Ed3fd888601EbCE021d98D1100E8c7f10c1224] =   172000000000000000000;
    bountyMembersAmounts[0x41Da203383a9f3D707455fE7Ef92252D97E548F5] =   138000000000000000000;
    bountyMembersAmounts[0x40C64fA06830630a5f4baa4818e5FCf4c854D98D] =  1586000000000000000000;
    bountyMembersAmounts[0x3e8b987Eaa6aa6d088C43b6f399Ee12b66a9Bc57] =   152000000000000000000;
    bountyMembersAmounts[0x3e0388D1DdBB6fE3ea9aDBC26411C3740009beb5] =   105000000000000000000;
    bountyMembersAmounts[0x3DCdaCff244119756108E8282F2ed0dD1eeCD281] =   354000000000000000000;
    bountyMembersAmounts[0x3c9F2E77C5B7AD87Ae13D8f855ceD9317a1Cd452] =  1044000000000000000000;
    bountyMembersAmounts[0x3C6180ca425dd4C5BE6681E43160f7263948F2C4] =   187000000000000000000;
    bountyMembersAmounts[0x3C04Cb67ADc95a92A7BA5e55a601bF079BE4a18c] =   139000000000000000000;
    bountyMembersAmounts[0x39afB1f083361f41e89F93bb75886383a70B5d46] =   113000000000000000000;
    bountyMembersAmounts[0x38Cf170539129E299DCC0981c8594B4bd4fb05C1] =   334000000000000000000;
    bountyMembersAmounts[0x374ac09231f62ad153f7f8de2c4017bacaacfca2] =   143000000000000000000;
    bountyMembersAmounts[0x36e45c1670a201d32c50fe49bad9c3afd365a750] =   157000000000000000000;
    bountyMembersAmounts[0x36C808f055D30596C13866135F19ebC2fA8d25c6] =   124000000000000000000;
    bountyMembersAmounts[0x366AdC50dfea3F19AC3F7C14871a0c9b095D0179] =   186000000000000000000;
    bountyMembersAmounts[0x3394ab2b7AE68BE879DCefb703eD8B255435BfbD] =   120000000000000000000;
    bountyMembersAmounts[0x33001f29822567f6391E1FF4d8580AcAe865b8e5] =   104000000000000000000;
    bountyMembersAmounts[0x32E267a416DbaEE7C3Dc32EB644731Fa98b4e9ec] =   122000000000000000000;
    bountyMembersAmounts[0x30Db51F26bE5252feEcF6e1E217203de52e4BDE5] =   170000000000000000000;
    bountyMembersAmounts[0x30B9892b4B2f66A42F4A223D9d9eDB190921Ec74] =   185000000000000000000;
    bountyMembersAmounts[0x3077D925F4399514a3349b6e812e290CBD0a2154] =   119000000000000000000;
    bountyMembersAmounts[0x2f8bEf1bC2e15308806CB9119DEE344aDe62DFac] =   110000000000000000000;
    bountyMembersAmounts[0x2f112648C408e10e771eAc16eABAf143a6D1965c] =   119000000000000000000;
    bountyMembersAmounts[0x2D375a25A80747de74AE9AAE665B2D647cfA4884] =   147000000000000000000;
    bountyMembersAmounts[0x2cf1147632faa66362D82431cbDE0a04E99770C9] =   119000000000000000000;
    bountyMembersAmounts[0x2cDcc7b82949B90cCe3C2c29E2D8d7d33dd398f6] =   104000000000000000000;
    bountyMembersAmounts[0x2C6e11E0F63317ea2e339116ED604Fb5655EA72C] =   180000000000000000000;
    bountyMembersAmounts[0x2c2B778389E2ca9658cd376Ea12031724116c159] =   100000000000000000000;
    bountyMembersAmounts[0x2aB0802e51C044EfE76C7e156Faf619f801DA5CA] =   150000000000000000000;
    bountyMembersAmounts[0x2aAdDdFfAf4dC686D0E4ABD2cC9F12ed409FE8BC] =   116000000000000000000;
    bountyMembersAmounts[0x2a6C91ED927b4DaBeb8cA926FB1BeEc6bDeBD573] =   122000000000000000000;
    bountyMembersAmounts[0x29fEdAFF8B5e61B5e7A0905c78BCe2F61A226F32] =   154000000000000000000;
    bountyMembersAmounts[0x298Bf086b08B96Ee94be7b142097a153C9A96eB5] =   102000000000000000000;
    bountyMembersAmounts[0x2874409f109068ED7151cD194e6F90894e3C3a88] =   170000000000000000000;
    bountyMembersAmounts[0x26be2cA7f14080f5C4796a250b5cf34eB3bd6a56] =   213000000000000000000;
    bountyMembersAmounts[0x266144D330385e02eDca4c5119Fa3277AF233912] =   132000000000000000000;
    bountyMembersAmounts[0x25C6Cd0B76c1d4D971BBCb841c8844793aDe036A] =   224000000000000000000;
    bountyMembersAmounts[0x24Fe640F8D311ecD88cD84b7d3c781547a98aB75] =   104000000000000000000;
    bountyMembersAmounts[0x24F099933cB4Ef332855d3b8f23cb6F0e5564828] =   205000000000000000000;
    bountyMembersAmounts[0x249686691F1a0AB9AFDD46801275B1309d8fcE36] =   134000000000000000000;
    bountyMembersAmounts[0x22e658A43C8567Da2Ad66A755873f900475910B8] =   194000000000000000000;
    bountyMembersAmounts[0x2082b12cFFfd4197a63Bd623dce360514Bb3d26B] =   102000000000000000000;
    bountyMembersAmounts[0x1f377f157e1b7872B414392EF05eF601637b3A47] =   117000000000000000000;
    bountyMembersAmounts[0x1f1F5af44803527257758784380E212cDe0A19CF] =   110000000000000000000;
    bountyMembersAmounts[0x1ba038fC3bbB8cefC943749228491251dAb2E35a] =   190000000000000000000;
    bountyMembersAmounts[0x1ae5FB280706dabc49CC3022e73e52132A155a07] =   102000000000000000000;
    bountyMembersAmounts[0x1a1a398DD3e21Dd154C9Bd806CF3eBDaC88473ee] =   101000000000000000000;
    bountyMembersAmounts[0x182883Fb404976fC4299461371c174264dEd5831] =   100000000000000000000;
    bountyMembersAmounts[0x17DF42ce8F06281E76bF1f0dcf009701F737E424] =   102000000000000000000;
    bountyMembersAmounts[0x17B2824ea0b15E1c71ad27988bB4Df996b0f9bA0] =   123000000000000000000;
    bountyMembersAmounts[0x17828cD18aD9784d3711688fEc4B6D30E16BC407] =  1988000000000000000000;
    bountyMembersAmounts[0x17303918fF12fD503961EBa5db01848De658729d] =   100000000000000000000;
    bountyMembersAmounts[0x15EbA2c1C584c5c991cEC88e4bD6337aE35C3CFF] =   107000000000000000000;
    bountyMembersAmounts[0x145DC5922F66bDaad017F5B1Ad2c114899BA57ed] =   103000000000000000000;
    bountyMembersAmounts[0x1241D156a9a774C72bA4b7DACbE717094D3D0D02] =   106000000000000000000;
    bountyMembersAmounts[0x12116576b04e4FD9b59623507D1FcB01a2e039Db] =   101000000000000000000;
    bountyMembersAmounts[0x112a571cE71E55376c7F9F115b5A7B4a2194E61E] =   112000000000000000000;
    bountyMembersAmounts[0x110D5d6a4B51001e115bc51Fa24392Bc52dD1146] =   129000000000000000000;
    bountyMembersAmounts[0x110495A92101e36EdA70a581E38b6cc81e173A7d] =   188000000000000000000;
    bountyMembersAmounts[0x103ef778B280E3275f21c3490286b1616aB60f7F] =   200000000000000000000;
    bountyMembersAmounts[0x1018a89AD01b2C4431a98987c180cFdE5a0d94D1] =   157000000000000000000;
    bountyMembersAmounts[0x0f7F641627DA51b800064417f85997ce0062e24E] =   110000000000000000000;
    bountyMembersAmounts[0x0e8F19b34D69b19B52891Fa65e582d253a3d66ea] =   236000000000000000000;
    bountyMembersAmounts[0x0Dd1266e2F1A38CB7D253eF8631b675A5879b9cF] =   150000000000000000000;
    bountyMembersAmounts[0x0cd414EeA730c8711651b501481b4F475A28e62e] =   108000000000000000000;
    bountyMembersAmounts[0x0ccB97Ca490F1FFE39ee5390331FFd40a758825d] =   190000000000000000000;
    bountyMembersAmounts[0x0c3DD6a74295C947EDFb4eA35a9302152d61Fc60] =   102000000000000000000;
    bountyMembersAmounts[0x0b9ac492a2fDcf27f4287502199694BbABcDf230] =   157000000000000000000;
    bountyMembersAmounts[0x0B4dD179AfCF1D1fA2ccE2079aC5460943eC8256] =   426000000000000000000;
    bountyMembersAmounts[0x0Af4F84505b50E5159f23cAbB6E45dbee0CFB6E2] =   372000000000000000000;
    bountyMembersAmounts[0x08d8b5a44AE4CE1f7a8490f1A9a176d28C4649f5] =   140000000000000000000;
    bountyMembersAmounts[0x08c4E05BF08E83882649a43b5dc7D9D6aF27F166] =   179000000000000000000;
    bountyMembersAmounts[0x07A0CBe5C6f2A666336225F8b0f4Bfa93E690787] =   440000000000000000000;
    bountyMembersAmounts[0x05be421368D776A8311960eb66C3B149B80E2248] =   228000000000000000000;
    bountyMembersAmounts[0x059E0f0BA6FDF3a3140bF35eBDF9bb15f2D17638] =   101000000000000000000;
    bountyMembersAmounts[0x0417b0aB5E76d9985EB952B0A1d238c6b8767a1b] =   210000000000000000000;
    bountyMembersAmounts[0x040E1e2981B05507578cA4ef4392237190a1E4f3] =   141000000000000000000;
    bountyMembersAmounts[0x038E7ec314e3418E900B5D2EC14fC1a35D3c5C0a] =   149000000000000000000;
    bountyMembersAmounts[0x02C61453DBf830e852892Cf9cd3a035B012a3F60] = 23877000000000000000000;
    bountyMembersAmounts[0x00B1f2289Ed59454e6907F2B07d749E539c0aFB7] =   114000000000000000000;
    bountyMembersAmounts[0x00ab57F0c2ee803990D73E28De22b2EdBb174CCa] =   106000000000000000000;
    bountyMembersAmounts[0x00741018314ebd4ba1e4e453b985a156e57102f6] =   108000000000000000000;
	bountyMembersAmounts[0xe47bd26318de067366eeda3ce62a475829907d40] =   156000000000000000000;
  } 
}