pragma solidity ^0.4.18;

contract CryptoPicture {

	address		public	_admin;
	uint				_supply = 29;
	uint 				_id;
	bytes32[29]			_cryptoPicture;
	bool		public	_endEdit;

	mapping ( bytes32 => string ) 	_namePicture;
	mapping ( bytes32 => string ) 	_author;
	mapping ( bytes32 => bytes32 ) 	_hashPicture;
	mapping ( bytes32 => address ) 	_owner;
	mapping ( address => mapping ( address => mapping ( bytes32 => bool ) ) ) 	_allowance;

	event 	Transfer( address from, address to, bytes32 picture );
	event 	Approval( address owner, address spender, bytes32 cryptoPicture, bool resolution );

	function 	CryptoPicture() public {
		_admin = msg.sender;
	}

	/*** Assert  functions ***/
	function 	assertAdmin() view private {
		if ( msg.sender != _admin ) {
			assert( false );
		}
	}

	function 	assertOwnerPicture( address owner, bytes32 hash ) view private {
		if ( owner != _owner[hash] ) {
			assert( false );
		}
	}

	function 	assertId( uint id ) view private {
		if ( id >= _supply )
			assert( false );
	}

	function 	assertAllowance( address from, bytes32 hash ) view private {
		if ( _allowance[from][msg.sender][hash] == false )
			assert( false );
	}

	function 	assertEdit() view private {
		if ( _endEdit == true )
			assert( false );
	}

	function	assertProtectedEdit( uint id ) view private {
		assertAdmin();
		assertEdit();
		assertId( id );
	}

	/*** Admin panel ***/
	function  	addPicture( string namePicture, bytes32 hashPicture, string author, address owner ) public {
		assertAdmin();
		assertId(_id);

		setPicture( _id, namePicture, hashPicture, author, owner );
		_id++;
	}

	function	setEndEdit() public {
		assertAdmin();
		_endEdit = true;
	}

	function 	setAdmin( address admin ) public {
		assertAdmin();
		_admin = admin;
	}

	/*** Edit function for Admin ***/
	function 	setNamePiture( uint id, string namePicture ) public {
		bytes32 	hash;

		assertProtectedEdit( id );

		hash = _cryptoPicture[id];
		setPicture( id, namePicture, _hashPicture[hash], _author[hash], _owner[hash] );
	}

	function 	setAuthor( uint id, string author ) public {
		bytes32 	hash;

		assertProtectedEdit( id );

		hash = _cryptoPicture[id];
		setPicture( id, _namePicture[hash], _hashPicture[hash], author, _owner[hash]);
	}

	function 		setHashPiture( uint id, bytes32 hashPicture ) public {
		bytes32 	hash;

		assertProtectedEdit( id );

		hash = _cryptoPicture[id];
		setPicture( id, _namePicture[hash], hashPicture, _author[hash], _owner[hash] );
	}

	function 		setOwner( uint id, address owner ) public {
		bytes32 	hash;

		assertProtectedEdit( id );

		hash = _cryptoPicture[id];
		setPicture( id, _namePicture[hash], _hashPicture[hash], _author[hash], owner );
	}

	/*** private function for edit field cryptoPicture	***/
	function 	setPicture( uint id, string namePicture, bytes32 hashPicture, string author, address owner ) private {
		bytes32 	hash;

		hash = sha256( this, id, namePicture, hashPicture, author );

		_cryptoPicture[id] = hash;
		_namePicture[hash] = namePicture;
		_author[hash] = author;
		_owner[hash] = owner;
		_hashPicture[hash] = hashPicture;
	}

	/*** ERC20 similary ***/
	function 	totalSupply() public constant returns ( uint )  {
		return 	_supply;
	}

	function 	allowance( address owner, address spender, bytes32 picture) public constant returns ( bool ) {
		return 	_allowance[owner][spender][picture];
	}

	function 	approve( address spender, bytes32 hash, bool resolution ) public returns ( bool ) {
		assertOwnerPicture( msg.sender, hash );

		_allowance[msg.sender][spender][hash] = resolution;
		Approval( msg.sender, spender, hash, resolution );
		return true;
	}

	function 	transfer( address to, bytes32 hash ) public returns ( bool ) {
		assertOwnerPicture( msg.sender, hash );

		_owner[hash] = to;
		Transfer( msg.sender, to, hash );
		return true;
	}

	function 	transferFrom( address from, address to, bytes32 hash ) public returns( bool ) {
		assertOwnerPicture( from, hash );
		assertAllowance( from, hash );

		_owner[hash] = to;
		_allowance[from][msg.sender][hash] = false;
		Transfer( from, to, hash );
		return true;
	}

	/*** Get variable ***/
	function 	getCryptoPicture( uint id ) public constant returns ( bytes32 ) {
		assertId( id );

		return _cryptoPicture[id];
	}

	function 	getNamePicture( bytes32 picture ) public constant returns ( string ) {
		return _namePicture[picture];
	}

	function 	getAutorPicture( bytes32 picture ) public constant returns ( string ) {
		return _author[picture];
	}

	function 	getHashPicture( bytes32 picture ) public constant returns ( bytes32 ) {
		return _hashPicture[picture];
	}

	function 	getOwnerPicture( bytes32 picture ) public constant returns ( address ) {
		return _owner[picture];
	}
}