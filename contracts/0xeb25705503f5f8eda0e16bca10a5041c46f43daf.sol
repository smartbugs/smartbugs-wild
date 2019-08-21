pragma solidity ^0.4.4;

contract mortal {
    /* Define variable owner of the type address*/
    address owner;

    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}




contract BananaBasket is mortal {
    event HistoryUpdated(string picId, uint[] result);
    address _owner;

    struct BasketState
    {
        //string picHash;
        mapping (uint=>uint) ratings;
    }

    mapping (string=>BasketState) basketStateHistory;

    

    function BananaBasket()
    {
        _owner = msg.sender;
    }

    function addNewState(string id, uint[] memory ratings)
    {
        basketStateHistory[id] = BasketState();

        for (var index = 0;  index < ratings.length; ++index) {
            basketStateHistory[id].ratings[index + 1] = ratings[index];
        }

        HistoryUpdated(id, ratings);
    }



    function getHistory(string id) constant 
    returns(uint[5] ratings)
    {
        //pichash = id;
        for (var index = 0;  index < 5; ++index) {
            ratings[index] = basketStateHistory[id].ratings[index + 1];
        }
    }
}