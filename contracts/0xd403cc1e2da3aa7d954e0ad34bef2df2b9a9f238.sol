pragma solidity ^0.4.18;

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
}


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

  function _numTokensForContributor(uint256 contributorExpectedTokens, State _state)
      internal view returns (uint256) {
    if (_state == State.DistributingNormally) {
      return contributorExpectedTokens;
    } else if (_state == State.DistributingProRata) {
      uint256 tokensRemaining = actualTotalTokens - tokensTransferred;
      uint256 tokens = actualTotalTokens.mul(contributorExpectedTokens) / expectedTotalTokens;

      // Handle roundoff on last contributor.
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
    require(contributionHashes[contributorIndex] == keccak256(contributor, contributorExpectedTokens));

    uint256 numTokens = _numTokensForContributor(contributorExpectedTokens, state);
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

    uint256 tokensTransferredThisCall = 0;
    uint256 end = start + contributors.length;
    State _state = state;
    for (uint256 i = start; i < end; ++i) {
      address contributor = contributors[i];
      uint256 expectedTokens = contributorExpectedTokens[i];
      require(contributionHashes[i] == keccak256(contributor, expectedTokens));
      contributionHashes[i] = 0x00000000000000000000000000000000;

      uint256 numTokens = _numTokensForContributor(expectedTokens, _state);
      tokensTransferredThisCall += numTokens;
      require(tokenContract.transfer(contributor, numTokens));
    }

    tokensTransferred += tokensTransferredThisCall;
    if (tokensTransferred == actualTotalTokens) {
      state = State.Done;
    }
  }

  function numTokensForContributor(uint256 contributorExpectedTokens)
      public view returns (uint256) {
    return _numTokensForContributor(contributorExpectedTokens, state);
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