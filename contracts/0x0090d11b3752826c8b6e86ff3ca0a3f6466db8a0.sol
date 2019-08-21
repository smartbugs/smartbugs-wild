pragma solidity ^0.4.24;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0 || b == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Mul overflow!");
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Sub overflow!");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Add overflow!");
        return c;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns(bool);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {

    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner, "Only Owner can do that!");
        _;
    }

    function transferOwnership(address _newOwner)
    external onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership()
    external {
        require(msg.sender == newOwner, "You are not new Owner!");
        owner = newOwner;
        newOwner = address(0);
        emit OwnershipTransferred(owner, newOwner);
    }
}

contract Permissioned {

    function approve(address _spender, uint256 _value) public returns(bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Burnable {

    function burn(uint256 _value) external returns(bool);
    function burnFrom(address _from, uint256 _value) external returns(bool);

    // This notifies clients about the amount burnt
    event Burn(address indexed _from, uint256 _value);
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract Aligato is ERC20Interface, Owned, Permissioned, Burnable {

    using SafeMath for uint256; //Be aware of overflows

    // This creates an array with all balances
    mapping(address => uint256) internal _balanceOf;

    // This creates an array with all allowance
    mapping(address => mapping(address => uint256)) internal _allowance;

    bool public isLocked = true; //only contract Owner can transfer tokens

    uint256 icoSupply = 0;

    //set ICO balance and emit
    function setICO(address user, uint256 amt) internal{
        uint256 amt2 = amt * (10 ** uint256(decimals));
        _balanceOf[user] = amt2;
        emit Transfer(0x0, user, amt2);
        icoSupply += amt2;
    }

    // As ICO been done on platform, we need set proper amouts for ppl that participate
    function doICO() internal{
setICO(	0x5cD4c4F9eb8F323d64873C55b8da45f915A8256F	,	205750	);
setICO(	0x937f403B2f5cd0C17BEE8EF5DB1ecb2E3C793343	,	130500	);
setICO(	0x7503033e1B7AF4C1bc5Dd16B45b88ac08aF256f9	,	120300	);
setICO(	0x06010e8bc01446aBf39190F305B3740BE442aD88	,	100500	);
setICO(	0x51dB593c4ACC25b527c251E4fAc40C1d0C37559D	,	42500	);
setICO(	0xD11c70764B03fd23E451574a824af2104Bec5908	,	40000	);
setICO(	0x0c1610251B1Ac4180981D09bc795784beF44115d	,	39938	);
setICO(	0x91679f8Ab88a243f6F4387407fd11d75131CF3D4	,	35000	);
setICO(	0x1ac43DEC17B267d502cc257e5ab545Af6228ba94	,	21750	);
setICO(	0x7fC6cC49a4Dd2C56dBD062141b5D2e3563e4b873	,	20000	);
setICO(	0xF19051aD24B50C14C612515fFbd68f06097d014C	,	19909	);
setICO(	0x3B6E06351c1E1bD62ffdC47C4ada2fD18a819482	,	19868	);
setICO(	0x20A2018CdC1D9A4f474C268b6c20670C597487B2	,	16169	);
setICO(	0x2fEcDEedF64C49563E90E926c7F2323DF1ba09D2	,	15000	);
setICO(	0xc9b8f7c277551dA2759c2f655Ab8429564bA6a76	,	12500	);
setICO(	0x1F2245636D7CeA33f73E4CAa7935481122AF31b9	,	12000	);
setICO(	0xbb9cDa8148153103cbe8EE0227a8c7a84666AA13	,	11125	);
setICO(	0x43E4d827e518Dd960498BD105E9e76971e5965FC	,	10500	);
setICO(	0x588749e9395A1EE6A8C9A6fb182Ebdd2796B9f0f	,	10268	);
setICO(	0x7e35AA166a8c78B49e61ab280f39915d9BB51C40	,	10000	);
setICO(	0xa2aFF7b4aC8df3FB1A789396267e0fe55b7D8783	,	8622	);
setICO(	0x7Bee818d0FD6b9f3A104e38036cC4e872517e789	,	7840	);
setICO(	0x0D2CCA65Be1F274E69224C57790731FFC3D6b767	,	7000	);
setICO(	0x2Fe29a9C8Ae4C676af671270CaED159bCF2A153b	,	6854	);
setICO(	0x7c5c27274F1cD86849e7DDd47191e4C3cd1Fe273	,	6400	);
setICO(	0xcEE7bF213816c93e8C5d87a3CC6C21dF38D120A2	,	5500	);
setICO(	0x6C5e4C05AD042880053A183a9Aa204212f09Eb65	,	5500	);
setICO(	0xA29Ecf7b205928bD4d9dEdEbA24dDEbcFE8cb8aF	,	5500	);
setICO(	0x42dfe28873c01a8D128eAaEfc3bde9FEcF22647A	,	5500	);
setICO(	0xF78d102a7f3048B5d5927dcA76601d943526F37b	,	4800	);
setICO(	0xd4E30D7b48287a72Bc99c5ABe5AB8dDE8B608802	,	4500	);
setICO(	0xeDAA7f020467e77249F9d08d81C50c4e33eB063D	,	4500	);
setICO(	0x3f2a9614f217acF05A8d6f144aEE5c1fAD564C3D	,	4500	);
setICO(	0x8a170A75845E5F39Db826470A9f28c6A331BF2B6	,	4000	);
setICO(	0xFB3018F1366219eD3fE8CE1B844860F9c4Fac5e7	,	4000	);
setICO(	0x47A85250507EB1b892AD310F78d40D170d24FED1	,	4000	);
setICO(	0x22eeb1c4265F7F7cFEB1e19AF7f32Ec361a4710E	,	4000	);
setICO(	0x6384f2d17A855435E7517C29d302690Dc02421C2	,	3700	);
setICO(	0x93E7A5b9fa8e34F58eE8d4B4562B627C04eAD99b	,	3500	);
setICO(	0xe714E0CcFCE4d0244f7431B43080C685d1504Bd0	,	3500	);
setICO(	0x27ef607C8F1b71aF3Df913C104eD73Ed66624871	,	3310	);
setICO(	0xd5B82B5BcEA28A2740b8dA56a345238Fb212B623	,	3200	);
setICO(	0xAA2dc38E8bD38C0faaa735B4C0D4a899059f5a0d	,	3125	);
setICO(	0x40b95671c37116Bf41F0D2E68BD93aD10d25502E	,	3055	);
setICO(	0xCe14cf3bB404eDC02db6Ba2d8178b200A3031aeA	,	3010	);
setICO(	0x74b04A0198b68722Ca630D041E60303B655Bd6A8	,	3000	);
setICO(	0x5Ca403BB07e4e792400d165Fd716d939C35AB49B	,	3000	);
setICO(	0x6eA366425fa4b6Cf070472aCA6991e0731de9A0D	,	3000	);
setICO(	0x3eE6ba8E7B299443Cc23eff3B8426A33aD6a2121	,	3000	);
setICO(	0xdfCee0e4E371e02d7744E9eCA3Fa6269E116b1C9	,	6524	);
setICO(	0x42A44787FaD2C644201B6c753DBAE2d990dFb47c	,	3000	);
setICO(	0xB5F1090997630A5E233467538C40C0e2e259A916	,	2630	);
setICO(	0x1ACCcE2F80A3660e672Da9F24E384D6143AF0C03	,	2585	);
setICO(	0xa32DF0f819e017b3ca2d43c67E4368edC844A804	,	2553	);
setICO(	0x7dD71b315f12De87C1F136A179DB8Cc144b58295	,	2500	);
setICO(	0x822e1a575CC4ce8D17d29cA07C082929A6B8A3bB	,	2500	);
setICO(	0x1915F337099Ce25Ee6ED818B53fF1F7623e3123F	,	2340	);
setICO(	0x6dAE092fa57D05681e919563f4ee63F2f7F1D201	,	2000	);
setICO(	0xc3923D820881B1F189123008749427A481E983Ca	,	2000	);
setICO(	0x3f47469982dE2348e44C9B56dB275E26e9259f4D	,	1900	);
setICO(	0xF6A657925812fad72a6FB51f0Fbb5328d9BF8f31	,	1650	);
setICO(	0x6a8058555c57BC1C59dcE48202DaD700fAA17D26	,	1600	);
setICO(	0xF4d4C9E869604715039cbD3027AEC95d083f9265	,	1600	);
setICO(	0x5F6520231C1ad754C574b01f34A36619C5CA2a02	,	1500	);
setICO(	0xA81Ea58d0377AaC22C78CA61c631B7b0BFf2029f	,	1500	);
setICO(	0x43396e7DF304adeFEdFF3cb3BEe3dF55D1764928	,	1500	);
setICO(	0xCcfdaA5C4E355075D1628DfaF4030a397EF0e91E	,	1500	);
setICO(	0x7e40CB0937bdf37be20F68E8d759ffD1138968Ec	,	1853	);
setICO(	0x0B8fEA04316355de3F912fc5F7aa2A32235E8986	,	1300	);
setICO(	0x0F57D11a21Fe457bd59bbaf8848410Cc38003eef	,	1200	);
setICO(	0xff3850d80A748202Fb36EF680486d64DDAA493e9	,	1091	);
setICO(	0x8d54F232DF1fB84781286Ccffb0671D436B21DFF	,	1046	);
setICO(	0x8966636fE61E876Fc6499a6B819D56Af40433083	,	1039	);
setICO(	0x8B25A8f699F314ef3011122AD1d0B102e326367f	,	1006	);
setICO(	0x32ABe252Ea2CE4E949738495Ed51f911F835Fd53	,	1000	);
setICO(	0x67eb2a1cC74cC366DDE5aE88A5E4F82eF1a13B49	,	1000	);
setICO(	0x680C150689d6b981d382206A39fB44301b62F837	,	1000	);
setICO(	0x70D7c067C206f1e42178604678ff2C0C9fd58E66	,	1000	);
setICO(	0x65cc14dc596073750a566205370239e8e20268E4	,	1000	);
setICO(	0x887995731f3fd390B7eeb6aEb978900af410D48B	,	800	);
setICO(	0x5f3861ffc2e75D00BA5c19728590986f3FF48808	,	760	);
setICO(	0x9b6ac30F4694d86d430ECDB2cD16F3e6e414cBb2	,	640	);
setICO(	0x9d35e4411272DF158a8634a2f529DEd0fF541973	,	593	);
setICO(	0x27B48344ed0b7Aaef62e1E679035f94a25DF2442	,	508	);
setICO(	0x351313F49476Ed58214D07Bb87162527be34978e	,	500	);
setICO(	0xd96B785ba950ccf4d336FbDC69c2a82fB6c485B4	,	500	);
setICO(	0x7Eb37Ddd2b4Ed95Be445a1BCBf33b458e0e0103D	,	400	);
setICO(	0xCA83fBDe3197c93d4754bf23fe2f5c745a4DcAA0	,	350	);
setICO(	0xd162BdB296b99527D137323BEdF80a0899476a3b	,	345	);
setICO(	0x93773a596DfB4E0641dC626306c903a0552E05E7	,	340	);
setICO(	0x61014d61b734162745E0B9770be56F2d21460cE6	,	300	);
setICO(	0x0b48AEBA0e8Ab53820c6Cc25249bB0c6A09f3E2c	,	300	);
setICO(	0xe24526F12eA980c237d25F5aefc2fe3Aa5fc70cd	,	250	);
setICO(	0x34FCb220FACd2746433a312D113737fCc4B32B11	,	196	);
setICO(	0x7037c3521616Ca33F3362cC4a8ef29dc172cC392	,	150	);
setICO(	0xf0d9C8b7b1C94B67d90131Eb5444Ff4D9fE98eAd	,	150	);
setICO(	0x65ba8BAa1857578606f5F69E975C658daE26eDe5	,	100	);
setICO(	0xb19cB24d619608eFe8a127756ac030D56586Fc84	,	100	);
setICO(	0x18fa81c761Bf09e86cDcb0D01C18d7f8ceDbeCc3	,	100	);
setICO(	0x7a666D30379576Cc4659b5440eF787c652eeD11B	,	100	);
setICO(	0x1b0ccb9B9d74D83F1A51656e1f20b0947bd5927d	,	100	);
setICO(	0xA29Cd944f7bA653D35cE627961246A87ffdB1156	,	100	);
setICO(	0xA88677Bed9DE38C818aFcC2C7FAD60D473A23542	,	100	);
setICO(	0xC5ffEb68fb7D13ffdff2f363aE560dF0Ce392a98	,	50	);
setICO(	0xc7EFE07b332b580eBA18DE013528De604E363b64	,	38	);
setICO(	0xFcc9aCC9FC667Ad2E7D7BcEDa58bbacEa9cB721A	,	20	);
setICO(	0x9cdEBfF1F20F6b7828AEAb3710D6caE61cB48cd4	,	5	);


    }

    /**
    * Constructor function
    *
    * Initializes contract with initial supply tokens to the creator of the contract
    */
    constructor(string _symbol, string _name, uint256 _supply, uint8 _decimals)
    public {
        require(_supply != 0, "Supply required!"); //avoid accidental deplyment with zero balance
        owner = msg.sender;
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        doICO();
        totalSupply = _supply.mul(10 ** uint256(decimals)); //supply in constuctor is w/o decimal zeros
        _balanceOf[msg.sender] = totalSupply - icoSupply;
        emit Transfer(address(0), msg.sender, totalSupply - icoSupply);
    }

    // unlock transfers for everyone
    function unlock() external onlyOwner returns (bool success)
    {
        require (isLocked == true, "It is unlocked already!"); //you can unlock only once
        isLocked = false;
        return true;
    }

    /**
    * Get the token balance for account
    *
    * Get token balance of `_owner` account
    *
    * @param _owner The address of the owner
    */
    function balanceOf(address _owner)
    external view
    returns(uint256 balance) {
        return _balanceOf[_owner];
    }

    /**
    * Internal transfer, only can be called by this contract
    */
    function _transfer(address _from, address _to, uint256 _value)
    internal {
        // check that contract is unlocked
        require (isLocked == false || _from == owner, "Contract is locked!");
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != address(0), "Can`t send to 0x0, use burn()");
        // Check if the sender has enough
        require(_balanceOf[_from] >= _value, "Not enough balance!");
        // Subtract from the sender
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        // Add the same to the recipient
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    /**
    * Transfer tokens
    *
    * Send `_value` tokens to `_to` from your account
    *
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transfer(address _to, uint256 _value)
    external
    returns(bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * Transfer tokens from other address
    *
    * Send `_value` tokens to `_to` on behalf of `_from`
    *
    * @param _from The address of the sender
    * @param _to The address of the recipient
    * @param _value the amount to send
    */
    function transferFrom(address _from, address _to, uint256 _value)
    external
    returns(bool success) {
        // Check allowance
        require(_value <= _allowance[_from][msg.sender], "Not enough allowance!");
        // Check balance
        require(_value <= _balanceOf[_from], "Not enough balance!");
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        emit Approval(_from, _to, _allowance[_from][_to]);
        return true;
    }

    /**
    * Set allowance for other address
    *
    * Allows `_spender` to spend no more than `_value` tokens on your behalf
    *
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    */
    function approve(address _spender, uint256 _value)
    public
    returns(bool success) {
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * Set allowance for other address and notify
    *
    * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
    *
    * @param _spender The address authorized to spend
    * @param _value the max amount they can spend
    * @param _extraData some extra information to send to the approved contract
    */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    external
    returns(bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender)
    external view
    returns(uint256 value) {
        return _allowance[_owner][_spender];
    }

    /**
    * Destroy tokens
    *
    * Remove `_value` tokens from the system irreversibly
    *
    * @param _value the amount of money to burn
    */
    function burn(uint256 _value)
    external
    returns(bool success) {
        _burn(msg.sender, _value);
        return true;
    }

    /**
    * Destroy tokens from other account
    *
    * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
    *
    * @param _from the address of the sender
    * @param _value the amount of money to burn
    */
    function burnFrom(address _from, uint256 _value)
    external
    returns(bool success) {
         // Check allowance
        require(_value <= _allowance[_from][msg.sender], "Not enough allowance!");
        // Is tehere enough coins on account
        require(_value <= _balanceOf[_from], "Insuffient balance!");
        // Subtract from the sender's allowance
        _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        _burn(_from, _value);
        emit Approval(_from, msg.sender, _allowance[_from][msg.sender]);
        return true;
    }

    function _burn(address _from, uint256 _value)
    internal {
        // Check if the targeted balance is enough
        require(_balanceOf[_from] >= _value, "Insuffient balance!");
        // Subtract from the sender
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        // Updates totalSupply
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(_from, address(0), _value);
    }

    // ------------------------------------------------------------------------
    // Don't accept accidental ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert("This contract is not accepting ETH.");
    }

    //Owner can take ETH from contract
    function withdraw(uint256 _amount)
    external onlyOwner
    returns (bool){
        require(_amount <= address(this).balance, "Not enough balance!");
        owner.transfer(_amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint256 _value)
    external onlyOwner
    returns(bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, _value);
    }
}