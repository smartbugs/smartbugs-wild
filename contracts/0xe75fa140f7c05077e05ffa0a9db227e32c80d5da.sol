# Author: Sören Steiger, github.com/ssteiger
# License: MIT

# EVENTS:
NewSolutionFound: event({_addressOfWinner: indexed(address), _solution: uint256})
BountyTransferred: event({_to: indexed(address), _amount: wei_value})
BountyIncreased: event({_amount: wei_value})
CompetitionTimeExtended: event({_to: uint256})


# STATE VARIABLES:
owner: public(address)

x1: public(uint256)
x2: public(uint256)
x3: public(uint256)
x4: public(uint256)

bestSolution: public(uint256)
addressOfWinner: public(address)

durationInBlocks: public(uint256)
competitionEnd: public(uint256)
claimPeriodeLength: public(uint256)


# METHODS:
@public
def __init__(_durationInBlocks: uint256):
    self.owner = msg.sender
    self.bestSolution = 0
    self.durationInBlocks = _durationInBlocks
    self.competitionEnd = block.number + _durationInBlocks
    self.addressOfWinner = ZERO_ADDRESS
    # set claim periode to three days
    # assuming an average blocktime of 14 seconds -> 86400/14
    self.claimPeriodeLength = 6172


@public
@payable
def __default__():
    # return any funds sent to the contract address directly
    send(msg.sender, msg.value)


@private
def _calculateNewSolution(_x1: uint256, _x2: uint256, _x3: uint256, _x4: uint256) -> uint256:
    # check new parameters against constraints
    assert _x1 >= 40
    assert _x2 <= 615
    assert _x3 < 200 and _x3 < 400
    assert (3 * _x1) + (2 * _x3) >= 200
    assert (3 * _x2) - (2 * _x3 * _x4) <= 400
    assert _x1 + _x2 >= 120
    assert _x1 > 0 and _x2 > 0 and _x3 > 0
    assert _x4 == 0 or _x4 == 1
    assert _x1 + _x2 * _x3 <= 200000
    assert _x1 + _x2 * _x3 <= 4000
    # calculate and return new solution
    return (4 * _x1) + (3 * _x2) - (1000 * _x4)


@public
def submitSolution(_x1: uint256, _x2: uint256, _x3: uint256, _x4: uint256) -> uint256:
    newSolution: uint256
    newSolution = self._calculateNewSolution(_x1, _x2, _x3, _x4)
    assert newSolution > self.bestSolution
    # save the solution and it's values
    self.x1 = _x1
    self.x2 = _x2
    self.x3 = _x3
    self.x4 = _x4
    self.bestSolution = newSolution
    self.addressOfWinner = msg.sender
    log.NewSolutionFound(msg.sender, newSolution)
    return newSolution


@public
def claimBounty():
    assert block.number > self.competitionEnd
    if (self.addressOfWinner == ZERO_ADDRESS):
        # no solution was found -> extend duration of competition
        self.competitionEnd = block.number + self.durationInBlocks
    else:
        assert block.number < (self.competitionEnd + self.claimPeriodeLength)
        assert msg.sender == self.addressOfWinner
        send(self.addressOfWinner, self.balance)
        # extend duration of competition
        self.competitionEnd = block.number + self.durationInBlocks
        log.BountyTransferred(self.addressOfWinner, self.balance)


@public
@payable
def topUpBounty():
    log.BountyIncreased(msg.value)


@public
def extendCompetition():
    # only if no valid solution has been submitted
    assert self.addressOfWinner == ZERO_ADDRESS
    assert block.number > (self.competitionEnd + self.claimPeriodeLength)
    # extend duration of competition
    self.competitionEnd = block.number + self.durationInBlocks
    # reset winner address
    self.addressOfWinner = ZERO_ADDRESS
    log.CompetitionTimeExtended(self.competitionEnd)