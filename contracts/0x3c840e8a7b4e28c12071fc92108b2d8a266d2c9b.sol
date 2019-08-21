pragma solidity 0.5.7;

interface IHumanityRegistry {
    function isHuman(address who) external view returns (bool);
}


// What is the name of the virtual reality world in Neal Stephenson's 1992 novel Snow Crash?
contract Question {

    IHumanityRegistry public registry;
    bytes32 public answerHash = 0x3f071a4c8c4762d45888fda3b7ff73f3d32dac78fd7b374266dec429dfabdfa8;

    constructor(IHumanityRegistry _registry) public payable {
        registry = _registry;
    }

    function answer(string memory response) public {
        require(registry.isHuman(msg.sender), "Question::answer: Only humans can answer");

        if (keccak256(abi.encode(response)) == answerHash) {
            selfdestruct(msg.sender);
        } else {
            revert("Question::answer: Incorrect response");
        }
    }

}