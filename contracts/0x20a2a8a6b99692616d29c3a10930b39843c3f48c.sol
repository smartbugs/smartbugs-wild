pragma solidity ^0.4.18;

contract Blockeds {
  mapping (address => bool) blocked;

  event Blocked(address _addr);
  event Unblocked(address _addr);

  function blockAddress(address _addr) public {
    require(!blocked[_addr]);
    blocked[_addr] = true;

    Blocked(_addr);
  }

  function unblockAddress(address _addr) public {
    require(blocked[_addr]);
    blocked[_addr] = false;

    Unblocked(_addr);
  }
}

/*
    저작권 2016, Jordi Baylina

    이 프로그램은 무료 소프트웨어입니다.
    이 프로그램은 Free Soft ware Foundation에서
    게시하는 GNU General Public License의
    조건에 따라 라이센스의 버전 3또는(선택 사항으로)
    이후 버전으로 재배포 및 또는 수정할 수 있습니다.

    이 프로그램은 유용할 것을 기대하여 배포되지만,
    상품성이나 특정 목적에 대한 적합성의 묵시적
    보증도 없이 모든 보증 없이 제공됩니다.
    자세한 내용은 GNU General Public License를 참조하십시오.

    이 프로그램과 함께 GNU General Public License 사본을 받아야합니다.
    그렇지 않으면, 참조 : <http://www.gnu.org/licenses/>
 */

/*
 * @title MiniMeToken
 * @author Jordi Baylina
 * @dev 이 토큰 계약의 목표는 이 토큰을 손쉽게 복제하는 것입니다.
 *      토큰을 사용하면 지정된 블록에서 DAO 및 DApps가 원래 토큰에 영향을 주지 않고 기능을 분산된 방식으로 업그레이드할 수 있습니다.
 * @dev ERC20과 호환되지만 추가 테스트를 진행해야합니다.
*/
contract Controlled {
    // 컨트롤러의 주소는 이 수정 프로그램으로 함수를 호출할 수 있는 유일한 주소입니다.
    modifier onlyController { require(msg.sender == controller); _; }

    address public controller;

    function Controlled() public { controller = msg.sender;}

    //                계약 당사자
    // _newController 새로운 계약자
    function changeController(address _newController) public onlyController {
        controller = _newController;
    }
}



// 토큰 컨트롤러 계약에서 이러한 기능을 구현해야 합니다.
contract TokenController {
    // @notice `_owner`가 이더리움을 MiniMeToken 계약에 보낼 때 호출됩니다.
    // @param   _owner 토큰을 생성하기 위해 이더리움을 보낸 주소
    // @return         이더리움이 정상 전송되는 경우는 true, 아닌 경우는 false
    function proxyPayment(address _owner) public payable returns(bool);

    // @notice         컨트롤러에 토큰 전송에 대해 알립니다.
    //                 원하는 경우 반응하는 컨트롤러
    // @param _from    전송의 출처
    // @param _to      전송 목적지
    // @param _amount  전송 금액
    // @return         컨트롤러가 전송을 승인하지 않는 경우 거짓
    function onTransfer(address _from, address _to, uint _amount) public returns(bool);

    // @notice                     컨트롤러에 승인 사실을 알리고, 필요한 경우 컨트롤러가 대응하도록 합니다.
    // @param _owner `approve ()`  를 호출하는 주소.
    // @param _spender `approve()` 호출하는 전송자
    // @param _amount `approve ()` 호출의 양
    // @return                     컨트롤러가 승인을 허가하지 않는 경우 거짓
    function onApprove(address _owner, address _spender, uint _amount) public
        returns(bool);
}

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes _data) public;
}

