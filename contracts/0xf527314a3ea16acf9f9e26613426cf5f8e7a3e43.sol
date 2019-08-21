pragma solidity 0.4.25;


contract Owned {
    address public owner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() internal {
        owner = msg.sender;
    }

    function setOwner(address _address) public onlyOwner {
        owner = _address;
    }
}


contract RequiringAuthorization is Owned {
    mapping(address => bool) public authorized;

    modifier onlyAuthorized {
        require(authorized[msg.sender]);
        _;
    }

    constructor() internal {
        authorized[msg.sender] = true;
    }

    function authorize(address _address) public onlyOwner {
        authorized[_address] = true;
    }

    function deauthorize(address _address) public onlyOwner {
        authorized[_address] = false;
    }
}


contract WalletController is RequiringAuthorization {
    address public destination;
    address public defaultSweeper = address(new DefaultSweeper(address(this)));

    mapping(address => address) public sweepers;

    event EthDeposit(address _from, address _to, uint _amount);
    event WalletCreated(address _address);
    event Sweeped(address _from, address _to, address _token, uint _amount);

    constructor() public {
        owner = msg.sender;
        destination = msg.sender;
    }

    function setDestination(address _destination) public {
        destination = _destination;
    }

    function createWallet() public onlyAuthorized {
        address wallet = address(new UserWallet(this));
        emit WalletCreated(wallet);
    }

    function addSweeper(address _token, address _sweeper) public onlyOwner {
        sweepers[_token] = _sweeper;
    }

    function sweeperOf(address _token) public view returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == 0) sweeper = defaultSweeper;
        return sweeper;
    }

    function logEthDeposit(address _from, address _to, uint _amount) public {
        emit EthDeposit(_from, _to, _amount);
    }

    function logSweep(address _from, address _to, address _token, uint _amount) public {
        emit Sweeped(_from, _to, _token, _amount);
    }
}


contract UserWallet {
    WalletController private controller;

    constructor (address _controller) public {
        controller = WalletController(_controller);
    }

    function () public payable {
        controller.logEthDeposit(msg.sender, address(this), msg.value);
    }

    function tokenFallback(address _from, uint _value, bytes _data) public pure {
        (_from);
        (_value);
        (_data);
    }

    function sweep(address _token, uint _amount) public returns (bool) {
        (_amount);
        return controller.sweeperOf(_token).delegatecall(msg.data);
    }
}


contract AbstractSweeper {
    WalletController public controller;

    constructor (address _controller) public {
        controller = WalletController(_controller);
    }

    function () public { revert(); }

    function sweep(address token, uint amount) public returns (bool);

    modifier canSweep() {
        if (!controller.authorized(msg.sender)) revert();
        _;
    }
}


contract DefaultSweeper is AbstractSweeper {

    constructor (address controller) public AbstractSweeper(controller) {}

    function sweep(address _token, uint _amount) public canSweep returns (bool) {
        bool success = false;
        address destination = controller.destination();

        if (_token != address(0)) {
            Token token = Token(_token);
            uint amount = _amount;
            if (amount > token.balanceOf(this)) {
                return false;
            }

            success = token.transfer(destination, amount);
        } else {
            uint amountInWei = _amount;
            if (amountInWei > address(this).balance) {
                return false;
            }
            success = destination.send(amountInWei);
        }

        if (success) {
            controller.logSweep(this, destination, _token, _amount);
        }
        return success;
    }
}


contract Token {
    function balanceOf(address a) public pure returns (uint) {
        (a);
        return 0;
    }

    function transfer(address a, uint val) public pure returns (bool) {
        (a);
        (val);
        return false;
    }
}