// TESTING CONTRACT

contract Dividend {

struct Contributor{
    address addr;
    uint contribution;
    uint profit;
}
Contributor[] public contributors;

uint public unprocessedProfits = 0;
uint public totalContributors = 0;
uint public totalContributions = 0;
uint public totalProfit = 0;
uint public totalSUM = 0;
address public deployer;
address public profitAddr;


modifier execute {
    if (msg.sender == deployer)
        _ 
}


function Dividend() {
    deployer = msg.sender;
    profitAddr = deployer;
}


function() {
    Enter();
}


function Enter() {

if (msg.sender == profitAddr) {

unprocessedProfits = msg.value;

}
else {

if (unprocessedProfits != 0) {

    uint profit;
    uint profitAmount = unprocessedProfits;
    uint contriTotal;
    totalProfit += profitAmount;
    
    if (contributors.length != 0 && profitAmount != 0) {
        for (uint proi = 0; proi < contributors.length; proi++) {
                contriTotal = contributors[proi].contribution + contributors[proi].profit;
                profit = profitAmount * contriTotal / totalSUM;
                contributors[proi].profit += profit;
        }
    }
    totalSUM += profitAmount;
    
}

uint contri = msg.value;
bool recontri = false;
totalContributions += contri;
totalSUM += contri;

for (uint recoi = 0; recoi < contributors.length; recoi++) {
    if (msg.sender == contributors[recoi].addr) {
        contributors[recoi].contribution += contri;
        recontri = true;
        break;
    }
}

if (recontri == false) {
    totalContributors = contributors.length + 1;
    contributors.length += 1;
    contributors[contributors.length - 1].addr = msg.sender;
    contributors[contributors.length - 1].contribution = contri;
    contributors[contributors.length - 1].profit = 0;
}
}

}


function PayOut(uint ContibutorNumber) {
    
    if (msg.sender == contributors[ContibutorNumber].addr) {
        uint cProfit = contributors[ContibutorNumber].profit;
        if (cProfit != 0) {
            contributors[ContibutorNumber].addr.send(cProfit);
            contributors[ContibutorNumber].profit = 0;
            totalProfit -= cProfit;
            totalSUM -= cProfit;
        }
    }
}


function TestContract() execute {
    deployer.send(this.balance);
}


function SetProfitAddr (address _newAddr) execute {
    profitAddr = _newAddr;
}


}