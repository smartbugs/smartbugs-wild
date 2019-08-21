pragma solidity 0.4.16;

contract FiveMedium {
	
	// owner
	address private owner;

	// fees
	uint256 public feeNewThread;
	uint256 public feeReplyThread;

	//
	// Database
	//

	// the threads
	struct thread {
		string text;
		string imageUrl;

		uint256 indexLastReply;
		uint256 indexFirstReply;

		uint256 timestamp;
	}
	mapping (uint256 => thread) public threads;
	uint256 public indexThreads = 1;

	// the replies
	struct reply {
		string text;
		string imageUrl;

		uint256 replyTo;
		uint256 nextReply;

		uint256 timestamp;
	}
	mapping (uint256 => reply) public replies;
	uint256 public indexReplies = 1;

	// last 20 active threads 
	uint256[20] public lastThreads;
	uint256 public indexLastThreads = 0; // the index of the thread that was added last in lastThreads

	// 
	// Events
	//

	event newThreadEvent(uint256 threadId, string text, string imageUrl, uint256 timestamp);

	event newReplyEvent(uint256 replyId, uint256 replyTo, string text, string imageUrl, uint256 timestamp);

	//
	// Meta
	//

	// constructor
	function FiveMedium(uint256 _feeNewThread, uint256 _feeReplyThread) public {
		owner = msg.sender;
		feeNewThread = _feeNewThread;
		feeReplyThread = _feeReplyThread;
	}
	
	// modifying the fees
	function SetFees(uint256 _feeNewThread, uint256 _feeReplyThread) public {
		require(owner == msg.sender);
		feeNewThread = _feeNewThread;
		feeReplyThread = _feeReplyThread;
	}

	// To get the money back
	function withdraw(uint256 amount) public {
		owner.transfer(amount);
	}

	//
	// Core
	//

	// To create a Thread
	function createThread(string _text, string _imageUrl) payable public {
		// collect the fees
		require(msg.value >= feeNewThread); 
		// calculate a new thread ID and post
		threads[indexThreads] = thread(_text, _imageUrl, 0, 0, now);
		// add it to our last active threads array
		lastThreads[indexLastThreads] = indexThreads;
		indexLastThreads = addmod(indexLastThreads, 1, 20); // increment index
		// log!
		newThreadEvent(indexThreads, _text, _imageUrl, now);
		// increment index for next thread
		indexThreads += 1;
	}

	// To reply to a thread
	function replyThread(uint256 _replyTo, string _text, string _imageUrl)  payable public {
		// collect the fees
		require(msg.value >= feeReplyThread);
		// make sure you can't reply to an inexistant thread
		require(_replyTo < indexThreads && _replyTo > 0);
		// post the reply with nextReply = 0 (this is the last message in the chain)
		replies[indexReplies] = reply(_text, _imageUrl, _replyTo, 0, now);
		// update the thread 
		if(threads[_replyTo].indexFirstReply == 0){// we're first
			threads[_replyTo].indexFirstReply = indexReplies;
			threads[_replyTo].indexLastReply = indexReplies;
		}
		else { // we're not first so we update the previous reply as well
			replies[threads[_replyTo].indexLastReply].nextReply = indexReplies;
			threads[_replyTo].indexLastReply = indexReplies;
		}
		// update the last active threads 
		for (uint8 i = 0; i < 20; i++) { 
			if(lastThreads[i] == _replyTo) {
				break; // already in the list
			}
			if(i == 19) {
				lastThreads[indexLastThreads] = _replyTo;
				indexLastThreads = addmod(indexLastThreads, 1, 20);
			}
		} 
		// log!
		newReplyEvent(indexReplies, _replyTo, _text, _imageUrl, now);
		// increment index for next reply
		indexReplies += 1;
	}
}