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

contract FourthBountyWPTpayoutPart1 {
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
    addressOfBountyMembers.push(0x040E1e2981B05507578cA4ef4392237190a1E4f3);
    addressOfBountyMembers.push(0x067d091195f7180Fa668BbBb0699A758d277C6F4);
    addressOfBountyMembers.push(0x00acB4E06Eb8F7ABcFfc1EC6384227cb206b5bd0);
    addressOfBountyMembers.push(0x07f964aBfC00f9571B392d78D0E8D0a303f527E9);
    addressOfBountyMembers.push(0x080829e54b8602d73ec1b93b898701a4ef975c03);
    addressOfBountyMembers.push(0x08A1F6543205e47CbDc52b8BC82cB8b9D070B714);
    addressOfBountyMembers.push(0x08A6aAa41aa5542F3D4c3552093f4677FBf9D5E2);
    addressOfBountyMembers.push(0x08d8b5a44AE4CE1f7a8490f1A9a176d28C4649f5);
    addressOfBountyMembers.push(0x09e9811B51642049700D0900b5E5F909D6EaA978);
    addressOfBountyMembers.push(0x0A0553d29d7Cc6a23e1Ff397C3A0819C82470Bf2);
    addressOfBountyMembers.push(0x0B4973456CAa9549312A4E1603b9fC35c4fCfd4C);
    addressOfBountyMembers.push(0x0B70Cb3FD53Bdc6dF4690f35b31E3990bADA174a);
    addressOfBountyMembers.push(0x0BED0eD0D22a9Bd068F955ca0b66F9981256a4BE);
    addressOfBountyMembers.push(0x0bF33e7C6Ca7C043244Ed9C8D7C95Be9d56D0282);
    addressOfBountyMembers.push(0x0c47609602BC1a8A4c1e7Bbc95e89938DeDB225B);
    addressOfBountyMembers.push(0x0fc0B2b6428c94b13cB644Eb2Bc489Df7FfD03a5);
    addressOfBountyMembers.push(0x10895c30D8d1ED483703DEF7bbCfa986bcb0A8cD);
    addressOfBountyMembers.push(0x112eCfa3b91cC4324aF9A9Bc4f846177dF0e9303);
    addressOfBountyMembers.push(0x132eC9fabbafc29aDF004Fe4433B8b656e5Be093);
    addressOfBountyMembers.push(0x134C07aBc09Adf212483a507a482c207C3BEE721);
    addressOfBountyMembers.push(0x13AbFbaB64D1BF5Ed661C3079962B3479eEa4528);
    addressOfBountyMembers.push(0x152e1e3b7964ed2c4465198c3d1db3c47842787f);
    addressOfBountyMembers.push(0x17303918fF12fD503961EBa5db01848De658729d);
    addressOfBountyMembers.push(0x17DEcde632980aB7a8FFC1bA698Da3b7719427E9);
    addressOfBountyMembers.push(0x17DF42ce8F06281E76bF1f0dcf009701F737E424);
    addressOfBountyMembers.push(0x1981d82819C4d1acD3447ecbBaf7660c88a92F0F);
    addressOfBountyMembers.push(0x1af50bD294BbDd99d6ac0e5CB1c067BfC7818CF3);
    addressOfBountyMembers.push(0x1Bb9EB3922baEBBFdad48e102442306fca73e216);
    addressOfBountyMembers.push(0x1C2C923A8168b607276b422eC05bB101b5579b41);
    addressOfBountyMembers.push(0x1f6CB6cfbb670F0B88aC34Bcc4bF5FF4c25a73c6);
    addressOfBountyMembers.push(0x217EBcF84F1bcB0e3780291a10Dd3b827a3C129f);
    addressOfBountyMembers.push(0x230a23A0756e7CC528021d2e4EFF54DCA2101427);
    addressOfBountyMembers.push(0x239993c2d7F16a6F68bbbF398885ef92ec75C888);
    addressOfBountyMembers.push(0x239F3F8f4f5BA293EE9e38308053FCaa43b37bC6);
    addressOfBountyMembers.push(0x23B6BB922962d35293c2f27C2025A5f2CfbD0B2f);
    addressOfBountyMembers.push(0x24a710d15c6E1339D33fB86B48d22643A5a5E243);
    addressOfBountyMembers.push(0x27561111Bb09D76368343a9c85339Db43D28Fc7D);
    addressOfBountyMembers.push(0x2B61F3BcD23D37d962A707e231bF3C53d1E9cDA7);
    addressOfBountyMembers.push(0x2ca0b69fc3f6d4286F70a3eEC55beF25c1018544);
    addressOfBountyMembers.push(0x2D375a25A80747de74AE9AAE665B2D647cfA4884);
    addressOfBountyMembers.push(0x2E24c2E1C7D69eAf7C17caf8757b3C8AfcDe02D1);
    addressOfBountyMembers.push(0x2e9f5bfb07067df44f31519a80799884431876e1);
    addressOfBountyMembers.push(0x2EBc07B00edc7e628de58895603cDD926B2C259A);
    addressOfBountyMembers.push(0x2f4348327fBa760B8C9307f5f9B3597e865e18E2);
    addressOfBountyMembers.push(0x300dBe667D7142469c4114012b92aCe168D88A31);
    addressOfBountyMembers.push(0x3077D925F4399514a3349b6e812e290CBD0a2154);
    addressOfBountyMembers.push(0x309c76d1aD3d58D6eB77Ba6b573e0A5efA1d3323);
    addressOfBountyMembers.push(0x32be4ABD4e2fd6306890A456e41E1B039Cb61F66);
    addressOfBountyMembers.push(0x34596458488dba489e4b56ddab91061c4850d29b);
    addressOfBountyMembers.push(0x39489361745d55acBF60D4CDB405dCaB5A667d10);
    addressOfBountyMembers.push(0x3a31d9d9120013A2f1F55Ce45068Ed9Ce4795e9F);
    addressOfBountyMembers.push(0x3AE92BC56A517cC7d378FF0e0714479A33C3a7BA);
    addressOfBountyMembers.push(0x3ca7bd100c27894b03bfcd4fc2e95ea4b666533a);
    addressOfBountyMembers.push(0x3D4Af5b6C97e16624981DB89300d3b32Be62f727);
    addressOfBountyMembers.push(0x3ee870e86693703996e441f986caaac31d7a5181);
    addressOfBountyMembers.push(0x402B0a6BBf253C4e44D2953D0AD50efBe4F6eBaa);
    addressOfBountyMembers.push(0x40DB5f92be3baAC1f1E5Cf4F43471f1Ec3501e4e);
    addressOfBountyMembers.push(0x415546D163DC4E004f980d0EDD4DD00B6eb58cE0);
    addressOfBountyMembers.push(0x42B4813d89c65683c8671Eccc5De1F9c3A122140);
    addressOfBountyMembers.push(0x43D9dD1950a78a21c6E615ad7A739eCAbB2F6F23);
    addressOfBountyMembers.push(0x4410d1AE1F2f5e9fc4b6b133C23791e385F3eBc9);
    addressOfBountyMembers.push(0x452c72e0010239e8aE3B53113E1d3E76FA6b3165);
    addressOfBountyMembers.push(0x45334470D78f87E2b6097Ef520cC949ef5d7573F);
    addressOfBountyMembers.push(0x459c6915a08c6B0C7fEE13651Dd9faE6E47FF678);
    addressOfBountyMembers.push(0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF);
    addressOfBountyMembers.push(0x460BAA28e768d0C9D1BFc885ad91B253C3373048);
    addressOfBountyMembers.push(0x4EeCcAAAe00d3E9329476e6e43d40E5895ec8497);
    addressOfBountyMembers.push(0x4F2dED30C27C4A7926B34c697Edd726aE379c3cE);
    addressOfBountyMembers.push(0x56ACb598e1B89CD6Ca7b10C214B9108C543B385e);
    addressOfBountyMembers.push(0x5826fe6d87Bc3088EEaAA8687f8d3e4416e146E8);
    addressOfBountyMembers.push(0x5843787775CF8320C79f9dd60Be228aB0FF51123); 
    addressOfBountyMembers.push(0x5949cdCC43DB6968CC2c79f8a4C72F852C046e34);
    addressOfBountyMembers.push(0x59C5c4b795E9DB078c74BAcC0Fcad5cee75D1050);
    addressOfBountyMembers.push(0x5B3fE56B7cfC456A5E721Df4b2d4A6b7ce7e4710);
    addressOfBountyMembers.push(0x5C29dadDFa7472034bda0B8a218D7c15c7e6a904);
    addressOfBountyMembers.push(0x5c50564cEEEb5B85CFeeC31572A748cC1185356c);
    addressOfBountyMembers.push(0x5e175bE4d23Fa25604CE7848F60FB340894D5CDA);
    addressOfBountyMembers.push(0x5f2B0CaBFdBf8dD4b6D941C4d53CF34F4efB2c9F);
    addressOfBountyMembers.push(0x605AAEfBe961114032a9a65e5963801eaEd0A25C);
    addressOfBountyMembers.push(0x60cf7c40148370579133Fcf4e2bAe9Deec18ffb2);
    addressOfBountyMembers.push(0x6169852ed50B5E59E998279109dACF0882414A59);
    addressOfBountyMembers.push(0x634FbD8206EE0AaFB1E11522321Eec145825af1d);
    addressOfBountyMembers.push(0x63515D455393dDc5F8F321dd084d1bd000545573);
    addressOfBountyMembers.push(0x65faE6F3b14a962E77cf99B3eceBe4a606b9BAa9);
    addressOfBountyMembers.push(0x66e5D5824689207A0A08367D727D01673edaa878);
    addressOfBountyMembers.push(0x680B04d71c0Fd3846E74C361Ad6125D58ec8a943);
    addressOfBountyMembers.push(0x689b5562b839851efF4c65F5783C59c11567d25D);
    addressOfBountyMembers.push(0x6e414d17eE6A80f9fAc326a0b79364Bde6Ae0B9f);
    addressOfBountyMembers.push(0x6e9c261D10575c87fE8724c54ccD26e59F77101a);
    addressOfBountyMembers.push(0x6ed8eb597f47079e03c5913f8a010c7dec4e9185);
    addressOfBountyMembers.push(0x70141ba86851D8A611fA79718D088bbfE39C9954);
    addressOfBountyMembers.push(0x70C1616E0BF5AF960bedB0B2cdE710487831A2B0);
    addressOfBountyMembers.push(0x73274282F25E91D0D1724e09e9fF9bd250e3377A);
    addressOfBountyMembers.push(0x733FF886E1B196e2Bd38829043efFE0971220479);
    addressOfBountyMembers.push(0x74bc3222a9609f4673b2c5b1c162defb9952e663);
    addressOfBountyMembers.push(0x74Ee49Cd610553D3e7f83bEe1873020ae1ddB469);
    addressOfBountyMembers.push(0x75f98535B0fB0F738c65fE25b7a6DD1E9C1286B1);
    addressOfBountyMembers.push(0x76ef754D7d1116F6CA912f877c88b777184670b1);
    addressOfBountyMembers.push(0x780e64F06c13525CD4F09d069622D95d4E82D66E);
  }

  function setBountyAmounts() internal { 
    bountyMembersAmounts[0x040E1e2981B05507578cA4ef4392237190a1E4f3] =   302000000000000000000;
    bountyMembersAmounts[0x067d091195f7180Fa668BbBb0699A758d277C6F4] =   260000000000000000000;
    bountyMembersAmounts[0x00acB4E06Eb8F7ABcFfc1EC6384227cb206b5bd0] =   801200000000000000000;
    bountyMembersAmounts[0x07f964aBfC00f9571B392d78D0E8D0a303f527E9] =   121000000000000000000;
    bountyMembersAmounts[0x080829e54b8602d73ec1b93b898701a4ef975c03] =  4658000000000000000000;
    bountyMembersAmounts[0x08A1F6543205e47CbDc52b8BC82cB8b9D070B714] =   135000000000000000000;
    bountyMembersAmounts[0x08A6aAa41aa5542F3D4c3552093f4677FBf9D5E2] =   246000000000000000000;
    bountyMembersAmounts[0x08d8b5a44AE4CE1f7a8490f1A9a176d28C4649f5] =  1178950000000000000000;
    bountyMembersAmounts[0x09e9811B51642049700D0900b5E5F909D6EaA978] =   100000000000000000000;
    bountyMembersAmounts[0x0A0553d29d7Cc6a23e1Ff397C3A0819C82470Bf2] =  1082000000000000000000;
    bountyMembersAmounts[0x0B4973456CAa9549312A4E1603b9fC35c4fCfd4C] =   107000000000000000000;
    bountyMembersAmounts[0x0B70Cb3FD53Bdc6dF4690f35b31E3990bADA174a] =  1131000000000000000000;
    bountyMembersAmounts[0x0BED0eD0D22a9Bd068F955ca0b66F9981256a4BE] =   771000000000000000000;
    bountyMembersAmounts[0x0bF33e7C6Ca7C043244Ed9C8D7C95Be9d56D0282] =   306000000000000000000;
    bountyMembersAmounts[0x0c47609602BC1a8A4c1e7Bbc95e89938DeDB225B] =   160000000000000000000;
    bountyMembersAmounts[0x0fc0B2b6428c94b13cB644Eb2Bc489Df7FfD03a5] =   184000000000000000000;
    bountyMembersAmounts[0x10895c30D8d1ED483703DEF7bbCfa986bcb0A8cD] =   140000000000000000000;
    bountyMembersAmounts[0x112eCfa3b91cC4324aF9A9Bc4f846177dF0e9303] =   239000000000000000000;
    bountyMembersAmounts[0x132eC9fabbafc29aDF004Fe4433B8b656e5Be093] =   102000000000000000000;
    bountyMembersAmounts[0x134C07aBc09Adf212483a507a482c207C3BEE721] =  1004000000000000000000;
    bountyMembersAmounts[0x13AbFbaB64D1BF5Ed661C3079962B3479eEa4528] =   550000000000000000000;
    bountyMembersAmounts[0x152e1e3b7964ed2c4465198c3d1db3c47842787f] =  3398000000000000000000;
    bountyMembersAmounts[0x17303918fF12fD503961EBa5db01848De658729d] =   100000000000000000000;
    bountyMembersAmounts[0x17DEcde632980aB7a8FFC1bA698Da3b7719427E9] =   128000000000000000000;
    bountyMembersAmounts[0x17DF42ce8F06281E76bF1f0dcf009701F737E424] =   858000000000000000000;
    bountyMembersAmounts[0x1981d82819C4d1acD3447ecbBaf7660c88a92F0F] =   102000000000000000000;
    bountyMembersAmounts[0x1af50bD294BbDd99d6ac0e5CB1c067BfC7818CF3] =   139000000000000000000;
    bountyMembersAmounts[0x1Bb9EB3922baEBBFdad48e102442306fca73e216] =  4481460000000000000000;
    bountyMembersAmounts[0x1C2C923A8168b607276b422eC05bB101b5579b41] =   104000000000000000000;
    bountyMembersAmounts[0x1f6CB6cfbb670F0B88aC34Bcc4bF5FF4c25a73c6] =   120000000000000000000;
    bountyMembersAmounts[0x217EBcF84F1bcB0e3780291a10Dd3b827a3C129f] =  1407000000000000000000;
    bountyMembersAmounts[0x230a23A0756e7CC528021d2e4EFF54DCA2101427] =   195000000000000000000;
    bountyMembersAmounts[0x239993c2d7F16a6F68bbbF398885ef92ec75C888] =   102000000000000000000;
    bountyMembersAmounts[0x239F3F8f4f5BA293EE9e38308053FCaa43b37bC6] =   104000000000000000000;
    bountyMembersAmounts[0x23B6BB922962d35293c2f27C2025A5f2CfbD0B2f] =   114000000000000000000;
    bountyMembersAmounts[0x24a710d15c6E1339D33fB86B48d22643A5a5E243] =   145000000000000000000;
    bountyMembersAmounts[0x27561111Bb09D76368343a9c85339Db43D28Fc7D] =   200000000000000000000;
    bountyMembersAmounts[0x2B61F3BcD23D37d962A707e231bF3C53d1E9cDA7] =   108000000000000000000;
    bountyMembersAmounts[0x2ca0b69fc3f6d4286F70a3eEC55beF25c1018544] =   118000000000000000000;
    bountyMembersAmounts[0x2D375a25A80747de74AE9AAE665B2D647cfA4884] =   185000000000000000000;
    bountyMembersAmounts[0x2E24c2E1C7D69eAf7C17caf8757b3C8AfcDe02D1] =   226000000000000000000;
    bountyMembersAmounts[0x2e9f5bfb07067df44f31519a80799884431876e1] =   126000000000000000000;
    bountyMembersAmounts[0x2EBc07B00edc7e628de58895603cDD926B2C259A] =   108000000000000000000;
    bountyMembersAmounts[0x2f4348327fBa760B8C9307f5f9B3597e865e18E2] =   113000000000000000000;
    bountyMembersAmounts[0x300dBe667D7142469c4114012b92aCe168D88A31] =   524000000000000000000;
    bountyMembersAmounts[0x3077D925F4399514a3349b6e812e290CBD0a2154] =   313000000000000000000;
    bountyMembersAmounts[0x309c76d1aD3d58D6eB77Ba6b573e0A5efA1d3323] =   102000000000000000000;
    bountyMembersAmounts[0x32be4ABD4e2fd6306890A456e41E1B039Cb61F66] =  2002725000000000000000;
    bountyMembersAmounts[0x34596458488dba489e4b56ddab91061c4850d29b] =   108000000000000000000;
    bountyMembersAmounts[0x39489361745d55acBF60D4CDB405dCaB5A667d10] =   104000000000000000000;
    bountyMembersAmounts[0x3a31d9d9120013A2f1F55Ce45068Ed9Ce4795e9F] =   128000000000000000000;
    bountyMembersAmounts[0x3AE92BC56A517cC7d378FF0e0714479A33C3a7BA] =   119000000000000000000;
    bountyMembersAmounts[0x3ca7bd100c27894b03bfcd4fc2e95ea4b666533a] =   135000000000000000000;
    bountyMembersAmounts[0x3D4Af5b6C97e16624981DB89300d3b32Be62f727] =   167000000000000000000;
    bountyMembersAmounts[0x3ee870e86693703996e441f986caaac31d7a5181] =   138000000000000000000;
    bountyMembersAmounts[0x402B0a6BBf253C4e44D2953D0AD50efBe4F6eBaa] = 40420000000000000000000;
    bountyMembersAmounts[0x40DB5f92be3baAC1f1E5Cf4F43471f1Ec3501e4e] =   145000000000000000000;
    bountyMembersAmounts[0x415546D163DC4E004f980d0EDD4DD00B6eb58cE0] =   139000000000000000000;
    bountyMembersAmounts[0x42B4813d89c65683c8671Eccc5De1F9c3A122140] =   200000000000000000000;
    bountyMembersAmounts[0x43D9dD1950a78a21c6E615ad7A739eCAbB2F6F23] =   114000000000000000000;
    bountyMembersAmounts[0x4410d1AE1F2f5e9fc4b6b133C23791e385F3eBc9] =   237000000000000000000;
    bountyMembersAmounts[0x452c72e0010239e8aE3B53113E1d3E76FA6b3165] =   126000000000000000000;
    bountyMembersAmounts[0x45334470D78f87E2b6097Ef520cC949ef5d7573F] =   104000000000000000000;
    bountyMembersAmounts[0x459c6915a08c6B0C7fEE13651Dd9faE6E47FF678] =   264000000000000000000;
    bountyMembersAmounts[0x45E72304e39A5b18C8cC3DE7C21F637065FF76BF] =  1866000000000000000000;
    bountyMembersAmounts[0x460BAA28e768d0C9D1BFc885ad91B253C3373048] =   747000000000000000000;
    bountyMembersAmounts[0x4EeCcAAAe00d3E9329476e6e43d40E5895ec8497] =   800000000000000000000;
    bountyMembersAmounts[0x4F2dED30C27C4A7926B34c697Edd726aE379c3cE] =   102000000000000000000;
    bountyMembersAmounts[0x56ACb598e1B89CD6Ca7b10C214B9108C543B385e] =   124000000000000000000;
    bountyMembersAmounts[0x5826fe6d87Bc3088EEaAA8687f8d3e4416e146E8] =   104000000000000000000;
    bountyMembersAmounts[0x5843787775CF8320C79f9dd60Be228aB0FF51123] =   100000000000000000000;
    bountyMembersAmounts[0x5949cdCC43DB6968CC2c79f8a4C72F852C046e34] =   882000000000000000000;
    bountyMembersAmounts[0x59C5c4b795E9DB078c74BAcC0Fcad5cee75D1050] =   102000000000000000000;
    bountyMembersAmounts[0x5B3fE56B7cfC456A5E721Df4b2d4A6b7ce7e4710] =   102000000000000000000;
    bountyMembersAmounts[0x5C29dadDFa7472034bda0B8a218D7c15c7e6a904] =   132000000000000000000;
    bountyMembersAmounts[0x5c50564cEEEb5B85CFeeC31572A748cC1185356c] =   116000000000000000000;
    bountyMembersAmounts[0x5e175bE4d23Fa25604CE7848F60FB340894D5CDA] =   105000000000000000000;
    bountyMembersAmounts[0x5f2B0CaBFdBf8dD4b6D941C4d53CF34F4efB2c9F] =   125000000000000000000;
    bountyMembersAmounts[0x605AAEfBe961114032a9a65e5963801eaEd0A25C] =   120000000000000000000;
    bountyMembersAmounts[0x60cf7c40148370579133Fcf4e2bAe9Deec18ffb2] =   104000000000000000000;
    bountyMembersAmounts[0x6169852ed50B5E59E998279109dACF0882414A59] =   108000000000000000000;
    bountyMembersAmounts[0x634FbD8206EE0AaFB1E11522321Eec145825af1d] =   187000000000000000000;
    bountyMembersAmounts[0x63515D455393dDc5F8F321dd084d1bd000545573] =   104000000000000000000;
    bountyMembersAmounts[0x65faE6F3b14a962E77cf99B3eceBe4a606b9BAa9] =   156000000000000000000;
    bountyMembersAmounts[0x66e5D5824689207A0A08367D727D01673edaa878] =   402000000000000000000;
    bountyMembersAmounts[0x680B04d71c0Fd3846E74C361Ad6125D58ec8a943] =   985000000000000000000;
    bountyMembersAmounts[0x689b5562b839851efF4c65F5783C59c11567d25D] =   414000000000000000000;
    bountyMembersAmounts[0x6e414d17eE6A80f9fAc326a0b79364Bde6Ae0B9f] =   128000000000000000000;
    bountyMembersAmounts[0x6e9c261D10575c87fE8724c54ccD26e59F77101a] =   102000000000000000000;
    bountyMembersAmounts[0x6ed8eb597f47079e03c5913f8a010c7dec4e9185] =   102000000000000000000;
    bountyMembersAmounts[0x70141ba86851D8A611fA79718D088bbfE39C9954] =   104000000000000000000;
    bountyMembersAmounts[0x70C1616E0BF5AF960bedB0B2cdE710487831A2B0] =  1638000000000000000000;
    bountyMembersAmounts[0x73274282F25E91D0D1724e09e9fF9bd250e3377A] =   100000000000000000000;
    bountyMembersAmounts[0x733FF886E1B196e2Bd38829043efFE0971220479] =   807000000000000000000;
    bountyMembersAmounts[0x74bc3222a9609f4673b2c5b1c162defb9952e663] =   220000000000000000000;
    bountyMembersAmounts[0x74Ee49Cd610553D3e7f83bEe1873020ae1ddB469] =   104000000000000000000;
    bountyMembersAmounts[0x75f98535B0fB0F738c65fE25b7a6DD1E9C1286B1] =   149000000000000000000;
    bountyMembersAmounts[0x76ef754D7d1116F6CA912f877c88b777184670b1] =   218000000000000000000;
    bountyMembersAmounts[0x780e64F06c13525CD4F09d069622D95d4E82D66E] =   103000000000000000000;
  } 
}