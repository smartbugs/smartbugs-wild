pragma solidity ^0.4.9;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }
}

contract BirthdayPuzzle is owned {
    uint balance;
    bool solved = false;

    function() onlyOwner payable {
        balance += msg.value;
    }
    
    function powerWithModulus(uint256 base, uint256 exponent, uint256 modulus) private
        returns(uint256)
    {
        uint256 result = 1;

        base %= modulus;

        while (exponent > 0) {
            if (exponent % 2 == 1) {
                result = (result * base) % modulus;
            }

            base = (base * base) % modulus;
            exponent /= 2;
        }

        return result;
    }

    event Solved(
        address solver
    );

    event UnsuccessfulAttempt(
        address attempter
    );

    function solvePuzzle(uint256 solution) public
    {
        if (solved) throw;

        uint256 a = 50540984125924;
        uint256 b = 50540984125915;
        uint256 c = 1981;
        uint256 d = 2017;
        uint256 e;

        e = powerWithModulus(1234567890, solution, 4 * a + c);
        if (powerWithModulus(e, d, 4 * b + d) == 1234567890) {
            Solved(msg.sender);
            solved = true;
            msg.sender.send(balance);
        } else {
            UnsuccessfulAttempt(msg.sender);
        }
    }
}