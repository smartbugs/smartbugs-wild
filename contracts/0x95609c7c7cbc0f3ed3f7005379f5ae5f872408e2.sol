pragma solidity ^0.4.17;

//
// ==== DISCLAIMER ====
//
// ETHEREUM IS STILL AN EXPEREMENTAL TECHNOLOGY.
// ALTHOUGH THIS SMART CONTRACT WAS CREATED WITH GREAT CARE AND IN THE HOPE OF BEING USEFUL, NO GUARANTEES OF FLAWLESS OPERATION CAN BE GIVEN.
// IN PARTICULAR - SUBTILE BUGS, HACKER ATTACKS OR MALFUNCTION OF UNDERLYING TECHNOLOGY CAN CAUSE UNINTENTIONAL BEHAVIOUR.
// YOU ARE STRONGLY ENCOURAGED TO STUDY THIS SMART CONTRACT CAREFULLY IN ORDER TO UNDERSTAND POSSIBLE EDGE CASES AND RISKS.
// DON'T USE THIS SMART CONTRACT IF YOU HAVE SUBSTANTIAL DOUBTS OR IF YOU DON'T KNOW WHAT YOU ARE DOING.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ====
//
//
// ==== PARANOIA NOTICE ====
// A careful reader will find some additional checks and excessive code, consuming some extra gas. This is intentional.
// Even though the contract should work without these parts, they make the code more secure in production and for future refactoring.
// Also, they show more clearly what we have considered and addressed during development.
// Discussion is welcome!
// ====
//

/// @author ethernian
/// @notice report bugs to: bugs@ethernian.com
/// @title BnsPresale Contract