// 실제 토큰 계약인 기본 컨트롤러는 계약서를 배포하는 msg.sender이므로
// 이 토큰은 대개 토큰 컨트롤러 계약에 의해 배포되며,
// Giveth는 "Campaign"을 호출합니다.
contract MiniMeToken is Controlled {
    string public name;                // 토큰 이름 : EX DigixDAO token
    uint8 public decimals;             // 최소 단위의 소수 자릿수
    string public symbol;              // 식별자 EX : e.g. REP
    string public version = 'MMT_0.2'; // 버전 관리 방식

    // @dev `Checkpoint` 블록 번호를 지정된 값에 연결하는 구조이며,
    //                    첨부된 블록 번호는 마지막으로 값을 변경한 번호입니다.
    struct  Checkpoint {

        // `fromBlock` 값이 생성된 블록 번호입니다.
        uint128 fromBlock;

        // `value` 특정 블록 번호의 토큰 양입니다.
        uint128 value;
    }

    // `parentToken` 이 토큰을 생성하기 위해 복제 된 토큰 주소입니다.
    //               복제되지 않은 토큰의 경우 0x0이 됩니다.
    MiniMeToken public parentToken;

    // `parentSnapShotBlock` 상위 토큰의 블록 번호로,
    //                       복제 토큰의 초기 배포를 결정하는 데 사용됨
    uint public parentSnapShotBlock;

    // `creationBlock` 복제 토큰이 생성된 블록 번호입니다.
    uint public creationBlock;

    // `balances` 이 계약에서 잔액이 변경될 때 변경 사항이 발생한
    //            블록 번호도 맵에 포함되어 있으며 각 주소의 잔액을 추적하는 맵입니다.
    mapping (address => Checkpoint[]) balances;

    // `allowed` 모든 ERC20 토큰에서와 같이 추가 전송 권한을 추적합니다.
    mapping (address => mapping (address => uint256)) allowed;

    // 토큰의 `totalSupply` 기록을 추적합니다.
    Checkpoint[] totalSupplyHistory;

    // 토큰이 전송 가능한지 여부를 결정하는 플래그 입니다.
    bool public transfersEnabled;

    // 새 복제 토큰을 만드는 데 사용 된 팩토리
    MiniMeTokenFactory public tokenFactory;

    /*
     * 건설자
     */
    // @notice MiniMeToken을 생성하는 생성자
    // @param _tokenFactory MiniMeTokenFactory 계약의 주소
    //                               복제 토큰 계약을 생성하는 MiniMeTokenFactory 계약의 주소,
    //                               먼저 토큰 팩토리를 배포해야합니다.
    // @param _parentToken           상위 토큰의 ParentTokerut 주소 (새 토큰인 경우 0x0으로 설정됨)
    // @param _parentSnapShotBlock   복제 토큰의 초기 배포를 결정할 상위 토큰의 블록(새 토큰인 경우 0으로 설정됨)
    // @param _tokenName             새 토큰의 이름
    // @param _decimalUnits          새 토큰의 소수 자릿수
    // @param _tokenSymbol           새 토큰에 대한 토큰 기호
    // @param _transfersEnabled true 이면 토큰을 전송할 수 있습니다.
    function MiniMeToken(
        address _tokenFactory,
        address _parentToken,
        uint _parentSnapShotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public {
        tokenFactory = MiniMeTokenFactory(_tokenFactory);
        name = _tokenName;                                 // 이름 설정
        decimals = _decimalUnits;                          // 십진수 설정
        symbol = _tokenSymbol;                             // 기호 설정 (심볼)
        parentToken = MiniMeToken(_parentToken);
        parentSnapShotBlock = _parentSnapShotBlock;
        transfersEnabled = _transfersEnabled;
        creationBlock = block.number;
    }

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);
        doTransfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount
    ) public returns (bool success) {
        if (msg.sender != controller) {
            require(transfersEnabled);

            require(allowed[_from][msg.sender] >= _amount);
            allowed[_from][msg.sender] -= _amount;
        }
        doTransfer(_from, _to, _amount);
        return true;
    }

    function doTransfer(address _from, address _to, uint _amount
    ) internal {

           if (_amount == 0) {
               Transfer(_from, _to, _amount);
               return;
           }

           require(parentSnapShotBlock < block.number);

           require((_to != 0) && (_to != address(this)));

           var previousBalanceFrom = balanceOfAt(_from, block.number);

           require(previousBalanceFrom >= _amount);

           if (isContract(controller)) {
               require(TokenController(controller).onTransfer(_from, _to, _amount));
           }

           updateValueAtNow(balances[_from], previousBalanceFrom - _amount);

           var previousBalanceTo = balanceOfAt(_to, block.number);
           require(previousBalanceTo + _amount >= previousBalanceTo);
           updateValueAtNow(balances[_to], previousBalanceTo + _amount);

           Transfer(_from, _to, _amount);

    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        require(transfersEnabled);

        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));

        // 승인 기능 호출의 토큰 컨트롤러에 알림
        if (isContract(controller)) {
            require(TokenController(controller).onApprove(msg.sender, _spender, _amount));
        }

        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender
    ) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function approveAndCall(address _spender, uint256 _amount, bytes _extraData
    ) public returns (bool success) {
        require(approve(_spender, _amount));

        ApproveAndCallFallBack(_spender).receiveApproval(
            msg.sender,
            _amount,
            this,
            _extraData
        );

        return true;
    }

    function totalSupply() public constant returns (uint) {
        return totalSupplyAt(block.number);
    }

    /*
     * 히스토리 내 쿼리 균형 및 총 공급
     */
    function balanceOfAt(address _owner, uint _blockNumber) public constant
        returns (uint) {

        if ((balances[_owner].length == 0)
            || (balances[_owner][0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.balanceOfAt(_owner, min(_blockNumber, parentSnapShotBlock));
            } else {
                // 상위토큰이 없다.
                return 0;
            }
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

    function totalSupplyAt(uint _blockNumber) public constant returns(uint) {
        if ((totalSupplyHistory.length == 0)
            || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            if (address(parentToken) != 0) {
                return parentToken.totalSupplyAt(min(_blockNumber, parentSnapShotBlock));
            } else {
                return 0;
            }
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

    /*
     * 토큰 복제 방법
     */
    function createCloneToken(
        string _cloneTokenName,
        uint8 _cloneDecimalUnits,
        string _cloneTokenSymbol,
        uint _snapshotBlock,
        bool _transfersEnabled
        ) public returns(address) {
        if (_snapshotBlock == 0) _snapshotBlock = block.number;
        MiniMeToken cloneToken = tokenFactory.createCloneToken(
            this,
            _snapshotBlock,
            _cloneTokenName,
            _cloneDecimalUnits,
            _cloneTokenSymbol,
            _transfersEnabled
            );

        cloneToken.changeController(msg.sender);

        NewCloneToken(address(cloneToken), _snapshotBlock);
        return address(cloneToken);
    }

    /*
     * 토큰 생성 및 소각
     */
    function generateTokens(address _owner, uint _amount
    ) public onlyController returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply);
        uint previousBalanceTo = balanceOf(_owner);
        require(previousBalanceTo + _amount >= previousBalanceTo);
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_owner], previousBalanceTo + _amount);
        Transfer(0, _owner, _amount);
        return true;
    }

    function destroyTokens(address _owner, uint _amount
    ) onlyController public returns (bool) {
        uint curTotalSupply = totalSupply();
        require(curTotalSupply >= _amount);
        uint previousBalanceFrom = balanceOf(_owner);
        require(previousBalanceFrom >= _amount);
        updateValueAtNow(totalSupplyHistory, curTotalSupply - _amount);
        updateValueAtNow(balances[_owner], previousBalanceFrom - _amount);
        Transfer(_owner, 0, _amount);
        return true;
    }

    /*
     * 토큰 전송 사용
     */
    function enableTransfers(bool _transfersEnabled) public onlyController {
        transfersEnabled = _transfersEnabled;
    }

    /*
     * 스냅 샷 배열에서 값을 쿼리하고 설정하는 내부 도우미 함수
     */
    function getValueAt(Checkpoint[] storage checkpoints, uint _block
    ) constant internal returns (uint) {
        if (checkpoints.length == 0) return 0;

        // 실제 값 바로 가기
        if (_block >= checkpoints[checkpoints.length-1].fromBlock)
            return checkpoints[checkpoints.length-1].value;
        if (_block < checkpoints[0].fromBlock) return 0;

        // 배열의 값을 2진 검색
        uint min = 0;
        uint max = checkpoints.length-1;
        while (max > min) {
            uint mid = (max + min + 1)/ 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

    function updateValueAtNow(Checkpoint[] storage checkpoints, uint _value
    ) internal  {
        if ((checkpoints.length == 0)
        || (checkpoints[checkpoints.length -1].fromBlock < block.number)) {
               Checkpoint storage newCheckPoint = checkpoints[ checkpoints.length++ ];
               newCheckPoint.fromBlock =  uint128(block.number);
               newCheckPoint.value = uint128(_value);
           } else {
               Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
               oldCheckPoint.value = uint128(_value);
           }
    }

    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
            size := extcodesize(_addr)
        }
        return size>0;
    }

    function min(uint a, uint b) pure internal returns (uint) {
        return a < b ? a : b;
    }

    function () public payable {
        require(isContract(controller));
        require(TokenController(controller).proxyPayment.value(msg.value)(msg.sender));
    }

    /*
     * 안전 방법
     */
    function claimTokens(address _token) public onlyController {
        if (_token == 0x0) {
            controller.transfer(this.balance);
            return;
        }

        MiniMeToken token = MiniMeToken(_token);
        uint balance = token.balanceOf(this);
        token.transfer(controller, balance);
        ClaimedTokens(_token, controller, balance);
    }

    /*
     * 이벤트
     */
    event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event NewCloneToken(address indexed _cloneToken, uint _snapshotBlock);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
        );
}

