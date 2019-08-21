pragma solidity ^0.4.6;

//
// ==== DISCLAIMER ====
//
// ETHEREUM IS STILL AN EXPEREMENTAL TECHNOLOGY.
// ALTHOUGH THIS SMART CONTRACT CREATED WITH GREAT CARE AND IN HOPE TO BE USEFUL, NO GUARANTEES OF FLAWLES OPERATION CAN BE GIVEN. 
// ESPECIALLY SUBTILE BUGS, HACKER ATTACS OR MALFUNCTION OF UNDERLYING TECHNOLOGY CAN CAUSE AN UNINTENTIONAL BEHAVIOUR. 
// YOU ARE DEEPLY ENCORAGED TO STUDY THIS SMART CONTRACT CAREFULLY IN ORDER TO UNDERSTAND POSSIBLE EDGE CASES AND RISKS. 
// DON'T USE THIS SMART CONTRACT IN CASE OF ANY SUBSTANTIONAL DOUBTS OR IF YOU DON'T KNOW WHAT ARE YOU DOING.
//
// THIS SOFTWARE IS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY 
// AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
// OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// ====
//
//
// ==== PARANOIA NOTICE ==== 
// A careful reader will find here some unnecessary checks and excessive code consuming some extra valuable gas. It is intentionally. 
// Even contract should works without these parts, they make the code more secure in production as well for future refactoring.
// Additionally it shows more clearly what we have took care of.
// You are welcome to discuss that places.
// ====
//

/// @author ethernian
/// @notice report bugs to: bugs@ethernian.com
/// @title Presale Contract

contract Presale {

    string public constant VERSION = "0.1.4-beta";

    /* ====== configuration START ====== */

    uint public constant PRESALE_START  = 3127400;    /* approx. 22.01.2017 20:00 CET */
    uint public constant PRESALE_END    = 3127410;    /* approx. 23.01.2017 14:00 CET */
    uint public constant WITHDRAWAL_END = 3127420;    /* approx. 23.01.2017 18:00 CET */

    address public constant OWNER = 0x41ab8360dEF1e19FdFa32092D83a7a7996C312a4;

    uint public constant MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH = 1;
    uint public constant MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH = 5;
    uint public constant MIN_ACCEPTED_AMOUNT_FINNEY = 1;

    /* ====== configuration END ====== */

    string[5] private stateNames = ["BEFORE_START",  "PRESALE_RUNNING", "WITHDRAWAL_RUNNING", "REFUND_RUNNING", "CLOSED" ];
    enum State { BEFORE_START,  PRESALE_RUNNING, WITHDRAWAL_RUNNING, REFUND_RUNNING, CLOSED }

    uint public total_received_amount;
    mapping (address => uint) public balances;

    uint private constant MIN_TOTAL_AMOUNT_TO_RECEIVE = MIN_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MAX_TOTAL_AMOUNT_TO_RECEIVE = MAX_TOTAL_AMOUNT_TO_RECEIVE_ETH * 1 ether;
    uint private constant MIN_ACCEPTED_AMOUNT = MIN_ACCEPTED_AMOUNT_FINNEY * 1 finney;
    bool public isAborted = false;


    //constructor
    function Presale () validSetupOnly() { }

    //
    // ======= interface methods =======
    //

    //accept payments here
    function ()
    payable
    noReentrancy
    {
        State state = currentState();
        if (state == State.PRESALE_RUNNING) {
            receiveFunds();
        } else if (state == State.REFUND_RUNNING) {
            // any entring call in Refund Phase will cause full refund
            sendRefund();
        } else {
            throw;
        }
    }

    function refund() external
    inState(State.REFUND_RUNNING)
    noReentrancy
    {
        sendRefund();
    }


    function withdrawFunds() external
    inState(State.WITHDRAWAL_RUNNING)
    onlyOwner
    noReentrancy
    {
        // transfer funds to owner if any
        if (!OWNER.send(this.balance)) throw;
    }

    function abort() external
    inStateBefore(State.REFUND_RUNNING)
    onlyOwner
    {
        isAborted = true;
    }

    //displays current contract state in human readable form
    function state()  external constant
    returns (string)
    {
        return stateNames[ uint(currentState()) ];
    }


    //
    // ======= implementation methods =======
    //

    function sendRefund() private tokenHoldersOnly {
        // load balance to refund plus amount currently sent
        var amount_to_refund = balances[msg.sender] + msg.value;
        // reset balance
        balances[msg.sender] = 0;
        // send refund back to sender
        if (!msg.sender.send(amount_to_refund)) throw;
    }


    function receiveFunds() private notTooSmallAmountOnly {
      // no overflow is possible here: nobody have soo much money to spend.
      if (total_received_amount + msg.value > MAX_TOTAL_AMOUNT_TO_RECEIVE) {
          // accept amount only and return change
          var change_to_return = total_received_amount + msg.value - MAX_TOTAL_AMOUNT_TO_RECEIVE;
          if (!msg.sender.send(change_to_return)) throw;

          var acceptable_remainder = MAX_TOTAL_AMOUNT_TO_RECEIVE - total_received_amount;
          balances[msg.sender] += acceptable_remainder;
          total_received_amount += acceptable_remainder;
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
        } else if (block.number <= PRESALE_END && total_received_amount < MAX_TOTAL_AMOUNT_TO_RECEIVE) {
            return State.PRESALE_RUNNING;
        } else if (this.balance == 0) {
            return State.CLOSED;
        } else if (block.number <= WITHDRAWAL_END && total_received_amount >= MIN_TOTAL_AMOUNT_TO_RECEIVE) {
            return State.WITHDRAWAL_RUNNING;
        } else {
            return State.REFUND_RUNNING;
        } 
    }

    //
    // ============ modifiers ============
    //

    //fails if state dosn't match
    modifier inState(State state) {
        if (state != currentState()) throw;
        _;
    }

    //fails if the current state is not before than the given one.
    modifier inStateBefore(State state) {
        if (currentState() >= state) throw;
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
                throw;
        _;
    }


    //accepts calls from owner only
    modifier onlyOwner(){
        if (msg.sender != OWNER)  throw;
        _;
    }


    //accepts calls from token holders only
    modifier tokenHoldersOnly(){
        if (balances[msg.sender] == 0) throw;
        _;
    }


    // don`t accept transactions with value less than allowed minimum
    modifier notTooSmallAmountOnly(){	
        if (msg.value < MIN_ACCEPTED_AMOUNT) throw;
        _;
    }


    //prevents reentrancy attacs
    bool private locked = false;
    modifier noReentrancy() {
        if (locked) throw;
        locked = true;
        _;
        locked = false;
    }
}//contract