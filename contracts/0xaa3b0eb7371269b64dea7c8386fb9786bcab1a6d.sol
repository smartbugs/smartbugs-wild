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

contract SecondBountyWPTpayout_part2 {
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
    addressOfBountyMembers.push(0x56Dd480A7F0e2adf190320F36795A35EF14a273b);
    addressOfBountyMembers.push(0x5706f86D8924C05FcCB48069ED36d496E1F6e430);
    addressOfBountyMembers.push(0x573b8C85e1f1DdC80A13906607b5eAb4794230eb);
    addressOfBountyMembers.push(0x5B36E70B17Cb5802e3Db17Cc1f176c0983dfD31D);
    addressOfBountyMembers.push(0x5b8315c2C3210B52B0C30DCF7bE1edbcd6FD954B);
    addressOfBountyMembers.push(0x5c1Dd6e3c6F4C308d843523128Bc5dDd42f7724C);
    addressOfBountyMembers.push(0x5Cc2e30e3af89363c437342a3AbB5762C09d0A58);
    addressOfBountyMembers.push(0x5D5b3CbD222863Cd1260A5f2205EFfC3C28b33e4);
    addressOfBountyMembers.push(0x5f74Bf64D65Ca8FBe11D1F1A0b1CAF48727f843f);
    addressOfBountyMembers.push(0x6029da9fB2ECEC7E0d88Ca0d0a90E087da8Ddd8E);
    addressOfBountyMembers.push(0x62A276d12139757628eEf807C57263692D7B6568);
    addressOfBountyMembers.push(0x6358341BDDA56981B1b2C480d215d9C6DCb70C20);
    addressOfBountyMembers.push(0x6377bf4cBcE21a5997Db0c3B749D6dAF961Cb00D);
    addressOfBountyMembers.push(0x63B56909257c89953E888c9a4FA83816d3d24Dc2);
    addressOfBountyMembers.push(0x63CfBa162C5a14756635EA68E10D0972dfD013ca);
    addressOfBountyMembers.push(0x63e73058e65Ba0FE3f925d2948988782d2617ab2);
    addressOfBountyMembers.push(0x64DA63626eA468efCF8fFF8a70E2cb8Cdf94b5D3);
    addressOfBountyMembers.push(0x656Cf0f39D9Da10FcCB2d529F478Fc1d332ee329);
    addressOfBountyMembers.push(0x656dbA82000b71A9DF73ACA17F941C53e5673b8d);
    addressOfBountyMembers.push(0x68227e98ca8c451660dbae1f62189a91fcc0864e);
    addressOfBountyMembers.push(0x686133437f494CE5913F6734BB4b07C065D68dE1);
    addressOfBountyMembers.push(0x6899bADb5FD5b8895eEc6F755d9bfFFC387273Fa);
    addressOfBountyMembers.push(0x691fc6581461a5a3f8864187c7C87b6BFab7041E);
    addressOfBountyMembers.push(0x695e9089fDD7D92037e525aC2CB59a509A0e9A84);
    addressOfBountyMembers.push(0x6a1BD1876587dA00a9F877a6e42Af91828B2c47A);
    addressOfBountyMembers.push(0x6a869e7712957841f423fe962aa3d7c301f17b62);
    addressOfBountyMembers.push(0x6b386f9F3bC10214E816a1E570B31D25e7B52bF1);
    addressOfBountyMembers.push(0x6Bc10296153a7e7160D5fF14a33A5dfae68C12ab);
    addressOfBountyMembers.push(0x6D79d6DAFe56cf46A754B6E9af60CbB9Bdd92992);
    addressOfBountyMembers.push(0x6da95f064cc7072d3a9c53822b47bdc230840337);
    addressOfBountyMembers.push(0x6Dbcb37657833BF86Cbc073A1C9A8C8387d9E04A);
    addressOfBountyMembers.push(0x6e06d0Cb11A610fbfEE929bcAEBFBDcD26907081);
    addressOfBountyMembers.push(0x6F1CFBc48e86cC9f8b1a9ae48EB5b8aD71c46d57);
    addressOfBountyMembers.push(0x6F21033Ea662521C7a7C067E022066420Fb015af);
    addressOfBountyMembers.push(0x6F9FEc8F3029A843d02B812923A98a7008b1f3A8);
    addressOfBountyMembers.push(0x726356cF0ED11183a093d5c454deb6F9543831f7);
    addressOfBountyMembers.push(0x7265B09B51634f67Fa6531DD963a15CF37b3e31b);
    addressOfBountyMembers.push(0x727c9080069dFF36A93f66d59B234c9865EB3450);
    addressOfBountyMembers.push(0x72a9596D79895C6a23dC71C6eCd7a654C6E77672);
    addressOfBountyMembers.push(0x7631e06DE3f88f78Bb60f64b35C29b442563Db09);
    addressOfBountyMembers.push(0x7664a08112F166bF85470b0462C3E9B8C5960bb1);
    addressOfBountyMembers.push(0x76ef754D7d1116F6CA912f877c88b777184670b1);
    addressOfBountyMembers.push(0x780e64F06c13525CD4F09d069622D95d4E82D66E);
    addressOfBountyMembers.push(0x7882F927b75Ef77D75D4592FB8971B491E58d42d);
    addressOfBountyMembers.push(0x79bd7d5599b4c8483606c11c66599d2F04253D39);
    addressOfBountyMembers.push(0x7ae8b683d00d5e1A89BE60dA68f102804e4B4D98);
    addressOfBountyMembers.push(0x7BBAd9d141a790b40a2DEa972AEa8F314B397bf9);
    addressOfBountyMembers.push(0x7c1626669B377664F25CE2E6cC25dec4037946Ef);
    addressOfBountyMembers.push(0x7D074Bec6608952458e9b12b5BA5D3A87DdE1175);
    addressOfBountyMembers.push(0x7d387e70B03B8fc331bb1D0e47Ab4681d70e6F15);
    addressOfBountyMembers.push(0x7dFaf7EaD8814265FE82253b94603B042E0c9358);
    addressOfBountyMembers.push(0x8013DF793d20cD4C13F2Ec31a23D21Cd221612b5);
    addressOfBountyMembers.push(0x80ACf6389eD2bCa836522C573039677A35AF795C);
    addressOfBountyMembers.push(0x80ead8849D23F0459878b5B3582A80FC20eB88fC);
    addressOfBountyMembers.push(0x812aCA886C5491d471fEaed676f0CD0AEd8bc659);
    addressOfBountyMembers.push(0x821De76eeDE1ef45451D3080De748AF06A43910f);
    addressOfBountyMembers.push(0x822FD4b17718cadEDEC287aDfc3432Df0700F9c7);
    addressOfBountyMembers.push(0x824a66eF9A47e83f03cB9997270F9333CF68A7b8);
    addressOfBountyMembers.push(0x82b2eF324E2EC56F9397F243Eeb34E67eB590F80);
    addressOfBountyMembers.push(0x82f527b4bad3ff193a31b844b5156edbdf1ac483);
    addressOfBountyMembers.push(0x83272588225b466cD2ABA44Bb55e2d0975CD0786);
    addressOfBountyMembers.push(0x843F9A13a816Ae5d85336da5eC70e8447b22F429);
    addressOfBountyMembers.push(0x84da87b971860d04CD249517c5E7948db0F893F3);
    addressOfBountyMembers.push(0x860131A3726a7a3A66C8f9389EF6273f5d0D6b6D);
    addressOfBountyMembers.push(0x89095edc877ed4ed7d201c9c76edb68baa187e2b);
    addressOfBountyMembers.push(0x89c0236789A3Bc8f4Ed06be1863a3817f99B5dce);
    addressOfBountyMembers.push(0x8A3A160decF48fD70d99Fda9F386DD1eA41d17DF);
    addressOfBountyMembers.push(0x8e09Ac8b853c9534B1900C33CA8D026D24077953);
    addressOfBountyMembers.push(0x8e7Ef98A7284652cbF72F9D701Cc1161DBe7A374);
    addressOfBountyMembers.push(0x8fEB62d9dBb8daCAD4d49e7C8cc93Db1aC584166);
    addressOfBountyMembers.push(0x900A7b05cB1e3fBCD699F8dF9c9399ff9d1CbEd2);
    addressOfBountyMembers.push(0x904c47031357936799B76CbA53DBAD59855603fC);
    addressOfBountyMembers.push(0x90b07af0aAA4A705bCC441c2B1D0B581F42bcDB4);
    addressOfBountyMembers.push(0x90D05705eF23bBabB676fFC161A251C3CAe9C966);
    addressOfBountyMembers.push(0x9119E1338782C7B9D6Dfe2F579FddC6153FE8397);
    addressOfBountyMembers.push(0x914451625DF60231b7EC04993B5F435B8eE91Eba);
    addressOfBountyMembers.push(0x9273777d99258b7B0ae2255de2B5b3D9d742f507);
    addressOfBountyMembers.push(0x9319Df4ed6D20DA8e6E264f4cd04802eA9A56bE2);
    addressOfBountyMembers.push(0x937fe2c8bd616344a9Be33fDEC04D6F15f53c20F);
    addressOfBountyMembers.push(0x93C02D733d42fa7Ac36dF84D8285dAe770890e8f);
    addressOfBountyMembers.push(0x944E3843f832e1C0E9B5d345FF1245Ba61946675);
    addressOfBountyMembers.push(0x94c30dBB7EA6df4FCAd8c8864Edfc9c59cB8Db14);
    addressOfBountyMembers.push(0x967668b7795Dd22aAC21e5E4866d6AF8597892D9);
    addressOfBountyMembers.push(0x9692efcb1baf875f72342980ee742352dcb35b20);
    addressOfBountyMembers.push(0x96C41b12F88b825594427a75Dda82ae9020a4349);
    addressOfBountyMembers.push(0x96d07EB199655D506911b00d6243f3d990832CFE);
    addressOfBountyMembers.push(0x99DD75BDFB142E424cDDC3a9dc7bf527CB8Bc4ec);
    addressOfBountyMembers.push(0x9a43047ED2ea4D70Ce5B3B9eC593a5bE91105956);
    addressOfBountyMembers.push(0x9b5619f18c1712d42824c092718BC6Eed8127baE);
    addressOfBountyMembers.push(0x9b58FdE3af8A5E73d8bab9943833dE65d76a0F64);
    addressOfBountyMembers.push(0x9C2f0b4123d3e0C3C35d081E61F464f8D609670b);
    addressOfBountyMembers.push(0x9d03F4dC892f7f24e94581bC294DC98183796bDf);
    addressOfBountyMembers.push(0x9d98E8520d27610148Bda5c9F3da2CE4f674cc85);
    addressOfBountyMembers.push(0x9eb04d5B0b2159ec6096F41b55C44A36B2D0DE08);
    addressOfBountyMembers.push(0x9F39E96a29874aB47a282d5D171F7bD456940589);
    addressOfBountyMembers.push(0xa2175a9b58Ecb1992fD79a04AC37e59a82774005);
    addressOfBountyMembers.push(0xa44c22dce05acda274d77f743864c32c804262d1);
    addressOfBountyMembers.push(0xa4A3D2BB0da871CD891d6F724D268aA21809DffE);
    addressOfBountyMembers.push(0xA634550Bb1EcDEf1f648F59Ff159e5bd6e340D38);
    addressOfBountyMembers.push(0xA704e8EB038A822bD9D980Fb258bC4998dfc8578);
    addressOfBountyMembers.push(0xA7f21A4827831ad52f41977f6a8846534c399b33);
  }

  function setBountyAmounts() internal { 
    bountyMembersAmounts[0x56Dd480A7F0e2adf190320F36795A35EF14a273b] =  1391000000000000000000;
    bountyMembersAmounts[0x5706f86D8924C05FcCB48069ED36d496E1F6e430] =    16000000000000000000;
    bountyMembersAmounts[0x573b8C85e1f1DdC80A13906607b5eAb4794230eb] =    16000000000000000000;
    bountyMembersAmounts[0x5B36E70B17Cb5802e3Db17Cc1f176c0983dfD31D] =   358500000000000000000;
    bountyMembersAmounts[0x5b8315c2C3210B52B0C30DCF7bE1edbcd6FD954B] =  1966000000000000000000;
    bountyMembersAmounts[0x5c1Dd6e3c6F4C308d843523128Bc5dDd42f7724C] =   497520000000000000000;
    bountyMembersAmounts[0x5Cc2e30e3af89363c437342a3AbB5762C09d0A58] =   743520000000000000000;
    bountyMembersAmounts[0x5D5b3CbD222863Cd1260A5f2205EFfC3C28b33e4] =    44000000000000000000;
    bountyMembersAmounts[0x5f74Bf64D65Ca8FBe11D1F1A0b1CAF48727f843f] =  2098000000000000000000;
    bountyMembersAmounts[0x6029da9fB2ECEC7E0d88Ca0d0a90E087da8Ddd8E] =    10000000000000000000;
    bountyMembersAmounts[0x62A276d12139757628eEf807C57263692D7B6568] =  1858000000000000000000;
    bountyMembersAmounts[0x6358341BDDA56981B1b2C480d215d9C6DCb70C20] =    10000000000000000000;
    bountyMembersAmounts[0x6377bf4cBcE21a5997Db0c3B749D6dAF961Cb00D] =   121000000000000000000;
    bountyMembersAmounts[0x63B56909257c89953E888c9a4FA83816d3d24Dc2] = 30000000000000000000000;
    bountyMembersAmounts[0x63CfBa162C5a14756635EA68E10D0972dfD013ca] =    10000000000000000000;
    bountyMembersAmounts[0x63e73058e65Ba0FE3f925d2948988782d2617ab2] =   110000000000000000000;
    bountyMembersAmounts[0x64DA63626eA468efCF8fFF8a70E2cb8Cdf94b5D3] =    16000000000000000000;
    bountyMembersAmounts[0x656Cf0f39D9Da10FcCB2d529F478Fc1d332ee329] =    16000000000000000000;
    bountyMembersAmounts[0x656dbA82000b71A9DF73ACA17F941C53e5673b8d] =    27000000000000000000;
    bountyMembersAmounts[0x68227e98ca8c451660dbae1f62189a91fcc0864e] =    10000000000000000000;
    bountyMembersAmounts[0x686133437f494CE5913F6734BB4b07C065D68dE1] =   785600000000000000000;
    bountyMembersAmounts[0x6899bADb5FD5b8895eEc6F755d9bfFFC387273Fa] =    10000000000000000000;
    bountyMembersAmounts[0x691fc6581461a5a3f8864187c7C87b6BFab7041E] =   106550000000000000000;
    bountyMembersAmounts[0x695e9089fDD7D92037e525aC2CB59a509A0e9A84] =   135000000000000000000;
    bountyMembersAmounts[0x6a1BD1876587dA00a9F877a6e42Af91828B2c47A] =    16000000000000000000;
    bountyMembersAmounts[0x6a869e7712957841f423fe962aa3d7c301f17b62] =  2613450000000000000000;
    bountyMembersAmounts[0x6b386f9F3bC10214E816a1E570B31D25e7B52bF1] =    19000000000000000000;
    bountyMembersAmounts[0x6Bc10296153a7e7160D5fF14a33A5dfae68C12ab] =    22000000000000000000;
    bountyMembersAmounts[0x6D79d6DAFe56cf46A754B6E9af60CbB9Bdd92992] =   102600000000000000000;
    bountyMembersAmounts[0x6da95f064cc7072d3a9c53822b47bdc230840337] = 10026000000000000000000;
    bountyMembersAmounts[0x6Dbcb37657833BF86Cbc073A1C9A8C8387d9E04A] =   144000000000000000000;
    bountyMembersAmounts[0x6e06d0Cb11A610fbfEE929bcAEBFBDcD26907081] =    12000000000000000000;
    bountyMembersAmounts[0x6F1CFBc48e86cC9f8b1a9ae48EB5b8aD71c46d57] =    10000000000000000000;
    bountyMembersAmounts[0x6F21033Ea662521C7a7C067E022066420Fb015af] =    10000000000000000000;
    bountyMembersAmounts[0x6F9FEc8F3029A843d02B812923A98a7008b1f3A8] =    52000000000000000000;
    bountyMembersAmounts[0x726356cF0ED11183a093d5c454deb6F9543831f7] =   494210000000000000000;
    bountyMembersAmounts[0x7265B09B51634f67Fa6531DD963a15CF37b3e31b] =    54000000000000000000;
    bountyMembersAmounts[0x727c9080069dFF36A93f66d59B234c9865EB3450] =   711510000000000000000;
    bountyMembersAmounts[0x72a9596D79895C6a23dC71C6eCd7a654C6E77672] =    19000000000000000000;
    bountyMembersAmounts[0x7631e06DE3f88f78Bb60f64b35C29b442563Db09] =    70000000000000000000;
    bountyMembersAmounts[0x7664a08112F166bF85470b0462C3E9B8C5960bb1] =     5000000000000000000;
    bountyMembersAmounts[0x76ef754D7d1116F6CA912f877c88b777184670b1] =   132000000000000000000;
    bountyMembersAmounts[0x780e64F06c13525CD4F09d069622D95d4E82D66E] =    82000000000000000000;
    bountyMembersAmounts[0x7882F927b75Ef77D75D4592FB8971B491E58d42d] =    12000000000000000000;
    bountyMembersAmounts[0x79bd7d5599b4c8483606c11c66599d2F04253D39] =   380950000000000000000;
    bountyMembersAmounts[0x7ae8b683d00d5e1A89BE60dA68f102804e4B4D98] =    10000000000000000000;
    bountyMembersAmounts[0x7BBAd9d141a790b40a2DEa972AEa8F314B397bf9] =   120000000000000000000;
    bountyMembersAmounts[0x7c1626669B377664F25CE2E6cC25dec4037946Ef] =   144000000000000000000;
    bountyMembersAmounts[0x7D074Bec6608952458e9b12b5BA5D3A87DdE1175] =  7118110000000000000000;
    bountyMembersAmounts[0x7d387e70B03B8fc331bb1D0e47Ab4681d70e6F15] =   773900000000000000000;
    bountyMembersAmounts[0x7dFaf7EaD8814265FE82253b94603B042E0c9358] =    22000000000000000000;
    bountyMembersAmounts[0x8013DF793d20cD4C13F2Ec31a23D21Cd221612b5] =    22000000000000000000;
    bountyMembersAmounts[0x80ACf6389eD2bCa836522C573039677A35AF795C] =   625000000000000000000;
    bountyMembersAmounts[0x80ead8849D23F0459878b5B3582A80FC20eB88fC] =  2134000000000000000000;
    bountyMembersAmounts[0x812aCA886C5491d471fEaed676f0CD0AEd8bc659] =    10000000000000000000;
    bountyMembersAmounts[0x821De76eeDE1ef45451D3080De748AF06A43910f] =   106000000000000000000;
    bountyMembersAmounts[0x822FD4b17718cadEDEC287aDfc3432Df0700F9c7] =    13000000000000000000;
    bountyMembersAmounts[0x824a66eF9A47e83f03cB9997270F9333CF68A7b8] =    19000000000000000000;
    bountyMembersAmounts[0x82b2eF324E2EC56F9397F243Eeb34E67eB590F80] =   120000000000000000000;
    bountyMembersAmounts[0x82f527b4bad3ff193a31b844b5156edbdf1ac483] =    10000000000000000000;
    bountyMembersAmounts[0x83272588225b466cD2ABA44Bb55e2d0975CD0786] =    57600000000000000000;
    bountyMembersAmounts[0x843F9A13a816Ae5d85336da5eC70e8447b22F429] =  2842000000000000000000;
    bountyMembersAmounts[0x84da87b971860d04CD249517c5E7948db0F893F3] =    10000000000000000000;
    bountyMembersAmounts[0x860131A3726a7a3A66C8f9389EF6273f5d0D6b6D] =    10000000000000000000;
    bountyMembersAmounts[0x89095edc877ed4ed7d201c9c76edb68baa187e2b] =  3931000000000000000000;
    bountyMembersAmounts[0x89c0236789A3Bc8f4Ed06be1863a3817f99B5dce] =    10000000000000000000;
    bountyMembersAmounts[0x8A3A160decF48fD70d99Fda9F386DD1eA41d17DF] =    29000000000000000000;
    bountyMembersAmounts[0x8e09Ac8b853c9534B1900C33CA8D026D24077953] =    22000000000000000000;
    bountyMembersAmounts[0x8e7Ef98A7284652cbF72F9D701Cc1161DBe7A374] =    37000000000000000000;
    bountyMembersAmounts[0x8fEB62d9dBb8daCAD4d49e7C8cc93Db1aC584166] =    10000000000000000000;
    bountyMembersAmounts[0x900A7b05cB1e3fBCD699F8dF9c9399ff9d1CbEd2] =  1705990000000000000000;
    bountyMembersAmounts[0x904c47031357936799B76CbA53DBAD59855603fC] =    13000000000000000000;
    bountyMembersAmounts[0x90b07af0aAA4A705bCC441c2B1D0B581F42bcDB4] =  2339400000000000000000;
    bountyMembersAmounts[0x90D05705eF23bBabB676fFC161A251C3CAe9C966] =    36000000000000000000;
    bountyMembersAmounts[0x9119E1338782C7B9D6Dfe2F579FddC6153FE8397] =  5078880000000000000000;
    bountyMembersAmounts[0x914451625DF60231b7EC04993B5F435B8eE91Eba] =  1930000000000000000000;
    bountyMembersAmounts[0x9273777d99258b7B0ae2255de2B5b3D9d742f507] =    10000000000000000000;
    bountyMembersAmounts[0x9319Df4ed6D20DA8e6E264f4cd04802eA9A56bE2] =  2086000000000000000000;
    bountyMembersAmounts[0x937fe2c8bd616344a9Be33fDEC04D6F15f53c20F] =   230870000000000000000;
    bountyMembersAmounts[0x93C02D733d42fa7Ac36dF84D8285dAe770890e8f] =   226280000000000000000;
    bountyMembersAmounts[0x944E3843f832e1C0E9B5d345FF1245Ba61946675] =   100000000000000000000;
    bountyMembersAmounts[0x94c30dBB7EA6df4FCAd8c8864Edfc9c59cB8Db14] =   140000000000000000000;
    bountyMembersAmounts[0x967668b7795Dd22aAC21e5E4866d6AF8597892D9] =  1270000000000000000000;
    bountyMembersAmounts[0x9692efcb1baf875f72342980ee742352dcb35b20] =   323700000000000000000;
    bountyMembersAmounts[0x96C41b12F88b825594427a75Dda82ae9020a4349] =    31000000000000000000;
    bountyMembersAmounts[0x96d07EB199655D506911b00d6243f3d990832CFE] =    22000000000000000000;
    bountyMembersAmounts[0x99DD75BDFB142E424cDDC3a9dc7bf527CB8Bc4ec] =  2259350000000000000000;
    bountyMembersAmounts[0x9a43047ED2ea4D70Ce5B3B9eC593a5bE91105956] =  1966000000000000000000;
    bountyMembersAmounts[0x9b5619f18c1712d42824c092718BC6Eed8127baE] =  2146000000000000000000;
    bountyMembersAmounts[0x9b58FdE3af8A5E73d8bab9943833dE65d76a0F64] =    19000000000000000000;
    bountyMembersAmounts[0x9C2f0b4123d3e0C3C35d081E61F464f8D609670b] =  5214040000000000000000;
    bountyMembersAmounts[0x9d03F4dC892f7f24e94581bC294DC98183796bDf] =    10000000000000000000;
    bountyMembersAmounts[0x9d98E8520d27610148Bda5c9F3da2CE4f674cc85] =  2086000000000000000000;
    bountyMembersAmounts[0x9eb04d5B0b2159ec6096F41b55C44A36B2D0DE08] =    12000000000000000000;
    bountyMembersAmounts[0x9F39E96a29874aB47a282d5D171F7bD456940589] =  2014000000000000000000;
    bountyMembersAmounts[0xa2175a9b58Ecb1992fD79a04AC37e59a82774005] =  1978000000000000000000;
    bountyMembersAmounts[0xa44c22dce05acda274d77f743864c32c804262d1] = 53187000000000000000000;
    bountyMembersAmounts[0xa4A3D2BB0da871CD891d6F724D268aA21809DffE] =    34000000000000000000;
    bountyMembersAmounts[0xA634550Bb1EcDEf1f648F59Ff159e5bd6e340D38] =    22000000000000000000;
    bountyMembersAmounts[0xA704e8EB038A822bD9D980Fb258bC4998dfc8578] =    18000000000000000000;
    bountyMembersAmounts[0xA7f21A4827831ad52f41977f6a8846534c399b33] =    10000000000000000000;
  } 
}