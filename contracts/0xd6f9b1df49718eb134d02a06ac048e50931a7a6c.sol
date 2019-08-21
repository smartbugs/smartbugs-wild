pragma solidity ^0.4.18;

contract ZastrinPay {

  /*
   * Author: Mahesh Murthy
   * Company: Zastrin, Inc
   * Contact: mahesh@zastrin.com
   */

  address public owner;

  struct paymentInfo {
    uint userId;
    uint amount;
    uint purchasedAt;
    bool refunded;
    bool cashedOut;
  }

  mapping(uint => bool) coursesOffered;
  mapping(address => mapping(uint => paymentInfo)) customers;

  uint fallbackAmount;

  event NewPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer, uint _amount);
  event RefundPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer);

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function ZastrinPay() public {
    owner = msg.sender;
  }

  function addCourse(uint _courseId) public onlyOwner {
    coursesOffered[_courseId] = true;
  }

  function buyCourse(uint _courseId, uint _userId) public payable {
    require(coursesOffered[_courseId]);
    customers[msg.sender][_courseId].amount += msg.value;
    customers[msg.sender][_courseId].purchasedAt = now;
    customers[msg.sender][_courseId].userId = _userId;
    NewPayment(_courseId, _userId, msg.sender, msg.value);
  }

  function getRefund(uint _courseId) public {
    require(customers[msg.sender][_courseId].userId > 0);
    require(customers[msg.sender][_courseId].refunded == false);
    require(customers[msg.sender][_courseId].purchasedAt + (3 hours) > now);
    customers[msg.sender][_courseId].refunded = true;
    msg.sender.transfer(customers[msg.sender][_courseId].amount);
    RefundPayment(_courseId, customers[msg.sender][_courseId].userId, msg.sender);
  }

  function cashOut(address _customer, uint _courseId) public onlyOwner {
    require(customers[_customer][_courseId].refunded == false);
    require(customers[_customer][_courseId].cashedOut == false);
    require(customers[_customer][_courseId].purchasedAt + (3 hours) < now);
    customers[_customer][_courseId].cashedOut = true;
    owner.transfer(customers[_customer][_courseId].amount);
  }

  function cashOutFallbackAmount() public onlyOwner {
    owner.transfer(fallbackAmount);
  }

  function() public payable {
    fallbackAmount += msg.value;
  }
}