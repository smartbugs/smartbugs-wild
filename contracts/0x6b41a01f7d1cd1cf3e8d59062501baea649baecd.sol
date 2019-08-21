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

contract ThirdBountyWPTpayoutPart1 {
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
    addrPerStep = 20;
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
    addressOfBountyMembers.push(0x0030FdCfe491FC3c4de83ed4abffBF404ea70C50);
    addressOfBountyMembers.push(0x00B1f2289Ed59454e6907F2B07d749E539c0aFB7);
    addressOfBountyMembers.push(0x0580adF592933Eb406AD95cAFcfa1aa82897062c);
    addressOfBountyMembers.push(0x07c8e3017BFf550A4510d93209C2da97b24d43D1);
    addressOfBountyMembers.push(0x09FBe998b3ADd115B0a9fd03548593b19a8D599b);
    addressOfBountyMembers.push(0x1035E6bE87338923D3346aC6A8C8705d3f26892f);
    addressOfBountyMembers.push(0x10Aa25a12430F9142fA618f309B7f90D7DD7A0dB);
    addressOfBountyMembers.push(0x11BFf13c57C664b22B57660b630531d6f99085Ed);
    addressOfBountyMembers.push(0x132eC9fabbafc29aDF004Fe4433B8b656e5Be093);
    addressOfBountyMembers.push(0x1441F22B88c1b39e6Df949a9CE6AeD366bd6887E);
    addressOfBountyMembers.push(0x145DC5922F66bDaad017F5B1Ad2c114899BA57ed);
    addressOfBountyMembers.push(0x1521E5141545090bc80FaFA7c2a5f4b75221c845);
    addressOfBountyMembers.push(0x158906E9C4483939B8B29C78Ce0B7556E1511Bce);
    addressOfBountyMembers.push(0x17E56C86EAFf21a51C3E69BeDCA90661edf66B95);
    addressOfBountyMembers.push(0x18B1671C22480Eb27E333CF2e235Ad6E4aD0aA2E);
    addressOfBountyMembers.push(0x1aD6C0Fec98b3e3eD411C8D49Be10ce1f48C34D0);
    addressOfBountyMembers.push(0x2005776165be2604d5a804e3d0e0317fb2728b62);
    addressOfBountyMembers.push(0x2072dc440EaA06436aB60B7FC4C3c7365AaE9cbd);
    addressOfBountyMembers.push(0x2074689c9B27472887828c2650313F184a55Ed8c);
    addressOfBountyMembers.push(0x2189fbce8a8e5726f6cf96355a1c335ab30713a9);
    addressOfBountyMembers.push(0x2581b319b78C7153D5EB61184A88c22b249a971f);
    addressOfBountyMembers.push(0x26ee90ba1f0898c2a50796270cb1b376c2742dab);
    addressOfBountyMembers.push(0x2A4a888fd8690F7cB56855db98180a479A181fbd);
    addressOfBountyMembers.push(0x2A77e40b47C8990605509f377Cd2450c47a6BED8);
    addressOfBountyMembers.push(0x2e9f5bfb07067df44f31519a80799884431876e1);
    addressOfBountyMembers.push(0x2f4348327fBa760B8C9307f5f9B3597e865e18E2);
    addressOfBountyMembers.push(0x3077D925F4399514a3349b6e812e290CBD0a2154);
    addressOfBountyMembers.push(0x316B2C3a805035e4ceBB13F63bd9d4eAeF1586fA);
    addressOfBountyMembers.push(0x319C9f308E5B8069b4cDAA6F6d64dF9e56780Bbc);
    addressOfBountyMembers.push(0x32f7c3EE5C1C17a0901064743291CE67849AD8F2);
    addressOfBountyMembers.push(0x330afbe5216d071935b2F0a57B9834884129C017);
    addressOfBountyMembers.push(0x33904dB22F2456E272490F407DF9235EE6B99b90);
    addressOfBountyMembers.push(0x33AD7F93F1A107ff74325302CA9b41113D6d226e);
    addressOfBountyMembers.push(0x34819906Cc7c89912a38d6D01E49413f76595c00);
    addressOfBountyMembers.push(0x348aAF5891120fEf67AfC218D8feEe033544CEC9);
    addressOfBountyMembers.push(0x34DFff1699850F78229885D38C551da31D37f683);
    addressOfBountyMembers.push(0x36e45c1670a201d32c50fe49bad9c3afd365a750);
    addressOfBountyMembers.push(0x3784Bc8bF2CdcD9d19A0dAf886a3f12544CaEA87);
    addressOfBountyMembers.push(0x38Cf170539129E299DCC0981c8594B4bd4fb05C1);
    addressOfBountyMembers.push(0x39CF9984866c8d9D6830840e92B5181c25E573CE);
    addressOfBountyMembers.push(0x3D867abE8538D74981Ba1A153aF31D4a2Af0B443);
    addressOfBountyMembers.push(0x3d90d9291EE073d3A13f6BF9349463bCf5C6Cc72);
    addressOfBountyMembers.push(0x3e25CBa7dD7391Dc7b1629C673FF2eF72b17e992);
    addressOfBountyMembers.push(0x40033Bd539a821382D087d92a8A7711D57764C23);
    addressOfBountyMembers.push(0x402DE95A651988B4dddac069F77184D98c589dD4);
    addressOfBountyMembers.push(0x4087F388af16406FFAa8a9776e7577f08CB45e21);
    addressOfBountyMembers.push(0x43212e86F82AfAfE230cAf01edD63D163272E29B);
    addressOfBountyMembers.push(0x43a002f7E3E906BE41d6B15E811779C798a4765a);
    addressOfBountyMembers.push(0x44F9D944C6307F19e0D4C25E739165F5BCc9EeB2);
    addressOfBountyMembers.push(0x457b2E4c61F1961B5EC496a675925216E9BaA6B1);
    addressOfBountyMembers.push(0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF);
    addressOfBountyMembers.push(0x460BAA28e768d0C9D1BFc885ad91B253C3373048);
    addressOfBountyMembers.push(0x46372a7D7Ac34d50917e149BAa7be5019c324F78);
    addressOfBountyMembers.push(0x47eecF53020A5996F803794b4290ed05f526FeC4);
    addressOfBountyMembers.push(0x488E342D6423EeD4B21DE253a945C1260359e663);
    addressOfBountyMembers.push(0x49985D6cFC27dF43A97Dda0883d60b57b51F47A7);
    addressOfBountyMembers.push(0x49dE37E34e8B5757B9f77b70F4E7bBA10B711985);
    addressOfBountyMembers.push(0x49e85794dad2816dc4a4093669b1b15e814f15a5);
    addressOfBountyMembers.push(0x4a0FAc59D0d87d4B291ED553Ca6ed589e7755487);
    addressOfBountyMembers.push(0x4B48adE1B4099fc2A1b53d7749288b23a72879fD);
    addressOfBountyMembers.push(0x4e6b0de009fd0f5f70760f535fc98e85e3f0761f);
    addressOfBountyMembers.push(0x4f27C7bc1AAa55a6C798a8295eA5a7B554eA7B6d);
    addressOfBountyMembers.push(0x522aB87522A15A7004DFaa4b358d4f2c8b9f2fAE);
    addressOfBountyMembers.push(0x5426E078cD1D12C53825eb93d8fEfa69b8f6e91F);
    addressOfBountyMembers.push(0x54Ff62E93f5801d423919aD2fD4b1b58D793C635);
    addressOfBountyMembers.push(0x576db3662Ba771bd56746d388500F0869deEeAF1);
    addressOfBountyMembers.push(0x57A647435a578aeB8c276c23c4306b57EB40AfD4);
    addressOfBountyMembers.push(0x57Cb4A824058B5af12b121229f7092f2E05C5e3F);
    addressOfBountyMembers.push(0x59fF96FC1Ba72D8ec9Ec0179Da53E72A5D0ed058);
    addressOfBountyMembers.push(0x5a78D47119964f9F9529Bcab667004e8743C1824);
    addressOfBountyMembers.push(0x5af884fd7Fffd78Ff115219F0E0772Fff3D19ACC);
    addressOfBountyMembers.push(0x5Ee81D38C4A690f3761C3dCe85033DA35114722b);
    addressOfBountyMembers.push(0x60De9293FAEe42508ABecBC6B9C7D07D082383B5);
    addressOfBountyMembers.push(0x62E894701794526c531ECeaF772Fb32C9b08f325);
    addressOfBountyMembers.push(0x63515D455393dDc5F8F321dd084d1bd000545573);
    addressOfBountyMembers.push(0x6364c0798a5c63c10F99924179416EDBC56C433d);
    addressOfBountyMembers.push(0x6371a1CbC462124CdA569f3397e034b0BBa5EbAc);
    addressOfBountyMembers.push(0x63B56909257c89953E888c9a4FA83816d3d24Dc2);
    addressOfBountyMembers.push(0x63D87F83E307493517e46e3BDA4704Bcf8838b87);
    addressOfBountyMembers.push(0x640B68dc41a2E19aea27dc3afA77E7AD0589ef89);
    addressOfBountyMembers.push(0x6460110594fB5B11e6d3e2f061efA1Ba14a89890);
    addressOfBountyMembers.push(0x65faE6F3b14a962E77cf99B3eceBe4a606b9BAa9);
    addressOfBountyMembers.push(0x6647136A9b70B274B042e484846580343eBe8421);
    addressOfBountyMembers.push(0x66F67E7d8e15085c7eB73341D0c769aFb1f2fDE5);
    addressOfBountyMembers.push(0x6994fBAc9242C15fa1F437010049A8D9bDE079D3);
    addressOfBountyMembers.push(0x6A30940928F7E4f8CBCa6AE67AE2050942d5E5aA);
    addressOfBountyMembers.push(0x6a3f9fa682cdeb2b76db8ba24a3eed8cfcdaeb40);
    addressOfBountyMembers.push(0x6Af951Eaab39D484cd666EaC82588B42f89ac1Ab);
    addressOfBountyMembers.push(0x6C0DA4563525aeFBF9fB98F7Fc374C5fA27B4240);
    addressOfBountyMembers.push(0x6c1a574c9e060d0047cB9bA372092e9227ea41F3);
    addressOfBountyMembers.push(0x6F98763ff5F6Ca0aFF91acdDF8b85032FE62F704);
    addressOfBountyMembers.push(0x6F9FEc8F3029A843d02B812923A98a7008b1f3A8);
    addressOfBountyMembers.push(0x6fBFc6d96bbbA406262234941b50A5C51C5814D5);
    addressOfBountyMembers.push(0x712a1Ced46E5cb13e39307fF3Fb054425F7660E1);
    addressOfBountyMembers.push(0x7172cD07a4207a80FC28545d9fCA5F6797Fa0eCc);
    addressOfBountyMembers.push(0x729f049686424e6b225130101c200491c4c506f1);
    addressOfBountyMembers.push(0x72Ec30d6b3B2a5Dc9d60207d6A63dD521da26188);
    addressOfBountyMembers.push(0x7470974Ea611f889DeCB48FdD0AB30A570333c11);
    addressOfBountyMembers.push(0x748a322D93F0061d720622E064919Cec1a2ED0bF);
    addressOfBountyMembers.push(0x78Dd46a3F1C217Eb1988b35db991a0869Be28a4C);
  }

  function setBountyAmounts() internal { 
    bountyMembersAmounts[0x0030FdCfe491FC3c4de83ed4abffBF404ea70C50] =  1115250000000000000000;
    bountyMembersAmounts[0x00B1f2289Ed59454e6907F2B07d749E539c0aFB7] =   102000000000000000000;
    bountyMembersAmounts[0x0580adF592933Eb406AD95cAFcfa1aa82897062c] = 22013000000000000000000;
    bountyMembersAmounts[0x07c8e3017BFf550A4510d93209C2da97b24d43D1] =   213000000000000000000;
    bountyMembersAmounts[0x09FBe998b3ADd115B0a9fd03548593b19a8D599b] =   106000000000000000000;
    bountyMembersAmounts[0x1035E6bE87338923D3346aC6A8C8705d3f26892f] =   142000000000000000000;
    bountyMembersAmounts[0x10Aa25a12430F9142fA618f309B7f90D7DD7A0dB] =   355000000000000000000;
    bountyMembersAmounts[0x11BFf13c57C664b22B57660b630531d6f99085Ed] =   100000000000000000000;
    bountyMembersAmounts[0x132eC9fabbafc29aDF004Fe4433B8b656e5Be093] =   100000000000000000000;
    bountyMembersAmounts[0x1441F22B88c1b39e6Df949a9CE6AeD366bd6887E] =   100000000000000000000;
    bountyMembersAmounts[0x145DC5922F66bDaad017F5B1Ad2c114899BA57ed] =   193000000000000000000;
    bountyMembersAmounts[0x1521E5141545090bc80FaFA7c2a5f4b75221c845] =   612000000000000000000;
    bountyMembersAmounts[0x158906E9C4483939B8B29C78Ce0B7556E1511Bce] =    10000000000000000000;
    bountyMembersAmounts[0x17E56C86EAFf21a51C3E69BeDCA90661edf66B95] =  3007800000000000000000;
    bountyMembersAmounts[0x18B1671C22480Eb27E333CF2e235Ad6E4aD0aA2E] =  2005200000000000000000;
    bountyMembersAmounts[0x1aD6C0Fec98b3e3eD411C8D49Be10ce1f48C34D0] =   100000000000000000000;
    bountyMembersAmounts[0x2005776165be2604d5a804e3d0e0317fb2728b62] =   862000000000000000000;
    bountyMembersAmounts[0x2072dc440EaA06436aB60B7FC4C3c7365AaE9cbd] =   106000000000000000000;
    bountyMembersAmounts[0x2074689c9B27472887828c2650313F184a55Ed8c] =   103000000000000000000;
    bountyMembersAmounts[0x2189fbce8a8e5726f6cf96355a1c335ab30713a9] =   122000000000000000000;
    bountyMembersAmounts[0x2581b319b78C7153D5EB61184A88c22b249a971f] =  8580000000000000000000;
    bountyMembersAmounts[0x26ee90ba1f0898c2a50796270cb1b376c2742dab] =   120000000000000000000;
    bountyMembersAmounts[0x2A4a888fd8690F7cB56855db98180a479A181fbd] =   106000000000000000000;
    bountyMembersAmounts[0x2A77e40b47C8990605509f377Cd2450c47a6BED8] =   100000000000000000000;
    bountyMembersAmounts[0x2e9f5bfb07067df44f31519a80799884431876e1] =   100000000000000000000;
    bountyMembersAmounts[0x2f4348327fBa760B8C9307f5f9B3597e865e18E2] =   100000000000000000000;
    bountyMembersAmounts[0x3077D925F4399514a3349b6e812e290CBD0a2154] =   126000000000000000000;
    bountyMembersAmounts[0x316B2C3a805035e4ceBB13F63bd9d4eAeF1586fA] =   126000000000000000000;
    bountyMembersAmounts[0x319C9f308E5B8069b4cDAA6F6d64dF9e56780Bbc] =   108000000000000000000;
    bountyMembersAmounts[0x32f7c3EE5C1C17a0901064743291CE67849AD8F2] =  3429590000000000000000;
    bountyMembersAmounts[0x330afbe5216d071935b2F0a57B9834884129C017] =    28000000000000000000;
    bountyMembersAmounts[0x33904dB22F2456E272490F407DF9235EE6B99b90] =   106000000000000000000;
    bountyMembersAmounts[0x33AD7F93F1A107ff74325302CA9b41113D6d226e] =  7708500000000000000000;
    bountyMembersAmounts[0x34819906Cc7c89912a38d6D01E49413f76595c00] = 23888000000000000000000;
    bountyMembersAmounts[0x348aAF5891120fEf67AfC218D8feEe033544CEC9] =   334000000000000000000;
    bountyMembersAmounts[0x34DFff1699850F78229885D38C551da31D37f683] =   200000000000000000000;
    bountyMembersAmounts[0x36e45c1670a201d32c50fe49bad9c3afd365a750] =   150000000000000000000;
    bountyMembersAmounts[0x3784Bc8bF2CdcD9d19A0dAf886a3f12544CaEA87] =   130000000000000000000;
    bountyMembersAmounts[0x38Cf170539129E299DCC0981c8594B4bd4fb05C1] =   114000000000000000000;
    bountyMembersAmounts[0x39CF9984866c8d9D6830840e92B5181c25E573CE] =   110000000000000000000;
    bountyMembersAmounts[0x3D867abE8538D74981Ba1A153aF31D4a2Af0B443] =   430000000000000000000;
    bountyMembersAmounts[0x3d90d9291EE073d3A13f6BF9349463bCf5C6Cc72] =   454000000000000000000;
    bountyMembersAmounts[0x3e25CBa7dD7391Dc7b1629C673FF2eF72b17e992] =   118000000000000000000;
    bountyMembersAmounts[0x40033Bd539a821382D087d92a8A7711D57764C23] =   250000000000000000000;
    bountyMembersAmounts[0x402DE95A651988B4dddac069F77184D98c589dD4] =  7651740000000000000000;
    bountyMembersAmounts[0x4087F388af16406FFAa8a9776e7577f08CB45e21] =   123000000000000000000;
    bountyMembersAmounts[0x43212e86F82AfAfE230cAf01edD63D163272E29B] =   159000000000000000000;
    bountyMembersAmounts[0x43a002f7E3E906BE41d6B15E811779C798a4765a] =   190000000000000000000;
    bountyMembersAmounts[0x44F9D944C6307F19e0D4C25E739165F5BCc9EeB2] =   103000000000000000000;
    bountyMembersAmounts[0x457b2E4c61F1961B5EC496a675925216E9BaA6B1] =   778000000000000000000;
    bountyMembersAmounts[0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF] =   110000000000000000000;
    bountyMembersAmounts[0x460BAA28e768d0C9D1BFc885ad91B253C3373048] =  1200000000000000000000;
    bountyMembersAmounts[0x46372a7D7Ac34d50917e149BAa7be5019c324F78] =  5140000000000000000000;
    bountyMembersAmounts[0x47eecF53020A5996F803794b4290ed05f526FeC4] =   107000000000000000000;
    bountyMembersAmounts[0x488E342D6423EeD4B21DE253a945C1260359e663] = 12857000000000000000000;
    bountyMembersAmounts[0x49985D6cFC27dF43A97Dda0883d60b57b51F47A7] =    12000000000000000000;
    bountyMembersAmounts[0x49dE37E34e8B5757B9f77b70F4E7bBA10B711985] =   109000000000000000000;
    bountyMembersAmounts[0x49e85794dad2816dc4a4093669b1b15e814f15a5] =    22000000000000000000;
    bountyMembersAmounts[0x4a0FAc59D0d87d4B291ED553Ca6ed589e7755487] =   276950000000000000000;
    bountyMembersAmounts[0x4B48adE1B4099fc2A1b53d7749288b23a72879fD] =   568000000000000000000;
    bountyMembersAmounts[0x4e6b0de009fd0f5f70760f535fc98e85e3f0761f] =   100000000000000000000;
    bountyMembersAmounts[0x4f27C7bc1AAa55a6C798a8295eA5a7B554eA7B6d] =   190000000000000000000;
    bountyMembersAmounts[0x522aB87522A15A7004DFaa4b358d4f2c8b9f2fAE] =   120000000000000000000;
    bountyMembersAmounts[0x5426E078cD1D12C53825eb93d8fEfa69b8f6e91F] =   113000000000000000000;
    bountyMembersAmounts[0x54Ff62E93f5801d423919aD2fD4b1b58D793C635] =   162000000000000000000;
    bountyMembersAmounts[0x576db3662Ba771bd56746d388500F0869deEeAF1] =   226000000000000000000;
    bountyMembersAmounts[0x57A647435a578aeB8c276c23c4306b57EB40AfD4] =  4171770000000000000000;
    bountyMembersAmounts[0x57Cb4A824058B5af12b121229f7092f2E05C5e3F] =   103000000000000000000;
    bountyMembersAmounts[0x59fF96FC1Ba72D8ec9Ec0179Da53E72A5D0ed058] =   100000000000000000000;
    bountyMembersAmounts[0x5a78D47119964f9F9529Bcab667004e8743C1824] =   334000000000000000000;
    bountyMembersAmounts[0x5af884fd7Fffd78Ff115219F0E0772Fff3D19ACC] =   663000000000000000000;
    bountyMembersAmounts[0x5Ee81D38C4A690f3761C3dCe85033DA35114722b] =   100000000000000000000;
    bountyMembersAmounts[0x60De9293FAEe42508ABecBC6B9C7D07D082383B5] =   104000000000000000000;
    bountyMembersAmounts[0x62E894701794526c531ECeaF772Fb32C9b08f325] =  1780000000000000000000;
    bountyMembersAmounts[0x63515D455393dDc5F8F321dd084d1bd000545573] =   200000000000000000000;
    bountyMembersAmounts[0x6364c0798a5c63c10F99924179416EDBC56C433d] =   154000000000000000000;
    bountyMembersAmounts[0x6371a1CbC462124CdA569f3397e034b0BBa5EbAc] =   105000000000000000000;
    bountyMembersAmounts[0x63B56909257c89953E888c9a4FA83816d3d24Dc2] =  5736040000000000000000;
    bountyMembersAmounts[0x63D87F83E307493517e46e3BDA4704Bcf8838b87] =  1967000000000000000000;
    bountyMembersAmounts[0x640B68dc41a2E19aea27dc3afA77E7AD0589ef89] =  4010400000000000000000;
    bountyMembersAmounts[0x6460110594fB5B11e6d3e2f061efA1Ba14a89890] =   103000000000000000000;
    bountyMembersAmounts[0x65faE6F3b14a962E77cf99B3eceBe4a606b9BAa9] =   119000000000000000000;
    bountyMembersAmounts[0x6647136A9b70B274B042e484846580343eBe8421] =   136000000000000000000;
    bountyMembersAmounts[0x66F67E7d8e15085c7eB73341D0c769aFb1f2fDE5] =   162000000000000000000;
    bountyMembersAmounts[0x6994fBAc9242C15fa1F437010049A8D9bDE079D3] =  9390000000000000000000;
    bountyMembersAmounts[0x6A30940928F7E4f8CBCa6AE67AE2050942d5E5aA] =   107000000000000000000;
    bountyMembersAmounts[0x6a3f9fa682cdeb2b76db8ba24a3eed8cfcdaeb40] =   706000000000000000000;
    bountyMembersAmounts[0x6Af951Eaab39D484cd666EaC82588B42f89ac1Ab] =   101000000000000000000;
    bountyMembersAmounts[0x6C0DA4563525aeFBF9fB98F7Fc374C5fA27B4240] =  8000000000000000000000;
    bountyMembersAmounts[0x6c1a574c9e060d0047cB9bA372092e9227ea41F3] =   137000000000000000000;
    bountyMembersAmounts[0x6F98763ff5F6Ca0aFF91acdDF8b85032FE62F704] =  2000000000000000000000;
    bountyMembersAmounts[0x6F9FEc8F3029A843d02B812923A98a7008b1f3A8] =   112000000000000000000;
    bountyMembersAmounts[0x6fBFc6d96bbbA406262234941b50A5C51C5814D5] =   100000000000000000000;
    bountyMembersAmounts[0x712a1Ced46E5cb13e39307fF3Fb054425F7660E1] =   713700000000000000000;
    bountyMembersAmounts[0x7172cD07a4207a80FC28545d9fCA5F6797Fa0eCc] =   103000000000000000000;
    bountyMembersAmounts[0x729f049686424e6b225130101c200491c4c506f1] =    94000000000000000000;
    bountyMembersAmounts[0x72Ec30d6b3B2a5Dc9d60207d6A63dD521da26188] =   115000000000000000000;
    bountyMembersAmounts[0x7470974Ea611f889DeCB48FdD0AB30A570333c11] =   490000000000000000000;
    bountyMembersAmounts[0x748a322D93F0061d720622E064919Cec1a2ED0bF] =   118000000000000000000;
    bountyMembersAmounts[0x78Dd46a3F1C217Eb1988b35db991a0869Be28a4C] =  3250240000000000000000;
  } 
}