/*
 * MiniMeTokenFactory
 */
// 이 계약은 계약에서 복제 계약을 생성하는 데 사용됩니다.
contract MiniMeTokenFactory {
    //                      새로운 기능으로 새로운 토큰을 만들어 DApp를 업데이트하십시오.
    //  msg.sender          는 이 복제 토큰의 컨트롤러가됩니다.
    // _parentToken         복제 될 토큰의 주소
    // _snapshotBlock       상위 토큰 블록
    //                      복제 토큰의 초기 배포 결정
    // _tokenName           새 토큰의 이름
    // @param _decimalUnits 새 토큰의 소수 자릿수
    // @param _tokenSymbol  새 토큰에 대한 토큰 기호
    // @param _transfersEnabled true 이면 토큰을 전송할 수 있습니다.
    // @return              새 토큰 계약의 주소
    function createCloneToken(
        address _parentToken,
        uint _snapshotBlock,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transfersEnabled
    ) public returns (MiniMeToken) {
        MiniMeToken newToken = new MiniMeToken(
            this,
            _parentToken,
            _snapshotBlock,
            _tokenName,
            _decimalUnits,
            _tokenSymbol,
            _transfersEnabled
            );

        newToken.changeController(msg.sender);
        return newToken;
    }
}

/**
 * @title RET
 * @dev RET는 MiniMeToken을 상속받은 ERC20 토큰 계약입니다.
 */
