contract MyScheme {
 
    uint treeBalance;
    uint numInvestorsMinusOne;
    uint treeDepth;
    address[] myTree;
 
    function MyScheme() {
        treeBalance = 0;
        myTree.length = 6;
        myTree[0] = msg.sender;
        numInvestorsMinusOne = 0;
    }
   
        function getNumInvestors() constant returns (uint a){
                a = numInvestorsMinusOne+1;
        }
   
        function() {
        uint amount = msg.value;
        if (amount>=1000000000000000000){
            numInvestorsMinusOne+=1;
            myTree[numInvestorsMinusOne]=msg.sender;
            amount-=1000000000000000000;
            treeBalance+=1000000000000000000;
            if (numInvestorsMinusOne<=2){
                myTree[0].send(treeBalance);
                treeBalance=0;
                treeDepth=1;
            }
            else if (numInvestorsMinusOne+1==myTree.length){
                    for(uint i=myTree.length-3*(treeDepth+1);i<myTree.length-treeDepth-2;i++){
                        myTree[i].send(500000000000000000);
                        treeBalance-=500000000000000000;
                    }
                    uint eachLevelGets = treeBalance/(treeDepth+1)-1;
                    uint numInLevel = 1;
                    for(i=0;i<myTree.length-treeDepth-2;i++){
                        myTree[i].send(eachLevelGets/numInLevel-1);
                        treeBalance -= eachLevelGets/numInLevel-1;
                        if (numInLevel*(numInLevel+1)/2 -1== i){
                            numInLevel+=1;
                        }
                    }
                    myTree.length+=treeDepth+3;
                    treeDepth+=1;
            }
        }
                treeBalance+=amount;
    }
}