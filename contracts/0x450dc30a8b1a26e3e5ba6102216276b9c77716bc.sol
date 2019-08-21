contract AlarmClockTipFaucet {
// Alarm Clock 0.8 is on its way, adding time-based scheduling to Ethereum

// This is a contract for tipping the dev for the work leading up to this 0.8 release

// The TipFaucet is open for 10 days, after which the dev can withdraw a clump-sum

address piperMerriam;
uint timeToPayout;


function AlarmClockTipFaucet() {
    piperMerriam = 0xd3cda913deb6f67967b99d67acdfa1712c293601;
    timeToPayout = now + 10 days;
}

modifier isPiper { 
if (msg.sender != piperMerriam) throw;
_
}

modifier isOpen {
if(block.timestamp > timeToPayout) throw;
_
}

modifier canWithdraw {
if(block.timestamp < timeToPayout) throw;
_
}

function() isOpen {
}

function withdraw() isPiper canWithdraw {
    msg.sender.send(this.balance);
}

}