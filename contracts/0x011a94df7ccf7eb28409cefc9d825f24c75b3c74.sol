/**
 * Source Code first verified at https://etherscan.io on Saturday, May 18, 2019
 (UTC) */

/**
 * Source Code first verified at https://etherscan.io on Wednesday, May 15, 2019
 (UTC) */

/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 14, 2019
 (UTC) */

/**
 * Source Code first verified at https://etherscan.io on Tuesday, May 14, 2019
 (UTC) */

/**
 * Source Code first verified at https://etherscan.io on Thursday, April 25, 2019
 (UTC) */

pragma solidity ^0.4.25;
contract SalaryInfo {
    struct User {
        string name;
        // string horce_image;
        // string unique_id;
        // string sex;
        // uint256 DOB;
        // string country_name;
        // string Pedigree_name;
        // string color;
        // string owner_name;
        // string breed;
        // string Pedigree_link;
    }
    User[] public users;

    function addUser(string name, string horce_image, string unique_id, string sex,string DOB, string country_name, string Pedigree_name,string color, string owner_name,string breed,string Pedigree_link,string Pedigree_image) public returns(uint) {
        users.length++;
        // users[users.length-1].salaryId = unique_id;
        users[users.length-1].name = name;
        // users[users.length-1].userAddress = horce_image;
       //users[users.length-1].salary = _salary;
        return users.length;
    }
      
      
     function add_medical_records(string record_type, string medical_date, string vaccination,string product,string details) public returns(uint) {
    //     users.length++;
    //     // users[users.length-1].salaryId = unique_id;
    //     users[users.length-1].name = name;
    //     // users[users.length-1].userAddress = horce_image;
    //   //users[users.length-1].salary = _salary;
    //     return users.length;
     }
    
    function getUsersCount() public constant returns(uint) {
        return users.length;
    }

    function getUser(uint index) public constant returns(string) {
        return (users[index].name);
    }
}