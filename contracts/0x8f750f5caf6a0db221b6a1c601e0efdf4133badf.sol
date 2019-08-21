pragma solidity ^0.4.15;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title LifPresale
 * @dev Contract to raise a max amount of Ether before TGE
 *
 * The token rate is 11 Lif per Ether, if you send 10 Ethers you will
 * receive 110 Lifs after TGE ends
 * The contract is pausable and it starts in paused state
 */

/**
 * TERMS AND CONDITIONS
 *
 * By sending Ether to this contract I agree to the following terms
 * and conditions:
 *

Simple Agreement for Future Tokens
This Simple Agreement for Future Tokens (this “Agreement”) is entered into on between WT Limited (the “Company”) and (the “Buyer”) in connection with Company’s creation and distribution of the Líf blockchain token (“Project Token”) in furtherance of the establishment and operation of a B2B marketplace for travel inventory called Winding Tree, as described in the White Paper.
Please note that the agreement below only concerns the pre-sale token allocation and not the the Token Distribution Event, which will have its own rules, described in Exhibit A.
NOW, THEREFORE, in consideration of the above, Company and Buyer hereby agree as follows:
Definitions
Definitions of Certain Terms. The terms defined in this section, whenever used in this Agreement (including in the Exhibits), shall have the respective meanings indicated below.
Affiliate: with respect to any Person, any other Person directly or indirectly controlling, controlled by or under common control with such Person.
Bonus Rate: shall equal 10 percent (%).
ERC20: the Ethereum Request for Comment No. 20 smart contract standard setting the initial guidelines for a blockchain token that can be offered through, and available on, the Ethereum network in a standardized format in order to be tradable with other blockchain tokens on Ethereum (https://github.com/ethereum/EIPs/issues/20).
ETH: The blockchain token of Ethereum.
Ethereum: means the smart contract protocol, virtual machine and decentralized consensus mechanism including all its related components and protocol-related projects both present and future that is governed by the Ethereum Foundation based in Zug, Switzerland, which began operation (Genesis Block) on July 30th, 2015.
Governmental Authority: any nation or government, any state or other political subdivision thereof, any entity exercising legislative, judicial or administrative functions of or pertaining to government, including, without limitation, any governmental authority, agency, department, board, commission or instrumentality, and any court, tribunal or arbitrator(s) of competent jurisdiction, and any self-regulatory organization.
Intellectual Property: all of the following in any jurisdiction throughout the world: (i) all inventions (whether patentable or unpatentable and whether or not reduced to practice), including without limitation the Project technology, all improvements thereto, and all patents, patent applications, and patent disclosures, together with all reissuances, continuations, divisions, continuations in-part, revisions, and extensions; (ii) all trademarks, service marks, trade names, trade dress, logos, business and product names, corporate names, Internet domain names, slogans, other source identifiers, together with all translations, adaptations, derivations, and combinations thereof and including all goodwill associated therewith, and all applications, registrations and renewals in connection therewith; (iii) all copyrightable works, all copyrights and all applications, registrations and renewals in connection therewith, and all moral rights (and similar non-assignable rights) and all benefits of waivers of moral rights (and similar non-assignable rights) therein; (iv) all trade secrets and confidential, technical and business information (including but not limited to ideas, research and development, algorithms, compositions, processes, designs, drawings, formulae, trade secrets, know-how, industrial models, business methods, technical data and information, engineering and technical drawings, product specifications and confidential business information); (v) mask work and other semiconductor chip rights and all applications, registrations and renewals in connection therewith; (vi) software; (vii) all other intellectual property and proprietary rights; and (viii) copies and tangible embodiments thereof (in whatever form or medium, including electronic media).
Laws: laws, statutes, ordinances, rules, regulations, judgments, injunctions, orders and decrees.
Organizational Documents: the articles of incorporation, certificate of incorporation, charter, by-laws, articles of formation, certificate of formation, regulations, operating agreement, certificate of limited partnership, partnership agreement and all other similar documents, instruments or certificates executed, adopted or filed in connection with the creation, formation or organization of a Person, including any amendments thereto.
Person: an individual or legal entity or person, including a government or political subdivision or an agency or instrumentality thereof.
Project: the blockchain-enabled network and/or decentralized consensus project being developed by Company that will utilize the Project Token as native to its operations and/or functioning.
Project Founders: Maksim Izmaylov, Jakub Vysoky, Augusto Lemble, Pedro Anderson.
Project Plan: the plan containing a detailed overview of major milestones to be achieved and approximate dates of execution and launch of the blockchain-enabled network of the Project.
Project Token: Líf blockchain token, i.e. an ERC20 blockchain token created in connection with and native to the Project with the characteristics described in the Token Characteristics Document and distributed via (i) a Token Distribution Event and/or (ii) a methodology described in the Token Distribution Plan.
Project Token Protocol: a blockchain based protocol aiming at providing a decentralized B2B marketplace for travel inventory called Winding Tree.
Purchase Price: as defined in Section 2.
TGE: Token Generating Event taking place on November 1st, 2017.
Token Characteristics Document: attached hereto as Exhibit B.
Token Distribution Event: the intended offering of Project Tokens to the general public or other specified investors as the case may be.
Token Distribution Plan: attached hereto as Exhibit A.
Token Price: price of one Project Token.
White Paper: the technical document drafted and published by Company explaining the Project and its components, including the Project Plan and technical characteristics of the Project. Attached hereto as Exhibit C.
Purchase, Sale and Distribution of Tokens
On the Token Distribution Event, Company shall deliver to Buyer a number of Project Tokens calculated by the following formula:
x=Pt∗(1+b)
where “x” is the number of tokens that the Buyer will receive after the Token Distribution Event, “P” is Purchase Price, “t” is Token Price (determined at the end of the Token Distribution Event) and “b” is Bonus Rate (e.g. 0.1 for 10%).
Example: 100 ETH / 1 ETH * (1 + 0.1) = 110 tokens.
Usage License
Ownership of Project Tokens carries no rights, whether express or implied, other than a limited right (license) to use the Project Token Protocol, if and to the extent the Project Token Protocol has been successfully completed and launched.
In particular, Buyer understands and accepts that Project Tokens do not represent or constitute any ownership right or stake, share or security or equivalent rights nor any right to receive future revenues, shares or any other form of participation or governance right in or relating to the Project Token Protocol and/or the Project Tokens.
By transferring ETH to Company and/or receiving Project Tokens, no form of partnership, joint venture or any similar relationship between the Buyer and Company is created.
Risks
The Buyer understands and accepts the risks in connection with making a Contribution to Company and creating Project Tokens. In particular, but not concluding, the Buyer understands the inherent risks listed hereinafter as well as in the Contribution Terms, which will be handed over to Buyer:
Risk of software weaknesses: The Buyer understands and accepts that the Smart Contract System concept, the underlying software application and software platform (i.e. the Ethereum blockchain) is still in an early development stage and unproven, why there is no warranty that the process for creating Project Tokens will be uninterrupted or error-free and why there is an inherent risk that the software could contain weaknesses, vulnerabilities or bugs causing, inter alia, the complete loss of ETH and/or Project Tokens.
Regulatory risk: The Buyer understands and accepts that the blockchain technology allows new forms of interaction and that it is possible that certain jurisdictions will apply existing regulations on, or introduce new regulations addressing, blockchain technology based applications, which may be contrary to the current setup of the Smart Contract System and which may, inter alia, result in substantial modifications of the Smart Contract System and/or the Project Token Protocol, including its termination and the loss of Project Tokens for the Buyer.
Risk of abandonment / lack of success: The Buyer understands and accepts that the creation of the Project Tokens and the development of the Project Token Protocol may be abandoned for a number of reasons, including lack of interest from the public, lack of funding, lack of commercial success or prospects (e.g. caused by competing projects). The Buyer therefore understands that there is no assurance that, even if the Project Token Protocol is partially or fully developed and launched, the Buyer will receive any benefits through the Project Tokens held by him.
Risk of withdrawing partners: The Buyer understands and accepts that the TGE and the feasibility of the Project as a whole depends strongly on the collaboration of banks and other crucial partners of Company. The Buyer therefore understands that there is no assurance that TGE will take place as foreseen or the Project as a whole will be successfully executed.
Risk associated with other applications: The Buyer understands and accepts that the Project Token Protocol may give rise to other, alternative projects, promoted by unaffiliated third parties, under which Project Tokens will have no intrinsic value.
Risk of loss of private key: Project Tokens can only be accessed by using an Ethereum Wallet with a combination of Buyer’s account information (address), private key and password. The private key is encrypted with a password. The Buyer understands and accepts that if his private key file or password respectively got lost or stolen, the obtained Project Tokens associated with the Buyer's account (address) or password will be unrecoverable and will be permanently lost.
Risk of theft: The Buyer understands and accepts that the Smart Contract System concept, the underlying software application and software platform (i.e. the Ethereum blockchain) may be exposed to attacks by hackers or other individuals that could result in theft or loss of Project Tokens or ETH.
Risk of Ethereum mining attacks: The Buyer understands and accepts that, as with other cryptocurrencies, the blockchain used for the Smart Contract System is susceptible to mining attacks, including but not limited to double-spend attacks, majority mining power attacks, “selfish-mining” attacks, and race condition attacks. Any successful attacks present a risk to the Smart Contract System, expected proper execution and sequencing of Project Token transactions, and expected proper execution and sequencing of contract computations.
Token Liquidity. Buyer understands that with regard to Project Tokens no market liquidity may be guaranteed and that the value (if any) of Project Tokens over time may experience extreme volatility or depreciate resulting in full and total loss that will be borne exclusively by Buyer with respect to the Project Tokens Buyer purchases under this Agreement.
Risk of incompatible Wallet service: The Buyer understands and accepts, that the Wallet or Wallet service provider used for the contribution, has to be technically compatible with the Project Token. The failure to assure this may have the result that Buyer will not gain access to his Project Token.
Limited Warranties. Except as otherwise set forth herein, in the White Paper, Token Characteristics Document, and/or the Token Distribution Plan, Buyer understands and expressly accepts that there is no warranty whatsoever of the Project Token and/or the success of the Project, expressed or implied, to the extent permitted by law, and that Project Tokens will be created and delivered to Buyer at the sole risk of Buyer on an “as is” and “under development” basis and without, to the extent permitted by law, any warranties of any kind, including, but not limited to, express or implied warranties of merchantability or fitness for a particular purpose.
Limitations on Recovery. Buyer understands that Buyer has no right against any Company or any other Person to request any refund or redemption of the Purchase Price except as otherwise provided herein and/or as a result of, or in connection with, Company’s breach of this Agreement, negligence or willful misconduct.
Representation and Warranties of Company
Company hereby represents and warrants to Buyer, as of the date hereof, as follows:
Corporate Status. The Company is a duly organized, validly existing and in good standing under the laws of British Virgin Islands and has all requisite corporate power and authority to carry on its business as now conducted.
No Conflict. To the extent that could be reasonably known to the Company, the execution, delivery and performance of this Agreement will not result in (i) any violation of, be in conflict with in any material respect, or constitute a material default under, with or without the passage of time or the giving of notice (A) any provision of Company’s Organizational Documents; (B) any provision of any judgment, decree or order to which Company is a party, by which it is bound, or to which any of its material assets are subject; (C) any material contract, obligation, or commitment to which Company is a party or by which it is bound; or (D) any Laws applicable to the Company that the Company is aware of or should be aware of acting reasonably, or (ii) the creation of any material lien, charge or encumbrance upon any material assets of the Company. The Buyer understands that the Project Tokens and Token Distribution Event may not be well defined under law. The Company has taken reasonable steps to ensure the legitimacy of its operations.
Intellectual Property. Company has good and valid tile to all owned Intellectual Property. To the extent that could be reasonably known to the Company, the Company does not infringe, dilute, misappropriate or otherwise violate the rights of any third party in respect of any Intellectual Property. None of Company’s Intellectual Property is subject to any outstanding order, ruling, decree, judgment or stipulation by or with any court, tribunal, arbitrator or Governmental Authority.
Representations and Warranties of Buyer
Buyer hereby represents and warrants to Company, as of the date hereof, as follows:
Buyer Power and Authority. Buyer has all requisite power and authority to execute, issue and deliver this Agreement and purchase the Project Tokens, and to carry out and perform its obligations under this Agreement and any related agreements. The Agreement constitutes a legal, valid and binding obligation of Company enforceable against Buyer in accordance with its terms.
Buyer Status and Risk of Project. Buyer has sufficient knowledge and experience in business, financial matters to be able to evaluate the risks and merits of its purchase of the Project Tokens and is able to bear the risks thereof. Buyer understands that the Project and creation and distribution of the Project Tokens involve risks, including, but not limited to, the risk that (i) the technology associated with the Project will not function as intended; (i) the Project and Token Distribution Event will not be completed; (ii) the Project will fail to attract sufficient interest from key stakeholders; (iii) Company will fail to secure sufficient purchasers of Project Tokens; (iv) the Project Tokens may decrease in value over time and/or lose all monetary value; and (v) Company and/or the Project may be subject to investigation and punitive actions from Governmental Authorities.
Corporate Status. If Buyer is a legal entity, Buyer is duly organized, validly existing and in good standing under the laws of its domicile and has all requisite corporate power and authority to carry on its business as now conducted.
No Ownership Interest. Buyer understands the purchase and potential receipt of Project Tokens do not involve the purchase of shares or any equivalent in any existing or future public or private company, corporation or other entity in any jurisdiction nor does it confer any voting rights, seats on any board of directors or governance rights and obligations to Buyer, except for the rights described in the Token Characteristics Document (Exhibit B).
Limited Warranties. Except as otherwise set forth herein, in the White Paper, Token Characteristics Document, and/or the Token Distribution Plan, Buyer understands and expressly accepts that there is no warranty whatsoever of the Project Token and/or the success of the Project, expressed or implied, to the extent permitted by law, and that Project Tokens will be created and delivered to Buyer at the sole risk of Buyer on an “as is” and “under development” basis and without, to the extent permitted by law, any warranties of any kind, including, but not limited to, express or implied warranties of merchantability or fitness for a particular purpose.
Limitations on Recovery. Buyer understands that Buyer has no right against any Company or any other Person to request any refund of the Purchase Price except as otherwise provided herein and/or as a result of, or in connection with, Company’s breach of this Agreement, negligence or willful misconduct.
Token Liquidity. Buyer understands that with regard to Project Tokens no market liquidity may be guaranteed and that the value (if any) of Project Tokens over time may experience extreme volatility or depreciate resulting in full and total loss that will be borne exclusively by Buyer with respect to the Project Tokens Buyer purchases under this Agreement.
Sole Responsibility for Taxes. Buyer understands that Buyer bears sole responsibility for any taxes as a result of the matters and transactions the subject of this Agreement, and any future use, sale or other disposition of Project Tokens held by Buyer. To the extent permitted by law, Buyer agrees not to hold Company or any of its Affiliates, employees or agents (including developers, auditors, contractors or founders) liable for any taxes associated with or arising from Buyer’s purchase of Project Tokens hereunder, or the use or ownership of Project Tokens.
Covenants
From the date of this Agreement, Company may not permit the alteration of the Project Tokens to differ materially from the Token Characteristics Document other than upon the mutual written agreement of the parties.
From the date of this Agreement, Company shall:
provide Buyer with periodic updates regarding the Project and the fulfilment of the Project Plan;
to the extent practical and reasonable, follow best practices known in the blockchain industry for the development of tokens, smart contracts, decentralized consensus networks and blockchain technologies; and
act diligently and perform a full independent security audit on any smart contracts or vanguard technologies employed by the Company in connection with the Project.
Conditions Precedent
Conditions to Obligations of Buyer. The obligations of Buyer to consummate the transaction contemplated hereby shall be subject to the fulfilment on or prior to the date of execution of this Agreement of the following conditions:
Company has provided Buyer with the White Paper for Buyer’s review and feedback.
Company has provided Buyer with the Token Characteristics Document.
Company has provided Buyer with the Token Distribution Plan, which describes the number of Project Tokens to be created and distributed by Company.
Indemnification
Company shall defend, indemnify and hold harmless Buyer, its Affiliates and its officers, directors, employees, agents, successors and assigns (collectively, the “Buyer Indemnitees”) from and against, and pay or reimburse the Buyer Indemnitees for, any and all Losses resulting from (a) any inaccuracy in or breach of any representation or warranty when made or deemed made by Company in or pursuant to this Agreement, (b) any willful or negligent breach of or default in performance by Company under this Agreement or (c) any infringement, dilution, misappropriation, or violation of the rights of any third party in respect of any Intellectual Property where Company should have reasonably known that it was in breach of Intellectual Property of a third party.
Miscellaneous
Governing Law. This Agreement shall be governed in all respects, including as to validity, interpretation and effect, by the laws of Switzerland, without giving effect to its principles or rules of conflict of laws, to the extent such principles or rules are not mandatorily applicable by statute and would permit or require the application of the laws of another jurisdiction.
Successors and Assigns. This Agreement shall be binding upon and inure to the benefit of the parties, and their respective heirs, successors and permitted assigns. This Agreement shall not be assignable or otherwise transferable without the prior written consent of the other party, and any purported assignment in violation hereof shall be void.
Entire Agreement. This Agreement constitutes the entire agreement between the parties and supersedes all prior or contemporaneous agreements and understandings, both written and oral, between the parties with respect to the subject matter hereof.
Severability. If any provision of this Agreement is determined by a court of competent jurisdiction to be invalid, inoperative or unenforceable for any reason, the parties shall negotiate in good faith to modify this Agreement so as to effect the original intent of the parties as closely as possible in an acceptable manner in order that the transactions contemplated hereby be consumed as originally contemplated to the fullest extent possible.
Counterparts. This Agreement may be executed in several counterparts, each of which shall be deemed an original and all of which shall together constitute one and the same instrument.
No Partnership and No Agency. Nothing in this Agreement and no action taken by the parties pursuant to this Agreement shall constitute, or be deemed to constitute, a partnership, association, joint venture or other co-operative entity between any of the parties. Nothing in this Agreement and no action taken by the parties pursuant to this Agreement shall constitute, or be deemed to constitute, either party the agent of the other party for any purpose. No party has, pursuant to this Agreement, any authority or power to bind or to contract in the name of the other party.
Dispute Resolution.
All disputes arising out of or in connection with the present contract shall be finally settled under the Rules of Arbitration of the International Chamber of Commerce by one or more arbitrators appointed in accordance with the said Rules. Arbitration shall be conducted in Zurich. The number of arbitrators shall be [one/three]. Language of the proceedings shall be English.
Publications and Notifications, Fees and Expenses. The parties shall agree to any press release or publication that jointly involves the names, brands or officers of both parties. Written correspondence and notifications between the Parties, whether as a result of a dispute or otherwise intended to be official correspondence, may be email or common forms of social media (Skype, Slack, WhatsApp). Each party shall be solely liable for all its own fees, costs and otherwise in connection with negotiation and execution of this Agreement and any future dealings between the parties and/or future publications regarding the parties.
Confidentiality. This Agreement shall remain confidential between the parties in perpetuity, except to the extent required to be disclosed pursuant to applicable Laws and a one-time disclosure event to the general public. The content of the one-time public disclosure will be agreed to between the parties.
Termination. This Agreement shall terminate on the Token Distribution Date, provided that Articles 9 and 10 of this Agreement shall survive any termination hereof.


 */
contract LifPresale is Ownable, Pausable {
  using SafeMath for uint256;

  // The address where all funds will be forwarded
  address public wallet;

  // The total amount of wei raised
  uint256 public weiRaised;

  // The maximun amount of wei to be raised
  uint256 public maxCap;

  /**
     @dev Constructor. Creates the LifPresale contract
     The contract can start with some wei already raised, it will
     also have a maximun amount of wei to be raised and a wallet
     address where all funds will be forwarded inmediatly.

     @param _weiRaised see `weiRaised`
     @param _maxCap see `maxCap`
     @param _wallet see `wallet`
   */
  function LifPresale(uint256 _weiRaised, uint256 _maxCap, address _wallet) {
    require(_weiRaised < _maxCap);

    weiRaised = _weiRaised;
    maxCap = _maxCap;
    wallet = _wallet;
    paused = true;
  }

  /**
     @dev Fallback function that will be executed every time the contract
     receives ether, the contract will accept ethers when is not paused and
     when the amount sent plus the wei raised is not higher than the max cap.
   */
  function () whenNotPaused payable {
    require(weiRaised.add(msg.value) <= maxCap);

    weiRaised = weiRaised.add(msg.value);
    wallet.transfer(msg.value);
  }

}