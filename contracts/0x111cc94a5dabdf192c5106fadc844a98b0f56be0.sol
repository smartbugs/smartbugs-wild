contract DAO {
    function balanceOf(address addr) returns (uint);
    function transferFrom(address from, address to, uint balance) returns (bool);
    function getNewDAOAddress(uint _proposalID) constant returns(address _newDAO);
    uint public totalSupply;
}

/**
 * @title trustedChildWithdraw
 * @author Paul Szczesny, Alexey Akhunov
 * A simple withdraw contract for trusted childDAOs affected by the hard fork.
 * Based on the official WithdrawDAO contract found here: https://etherscan.io/address/0xbf4ed7b27f1d666546e30d74d50d173d20bca754#code
 */
contract trustedChildWithdraw {

  DAO constant public mainDAO = DAO(0xbb9bc244d798123fde783fcc1c72d3bb8c189413);
  uint[] public trustedProposals = [7, 10, 16, 20, 23, 26, 27, 28, 31, 34, 37, 39, 41, 44, 54, 57, 60, 61, 63, 64, 65, 66];
  mapping (uint => DAO) public whiteList;
  address constant curator = 0xda4a4626d3e16e094de3225a751aab7128e96526;

  /**
  * Populates the whiteList based on the list of trusted proposal Ids.
  */
  function trustedChildWithdraw() {
      for(uint i=0; i<trustedProposals.length; i++) {
          uint proposalId = trustedProposals[i];
          whiteList[proposalId] = DAO(mainDAO.getNewDAOAddress(proposalId));
      }
  }

  /**
  * Convienience function for the Curator to calculate the required amount of Wei
  * that needs to be transferred to this contract.
  */
  function requiredEndowment() constant returns (uint endowment) {
      uint sum = 0;
      for(uint i=0; i<trustedProposals.length; i++) {
          uint proposalId = trustedProposals[i];
          DAO childDAO = whiteList[proposalId];
          sum += childDAO.totalSupply();
      }
      return sum;
  }

  /**
   * Function call to withdraw ETH by burning childDao tokens.
   * @param proposalId The split proposal ID which created the childDao
   * @dev This requires that the token-holder authorizes this contract's address using the approve() function.
   */
  function withdraw(uint proposalId) external {
    //Check the token balance
    uint balance = whiteList[proposalId].balanceOf(msg.sender);

    // Transfer childDao tokens first, then send Ether back in return
    if (!whiteList[proposalId].transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
      throw;
  }

  /**
   * Return funds back to the curator.
   */
  function clawback() external {
    if (msg.sender != curator) throw;
    if (!curator.send(this.balance)) throw;
  }

}