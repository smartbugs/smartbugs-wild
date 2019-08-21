/*
	Verified Crypto Company token

	Copyright (C) Fusion Solutions KFT <contact@fusionsolutions.io> - All Rights Reserved

	This file is part of Verified Crypto Company token project.
	Unauthorized copying of this file or source, via any medium is strictly prohibited
	Proprietary and confidential
	This file can not be copied and/or distributed without the express permission of the Author.

	Written by Andor Rajci, August 2018
*/
pragma solidity 0.4.24;

library SafeMath {
    /* Internals */
    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a + b;
        assert( c >= a );
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a - b;
        assert( c <= a );
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a * b;
        assert( c == 0 || c / a == b );
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        return a / b;
    }
    function pow(uint256 a, uint256 b) internal pure returns(uint256 c) {
        c = a ** b;
        assert( c % a == 0 );
        return a ** b;
    }
}

contract Token {
	/* Declarations */
	using SafeMath for uint256;
	/* Structures */
	struct action_s {
		address origin;
		uint256 voteCounter;
		uint256 uid;
		mapping(address => uint256) voters;
	}
	/* Variables */
	string  public name = "Verified Crypto Company token";
	string  public symbol = "VRFD";
	uint8   public decimals = 0;
	uint256 public totalSupply = 1e6;
	uint256 public actionVotedRate;
	uint256 public ownerCounter;
	uint256 public voteUID;
	address public admin;
	mapping(address => uint256) public balanceOf;
	mapping(address => string) public nameOf;
	mapping(address => bool) public owners;
	mapping(bytes32 => action_s) public actions;
	/* Constructor */
	constructor(address _admin, uint256 _actionVotedRate, address[] _owners) public {
		uint256 i;
		require( _actionVotedRate <= 100 );
		actionVotedRate = _actionVotedRate;
		for ( i=0 ; i<_owners.length ; i++ ) {
			owners[_owners[i]] = true;
		}
		ownerCounter = _owners.length;
		balanceOf[address(this)] = totalSupply;
		emit Mint(address(this), totalSupply);
		admin = _admin;
	}
	/* Fallback */
	function () public { revert(); }
	/* Externals */
	function setStatus(address _target, uint256 _status, string _name) external forAdmin {
		require( balanceOf[_target] == 0 );
		balanceOf[address(this)] = balanceOf[address(this)].sub(_status);
		balanceOf[_target] = _status;
		nameOf[_target] = _name;
		emit Transfer(address(this), _target, _status);
	}
	function delStatus(address _target) external forAdmin {
		require( balanceOf[_target] > 0 );
		balanceOf[address(this)] = balanceOf[address(this)].add(balanceOf[_target]);
		emit Transfer(_target,  address(this), balanceOf[_target]);
		delete balanceOf[_target];
		delete nameOf[_target];
	}
	function changeAdmin(address _newAdmin) external forOwner {
		bytes32 _hash;
		_hash = keccak256('changeAdmin', _newAdmin);
		if ( actions[_hash].origin == 0x00 ) {
			emit newAdminAction(_hash, _newAdmin, msg.sender);
		}
		if ( doVote(_hash) ) {
			admin = _newAdmin;
		}
	}
	function newOwner(address _owner) external forOwner {
		bytes32 _hash;
		require( ! owners[_owner] );
		_hash = keccak256('addNewOwner', _owner);
		if ( actions[_hash].origin == 0x00 ) {
			emit newAddNewOwnerAction(_hash, _owner, msg.sender);
		}
		if ( doVote(_hash) ) {
			ownerCounter = ownerCounter.add(1);
			owners[_owner] = true;
		}
	}
	function delOwner(address _owner) external forOwner {
		bytes32 _hash;
		require( owners[_owner] );
		_hash = keccak256('delOwner', _owner);
		if ( actions[_hash].origin == 0x00 ) {
			emit newDelOwnerAction(_hash, _owner, msg.sender);
		}
		if ( doVote(_hash) ) {
			ownerCounter = ownerCounter.sub(1);
			owners[_owner] = false;
		}
	}
	/* Internals */
	function doVote(bytes32 _hash) internal returns (bool _voted) {
		require( owners[msg.sender] );
		if ( actions[_hash].origin == 0x00 ) {
			voteUID = voteUID.add(1);
			actions[_hash].origin = msg.sender;
			actions[_hash].voteCounter = 1;
			actions[_hash].uid = voteUID;
		} else if ( ( actions[_hash].voters[msg.sender] != actions[_hash].uid ) && actions[_hash].origin != msg.sender ) {
			actions[_hash].voters[msg.sender] = actions[_hash].uid;
			actions[_hash].voteCounter = actions[_hash].voteCounter.add(1);
			emit vote(_hash, msg.sender);
		}
		if ( actions[_hash].voteCounter.mul(100).div(ownerCounter) >= actionVotedRate ) {
			_voted = true;
			emit votedAction(_hash);
			delete actions[_hash];
		}
	}
	/* Modifiers */
	modifier forAdmin {
		require( msg.sender == admin );
		_;
	}
	modifier forOwner {
		require( owners[msg.sender] );
		_;
	}
	/* Events */
	event Mint(address indexed _addr, uint256 indexed _value);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event newAddNewOwnerAction(bytes32 _hash, address _owner, address _origin);
	event newDelOwnerAction(bytes32 _hash, address _owner, address _origin);
	event newAdminAction(bytes32 _hash, address _newAdmin, address _origin);
	event vote(bytes32 _hash, address _voter);
	event votedAction(bytes32 _hash);
}