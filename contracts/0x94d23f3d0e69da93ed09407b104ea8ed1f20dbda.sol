/*

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

https://lovcoin.github.io/

BETA/DRAFT - NOT TESTED !!! - DO NOT USE THIS SOURCE FOR LIVE-REVARD

Draft 0.1 - 08.feb.2018

*/



// ---
// Main LoveLock class
//
contract LoveLock
{
address public owner;                    // The owner of this contract

uint    public lastrecordindex;          // The highest record index, number of lovelocks
uint    public lovelock_price;           // Lovelock price (starts with ~ $9.99 in ETH, 0.0119 ETH)

address public last_buyer;               // Last buyer of a lovelock.
bytes32 public last_hash;                // Last index hash


//
// Datasets for the lovelocks.
//
struct DataRecord
{
string name1;
string name2;
string lovemessage;
uint   locktype;
} // struct DataRecord

mapping(bytes32 => DataRecord) public DataRecordStructs;





// ---
// Constructor
// 
function LoveLock () public
{
// Today 08.Feb.2018 - 1 ETH=$836, 0.0119 ~ $9.99

//lovelock_price           = 11900000000000000;
// (much smaller for testing)
lovelock_price             = 1100000000000000;
owner                    = msg.sender;
lastrecordindex          = 0;
} // Constructor
 



// ---
// withdraw_to_reward_contract
// 
function withdraw_to_reward_contract() public constant returns (bool)
{
address reward_contract = 0xF711233A0Bec76689FEA4870cc6f4224334DB9c3;
reward_contract.transfer( this.balance );
return(true);
} // withdraw_to_reward_contract



// ---
// number_to_hash
//
function number_to_hash( uint param ) public constant returns (bytes32)
{
bytes32 ret = keccak256(param);
return(ret);
} // number_to_hash





// ---
// Web3 event 'LovelockPayment'
//
event LovelockPayment
(
address indexed _from,
bytes32 hashindex,
uint _value2
);
    
    
// ---
// buy lovelock
//
function buy_lovelock( string name1, string name2, string lovemessage, uint locktype ) public payable returns (uint)
{
last_buyer = msg.sender;

// only if payed the full price.
if ( msg.value >= lovelock_price )
   {
   // Increment the record index.
   lastrecordindex = lastrecordindex + 1;  
       
   // calculate the hash of this index.   
   last_hash = keccak256(lastrecordindex);  
        
   // Store the lovelock data into the record for the eternity.
   DataRecordStructs[last_hash].name1       = name1;
   DataRecordStructs[last_hash].name2       = name2;
   DataRecordStructs[last_hash].lovemessage = lovemessage;
   DataRecordStructs[last_hash].locktype    = locktype;
   
   // The Web3-Event!!!
   LovelockPayment(msg.sender, last_hash, lastrecordindex);  
   
   return(1);
   } else
     {
     revert();
     }

 
return(0);
} 







// DEBUG - REMOVE, if going life!!!
// Kill (owner only)
//
function kill () public
{
if (msg.sender != owner) return;

/*
// Transfer tokens back to owner
uint256 balance = TokenContract.balanceOf(this);
assert(balance > 0);
TokenContract.transfer(owner, balance);
 */
owner.transfer( this.balance );
selfdestruct(owner);
} // kill



} // contract LoveLock