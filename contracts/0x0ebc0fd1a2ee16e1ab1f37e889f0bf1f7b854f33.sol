pragma solidity ^0.5.1;

contract KingoftheBill {
    address owner = msg.sender;
    address payable donee = 0xc7464dbcA260A8faF033460622B23467Df5AEA42;
    
    struct Record {
        string donorName; 
        uint donation; 
    }

    mapping(address => Record) private donorsbyAddress;

    address[] public addressLUT;

    uint public sumDonations;                       

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function donate(string memory _name) public payable {
        require(msg.value > 0);
        donorsbyAddress[msg.sender].donorName = _name; 
        donorsbyAddress[msg.sender].donation = donorsbyAddress[msg.sender].donation + msg.value;
        sumDonations = sumDonations + msg.value;
        addressLUT.push(msg.sender);
        donee.transfer(msg.value);   
    }

    function getDonationsofDonor (address _donor) external view returns(uint){ 
        return donorsbyAddress[_donor].donation;
    }

    function getNameofDonor (address _donor) external view returns(string memory){
        return donorsbyAddress[_donor].donorName;
    }

    function getaddressLUT() external view returns(address[] memory){
        return addressLUT;
    }

    function killContract() public onlyOwner {
        selfdestruct(donee);
    }

}