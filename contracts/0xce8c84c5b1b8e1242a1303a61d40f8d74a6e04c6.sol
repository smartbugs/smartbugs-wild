pragma solidity ^0.4.18;

contract BrandsRefundFond {
  mapping (address => uint256) public people;
  uint256 claim_amount = 16129032250000000;

  address public ceoAddress;
  modifier onlyCEO() { require(msg.sender == ceoAddress); _; }

  function BrandsRefundFond() public {
    ceoAddress = msg.sender;
    people[0x83c0efc6d8b16d87bfe1335ab6bcab3ed3960285] = 1;
    people[0xba2ade9224f68c8d7153c5ebd5dc7cccccf5af01] = 1;
    people[0x0effcec157f88e562eedc76a5c9022ac21f18feb] = 1;
    people[0xa3b61695e46432e5cccd0427ad956fa146379d08] = 1;
    people[0xc95bad7a549d3bf2f0f6d8b83107895135c099e3] = 1;
    people[0x548910a296fe242d3ad054e65b6652f708b9de24] = 1;
    people[0x172f820de0db7e26a5e7a70d322409199e2bfded] = 1;
    people[0xced199fe1d1ee28205d3ca4a7fdb180ae1c33580] = 1;
    people[0x3afabf42e03e0fdc3008e10dd013304f9e530de2] = 1;
    people[0x4f9a04bf67a65a59ef0beb8dcc83f7f3cc5c5d23] = 1;
    people[0xb87e73ad25086c43a16fe5f9589ff265f8a3a9eb] = 1;
    people[0x5c035bb4cb7dacbfee076a5e61aa39a10da2e956] = 1;
    people[0xcde993b6cc5cf39a3087fa166a81769f924146f6] = 1;
    people[0x05ca509d50d4b56474402910aced57394db2b546] = 1;
    people[0xa2381223639181689cd6c46d38a1a4884bb6d83c] = 1;
    people[0x3df86288ae08298c1797ba94ab87bce6b8640e66] = 1;
    people[0x5632ca98e5788eddb2397757aa82d1ed6171e5ad] = 1;
    people[0xb9aaf082eb83621ed7102ff5df4e311801c5e5d0] = 1;
    people[0x576edaa88129ba71825225bb1a9f88805acb34c3] = 1;
    people[0x28d02f67316123dc0293849a0d254ad86b379b34] = 1;
    people[0xd6e8d52be82550b230176b6e9ba49bc3faf43e4a] = 1;
    people[0x519f1b60f268f9309370b9c098edeca678a99f4f] = 1;
    people[0xa443838ad905148232f78f9521577c38932cd832] = 1;
    people[0x644d0dac1cc451c4e987b1ea7e599f6d70d14831] = 1;
    people[0x5e7b20d612ab4bf6b13c864bacd022360627cc83] = 1;
    people[0xbe624aa104b4b1a0d634ddb6c15358f56dcff111] = 1;
    people[0xe820f08968489c466c77c2ea1a5c436d8c70d896] = 1;
    people[0xbd6a9d2c44b571f33ee2192bd2d46aba2866405a] = 1;
    people[0x0659836869772cf479cfcedb659ce6099560b1e5] = 1;
    people[0x86d8221c408026a8fce569660c3783c1b7de391a] = 1;
    people[0xf3c2f29bd3199c33d26cbc31d440f66d2065c4b3] = 1;
    people[0x6f63d5a49ce816e0c8fad2223fa38fd439ec920b] = 1;
    people[0xb03bef1d9659363a9357ab29a05941491accb4ec] = 1;
    people[0x097d2f2ffbf03e0b14e416c05ab55ae8be673073] = 1;
    people[0x2e6236591bfa37c683ce60d6cfde40396a114ff1] = 1;
    people[0xa77c4fe17cfd86a499ade6ecc8b3bee2f698c8e0] = 1;
    people[0x970177d21299548900b4dffcf759a46f9809bab5] = 1;
    people[0x833164041aaff3cd6c7d80affbd923c1d1ceb4b3] = 1;
    people[0x21ffb16fbccc48481e7acafedd8d75bed4258a88] = 1;
    people[0x1de5125581ec31e9f710cb08b6a2506ab3fd69eb] = 1;
    people[0x327bfb6286026bd1a017ba6693e0f47c8b98731b] = 1;
    people[0x21b45dcae6aec9445cdde79ef8b5ef1442e79b00] = 1;
    people[0x6ef05000f40efc75e3d66b37e9584dc807bb28f7] = 1;
    people[0x6132e824e08b78eef93a58108b13497104637122] = 1;
    people[0xafe2b51592b89095a4cfb18da2b5914b528f4c01] = 1;
    people[0x94b66369eec9423011739570f54acabbec4343dd] = 1;
    people[0xf0fd21966c2c3a400b7dc18a74b976a1daeb63f9] = 1;
    people[0x36e058332ae39efad2315776b9c844e30d07388b] = 1;
    people[0x98aec1e4e88564a48331e55b4366f6f4b2e48f24] = 1;
    people[0x3177abbe93422c9525652b5d4e1101a248a99776] = 1;
    people[0x8da4f82dc4d03c5421bb2087f858750c650d8571] = 1;
    people[0x049bed1598655b64f09e4835084fbc502ab1ad86] = 1;
    people[0x3130259deedb3052e24fad9d5e1f490cb8cccaa0] = 1;
    people[0xb622f43c3fe256ee4ec3a33d3ac6cd3c185989c0] = 1;
    people[0xcfe0be2056b20cdd6a3fb5dcd7b809155a25b056] = 1;
    people[0x466acfe9f93d167ea8c8fa6b8515a65aa47784dd] = 1;
    people[0x05f2c11996d73288abe8a31d8b593a693ff2e5d8] = 1;
    people[0x183febd8828a9ac6c70c0e27fbf441b93004fc05] = 1;
    people[0xf7fdb1bce59e83ba8d07c50782270ba315ee62b6] = 1;
  }

  function getPerson(address _address) public view returns (uint256 last_claim) {
    last_claim = people[_address];
  }
  
  function getBalance() public view returns (uint256 balance){
    balance = this.balance;
  }

  function claim() public payable {
    require(msg.sender != address(0));
    require(this.balance > claim_amount);
    require(people[msg.sender] == 1);
    people[msg.sender] = 0;
    msg.sender.transfer(claim_amount);
  }
  
  function add() public payable {
  }

  function payout() public onlyCEO {
    ceoAddress.transfer(this.balance);
  }
}