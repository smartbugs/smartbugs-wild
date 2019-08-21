interface ERC20 {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  //function div(uint256 a, uint256 b) internal pure returns (uint256) {
    //// require(b > 0); // Solidity automatically throws when dividing by 0
    //uint256 c = a / b;
    //// require(a == b * c + a % b); // There is no case in which this doesn't hold
    //return c;
  //}

  //function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    //require(b <= a);
    //return a - b;
  //}

  //function add(uint256 a, uint256 b) internal pure returns (uint256) {
    //uint256 c = a + b;
    //require(c >= a);
    //return c;
  //}
}

// A contract that distributes ERC20 tokens with predetermined terms.
// WARNING: This contract does not protect against malicious token contracts,
//          under the assumption that if the token sellers are malicious,
//          the tokens will be worthless anyway.
contract Distribution {
  using SafeMath for uint256;

  enum State {
    AwaitingTokens,
    DistributingNormally,
    DistributingProRata,
    Done
  }
 
  address admin;
  ERC20 tokenContract;
  State state;
  uint256 actualTotalTokens;
  uint256 tokensTransferred;

  bytes32[] contributionHashes;
  uint256 expectedTotalTokens;

  function Distribution(address _admin, ERC20 _tokenContract,
                        bytes32[] _contributionHashes, uint256 _expectedTotalTokens) public {
    expectedTotalTokens = _expectedTotalTokens;
    contributionHashes = _contributionHashes;
    tokenContract = _tokenContract;
    admin = _admin;

    state = State.AwaitingTokens;
  }

  function handleTokensReceived() public {
    require(state == State.AwaitingTokens);
    uint256 totalTokens = tokenContract.balanceOf(this);
    require(totalTokens > 0);

    tokensTransferred = 0;
    if (totalTokens == expectedTotalTokens) {
      state = State.DistributingNormally;
    } else {
      actualTotalTokens = totalTokens;
      state = State.DistributingProRata;
    }
  }

  function _numTokensForContributor(uint256 contributorExpectedTokens,
                                    uint256 _tokensTransferred, State _state)
      internal view returns (uint256) {
    if (_state == State.DistributingNormally) {
      return contributorExpectedTokens;
    } else if (_state == State.DistributingProRata) {
      uint256 tokens = actualTotalTokens.mul(contributorExpectedTokens) / expectedTotalTokens;

      // Handle roundoff on last contributor.
      uint256 tokensRemaining = actualTotalTokens - _tokensTransferred;
      if (tokens < tokensRemaining) {
        return tokens;
      } else {
        return tokensRemaining;
      }
    } else {
      revert();
    }
  }

  function doDistribution(uint256 contributorIndex, address contributor,
                          uint256 contributorExpectedTokens)
      public {
    // Make sure the arguments match the compressed storage.
    require(contributionHashes[contributorIndex] == keccak256(contributor, contributorExpectedTokens));

    uint256 numTokens = _numTokensForContributor(contributorExpectedTokens,
                                                 tokensTransferred, state);
    contributionHashes[contributorIndex] = 0x00000000000000000000000000000000;
    tokensTransferred += numTokens;
    if (tokensTransferred == actualTotalTokens) {
      state = State.Done;
    }

    require(tokenContract.transfer(contributor, numTokens));
  }

  function doDistributionRange(uint256 start, address[] contributors,
                               uint256[] contributorExpectedTokens) public {
    require(contributors.length == contributorExpectedTokens.length);

    uint256 tokensTransferredSoFar = tokensTransferred;
    uint256 end = start + contributors.length;
    State _state = state;
    for (uint256 i = start; i < end; ++i) {
      address contributor = contributors[i];
      uint256 expectedTokens = contributorExpectedTokens[i];
      require(contributionHashes[i] == keccak256(contributor, expectedTokens));
      contributionHashes[i] = 0x00000000000000000000000000000000;

      uint256 numTokens = _numTokensForContributor(expectedTokens, tokensTransferredSoFar, _state);
      tokensTransferredSoFar += numTokens;
      require(tokenContract.transfer(contributor, numTokens));
    }

    tokensTransferred = tokensTransferredSoFar;
    if (tokensTransferred == actualTotalTokens) {
      state = State.Done;
    }
  }

  function numTokensForContributor(uint256 contributorExpectedTokens)
      public view returns (uint256) {
    return _numTokensForContributor(contributorExpectedTokens, tokensTransferred, state);
  }

  function temporaryEscapeHatch(address to, uint256 value, bytes data) public {
    require(msg.sender == admin);
    require(to.call.value(value)(data));
  }

  function temporaryKill(address to) public {
    require(msg.sender == admin);
    require(tokenContract.balanceOf(this) == 0);
    selfdestruct(to);
  }
}
contract DistributionForTesting is Distribution {
  function DistributionForTesting(address _admin, ERC20 _tokenContract,
                                  bytes32[] _contributionHashes, uint256 _expectedTotalTokens)
    Distribution(_admin, _tokenContract, _contributionHashes, _expectedTotalTokens) public { }

  function getContributionHash(address contributor, uint256 expectedTokens)
      public pure returns (bytes32 result) {
    result = keccak256(contributor, expectedTokens);
  }

  function getNumTokensForContributorInternal(uint256 contributorExpectedTokens,
                                              uint256 _tokensTransferred, State _state)
      public view returns (uint256) {
    return _numTokensForContributor(contributorExpectedTokens, _tokensTransferred, _state);
  }

  function getAdmin() public pure returns (address) { return Distribution.admin; }
  function getTokenContract() public pure returns (ERC20) { return Distribution.tokenContract; }
  function getState() public pure returns (Distribution.State) { return Distribution.state; }
  function getActualTotalTokens() public pure returns (uint256) { return Distribution.actualTotalTokens; }

  function getContributionHashes() public pure returns (bytes32[]) { return Distribution.contributionHashes; }
  function getContributionHashByIndex(uint256 contributorIndex)
      public view returns (bytes32) { return Distribution.contributionHashes[contributorIndex]; }
  function getExpectedTotalTokens() public pure returns (uint256) { return Distribution.expectedTotalTokens; }
}