contract RET is MiniMeToken, Blockeds {
  bool public sudoEnabled = true;

  modifier onlySudoEnabled() {
    require(sudoEnabled);
    _;
  }

  modifier onlyNotBlocked(address _addr) {
    require(!blocked[_addr]);
    _;
  }

  event SudoEnabled(bool _sudoEnabled);

  function RET(address _tokenFactory) MiniMeToken(
    _tokenFactory,
    0x0,                  // 부모 토큰 없음
    0,                    // 상위의 스냅 샷 블록 번호 없음
    "Rapide Token",      // 토큰 이름
    18,                   // 십진법
    "RAP",                // 상징(심볼)
    false                 // 전송 사용
  ) public {}

  function transfer(address _to, uint256 _amount) public onlyNotBlocked(msg.sender) returns (bool success) {
    return super.transfer(_to, _amount);
  }

  function transferFrom(address _from, address _to, uint256 _amount) public onlyNotBlocked(_from) returns (bool success) {
    return super.transferFrom(_from, _to, _amount);
  }

  // 아래의 4개 기능은 'sudorsabled(하위 설정됨)'로만 활성화됩니다.
  // ALL : 3 개의 sudo 레벨
  function generateTokens(address _owner, uint _amount) public onlyController onlySudoEnabled returns (bool) {
    return super.generateTokens(_owner, _amount);
  }

  function destroyTokens(address _owner, uint _amount) public onlyController onlySudoEnabled returns (bool) {
    return super.destroyTokens(_owner, _amount);
  }

  function blockAddress(address _addr) public onlyController onlySudoEnabled {
    super.blockAddress(_addr);
  }

  function unblockAddress(address _addr) public onlyController onlySudoEnabled {
    super.unblockAddress(_addr);
  }

  function enableSudo(bool _sudoEnabled) public onlyController {
    sudoEnabled = _sudoEnabled;
    SudoEnabled(_sudoEnabled);
  }

  // byList 함수
  function generateTokensByList(address[] _owners, uint[] _amounts) public onlyController onlySudoEnabled returns (bool) {
    require(_owners.length == _amounts.length);

    for(uint i = 0; i < _owners.length; i++) {
      generateTokens(_owners[i], _amounts[i]);
    }

    return true;
  }
}