contract BnsPresale {

    string public constant VERSION = "0.2.0-bns";

    /* ====== configuration START ====== */
    uint public constant PRESALE_START  = 4470000; /* approx. WED NOV 01 2017 12:55:47 GMT+0100 (CET) */
    uint public constant PRESALE_END    = 5033333; /* approx. WED JAN 31 2018 19:39:39 GMT+0100 (CET) */
    uint public constant WITHDRAWAL_END = 5111111; /* approx. TUE FEB 13 2018 10:08:39 GMT+0100 (CET) */

    address public constant OWNER = 0x54ef8Ffc6EcdA95d286722c0358ad79123c3c8B0;

    uint public constant MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH = 0;
    uint public constant MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH = 3125;
    uint public constant MIN_ACCEPTED_AMOUNT_FINNEY = 1;

    /* ====== configuration END ====== */

    string[5] private stateNames = ["BEFORE_START",  "PRESALE_RUNNING", "WITHDRAWAL_RUNNING", "REFUND_RUNNING", "CLOSED" ];
    enum State { BEFORE_START,  PRESALE_RUNNING, WITHDRAWAL_RUNNING, REFUND_RUNNING, CLOSED }

    uint public total_received_amount;
    uint public total_refunded;
    mapping (address => uint) public balances;

    uint private constant MIN_TOTAL_AMOUNT_TO_RECEIVE = MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MAX_TOTAL_AMOUNT_TO_RECEIVE = MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MIN_ACCEPTED_AMOUNT = MIN_ACCEPTED_AMOUNT_FINNEY * 1 finney;
    bool public isAborted = false;
    bool public isStopped = false;


    //constructor
    function BnsPresale () public validSetupOnly() { }

    //
    // ======= interface methods =======
    //

    //accept payments here
    function ()
    payable
    noReentrancy
    public
    {
        State state = currentState();
        if (state == State.PRESALE_RUNNING) {
            receiveFunds();
        } else if (state == State.REFUND_RUNNING) {
            // any entring call in Refund Phase will cause full refund
            sendRefund();
        } else {
            revert();
        }
    }

    function refund() external
    inState(State.REFUND_RUNNING)
    noReentrancy
    {
        sendRefund();
    }


    function withdrawFunds() external
    onlyOwner
    noReentrancy
    {
        // transfer funds to owner if any
        OWNER.transfer(this.balance);
    }


    function abort() external
    inStateBefore(State.REFUND_RUNNING)
    onlyOwner
    {
        isAborted = true;
    }


    function stop() external
    inState(State.PRESALE_RUNNING)
    onlyOwner
    {
        isStopped = true;
    }


    //displays current contract state in human readable form
    function state() external constant
    returns (string)
    {
        return stateNames[ uint(currentState()) ];
    }


    //
    // ======= implementation methods =======
    //

    function sendRefund() private tokenHoldersOnly {
        // load balance to refund plus amount currently sent
        uint amount_to_refund = min(balances[msg.sender], this.balance - msg.value) ;

        // change balance
        balances[msg.sender] -= amount_to_refund;
        total_refunded += amount_to_refund;

        // send refund back to sender
        msg.sender.transfer(amount_to_refund + msg.value);
    }


    function receiveFunds() private notTooSmallAmountOnly {
      // no overflow is possible here: nobody have soo much money to spend.
      if (total_received_amount + msg.value > MAX_TOTAL_AMOUNT_TO_RECEIVE) {
          // accept amount only and return change
          var change_to_return = total_received_amount + msg.value - MAX_TOTAL_AMOUNT_TO_RECEIVE;
          var acceptable_remainder = MAX_TOTAL_AMOUNT_TO_RECEIVE - total_received_amount;
          balances[msg.sender] += acceptable_remainder;
          total_received_amount += acceptable_remainder;

          msg.sender.transfer(change_to_return);
      } else {
          // accept full amount
          balances[msg.sender] += msg.value;
          total_received_amount += msg.value;
      }
    }


    function currentState() private constant returns (State) {
        if (isAborted) {
            return this.balance > 0
                   ? State.REFUND_RUNNING
                   : State.CLOSED;
        } else if (block.number < PRESALE_START) {
            return State.BEFORE_START;
        } else if (block.number <= PRESALE_END && total_received_amount < MAX_TOTAL_AMOUNT_TO_RECEIVE && !isStopped) {
            return State.PRESALE_RUNNING;
        } else if (this.balance == 0) {
            return State.CLOSED;
        } else if (block.number <= WITHDRAWAL_END && total_received_amount >= MIN_TOTAL_AMOUNT_TO_RECEIVE) {
            return State.WITHDRAWAL_RUNNING;
        } else {
            return State.REFUND_RUNNING;
        }
    }

    function min(uint a, uint b) pure private returns (uint) {
        return a < b ? a : b;
    }


    //
    // ============ modifiers ============
    //

    //fails if state doesn't match
    modifier inState(State state) {
        assert(state == currentState());
        _;
    }

    //fails if the current state is not before than the given one.
    modifier inStateBefore(State state) {
        assert(currentState() < state);
        _;
    }


    //fails if something in setup is looking weird
    modifier validSetupOnly() {
        if ( OWNER == 0x0
            || PRESALE_START == 0
            || PRESALE_END == 0
            || WITHDRAWAL_END ==0
            || PRESALE_START <= block.number
            || PRESALE_START >= PRESALE_END
            || PRESALE_END   >= WITHDRAWAL_END
            || MIN_TOTAL_AMOUNT_TO_RECEIVE > MAX_TOTAL_AMOUNT_TO_RECEIVE )
                revert();
        _;
    }


    //accepts calls from owner only
    modifier onlyOwner(){
        assert(msg.sender == OWNER);
        _;
    }


    //accepts calls from token holders only
    modifier tokenHoldersOnly(){
        assert(balances[msg.sender] > 0);
        _;
    }


    // don`t accept transactions with value less than allowed minimum
    modifier notTooSmallAmountOnly(){
        assert(msg.value >= MIN_ACCEPTED_AMOUNT);
        _;
    }


    //prevents reentrancy attacs
    bool private locked = false;
    modifier noReentrancy() {
        assert(!locked);
        locked = true;
        _;
        locked = false;
    }
}//contract