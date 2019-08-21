pragma solidity ^0.4.0;

/*
 * Token - is a smart contract interface 
 * for managing common functionality of 
 * a token.
 *
 * ERC.20 Token standard: https://github.com/eth ereum/EIPs/issues/20
 */
contract TokenInterface {

        
    // total amount of tokens
    uint totalSupplyVar;

    
    /**
     *
     * balanceOf() - constant function check concrete tokens balance  
     *
     *  @param owner - account owner
     *  
     *  @return the value of balance 
     */                               
    function balanceOf(address owner) constant returns (uint256 balance);
    
    function transfer(address to, uint256 value) returns (bool success);

    function transferFrom(address from, address to, uint256 value) returns (bool success);

    /**
     *
     * approve() - function approves to a person to spend some tokens from 
     *           owner balance. 
     *
     *  @param spender - person whom this right been granted.
     *  @param value   - value to spend.
     * 
     *  @return true in case of succes, otherwise failure
     * 
     */
    function approve(address spender, uint256 value) returns (bool success);

    /**
     *
     * allowance() - constant function to check how much is 
     *               permitted to spend to 3rd person from owner balance
     *
     *  @param owner   - owner of the balance
     *  @param spender - permitted to spend from this balance person 
     *  
     *  @return - remaining right to spend 
     * 
     */
    function allowance(address owner, address spender) constant returns (uint256 remaining);
    
    function totalSupply() constant returns (uint256 totalSupply){
        return totalSupplyVar;    
    }

    // events notifications
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity ^0.4.2;

/*
 * StandardToken - is a smart contract  
 * for managing common functionality of 
 * a token.
 *
 * ERC.20 Token standard: 
 *         https://github.com/eth ereum/EIPs/issues/20
 */
contract StandardToken is TokenInterface {


    // token ownership
    mapping (address => uint256) balances;

    // spending permision management
    mapping (address => mapping (address => uint256)) allowed;
    
    
    
    function StandardToken(){
    }
    
    
    /**
     * transfer() - transfer tokens from msg.sender balance 
     *              to requested account
     *
     *  @param to    - target address to transfer tokens
     *  @param value - ammount of tokens to transfer
     *
     *  @return - success / failure of the transaction
     */    
    function transfer(address to, uint256 value) returns (bool success) {
        
        
        if (balances[msg.sender] >= value && value > 0) {

            // do actual tokens transfer       
            balances[msg.sender] -= value;
            balances[to]         += value;
            
            // rise the Transfer event
            Transfer(msg.sender, to, value);
            return true;
        } else {
            
            return false; 
        }
    }
    
    

    
    /**
     * transferFrom() - used to move allowed funds from other owner
     *                  account 
     *
     *  @param from  - move funds from account
     *  @param to    - move funds to account
     *  @param value - move the value 
     *
     *  @return - return true on success false otherwise 
     */
    function transferFrom(address from, address to, uint256 value) returns (bool success) {
    
        if ( balances[from] >= value && 
             allowed[from][msg.sender] >= value && 
             value > 0) {
                                          
    
            // do the actual transfer
            balances[from] -= value;    
            balances[to]   += value;            
            

            // addjust the permision, after part of 
            // permited to spend value was used
            allowed[from][msg.sender] -= value;
            
            // rise the Transfer event
            Transfer(from, to, value);
            return true;
        } else { 
            
            return false; 
        }
    }

    

    
    /**
     *
     * balanceOf() - constant function check concrete tokens balance  
     *
     *  @param owner - account owner
     *  
     *  @return the value of balance 
     */                               
    function balanceOf(address owner) constant returns (uint256 balance) {
        return balances[owner];
    }

    
    
    /**
     *
     * approve() - function approves to a person to spend some tokens from 
     *           owner balance. 
     *
     *  @param spender - person whom this right been granted.
     *  @param value   - value to spend.
     * 
     *  @return true in case of succes, otherwise failure
     * 
     */
    function approve(address spender, uint256 value) returns (bool success) {
        
        
        
        // now spender can use balance in 
        // ammount of value from owner balance
        allowed[msg.sender][spender] = value;
        
        // rise event about the transaction
        Approval(msg.sender, spender, value);
        
        return true;
    }
    

    /**
     *
     * allowance() - constant function to check how mouch is 
     *               permited to spend to 3rd person from owner balance
     *
     *  @param owner   - owner of the balance
     *  @param spender - permited to spend from this balance person 
     *  
     *  @return - remaining right to spend 
     * 
     */
    function allowance(address owner, address spender) constant returns (uint256 remaining) {
      return allowed[owner][spender];
    }

}


pragma solidity ^0.4.6;

/**
 * 
 * EventInfo - imutable class that denotes
 * the time of the virtual accelerator hack
 * event
 * 
 */
contract EventInfo{
    
    
    uint constant HACKATHON_5_WEEKS = 60 * 60 * 24 * 7 * 5;
    uint constant T_1_WEEK = 60 * 60 * 24 * 7;

    uint eventStart = 1479391200; // Thu, 17 Nov 2016 14:00:00 GMT
    uint eventEnd = eventStart + HACKATHON_5_WEEKS;
    
    
    /**
     * getEventStart - return the start of the event time
     */ 
    function getEventStart() constant returns (uint result){        
       return eventStart;
    } 
    
    /**
     * getEventEnd - return the end of the event time
     */ 
    function getEventEnd() constant returns (uint result){        
       return eventEnd;
    } 
    
    
    /**
     * getVotingStart - the voting starts 1 week after the 
     *                  event starts
     */ 
    function getVotingStart() constant returns (uint result){
        return eventStart+ T_1_WEEK;
    }

    /**
     * getTradingStart - the DST tokens trading starts 1 week 
     *                   after the event starts
     */ 
    function getTradingStart() constant returns (uint result){
        return eventStart+ T_1_WEEK;
    }

    /**
     * getNow - helper class to check what time the contract see
     */
    function getNow() constant returns (uint result){        
       return now;
    } 
    
}

pragma solidity ^0.4.0;

/**
 *
 * @title Hacker Gold
 * 
 * The official token powering the hack.ether.camp virtual accelerator.
 * This is the only way to acquire tokens from startups during the event.
 *
 * Whitepaper https://hack.ether.camp/whitepaper
 *
 */
contract HackerGold is StandardToken {

    // Name of the token    
    string public name = "HackerGold";

    // Decimal places
    uint8  public decimals = 3;
    // Token abbreviation        
    string public symbol = "HKG";
    
    // 1 ether = 200 hkg
    uint BASE_PRICE = 200;
    // 1 ether = 150 hkg
    uint MID_PRICE = 150;
    // 1 ether = 100 hkg
    uint FIN_PRICE = 100;
    // Safety cap
    uint SAFETY_LIMIT = 4000000 ether;
    // Zeros after the point
    uint DECIMAL_ZEROS = 1000;
    
    // Total value in wei
    uint totalValue;
    
    // Address of multisig wallet holding ether from sale
    address wallet;

    // Structure of sale increase milestones
    struct milestones_struct {
      uint p1;
      uint p2; 
      uint p3;
      uint p4;
      uint p5;
      uint p6;
    }
    // Milestones instance
    milestones_struct milestones;
    
    /**
     * Constructor of the contract.
     * 
     * Passes address of the account holding the value.
     * HackerGold contract itself does not hold any value
     * 
     * @param multisig address of MultiSig wallet which will hold the value
     */
    function HackerGold(address multisig) {
        
        wallet = multisig;

        // set time periods for sale
        milestones = milestones_struct(
        
          1476972000,  // P1: GMT: 20-Oct-2016 14:00  => The Sale Starts
          1478181600,  // P2: GMT: 03-Nov-2016 14:00  => 1st Price Ladder 
          1479391200,  // P3: GMT: 17-Nov-2016 14:00  => Price Stable, 
                       //                                Hackathon Starts
          1480600800,  // P4: GMT: 01-Dec-2016 14:00  => 2nd Price Ladder
          1481810400,  // P5: GMT: 15-Dec-2016 14:00  => Price Stable
          1482415200   // P6: GMT: 22-Dec-2016 14:00  => Sale Ends, Hackathon Ends
        );
        
        // assign recovery balance
        totalSupplyVar   = 16110893000;
        balances[0x342e62732b76875da9305083ea8ae63125a4e667] = 16110893000;
        totalValue    = 85362 ether;        
    }
    
    
    /**
     * Fallback function: called on ether sent.
     * 
     * It calls to createHKG function with msg.sender 
     * as a value for holder argument
     */
    function () payable {
        createHKG(msg.sender);
    }
    
    /**
     * Creates HKG tokens.
     * 
     * Runs sanity checks including safety cap
     * Then calculates current price by getPrice() function, creates HKG tokens
     * Finally sends a value of transaction to the wallet
     * 
     * Note: due to lack of floating point types in Solidity,
     * contract assumes that last 3 digits in tokens amount are stood after the point.
     * It means that if stored HKG balance is 100000, then its real value is 100 HKG
     * 
     * @param holder token holder
     */
    function createHKG(address holder) payable {
        
        if (now < milestones.p1) throw;
        if (now >= milestones.p6) throw;
        if (msg.value == 0) throw;
    
        // safety cap
        if (getTotalValue() + msg.value > SAFETY_LIMIT) throw; 
    
        uint tokens = msg.value * getPrice() * DECIMAL_ZEROS / 1 ether;

        totalSupplyVar += tokens;
        balances[holder] += tokens;
        totalValue += msg.value;
        
        if (!wallet.send(msg.value)) throw;
    }
    
    /**
     * Denotes complete price structure during the sale.
     *
     * @return HKG amount per 1 ETH for the current moment in time
     */
    function getPrice() constant returns (uint result) {
        
        if (now < milestones.p1) return 0;
        
        if (now >= milestones.p1 && now < milestones.p2) {
        
            return BASE_PRICE;
        }
        
        if (now >= milestones.p2 && now < milestones.p3) {
            
            uint days_in = 1 + (now - milestones.p2) / 1 days; 
            return BASE_PRICE - days_in * 25 / 7;  // daily decrease 3.5
        }

        if (now >= milestones.p3 && now < milestones.p4) {
        
            return MID_PRICE;
        }
        
        if (now >= milestones.p4 && now < milestones.p5) {
            
            days_in = 1 + (now - milestones.p4) / 1 days; 
            return MID_PRICE - days_in * 25 / 7;  // daily decrease 3.5
        }

        if (now >= milestones.p5 && now < milestones.p6) {
        
            return FIN_PRICE;
        }
        
        if (now >= milestones.p6){

            return 0;
        }

     }
    
    /**
     * Returns total stored HKG amount.
     * 
     * Contract assumes that last 3 digits of this value are behind the decimal place. i.e. 10001 is 10.001
     * Thus, result of this function should be divided by 1000 to get HKG value
     * 
     * @return result stored HKG amount
     */
    function getTotalSupply() constant returns (uint result) {
        return totalSupplyVar;
    } 

    /**
     * It is used for test purposes.
     * 
     * Returns the result of 'now' statement of Solidity language
     * 
     * @return unix timestamp for current moment in time
     */
    function getNow() constant returns (uint result) {
        return now;
    }

    /**
     * Returns total value passed through the contract
     * 
     * @return result total value in wei
     */
    function getTotalValue() constant returns (uint result) {
        return totalValue;  
    }
}
pragma solidity ^0.4.6;

/*
 * DSTContract - DST stands for decentralized startup team.
 *               the contract ensures funding for a decentralized
 *               team in 2 phases: 
 *
 *                +. Funding by HKG during the hackathon event. 
 *                +. Funding by Ether after the event is over. 
 *
 *               After the funds been collected there is a governence
 *               mechanism managed by proposition to withdraw funds
 *               for development usage. 
 *
 *               The DST ensures that backers of the projects keeps
 *               some influence on the project by ability to reject
 *               propositions they find as non effective. 
 *
 *               In very radical occasions the backers may loose 
 *               the trust in the team completelly, in that case 
 *               there is an option to propose impeachment process
 *               completelly removing the execute and assigning new
 *               person to manage the funds. 
 *
 */
contract DSTContract is StandardToken{

    // Zeros after the point
    uint DECIMAL_ZEROS = 1000;
    // Proposal lifetime
    uint PROPOSAL_LIFETIME = 10 days;
    // Proposal funds threshold, in percents
    uint PROPOSAL_FUNDS_TH = 20;

    address   executive; 
        
    EventInfo eventInfo;
    
    // Indicated where the DST is traded
    address virtualExchangeAddress;
    
    HackerGold hackerGold;
        
    mapping (address => uint256) votingRights;


    // 1 - HKG => DST qty; tokens for 1 HKG
    uint hkgPrice;
    
    // 1 - Ether => DST qty; tokens for 1 Ether
    uint etherPrice;
    
    string public name = "...";                   
    uint8  public decimals = 3;                 
    string public symbol = "...";
    
    bool ableToIssueTokens = true; 
    
    uint preferedQtySold;

    uint collectedHKG; 
    uint collectedEther;    
    
    // Proposal of the funds spending
    mapping (bytes32 => Proposal) proposals;

    enum ProposalCurrency { HKG, ETHER }
    ProposalCurrency enumDeclaration;
                  
       
    struct Proposal{
        
        bytes32 id;
        uint value;

        string urlDetails;

        uint votindEndTS;
                
        uint votesObjecting;
        
        address submitter;
        bool redeemed;

        ProposalCurrency proposalCurrency;
        
        mapping (address => bool) voted;
    }
    uint counterProposals;
    uint timeOfLastProposal;
    
    Proposal[] listProposals;
    

    /**
     * Impeachment process proposals
     */    
    struct ImpeachmentProposal{
        
        string urlDetails;
        
        address newExecutive;

        uint votindEndTS;        
        uint votesSupporting;
        
        mapping (address => bool) voted;        
    }
    ImpeachmentProposal lastImpeachmentProposal;

        
    /**
     * 
     *  DSTContract: ctor for DST token and governence contract
     *
     *  @param eventInfoAddr EventInfo: address of object denotes events 
     *                                  milestones      
     *  @param hackerGoldAddr HackerGold: address of HackerGold token
     *
     *  @param dstName string: dstName: real name of the team
     *
     *  @param dstSymbol string: 3 letter symbold of the team
     *
     */ 
    function DSTContract(EventInfo eventInfoAddr, HackerGold hackerGoldAddr, string dstName, string dstSymbol){
    
      executive   = msg.sender;  
      name        = dstName;
      symbol      = dstSymbol;

      hackerGold = HackerGold(hackerGoldAddr);
      eventInfo  = EventInfo(eventInfoAddr);
    }
    

    function() payable
               onlyAfterEnd {
        
        // there is tokens left from hackathon 
        if (etherPrice == 0) throw;
        
        uint tokens = msg.value * etherPrice * DECIMAL_ZEROS / (1 ether);
        
        // check if demand of tokens is 
        // overflow the supply 
        uint retEther = 0;
        if (balances[this] < tokens) {
            
            tokens = balances[this];
            retEther = msg.value - tokens / etherPrice * (1 finney);
        
            // return left ether 
            if (!msg.sender.send(retEther)) throw;
        }
        
        
        // do transfer
        balances[msg.sender] += tokens;
        balances[this] -= tokens;
        
        // count collected ether 
        collectedEther += msg.value - retEther; 
        
        // rise event
        BuyForEtherTransaction(msg.sender, collectedEther, totalSupplyVar, etherPrice, tokens);
        
    }

    
    
    /**
     * setHKGPrice - set price: 1HKG => DST tokens qty
     *
     *  @param qtyForOneHKG uint: DST tokens for 1 HKG
     * 
     */    
     function setHKGPrice(uint qtyForOneHKG) onlyExecutive  {
         
         hkgPrice = qtyForOneHKG;
         PriceHKGChange(qtyForOneHKG, preferedQtySold, totalSupplyVar);
     }
     
     
    
    /**
     * 
     * issuePreferedTokens - prefered tokens issued on the hackathon event
     *                       grant special rights
     *
     *  @param qtyForOneHKG uint: price DST tokens for one 1 HKG
     *  @param qtyToEmit uint: new supply of tokens 
     * 
     */
    function issuePreferedTokens(uint qtyForOneHKG, 
                                 uint256 qtyToEmit) onlyExecutive 
                                                 onlyIfAbleToIssueTokens
                                                 onlyBeforeEnd
                                                 onlyAfterTradingStart {
                
        // no issuence is allowed before enlisted on the
        // exchange 
        if (virtualExchangeAddress == 0x0) throw;
            
        totalSupplyVar += qtyToEmit;
        balances[this] += qtyToEmit;
        hkgPrice = qtyForOneHKG;
        
        
        // now spender can use balance in 
        // amount of value from owner balance
        allowed[this][virtualExchangeAddress] += qtyToEmit;
        
        // rise event about the transaction
        Approval(this, virtualExchangeAddress, qtyToEmit);
        
        // rise event 
        DstTokensIssued(hkgPrice, preferedQtySold, totalSupplyVar, qtyToEmit);
    }

    
    
    
    /**
     * 
     * buyForHackerGold - on the hack event this function is available 
     *                    the buyer for hacker gold will gain votes to 
     *                    influence future proposals on the DST
     *    
     *  @param hkgValue - qty of this DST tokens for 1 HKG     
     * 
     */
    function buyForHackerGold(uint hkgValue) onlyBeforeEnd 
                                             returns (bool success) {
    
      // validate that the caller is official accelerator HKG Exchange
      if (msg.sender != virtualExchangeAddress) throw;
      
      
      // transfer token 
      address sender = tx.origin;
      uint tokensQty = hkgValue * hkgPrice;

      // gain voting rights
      votingRights[sender] +=tokensQty;
      preferedQtySold += tokensQty;
      collectedHKG += hkgValue;

      // do actual transfer
      transferFrom(this, 
                   virtualExchangeAddress, tokensQty);
      transfer(sender, tokensQty);        
            
      // rise event       
      BuyForHKGTransaction(sender, preferedQtySold, totalSupplyVar, hkgPrice, tokensQty);
        
      return true;
    }
        
    
    /**
     * 
     * issueTokens - function will issue tokens after the 
     *               event, able to sell for 1 ether 
     * 
     *  @param qtyForOneEther uint: DST tokens for 1 ETH
     *  @param qtyToEmit uint: new tokens supply
     *
     */
    function issueTokens(uint qtyForOneEther, 
                         uint qtyToEmit) onlyAfterEnd 
                                         onlyExecutive
                                         onlyIfAbleToIssueTokens {
         
         balances[this] += qtyToEmit;
         etherPrice = qtyForOneEther;
         totalSupplyVar    += qtyToEmit;
         
         // rise event  
         DstTokensIssued(qtyForOneEther, totalSupplyVar, totalSupplyVar, qtyToEmit);
    }
     
    
    /**
     * setEtherPrice - change the token price
     *
     *  @param qtyForOneEther uint: new price - DST tokens for 1 ETH
     */     
    function setEtherPrice(uint qtyForOneEther) onlyAfterEnd
                                                onlyExecutive {
         etherPrice = qtyForOneEther; 

         // rise event for this
         NewEtherPrice(qtyForOneEther);
    }    
    

    /**
     *  disableTokenIssuance - function will disable any 
     *                         option for future token 
     *                         issuence
     */
    function disableTokenIssuance() onlyExecutive {
        ableToIssueTokens = false;
        
        DisableTokenIssuance();
    }

    
    /**
     *  burnRemainToken -  eliminated all available for sale
     *                     tokens. 
     */
    function burnRemainToken() onlyExecutive {
    
        totalSupplyVar -= balances[this];
        balances[this] = 0;
        
        // rise event for this
        BurnedAllRemainedTokens();
    }
    
    /**
     *  submitEtherProposal: submit proposal to use part of the 
     *                       collected ether funds
     *
     *   @param requestValue uint: value in wei 
     *   @param url string: details of the proposal 
     */ 
    function submitEtherProposal(uint requestValue, string url) onlyAfterEnd 
                                                                onlyExecutive returns (bytes32 resultId, bool resultSucces) {       
    
        // ensure there is no more issuence available 
        if (ableToIssueTokens) throw;
            
        // ensure there is no more tokens available 
        if (balanceOf(this) > 0) throw;

        // Possible to submit a proposal once 2 weeks 
        if (now < (timeOfLastProposal + 2 weeks)) throw;
            
        uint percent = collectedEther / 100;
            
        if (requestValue > PROPOSAL_FUNDS_TH * percent) throw;

        // if remained value is less than requested gain all.
        if (requestValue > this.balance) 
            requestValue = this.balance;    
            
        // set id of the proposal
        // submit proposal to the map
        bytes32 id = sha3(msg.data, now);
        uint timeEnds = now + PROPOSAL_LIFETIME; 
            
        Proposal memory newProposal = Proposal(id, requestValue, url, timeEnds, 0, msg.sender, false, ProposalCurrency.ETHER);
        proposals[id] = newProposal;
        listProposals.push(newProposal);
            
        timeOfLastProposal = now;                        
        ProposalRequestSubmitted(id, requestValue, timeEnds, url, msg.sender);
        
        return (id, true);
    }
    
    
     
    /**
     * 
     * submitHKGProposal - submit proposal to request for 
     *                     partial HKG funds collected 
     * 
     *  @param requestValue uint: value in HKG to request. 
     *  @param url string: url with details on the proposition 
     */
    function submitHKGProposal(uint requestValue, string url) onlyAfterEnd
                                                              onlyExecutive returns (bytes32 resultId, bool resultSucces){
        

        // If there is no 2 months over since the last event.
        // There is no posible to get any HKG. After 2 months
        // all the HKG is available. 
        if (now < (eventInfo.getEventEnd() + 8 weeks)) {
            throw;
        }

        // Possible to submit a proposal once 2 weeks 
        if (now < (timeOfLastProposal + 2 weeks)) throw;

        uint percent = preferedQtySold / 100;
        
        // validate the amount is legit
        // first 5 proposals should be less than 20% 
        if (counterProposals <= 5 && 
            requestValue     >  PROPOSAL_FUNDS_TH * percent) throw;
                
        // if remained value is less than requested 
        // gain all.
        if (requestValue > getHKGOwned()) 
            requestValue = getHKGOwned();
        
        
        // set id of the proposal
        // submit proposal to the map
        bytes32 id = sha3(msg.data, now);
        uint timeEnds = now + PROPOSAL_LIFETIME; 
        
        Proposal memory newProposal = Proposal(id, requestValue, url, timeEnds, 0, msg.sender, false, ProposalCurrency.HKG);
        proposals[id] = newProposal;
        listProposals.push(newProposal);
        
        ++counterProposals;
        timeOfLastProposal = now;                
                
        ProposalRequestSubmitted(id, requestValue, timeEnds, url, msg.sender);
        
        return (id, true);        
    }  
    
    
    
    /**
     * objectProposal - object previously submitted proposal, 
     *                  the objection right is obtained by 
     *                  purchasing prefered tokens on time of 
     *                  the hackathon.
     * 
     *  @param id bytes32 : the id of the proposla to redeem
     */
     function objectProposal(bytes32 id){
         
        Proposal memory proposal = proposals[id];
         
        // check proposal exist 
        if (proposals[id].id == 0) throw;

        // check already redeemed
        if (proposals[id].redeemed) throw;
         
        // ensure objection time
        if (now >= proposals[id].votindEndTS) throw;
         
        // ensure not voted  
        if (proposals[id].voted[msg.sender]) throw;
         
         // submit votes
         uint votes = votingRights[msg.sender];
         proposals[id].votesObjecting += votes;
         
         // mark voted 
         proposals[id].voted[msg.sender] = true; 
         
         uint idx = getIndexByProposalId(id);
         listProposals[idx] = proposals[id];   

         ObjectedVote(id, msg.sender, votes);         
     }
     
     
     function getIndexByProposalId(bytes32 id) returns (uint result){
         
         for (uint i = 0; i < listProposals.length; ++i){
             if (id == listProposals[i].id) return i;
         }
     }
    
    
   
    /**
     * redeemProposalFunds - redeem funds requested by prior 
     *                       submitted proposal     
     * 
     * @param id bytes32: the id of the proposal to redeem
     */
    function redeemProposalFunds(bytes32 id) onlyExecutive {

        if (proposals[id].id == 0) throw;
        if (proposals[id].submitter != msg.sender) throw;

        // ensure objection time
        if (now < proposals[id].votindEndTS) throw;
                           
    
            // check already redeemed
        if (proposals[id].redeemed) throw;

        // check votes objection => 55% of total votes
        uint objectionThreshold = preferedQtySold / 100 * 55;
        if (proposals[id].votesObjecting  > objectionThreshold) throw;
    
    
        if (proposals[id].proposalCurrency == ProposalCurrency.HKG){
            
            // send hacker gold 
            hackerGold.transfer(proposals[id].submitter, proposals[id].value);      
                        
        } else {
                        
           // send ether              
           bool success = proposals[id].submitter.send(proposals[id].value); 

           // rise event
           EtherRedeemAccepted(proposals[id].submitter, proposals[id].value);                              
        }
        
        // execute the proposal 
        proposals[id].redeemed = true; 
    }
    
    
    /**
     *  getAllTheFunds - to ensure there is no deadlock can 
     *                   can happen, and no case that voting 
     *                   structure will freeze the funds forever
     *                   the startup will be able to get all the
     *                   funds without a proposal required after
     *                   6 months.
     * 
     * 
     */             
    function getAllTheFunds() onlyExecutive {
        
        // If there is a deadlock in voting participates
        // the funds can be redeemed completelly in 6 months
        if (now < (eventInfo.getEventEnd() + 24 weeks)) {
            throw;
        }  
        
        // all the Ether
        bool success = msg.sender.send(this.balance);        
        
        // all the HKG
        hackerGold.transfer(msg.sender, getHKGOwned());              
    }
    
    
    /**
     * submitImpeachmentProposal - submit request to switch 
     *                             executive.
     * 
     *  @param urlDetails  - details of the impeachment proposal 
     *  @param newExecutive - address of the new executive 
     * 
     */             
     function submitImpeachmentProposal(string urlDetails, address newExecutive){
         
        // to offer impeachment you should have 
        // voting rights
        if (votingRights[msg.sender] == 0) throw;
         
        // the submission of the first impeachment 
        // proposal is possible only after 3 months
        // since the hackathon is over
        if (now < (eventInfo.getEventEnd() + 12 weeks)) throw;
        
                
        // check there is 1 months over since last one
        if (lastImpeachmentProposal.votindEndTS != 0 && 
            lastImpeachmentProposal.votindEndTS +  2 weeks > now) throw;


        // submit impeachment proposal
        // add the votes of the submitter 
        // to the proposal right away
        lastImpeachmentProposal = ImpeachmentProposal(urlDetails, newExecutive, now + 2 weeks, votingRights[msg.sender]);
        lastImpeachmentProposal.voted[msg.sender] = true;
         
        // rise event
        ImpeachmentProposed(msg.sender, urlDetails, now + 2 weeks, newExecutive);
     }
    
    
    /**
     * supportImpeachment - vote for impeachment proposal 
     *                      that is currently in progress
     *
     */
    function supportImpeachment(){

        // ensure that support is for exist proposal 
        if (lastImpeachmentProposal.newExecutive == 0x0) throw;
    
        // to offer impeachment you should have 
        // voting rights
        if (votingRights[msg.sender] == 0) throw;
        
        // check if not voted already 
        if (lastImpeachmentProposal.voted[msg.sender]) throw;
        
        // check if not finished the 2 weeks of voting 
        if (lastImpeachmentProposal.votindEndTS + 2 weeks <= now) throw;
                
        // support the impeachment
        lastImpeachmentProposal.voted[msg.sender] = true;
        lastImpeachmentProposal.votesSupporting += votingRights[msg.sender];

        // rise impeachment suppporting event
        ImpeachmentSupport(msg.sender, votingRights[msg.sender]);
        
        // if the vote is over 70% execute the switch 
        uint percent = preferedQtySold / 100; 
        
        if (lastImpeachmentProposal.votesSupporting >= 70 * percent){
            executive = lastImpeachmentProposal.newExecutive;
            
            // impeachment event
            ImpeachmentAccepted(executive);
        }
        
    } 
    
      
    
    // **************************** //
    // *     Constant Getters     * //
    // **************************** //
    
    function votingRightsOf(address _owner) constant returns (uint256 result) {
        result = votingRights[_owner];
    }
    
    function getPreferedQtySold() constant returns (uint result){
        return preferedQtySold;
    }
    
    function setVirtualExchange(address virtualExchangeAddr){
        if (virtualExchangeAddress != 0x0) throw;
        virtualExchangeAddress = virtualExchangeAddr;
    }

    function getHKGOwned() constant returns (uint result){
        return hackerGold.balanceOf(this);
    }
    
    function getEtherValue() constant returns (uint result){
        return this.balance;
    }
    
    function getExecutive() constant returns (address result){
        return executive;
    }
    
    function getHKGPrice() constant returns (uint result){
        return hkgPrice;
    }

    function getEtherPrice() constant returns (uint result){
        return etherPrice;
    }
    
    function getDSTName() constant returns(string result){
        return name;
    }    
    
    function getDSTNameBytes() constant returns(bytes32 result){
        return convert(name);
    }    

    function getDSTSymbol() constant returns(string result){
        return symbol;
    }    
    
    function getDSTSymbolBytes() constant returns(bytes32 result){
        return convert(symbol);
    }    

    function getAddress() constant returns (address result) {
        return this;
    }
    
    function getTotalSupply() constant returns (uint result) {
        return totalSupplyVar;
    } 
        
    function getCollectedEther() constant returns (uint results) {        
        return collectedEther;
    }
    
    function getCounterProposals() constant returns (uint result){
        return counterProposals;
    }
        
    function getProposalIdByIndex(uint i) constant returns (bytes32 result){
        return listProposals[i].id;
    }    

    function getProposalObjectionByIndex(uint i) constant returns (uint result){
        return listProposals[i].votesObjecting;
    }

    function getProposalValueByIndex(uint i) constant returns (uint result){
        return listProposals[i].value;
    }                  
    
    function getCurrentImpeachmentUrlDetails() constant returns (string result){
        return lastImpeachmentProposal.urlDetails;
    }
    
    
    function getCurrentImpeachmentVotesSupporting() constant returns (uint result){
        return lastImpeachmentProposal.votesSupporting;
    }
    
    function convert(string key) returns (bytes32 ret) {
            if (bytes(key).length > 32) {
                throw;
            }      

            assembly {
                ret := mload(add(key, 32))
            }
    }    
    
    // Emergency Fix limited by time functions
    function setVoteRight(address voter, uint ammount){
        
        // limited by [17 Jan 2017 00:00:00 GMT]
        if (now > 1484611200) throw;

        // limited by one account to fix 
        if (msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667) throw;

        votingRights[voter] = ammount;
    }
    
    // Emergency Fix limited by time functions
    function setBalance(address owner, uint ammount){

        // limited by [17 Jan 2017 00:00:00 GMT]
        if (now > 1484611200) throw;
        
        // limited by one account to fix 
        if (msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667) throw;
        
        balances[owner] = ammount;
    }
    
    // Emergency Fix limited by time functions
    function setInternalInfo(address fixExecutive, uint fixTotalSupply, uint256 fixPreferedQtySold, 
            uint256 fixCollectedHKG, uint fixCollectedEther){

        // limited by [17 Jan 2017 00:00:00 GMT]
        if (now > 1484611200) throw;
        
        // limited by one account to fix 
        if (msg.sender != 0x342e62732b76875da9305083ea8ae63125a4e667) throw;
        
        executive = fixExecutive;
        totalSupplyVar = fixTotalSupply;
        preferedQtySold = fixPreferedQtySold;
        collectedHKG = fixCollectedHKG;
        collectedEther = fixCollectedEther;
    }
    
    
    // ********************* //
    // *     Modifiers     * //
    // ********************* //    
 
    modifier onlyBeforeEnd() { if (now  >=  eventInfo.getEventEnd()) throw; _; }
    modifier onlyAfterEnd()  { if (now  <   eventInfo.getEventEnd()) throw; _; }
    
    modifier onlyAfterTradingStart()  { if (now  < eventInfo.getTradingStart()) throw; _; }
    
    modifier onlyExecutive()     { if (msg.sender != executive) throw; _; }
                                       
    modifier onlyIfAbleToIssueTokens()  { if (!ableToIssueTokens) throw; _; } 
    

    // ****************** //
    // *     Events     * //
    // ****************** //        

    
    event PriceHKGChange(uint indexed qtyForOneHKG, uint indexed tokensSold, uint indexed totalSupply);
    event BuyForHKGTransaction(address indexed buyer, uint indexed tokensSold, uint indexed totalSupply, uint qtyForOneHKG, uint tokensAmount);
    event BuyForEtherTransaction(address indexed buyer, uint indexed tokensSold, uint indexed totalSupply, uint qtyForOneEther, uint tokensAmount);

    event DstTokensIssued(uint indexed qtyForOneHKG, uint indexed tokensSold, uint indexed totalSupply, uint qtyToEmit);
    
    event ProposalRequestSubmitted(bytes32 id, uint value, uint timeEnds, string url, address sender);
    
    event EtherRedeemAccepted(address sender, uint value);
    
    event ObjectedVote(bytes32 id, address voter, uint votes);
    
    event ImpeachmentProposed(address submitter, string urlDetails, uint votindEndTS, address newExecutive);
    event ImpeachmentSupport(address supportter, uint votes);
    
    event ImpeachmentAccepted(address newExecutive);

    event NewEtherPrice(uint newQtyForOneEther);
    event DisableTokenIssuance();
    
    event BurnedAllRemainedTokens();
    
}