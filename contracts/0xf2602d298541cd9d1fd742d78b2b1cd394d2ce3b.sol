contract Devcon2Interface {
    function isTokenOwner(address _owner) constant returns (bool);
    function ownedToken(address _owner) constant returns (bytes32 tokenId);
}


contract Survey {
    Devcon2Interface public devcon2Token;

    // Mapping from tokenId to boolean noting whether this token has responded.
    mapping (bytes32 => bool) public hasResponded;
    
    // The timestamp when this survey will end.
    uint public surveyEndAt;

    // The question we wish to ask the token holders.
    string public question;

    // An array of answer options.
    bytes32[] public responseOptions;

    // Helper for accessing the number of options programatically.
    uint public numResponseOptions;

    // Histogram of the responses as a mapping from option index to number of
    // responses for that option.
    mapping (uint => uint) public responseCounts;

    // Total number of responses.
    uint public numResponses;

    // Event for logging response submissions.
    event Response(bytes32 indexed tokenId, uint responseId);

    /// @dev Sets up the survey contract
    /// @param tokenAddress Address of Devcon2 Identity Token contract.
    /// @param duration Integer duration the survey should remain open and accept answers.
    /// @param _question String the survey question.
    /// @param _responseOptions Array of Bytes32 allowed survey response options.
    function Survey(address tokenAddress, uint duration, string _question, bytes32[] _responseOptions) {
        devcon2Token = Devcon2Interface(tokenAddress);
        question = _question;
        numResponseOptions = _responseOptions.length;
        for (uint i=0; i < numResponseOptions; i++) {
            responseOptions.push(_responseOptions[i]);
        }
        surveyEndAt = now + duration;
    }

    /// @dev Respond to the survey
    /// @param responseId Integer index of the response option being submitted.
    function respond(uint responseId) returns (bool) {
        // Check our survey hasn't ended.
        if (now >= surveyEndAt) return false;

        // Only allow token holders
        if (!devcon2Token.isTokenOwner(msg.sender)) return false;

        // Each token has a unique bytes32 identifier.  Since tokens are
        // transferable, we want to use this value instead of the owner address
        // for preventing the same owner from responding multiple times.
        var tokenId = devcon2Token.ownedToken(msg.sender);

        // Sanity check.  The 0x0 token is invalid which means something went
        // wrong.
        if (tokenId == 0x0) throw;

        // verify that this token has not yet responded.
        if (hasResponded[tokenId]) return false;

        // verify the response is valid
        if (responseId >= responseOptions.length) return false;

        responseCounts[responseId] += 1;

        // log the response.
        Response(tokenId, responseId);

        // Mark this token as having responded to the question.
        hasResponded[tokenId] = true;

        // increment the response counter
        numResponses += 1;
    }
}


contract MainnetSurvey is Survey {
    function MainnetSurvey(uint duration, string _question, bytes32[] _responseOptions) Survey(0xabf65a51c7adc3bdef0adf8992884be38072c184, duration, _question, _responseOptions) {
    }
}


contract ETCSurvey is MainnetSurvey {
    function ETCSurvey() MainnetSurvey(
            2 weeks,
            "Do plan to pursue any development or involvement on the Ethereum Classic blockchain",
            _options
        )
    {
        bytes32[] memory _options = new bytes32[](4);
        _options[0] = "No Answer";
        _options[1] = "Yes";
        _options[2] = "No";
        _options[3] = "Undecided";
    }
}