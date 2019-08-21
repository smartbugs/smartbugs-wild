//
// This file is part of TrustEth.
// Copyright (c) 2016 Jacob Dawid <jacob@omg-it.works>
//
// TrustEth is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// TrustEth is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public
// License along with TrustEth.
// If not, see <http://www.gnu.org/licenses/>.
//

contract TrustEth {
    // A registered transaction initiated by the seller.
    struct Transaction {
      // Supplied by the seller (Step 1).
      uint sellerId; // The seller id of the seller who initiated this transaction and is about to receive the payment.
      uint amount; // The amount to pay to the seller for this transaction.

      // Filled out by the contract when transaction has been paid (Step 2).
      address paidWithAddress; // The address of the buyer issueing the payment.
      bool paid; // Flag that states this transaction has already been paid.
   
      // Rating supplied by the buyer (Step 3, optional).
      uint ratingValue; // Seller rating supplied by buyer.
      string ratingComment; // Comment on this transaction supplied by the buyer.
      bool rated; // Flag that states this transaction has already been rated.
    }

    // A registered seller on this contract.
    // Registered sellers can put up transactions and can be rated
    // by those who paid the transactions.
    struct Seller {
      // Seller information
      address etherAddress; // The sellers ether address.
      uint[] ratingIds; // The ids of the rating linked with this seller.
      uint[] transactionIds; // The ids of transactions linked with this seller.
      
      // Statistics about the seller
      uint averageRating; // Average value of ratings.
      uint transactionsPaid; // How many transactions have been paid?
      uint transactionsRated; // How many transactions have been rated?
    }

    Transaction[] public transactions; // All transactions.
    Seller[] public sellers; // All sellers

    // This mapping makes it easier to loopkup the seller that belongs to a certain address.
    mapping (address => uint) sellerLookup;

    // The sole contract owner.
    address public owner;

    // Configured fees.
    uint public registrationFee;
    uint public transactionFee;

    // Only owner administration flag.
    modifier onlyowner { if (msg.sender == owner) _ }

    // Administrative functions.
    function TrustEth() {
      owner = msg.sender;
      
      // Index 0 is a marker for invalid ids.
      sellers.length = 1;
      transactions.length = 1;

      // Initialize fees.
      registrationFee = 1 ether;
      transactionFee = 50 finney;
    }

    function retrieveFunds() onlyowner {
      owner.send(this.balance);
    }

    function adjustRegistrationFee(uint fee) onlyowner {
      registrationFee = fee;
    }

    function adjustTransactionFee(uint fee) onlyowner {
      transactionFee = fee;
    }

    function setOwner(address _owner) onlyowner {
      owner = _owner;
    }

    // Fallback function, do not accepts payments made directly to this contract address.
    function() {
      throw;
    }

    // Make a donation and acknowledge our development efforts. Thank you!
    function donate() {
      // That's awesome. Thank you.
      return;
    }

    // Register your seller address for a small fee to prevent flooding and
    // and recurring address recreation.
    function register() {
      // Retrieve the amount of ethers that have been sent along.
      uint etherPaid = msg.value;
      
      if(etherPaid < registrationFee) { throw; }

      // Create a new seller.
      uint sellerId = sellers.length;
      sellers.length += 1;

      // Store seller details and bind to address.
      sellers[sellerId].etherAddress = msg.sender;
      sellers[sellerId].averageRating = 0;

      // Save sellerId in lookup mapping.
      sellerLookup[msg.sender] = sellerId;
    }


    // Workflow

    // As a seller, put up a transaction.
    function askForEther(uint amount) {
      // Lookup the seller.
      uint sellerId = sellerLookup[msg.sender];

      // Check whether the seller is a registered seller.
      if(sellerId == 0) { throw; }
      
      // Create a new invoice.
      uint transactionId = transactions.length;
      transactions.length += 1;

      // Fill out seller info.
      transactions[transactionId].sellerId = sellerId;
      transactions[transactionId].amount = amount;

      // -> Pass transactionId to customer now.
    }

    // As a buyer, pay a transaction.
    function payEther(uint transactionId) {
      // Bail out in case the transaction id is invalid.      
      if(transactionId < 1 || transactionId >= transactions.length) { throw; }

      // Retrieve the amount of ethers that have been sent along.
      uint etherPaid = msg.value;
      uint etherAskedFor = transactions[transactionId].amount;
      uint etherNeeded = etherAskedFor + transactionFee;

      // If the amount of ethers does not suffice to pay, bail out :(      
      if(etherPaid < etherNeeded) { throw; }

      // Calculate how much has been overpaid.
      uint payback = etherPaid - etherNeeded;
      // ..and kindly return the payback :)
      msg.sender.send(payback);

      // Now take the remaining amount and send to the seller.
      sellers[transactions[transactionId].sellerId].etherAddress.send(etherAskedFor);
      // Rise transactions paid counter.
      sellers[transactions[transactionId].sellerId].transactionsPaid += 1;

      // Overpaid ethers send back, seller has been paid, now we're done.
      // Mark the transaction as finished.

      // Flag the invoice as paid.
      transactions[transactionId].paid = true;
      // Save the payers address so he is eligible to rate.
      transactions[transactionId].paidWithAddress = msg.sender;
    
      // -> Now the transaction can be rated by the address that has paid it.
    }

    // As a buyer, rate a transaction.
    function rate(uint transactionId, uint ratingValue, string ratingComment) {
      // Only the address that has paid the transaction may rate it.
      if(transactions[transactionId].paidWithAddress != msg.sender) { throw; }
      // Bail out in case the transaction id is invalid.        
      if(transactionId < 1 || transactionId >= transactions.length) { throw; }
      // Oops, transaction has already been rated!
      if(transactions[transactionId].rated) { throw; }
      // Oops, transaction has not been paid yet and cannot be rated!
      if(!transactions[transactionId].paid) { throw; }
      // Rating range is from 1 (incl.) to 10 (incl.).
      if(ratingValue < 1 || ratingValue > 10) { throw; }

      transactions[transactionId].ratingValue = ratingValue;
      transactions[transactionId].ratingComment = ratingComment;
      transactions[transactionId].rated = true;
      
      uint previousTransactionCount = sellers[transactions[transactionId].sellerId].transactionsRated;
      uint previousTransactionRatingSum = sellers[transactions[transactionId].sellerId].averageRating * previousTransactionCount;

      sellers[transactions[transactionId].sellerId].averageRating = (previousTransactionRatingSum + ratingValue) / (previousTransactionCount + 1);
      sellers[transactions[transactionId].sellerId].transactionsRated += 1;
    }
}