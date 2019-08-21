pragma solidity ^0.4.10;

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _allowance = allowed[_from][msg.sender];

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract CccTokenIco is StandardToken {
    using SafeMath for uint256;
    string public name = "Crypto Credit Card Token";
    string public symbol = "CCCR";
    uint8 public constant decimals = 6;
    
    uint256 public cntMembers = 0;
    uint256 public totalSupply = 200000000 * (uint256(10) ** decimals);
    uint256 public totalRaised;

    uint256 public startTimestamp;
    uint256 public durationSeconds = uint256(86400 * 93);//93 days - 15/11/17-16/02/18

    uint256 public minCap = 3000000 * (uint256(10) ** decimals);
    uint256 public maxCap = 200000000 * (uint256(10) ** decimals);
    
    uint256 public avgRate = uint256(uint256(10)**(18-decimals)).div(707);

    address public stuff = 0x0CcCb9bAAdD61F9e0ab25bD782765013817821bD;
    address public teama = 0xfc6851324e2901b3ea6170a90Cc43BFe667D617A;
    address public teamb = 0x21f0F5E81BEF4dc696C6BF0196c60a1aC797f953;
    address public teamc = 0xE8726942a46E6C6B3C1F061c14a15c0053A97B6b;
    address public teamd = 0xe388423Bc655543568dd5b454F47AeD2B304710F;
    address public teame = 0xa31B987F467aFF700F322105126619496955f503;
    address public founder = 0xbb2efFab932a4c2f77Fc1617C1a563738D71B0a7;
    address public baseowner;

    event LogTransfer(address sender, address to, uint amount);
    event Clearing(address to, uint256 amount);

    function CccTokenIco(
    ) 
    {
        cntMembers = 0;
        startTimestamp = now - 34 days;//19.12.2017
        baseowner = msg.sender;
        balances[baseowner] = totalSupply;
        Transfer(0x0, baseowner, totalSupply);

        ///carry out token holders from previous contract instance
        
        balances[baseowner] = balances[baseowner].sub(500003530122);
        balances[0x0cb9cb4723c1764d26b3ab38fec121d0390d5e12] = balances[0x0cb9cb4723c1764d26b3ab38fec121d0390d5e12].add(500003530122);
        Transfer(baseowner, 0x0cb9cb4723c1764d26b3ab38fec121d0390d5e12, 500003530122);

        balances[baseowner] = balances[baseowner].sub(276000000009);
        balances[0xaa00a534093975ac45ecac2365e40b2f81cf554b] = balances[0xaa00a534093975ac45ecac2365e40b2f81cf554b].add(276000000009);
        Transfer(baseowner, 0xaa00a534093975ac45ecac2365e40b2f81cf554b, 276000000009);

        balances[baseowner] = balances[baseowner].sub(200000000012);
        balances[0xdaeb100e594bec89aa8282d5b0f54e01100559b0] = balances[0xdaeb100e594bec89aa8282d5b0f54e01100559b0].add(200000000012);
        Transfer(baseowner, 0xdaeb100e594bec89aa8282d5b0f54e01100559b0, 200000000012);

        balances[baseowner] = balances[baseowner].sub(31740000001);
        balances[0x7fc4662f19e83c986a4b8d3160ee9a0582ac45a2] = balances[0x7fc4662f19e83c986a4b8d3160ee9a0582ac45a2].add(31740000001);
        Transfer(baseowner, 0x7fc4662f19e83c986a4b8d3160ee9a0582ac45a2, 31740000001);

        balances[baseowner] = balances[baseowner].sub(27318424808);
        balances[0xedfd6f7b43a4e2cdc39975b61965302c47c523cb] = balances[0xedfd6f7b43a4e2cdc39975b61965302c47c523cb].add(27318424808);
        Transfer(baseowner, 0xedfd6f7b43a4e2cdc39975b61965302c47c523cb, 27318424808);

        balances[baseowner] = balances[baseowner].sub(24130680006);
        balances[0x911af73f46c16f0682c707fdc46b3e5a9b756dfc] = balances[0x911af73f46c16f0682c707fdc46b3e5a9b756dfc].add(24130680006);
        Transfer(baseowner, 0x911af73f46c16f0682c707fdc46b3e5a9b756dfc, 24130680006);

        balances[baseowner] = balances[baseowner].sub(15005580557);
        balances[0x2cec090622838aa3abadd176290dea1bbd506466] = balances[0x2cec090622838aa3abadd176290dea1bbd506466].add(15005580557);
        Transfer(baseowner, 0x2cec090622838aa3abadd176290dea1bbd506466, 15005580557);

        balances[baseowner] = balances[baseowner].sub(9660000004);
        balances[0xf023fa938d0fed67e944b3df2efaa344c7a9bfb1] = balances[0xf023fa938d0fed67e944b3df2efaa344c7a9bfb1].add(9660000004);
        Transfer(baseowner, 0xf023fa938d0fed67e944b3df2efaa344c7a9bfb1, 9660000004);

        balances[baseowner] = balances[baseowner].sub(2652719081);
        balances[0xb63a69b443969139766e5734c50b2049297bf335] = balances[0xb63a69b443969139766e5734c50b2049297bf335].add(2652719081);
        Transfer(baseowner, 0xb63a69b443969139766e5734c50b2049297bf335, 2652719081);

        balances[baseowner] = balances[baseowner].sub(2460000000);
        balances[0xf8e55ebe2cc6cf9112a94c037046e2be3700ef3f] = balances[0xf8e55ebe2cc6cf9112a94c037046e2be3700ef3f].add(2460000000);
        Transfer(baseowner, 0xf8e55ebe2cc6cf9112a94c037046e2be3700ef3f, 2460000000);

        balances[baseowner] = balances[baseowner].sub(2351000007);
        balances[0x6245f92acebe1d59af8497ca8e9edc6d3fe586dd] = balances[0x6245f92acebe1d59af8497ca8e9edc6d3fe586dd].add(2351000007);
        Transfer(baseowner, 0x6245f92acebe1d59af8497ca8e9edc6d3fe586dd, 2351000007);

        balances[baseowner] = balances[baseowner].sub(1717313037);
        balances[0x2a8002c6ef65179bf4ba4ea6bcfda7a599b30a7f] = balances[0x2a8002c6ef65179bf4ba4ea6bcfda7a599b30a7f].add(1717313037);
        Transfer(baseowner, 0x2a8002c6ef65179bf4ba4ea6bcfda7a599b30a7f, 1717313037);

        balances[baseowner] = balances[baseowner].sub(1419509002);
        balances[0x5e454499faec83dc1aa65d9f0164fb558f9bfdef] = balances[0x5e454499faec83dc1aa65d9f0164fb558f9bfdef].add(1419509002);
        Transfer(baseowner, 0x5e454499faec83dc1aa65d9f0164fb558f9bfdef, 1419509002);

        balances[baseowner] = balances[baseowner].sub(1265308761);
        balances[0x77d7ab3250f88d577fda9136867a3e9c2f29284b] = balances[0x77d7ab3250f88d577fda9136867a3e9c2f29284b].add(1265308761);
        Transfer(baseowner, 0x77d7ab3250f88d577fda9136867a3e9c2f29284b, 1265308761);

        balances[baseowner] = balances[baseowner].sub(1009138801);
        balances[0x60a1db27141cbab745a66f162e68103f2a4f2205] = balances[0x60a1db27141cbab745a66f162e68103f2a4f2205].add(1009138801);
        Transfer(baseowner, 0x60a1db27141cbab745a66f162e68103f2a4f2205, 1009138801);

        balances[baseowner] = balances[baseowner].sub(941571961);
        balances[0xab58b3d1866065353bf25dbb813434a216afd99d] = balances[0xab58b3d1866065353bf25dbb813434a216afd99d].add(941571961);
        Transfer(baseowner, 0xab58b3d1866065353bf25dbb813434a216afd99d, 941571961);

        balances[baseowner] = balances[baseowner].sub(694928265);
        balances[0x8b545e68cf9363e09726e088a3660191eb7152e4] = balances[0x8b545e68cf9363e09726e088a3660191eb7152e4].add(694928265);
        Transfer(baseowner, 0x8b545e68cf9363e09726e088a3660191eb7152e4, 694928265);

        balances[baseowner] = balances[baseowner].sub(688204065);
        balances[0xa5add2ea6fde2abb80832ef9b6bdf723e1eb894e] = balances[0xa5add2ea6fde2abb80832ef9b6bdf723e1eb894e].add(688204065);
        Transfer(baseowner, 0xa5add2ea6fde2abb80832ef9b6bdf723e1eb894e, 688204065);

        balances[baseowner] = balances[baseowner].sub(671272463);
        balances[0xb4c56ab33eaecc6a1567d3f45e9483b0a529ac17] = balances[0xb4c56ab33eaecc6a1567d3f45e9483b0a529ac17].add(671272463);
        Transfer(baseowner, 0xb4c56ab33eaecc6a1567d3f45e9483b0a529ac17, 671272463);

        balances[baseowner] = balances[baseowner].sub(633682839);
        balances[0xd912f08de16beecab4cc8f1947c119caf6852cf4] = balances[0xd912f08de16beecab4cc8f1947c119caf6852cf4].add(633682839);
        Transfer(baseowner, 0xd912f08de16beecab4cc8f1947c119caf6852cf4, 633682839);

        balances[baseowner] = balances[baseowner].sub(633668277);
        balances[0xdc4b279fd978d248bef6c783c2c937f75855537e] = balances[0xdc4b279fd978d248bef6c783c2c937f75855537e].add(633668277);
        Transfer(baseowner, 0xdc4b279fd978d248bef6c783c2c937f75855537e, 633668277);

        balances[baseowner] = balances[baseowner].sub(632418818);
        balances[0x7399a52d49139c9593ea40c11f2f296ca037a18a] = balances[0x7399a52d49139c9593ea40c11f2f296ca037a18a].add(632418818);
        Transfer(baseowner, 0x7399a52d49139c9593ea40c11f2f296ca037a18a, 632418818);

        balances[baseowner] = balances[baseowner].sub(570202760);
        balances[0xbb4691d4dff55fb110f996d029900e930060fe48] = balances[0xbb4691d4dff55fb110f996d029900e930060fe48].add(570202760);
        Transfer(baseowner, 0xbb4691d4dff55fb110f996d029900e930060fe48, 570202760);

        balances[baseowner] = balances[baseowner].sub(428950000);
        balances[0x826fa4d3b34893e033b6922071b55c1de8074380] = balances[0x826fa4d3b34893e033b6922071b55c1de8074380].add(428950000);
        Transfer(baseowner, 0x826fa4d3b34893e033b6922071b55c1de8074380, 428950000);

        balances[baseowner] = balances[baseowner].sub(334650000);
        balances[0x12f3f72fb89f86110d666337c6cb49f3db4b15de] = balances[0x12f3f72fb89f86110d666337c6cb49f3db4b15de].add(334650000);
        Transfer(baseowner, 0x12f3f72fb89f86110d666337c6cb49f3db4b15de, 334650000);

        balances[baseowner] = balances[baseowner].sub(276000007);
        balances[0x65f34b34b2c5da1f1469f4165f4369242edbbec5] = balances[0x65f34b34b2c5da1f1469f4165f4369242edbbec5].add(276000007);
        Transfer(baseowner, 0xbb4691d4dff55fb110f996d029900e930060fe48, 276000007);

        balances[baseowner] = balances[baseowner].sub(181021555);
        balances[0x750b5f444a79895d877a821dfce321a9b00e77b3] = balances[0x750b5f444a79895d877a821dfce321a9b00e77b3].add(181021555);
        Transfer(baseowner, 0x750b5f444a79895d877a821dfce321a9b00e77b3, 181021555);

        balances[baseowner] = balances[baseowner].sub(143520151);
        balances[0x8d88391bfcb5d3254f82addba383523907e028bc] = balances[0x8d88391bfcb5d3254f82addba383523907e028bc].add(143520151);
        Transfer(baseowner, 0x8d88391bfcb5d3254f82addba383523907e028bc, 143520151);

        balances[baseowner] = balances[baseowner].sub(131825237);
        balances[0xf0db27cdabcc02ede5aee9574241a84af930f08e] = balances[0xf0db27cdabcc02ede5aee9574241a84af930f08e].add(131825237);
        Transfer(baseowner, 0xf0db27cdabcc02ede5aee9574241a84af930f08e, 131825237);

        balances[baseowner] = balances[baseowner].sub(99525370);
        balances[0x27bd1a5c0f6e66e6d82475fa7aff3e575e0d79d3] = balances[0x27bd1a5c0f6e66e6d82475fa7aff3e575e0d79d3].add(99525370);
        Transfer(baseowner, 0x27bd1a5c0f6e66e6d82475fa7aff3e575e0d79d3, 99525370);

		
        balances[baseowner] = balances[baseowner].sub(71712001);
        balances[0xc19aab396d51f7fa9d8a9c147ed77b681626d074] = balances[0xc19aab396d51f7fa9d8a9c147ed77b681626d074].add(71712001);
        Transfer(baseowner, 0xc19aab396d51f7fa9d8a9c147ed77b681626d074, 71712001);

        balances[baseowner] = balances[baseowner].sub(69000011);
        balances[0x1b90b11b8e82ae5a2601f143ebb6812cc18c7461] = balances[0x1b90b11b8e82ae5a2601f143ebb6812cc18c7461].add(69000011);
        Transfer(baseowner, 0x1b90b11b8e82ae5a2601f143ebb6812cc18c7461, 69000011);

        balances[baseowner] = balances[baseowner].sub(55873094);
        balances[0x9b4bccee634ffe55b70ee568d9f9c357c6efccb0] = balances[0x9b4bccee634ffe55b70ee568d9f9c357c6efccb0].add(55873094);
        Transfer(baseowner, 0x9b4bccee634ffe55b70ee568d9f9c357c6efccb0, 55873094);

        balances[baseowner] = balances[baseowner].sub(42465543);
        balances[0xa404999fa8815c53e03d238f3355dce64d7a533a] = balances[0xa404999fa8815c53e03d238f3355dce64d7a533a].add(42465543);
        Transfer(baseowner, 0xa404999fa8815c53e03d238f3355dce64d7a533a, 42465543);

        balances[baseowner] = balances[baseowner].sub(40228798);
        balances[0xdae37bde109b920a41d7451931c0ce7dd824d39a] = balances[0xdae37bde109b920a41d7451931c0ce7dd824d39a].add(40228798);
        Transfer(baseowner, 0xdae37bde109b920a41d7451931c0ce7dd824d39a, 40228798);

        balances[baseowner] = balances[baseowner].sub(27600006);
        balances[0x6f44062ec1287e4b6890c9df34571109894d2d5b] = balances[0x6f44062ec1287e4b6890c9df34571109894d2d5b].add(27600006);
        Transfer(baseowner, 0x6f44062ec1287e4b6890c9df34571109894d2d5b, 27600006);

        balances[baseowner] = balances[baseowner].sub(26027997);
        balances[0x5f1c5a1c4d275f8e41eafa487f45800efc6717bf] = balances[0x5f1c5a1c4d275f8e41eafa487f45800efc6717bf].add(26027997);
        Transfer(baseowner, 0x5f1c5a1c4d275f8e41eafa487f45800efc6717bf, 26027997);

        balances[baseowner] = balances[baseowner].sub(13800009);
        balances[0xfc35a274ae440d4804e9fc00cc3ceda4a7eda3b8] = balances[0xfc35a274ae440d4804e9fc00cc3ceda4a7eda3b8].add(13800009);
        Transfer(baseowner, 0xfc35a274ae440d4804e9fc00cc3ceda4a7eda3b8, 13800009);

        balances[baseowner] = balances[baseowner].sub(13463420);
        balances[0x0f4e5dde970f2bdc9fd079efcb2f4630d6deebbf] = balances[0x0f4e5dde970f2bdc9fd079efcb2f4630d6deebbf].add(13463420);
        Transfer(baseowner, 0x0f4e5dde970f2bdc9fd079efcb2f4630d6deebbf, 13463420);

        balances[baseowner] = balances[baseowner].sub(2299998);
        balances[0x7b6b64c0b9673a2a4400d0495f44eaf79b56b69e] = balances[0x7b6b64c0b9673a2a4400d0495f44eaf79b56b69e].add(2299998);
        Transfer(baseowner, 0x7b6b64c0b9673a2a4400d0495f44eaf79b56b69e, 2299998);

        balances[baseowner] = balances[baseowner].sub(1993866);
        balances[0x74a4d45b8bb857f627229b94cf2b9b74308c61bb] = balances[0x74a4d45b8bb857f627229b94cf2b9b74308c61bb].add(1993866);
        Transfer(baseowner, 0x74a4d45b8bb857f627229b94cf2b9b74308c61bb, 1993866);

        cntMembers = cntMembers.add(41);

    }

    function bva(address partner, uint256 value, uint256 rate, address adviser) isIcoOpen payable public 
    {
      uint256 tokenAmount = calculateTokenAmount(value);
      if(msg.value != 0)
      {
        tokenAmount = calculateTokenCount(msg.value,avgRate);
      }else
      {
        require(msg.sender == stuff);
        avgRate = avgRate.add(rate).div(2);
      }
      if(msg.value != 0)
      {
        Clearing(teama, msg.value.mul(6).div(100));
        teama.transfer(msg.value.mul(6).div(100));
        Clearing(teamb, msg.value.mul(6).div(1000));
        teamb.transfer(msg.value.mul(6).div(1000));
        Clearing(teamc, msg.value.mul(6).div(1000));
        teamc.transfer(msg.value.mul(6).div(1000));
        Clearing(teamd, msg.value.mul(1).div(100));
        teamd.transfer(msg.value.mul(1).div(100));
        Clearing(teame, msg.value.mul(9).div(1000));
        teame.transfer(msg.value.mul(9).div(1000));
        Clearing(stuff, msg.value.mul(9).div(1000));
        stuff.transfer(msg.value.mul(9).div(1000));
        Clearing(founder, msg.value.mul(70).div(100));
        founder.transfer(msg.value.mul(70).div(100));
        if(partner != adviser)
        {
          Clearing(adviser, msg.value.mul(20).div(100));
          adviser.transfer(msg.value.mul(20).div(100));
        }else
        {
          Clearing(founder, msg.value.mul(20).div(100));
          founder.transfer(msg.value.mul(20).div(100));
        } 
      }
      totalRaised = totalRaised.add(tokenAmount);
      balances[baseowner] = balances[baseowner].sub(tokenAmount);
      balances[partner] = balances[partner].add(tokenAmount);
      Transfer(baseowner, partner, tokenAmount);
      cntMembers = cntMembers.add(1);
    }
    
    function() isIcoOpen payable public
    {
      if(msg.value != 0)
      {
        uint256 tokenAmount = calculateTokenCount(msg.value,avgRate);
        Clearing(teama, msg.value.mul(6).div(100));
        teama.transfer(msg.value.mul(6).div(100));
        Clearing(teamb, msg.value.mul(6).div(1000));
        teamb.transfer(msg.value.mul(6).div(1000));
        Clearing(teamc, msg.value.mul(6).div(1000));
        teamc.transfer(msg.value.mul(6).div(1000));
        Clearing(teamd, msg.value.mul(1).div(100));
        teamd.transfer(msg.value.mul(1).div(100));
        Clearing(teame, msg.value.mul(9).div(1000));
        teame.transfer(msg.value.mul(9).div(1000));
        Clearing(stuff, msg.value.mul(9).div(1000));
        stuff.transfer(msg.value.mul(9).div(1000));
        Clearing(founder, msg.value.mul(90).div(100));
        founder.transfer(msg.value.mul(90).div(100));
        totalRaised = totalRaised.add(tokenAmount);
        balances[baseowner] = balances[baseowner].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        Transfer(baseowner, msg.sender, tokenAmount);
        cntMembers = cntMembers.add(1);
      }
    }

    function calculateTokenAmount(uint256 count) constant returns(uint256) 
    {
        uint256 icoDeflator = getIcoDeflator();
        return count.mul(icoDeflator).div(100);
    }

    function calculateTokenCount(uint256 weiAmount, uint256 rate) constant returns(uint256) 
    {
        if(rate==0)revert();
        uint256 icoDeflator = getIcoDeflator();
        return weiAmount.div(rate).mul(icoDeflator).div(100);
    }

    function getIcoDeflator() constant returns (uint256)
    {
        if (now <= startTimestamp + 14 days)//15.11.2017-29.11.2017 38% 
        {
            return 138;
        }else if (now <= startTimestamp + 46 days)//29.11.2017-31.12.2017 23% 
        {
            return 123;
        }else if (now <= startTimestamp + 60 days)//01.01.2018-14.01.2018 15% 
        {
            return 115;
        }else if (now <= startTimestamp + 74 days)//15.01.2018-28.01.2018
        {
            return 109;
        }else
        {
            return 105;
        }
    }

    function finalize(uint256 weiAmount) isIcoFinished isStuff payable public
    {
      if(msg.sender == founder)
      {
        founder.transfer(weiAmount);
      }
    }

    function transfer(address _to, uint _value) isIcoFinished returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    modifier isStuff() 
    {
        require(msg.sender == stuff || msg.sender == founder);
        _;
    }

    modifier isIcoOpen() 
    {
        require(now >= startTimestamp);//15.11-29.11 pre ICO
        require(now <= startTimestamp + 14 days || now >= startTimestamp + 19 days);//gap 29.11-04.12
        require(now <= (startTimestamp + durationSeconds) || totalRaised < minCap);//04.12-02.02 ICO
        require(totalRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() 
    {
        require(now >= startTimestamp);
        require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds) && totalRaised >= minCap));
        _;
    }

}