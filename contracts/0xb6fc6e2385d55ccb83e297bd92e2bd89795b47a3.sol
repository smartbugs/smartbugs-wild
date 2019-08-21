pragma solidity ^0.4.25;

contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view   returns (address owner);
    // ownerof
    // deploy:  public ->external
    // test : external -> public
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    function supportsInterface(bytes4 _interfaceID) external view returns (bool);

}




contract ClockAuctionBase {

    //@dev 옥션이 생성되었을 때 발생하는 이벤트
    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    //@dev 옥션이 성공하였을 때 발생하는 이벤트
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    //@dev 옥션이 취소하였을 때 발생하는 이벤트
    event AuctionCancelled(uint256 tokenId);

    //@dev 옥션 정보를 가지고 있는 구조체
    struct Auction {
        //seller의 주소
        address seller;
        // 경매 시작 가격
        uint128 startingPrice;
        // 경매 종료 가격
        uint128 endingPrice;
        // 경매 기간
        uint64 duration;
        // 경매 시작 시점
        uint64 startedAt;
    }

    //@dev ERC721 PonyCore의 주소
    ERC721 public nonFungibleContract;

    //@dev 수수료율
    uint256 public ownerCut;

    //@dev Pony Id에 해당하는 옥션 정보를 가지고 있는 테이블
    mapping(uint256 => Auction) tokenIdToAuction;

    //@dev 요청한 주소가 토큰 아이디(포니)를 소유하고 있는지 확인하기 위한 internal Method
    //@param _claimant  요청한 주소
    //@param _tokenId  포니 아이디
    function _owns(address _claimant, uint256 _tokenId)
    internal
    view
    returns (bool)
    {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }


    //@dev PonyCore Contract에 id에 해당하는 pony를 escrow 시키는 internal method
    //@param _owner  소유자 주소
    //@param _tokenId  포니 아이디
    function _escrow(address _owner, uint256 _tokenId)
    internal
    {
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    //@dev 입력한 주소로 pony의 소유권을 이전시키는 internal method
    //@param _receiver  포니를 소요할 주소
    //@param _tokenId  포니 아이디
    function _transfer(address _receiver, uint256 _tokenId)
    internal
    {
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    //@dev 경매에 등록시키는 internal method
    //@param _tokenId  포니 아이디
    //@param _auction  옥션 정보
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    //@dev 경매를 취소시키는 internal method
    //@param _tokenId  포니 아이디
    //@param _seller  판매자의 주소
    function _cancelAuction(uint256 _tokenId, address _seller)
    internal
    {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

    //@dev 경매를 참여시키는 internal method
    //@param _tokenId  포니 아이디
    //@param _bidAmount 경매 가격 (최종)
    function _bid(uint256 _tokenId, uint256 _bidAmount)
    internal
    returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(_isOnAuction(auction));

        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        address seller = auction.seller;

        _removeAuction(_tokenId);

        if (price > 0) {
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;
            seller.transfer(sellerProceeds);
        }

        uint256 bidExcess = _bidAmount - price;
        msg.sender.transfer(bidExcess);

        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    //@dev 경매에서 제거 시키는 internal method
    //@param _tokenId  포니 아이디
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    //@dev 경매가 진행중인지 확인하는 internal method
    //@param _auction 경매 정보
    function _isOnAuction(Auction storage _auction)
    internal
    view
    returns (bool)
    {
        return (_auction.startedAt > 0);
    }

    //@dev 현재 경매 가격을 리턴하는 internal method
    //@param _auction 경매 정보
    function _currentPrice(Auction storage _auction)
    internal
    view
    returns (uint256)
    {
        uint256 secondsPassed = 0;

        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    //@dev 현재 경매 가격을 계산하는 internal method
    //@param _startingPrice 경매 시작 가격
    //@param _endingPrice 경매 종료 가격
    //@param _duration 경매 기간
    //@param _secondsPassed  경과 시간
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
    internal
    pure
    returns (uint256)
    {
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;
            return uint256(currentPrice);
        }
    }
    //@dev 현재 가격을 기준으로 수수료를 적용하여 가격을 리턴하는 internal method
    //@param _price 현재 가격
    function _computeCut(uint256 _price)
    internal
    view
    returns (uint256)
    {
        return _price * ownerCut / 10000;
    }

}





contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
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
    function transferOwnership(address newOwner)public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

//@title 컨트렉트에 대한 중지 및 시작 기능을 제공해주는 컨트렉트
//@dev 컨트렉트 owner만이 컨트렉트 기능을 작동시킬 수 있음
contract Pausable is Ownable {

    //@dev 컨트렉트가 멈추었을때 발생하는 이벤트
    event Pause();
    //@dev 컨트렉트가 시작되었을 때 발생하는 이벤트
    event Unpause();

    //@dev Contract의 운영을 관리(시작, 중지)하는 변수로서
    //paused true가 되지 않으면  컨트렉트의 대부분 동작들이 작동하지 않음
    bool public paused = false;


    //@dev paused가 멈추지 않았을 때 기능을 수행하도록 해주는 modifier
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    //@dev paused가 멈춰을 때 기능을 수행하도록 해주는 modifier
    modifier whenPaused {
        require(paused);
        _;
    }

    //@dev owner 권한을 가진 사용자와 paused가 falsed일 때 수행 가능
    //paused를 true로 설정
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }


    //@dev owner 권한을 가진 사용자와 paused가 true일때
    //paused를 false로 설정
    function unPause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}



//@title non-fungible 토큰을 위한 Clock Auction

contract ClockAuction is Pausable, ClockAuctionBase {

    //@dev ERC721 Interface를 준수하고 있는지 체크하기 위해서 필요한 변수
    bytes4 constant InterfaceSignature_ERC721 =bytes4(0x9a20483d);

    //@dev ClockAuction의 생성자
    //@param _nftAddr PonyCore의 주소
    //@param _cut 수수료 율
    constructor(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;
    }

    //@dev contract에서 잔고를 인출하기 위해서 사용
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        nftAddress.transfer(address(this).balance);
    }

    //@dev  판매용 경매 생성
    //@param _tokenId 포니의 아이디
    //@param _startingPrice 경매의 시작 가격
    //@param _endingPrice  경매의 종료 가격
    //@param _duration 경매 기간
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
    external
    whenNotPaused
    {

        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    //@dev 경매에 참여
    //@param _tokenId 포니의 아이디
    function bid(uint256 _tokenId)
    external
    payable
    whenNotPaused
    {
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    //@dev 경매를 취소
    //@param _tokenId 포니의 아이디
    function cancelAuction(uint256 _tokenId)
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    //@dev 컨트랙트가 멈출 경우 포니아이디에 대해 경매를 취소하는 기능
    //@param _tokenId 포니의 아이디
    //modifier Owner
    function cancelAuctionWhenPaused(uint256 _tokenId)
    whenPaused
    onlyOwner
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    //@dev 옥션의 정보를 가져옴
    //@param _tokenId 포니의 아이디
    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.startingPrice,
        auction.endingPrice,
        auction.duration,
        auction.startedAt
        );
    }

    //@dev 현재의 가격을 가져옴
    //@param _tokenId 포니의 아이디
    function getCurrentPrice(uint256 _tokenId)
    external
    view
    returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }
}


contract GeneScienceInterface {
    function isGeneScience() public pure returns (bool);
    function createNewGen(bytes22 genes1, bytes22 genes22) external returns (bytes22, uint);
}


contract PonyAbilityInterface {

    function isPonyAbility() external pure returns (bool);

    function getBasicAbility(bytes22 _genes) external pure returns(uint8, uint8, uint8, uint8, uint8);

   function getMaxAbilitySpeed(
        uint _matronDerbyAttendCount,
        uint _matronRanking,
        uint _matronWinningCount,
        bytes22 _childGenes        
      ) external view returns (uint);

    function getMaxAbilityStamina(
        uint _sireDerbyAttendCount,
        uint _sireRanking,
        uint _sireWinningCount,
        bytes22 _childGenes
    ) external view returns (uint);
    
    function getMaxAbilityStart(
        uint _matronRanking,
        uint _matronWinningCount,
        uint _sireDerbyAttendCount,
        bytes22 _childGenes
        ) external view returns (uint);
    
        
    function getMaxAbilityBurst(
        uint _matronDerbyAttendCount,
        uint _sireWinningCount,
        uint _sireRanking,
        bytes22 _childGenes
    ) external view returns (uint);

    function getMaxAbilityTemperament(
        uint _matronDerbyAttendCount,
        uint _matronWinningCount,
        uint _sireDerbyAttendCount,
        uint _sireWinningCount,
        bytes22 _childGenes
    ) external view returns (uint);

  }


//@title 포니에 대한 접근 권한을 관리하는 컨트렉트
//@dev CFO, COO, CLevel, derby, reward에 대한 주소를 지정하고
//contract의 method에 modifier를 통해서 사용하면 지정된 주소의
//사용자 만이 그 기능을 사용할 수 있도록 접근을 제어 해줌
contract PonyAccessControl {

    event ContractUpgrade(address newContract);

    //@dev CFO,COO 역활을 수행하는 계정의 주소
    address public cfoAddress;
    address public cooAddress;    
    address public derbyAddress; // derby update 전용
    address public rewardAddress; // reward send 전용    

    //@dev Contract의 운영을 관리(시작, 중지)하는 변수로서
    //paused true가 되지 않으면  컨트렉트의 대부분 동작들이 작동하지 않음
    bool public paused = false;

    //@dev CFO 주소로 지정된 사용자만이 기능을 수행할 수 있도록해주는 modifier
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    //@dev COO 주소로 지정된 사용자만이 기능을 수행할 수 있도록해주는 modifier
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }      

    //@dev derby 주소로 지정된 사용자만이 기능을 수행할 수 있도록해주는 modifier
    modifier onlyDerbyAdress() {
        require(msg.sender == derbyAddress);
        _;
    }

    //@dev reward 주소로 지정된 사용자만이 기능을 수행할 수 있도록해주는 modifier
    modifier onlyRewardAdress() {
        require(msg.sender == rewardAddress);
        _;
    }           

    //@dev COO, CFO, derby, reward 주소로 지정된 사용자들 만이 기능을 수행할 수 있도록해주는 modifier
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == cfoAddress ||            
            msg.sender == derbyAddress ||
            msg.sender == rewardAddress            
        );
        _;
    }

    //@dev CFO 권한을 가진 사용자만 수행 가능,새로운 CF0 계정을 지정
    function setCFO(address _newCFO) external onlyCFO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    //@dev CFO 권한을 가진 사용자만 수행 가능,새로운 COO 계정을 지정
    function setCOO(address _newCOO) external onlyCFO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }    

    //@dev COO 권한을 가진 사용자만 수행 가능,새로운 Derby 계정을 지정
    function setDerbyAdress(address _newDerby) external onlyCOO {
        require(_newDerby != address(0));

        derbyAddress = _newDerby;
    }

    //@dev COO 권한을 가진 사용자만 수행 가능,새로운 Reward 계정을 지정
    function setRewardAdress(address _newReward) external onlyCOO {
        require(_newReward != address(0));

        rewardAddress = _newReward;
    }    

    //@dev paused가 멈추지 않았을 때 기능을 수행하도록 해주는 modifier
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    //@dev paused가 멈춰을 때 기능을 수행하도록 해주는 modifier
    modifier whenPaused {
        require(paused);
        _;
    }

    //@dev COO 권한을 가진 사용자와 paused가 falsed일 때 수행 가능
    //paused를 true로 설정
    function pause() external onlyCOO whenNotPaused {
        paused = true;
    }

    //@dev COO 권한을 가진 사용자와 paused가 true일때
    //paused를 false로 설정
    function unPause() public onlyCOO whenPaused {
        paused = false;
    }
}

















//@title SaleClockAuction

contract SaleClockAuction is ClockAuction {

    //@dev SaleClockAuction인지 확인해주기 위해서 사용하는 값
    bool public isSaleClockAuction = true;

    //@dev GEN0의 판매 개수
    uint256 public gen0SaleCount;
    //@dev GEN0의 최종 판매 갯수
    uint256[5] public lastGen0SalePrices;

    //@dev SaleClockAuction 생성자
    //@param _nftAddr PonyCore의 주소
    //@param _cut 수수료 율
    constructor(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}

    //@dev  판매용 경매 생성
    //@param _tokenId 포니의 아이디
    //@param _startingPrice 경매의 시작 가격
    //@param _endingPrice  경매의 종료 가격
    //@param _duration 경매 기간
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
    external
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    //@dev 경매에 참여
    //@param _tokenId 포니의 아이디
    function bid(uint256 _tokenId)
    external
    payable
    {
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

        if (seller == address(nonFungibleContract)) {
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }

    //@dev 포니 가격을 리턴 (최근 판매된 다섯개의 평균 가격)
    function averageGen0SalePrice()
    external
    view
    returns (uint256)
    {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastGen0SalePrices[i];
        }
        return sum / 5;
    }


}




//@title SiringClockAuction

contract SiringClockAuction is ClockAuction {

    //@dev SiringClockAuction인지 확인해주기 위해서 사용하는 값
    bool public isSiringClockAuction = true;

    //@dev SiringClockAuction의 생성자
    //@param _nftAddr PonyCore의 주소
    //@param _cut 수수료 율
    constructor(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}

    //@dev 경매를 생성
    //@param _tokenId 포니의 아이디
    //@param _startingPrice 경매의 시작 가격
    //@param _endingPrice  경매의 종료 가격
    //@param _duration 경매 기간
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
    external
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    //@dev 경매에 참여
    //@param _tokenId 포니의 아이디
    function bid(uint256 _tokenId)
    external
    payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        _bid(_tokenId, msg.value);
        _transfer(seller, _tokenId);
    }

}






//@title 포니의 기본 contract
//@dev Pony에 관련된 모든 struct, event, variables를 가지고 있음
contract PonyBase is PonyAccessControl {

    //@dev 새로운 Pony가 생성되었을 때 발생하는 이벤트 (giveBirth 메소드 호출 시 발생)
    event Birth(address owner, uint256 ponyId, uint256 matronId, uint256 sireId, bytes22 genes);

    //@dev 기존 코어 데이터 이전용(새로운 ponyId)
    event Relocate(address owner, uint256 ponyId, bytes22 genes);

    //@dev 포니의 소유권 이전이 발생하였을 때 발생하는 이벤트 (출생 포함)
    event Transfer(address from, address to, uint256 tokenId);

    //@dev 당근구매시 발생하는 이벤트
    event carrotPurchased(address buyer, uint256 receivedValue, uint256 carrotCount);

    //@dev 랭킹보상이 지급되면 발생하는 이벤트
    event RewardSendSuccessful(address from, address to, uint256 value);    

    //@dev 당근 환전시 발생하는 이벤트
    event CarrotToETHSuccessful(address to, uint256 count, uint256 value);    

    struct Pony {
        // 포니의 탄생 시간
        uint64 birthTime;
        // 새로운 쿨다운 적용되었을때, cooldown이 끝나는 block의 번호
        uint64 cooldownEndBlock;
        // 모의 아이디
        uint32 matronId;
        // 부의 아이디
        uint32 sireId;        
        // 나이
        uint8 age;
        // 개월 수
        uint8 month;
        // 은퇴 나이
        uint8 retiredAge;        
        // 유전자 정보
        bytes22 genes;        
    }
    
    struct Ability {
        //속도
        uint8 speed;
        //스테미너
        uint8 stamina;
        //스타트
        uint8 start;
        //폭발력
        uint8 burst;
        //기질
        uint8 temperament;
        //속도

        //최대 속도
        uint8 maxSpeed;
        //최대 스테미너
        uint8 maxStamina;
        //최대 시작
        uint8 maxStart;
        //최대 폭발력
        uint8 maxBurst;
        //최대 기질
        uint8 maxTemperament;
    }

    struct Gen0Stat {
        //은퇴나이
        uint8 retiredAge;
        //최대 속도
        uint8 maxSpeed;
        //최대 스테미너
        uint8 maxStamina;
        //최대 시작
        uint8 maxStart;
        //최대 폭발력
        uint8 maxBurst;
        //최대 기질
        uint8 maxTemperament;
    }    

    //@dev 교배가 발생할때의 다음 교배까지 필요한 시간을 가진 배열
    uint32[15] public cooldowns = [
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(24 hours),
        uint32(48 hours),
        uint32(5 days),
        uint32(7 days),
        uint32(10 days),
        uint32(15 days)
    ];


    // 능력치 정보를 가지고 있는 배열
    Ability[] ability;

    // Gen0생성포니의 은퇴나이 Max능력치 정보
    Gen0Stat public gen0Stat; 

    // 모든 포니의 정보를 가지고 있는 배열
    Pony[] ponies;

    //포니 아이디에 대한 소유권를 가진 주소들에 대한 테이블
    mapping(uint256 => address) public ponyIndexToOwner;
    //주소에 해당하는 소유자가 가지고 있는 포니의 개수를 가진 m테이블
    mapping(address => uint256) ownershipTokenCount;
    //포니 아이디에 대한 소유권 이전을 허용한 주소 정보를 가진 테이블
    mapping(uint256 => address) public ponyIndexToApproved;    

    //@dev 시간 기반의 Pony의 경매를 담당하는 SaleClockAuction의 주소
    SaleClockAuction public saleAuction;
    //@dev 교배 기반의 Pony의 경매를 담당하는 SiringClockAuction의 주소
    SiringClockAuction public siringAuction;    

	//@dev 교배 시 능력치를 계산하는 컨트렉트의 주소
    PonyAbilityInterface public ponyAbility;

    //@dev 교배 시 유전자 정보를 생성하는 컨트렉트의 주소
    GeneScienceInterface public geneScience;

    // 새로운 블록이 생성되기까지 소유되는 시간
    uint256 public secondsPerBlock = 15;

    //@dev 포니의 소유권을 이전해는 internal Method
    //@param _from 보내는 지갑 주소
    //@param _to 받는 지갑 주소
    //@param _tokenId Pony의 아이디
    function _transfer(address _from, address _to, uint256 _tokenId)
    internal
    {
        ownershipTokenCount[_to]++;
        ponyIndexToOwner[_tokenId] = _to;
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;            
            delete ponyIndexToApproved[_tokenId];
        }
        emit Transfer(_from, _to, _tokenId);
    }

    //@dev 신규 포니를 생성하는 internal Method
    //@param _relocate  코어 이전용
    //@param _matronId  종마의 암컷의 id
    //@param _sireId 종마의 수컷의 id
    //@param _age  포니의 나이
    //@param _month  포니의 나이
    //@param _genes 포니의 유전자 정보
    //@param _derbyMaxCount 경마 최대 참여 개수
    //@param _owner 포니의 소유자
    //@param _maxSpeed 최대 능력치
    //@param _maxStamina 최대 스테미너
    //@param _maxStart 최대 스타트
    //@param _maxBurst 최대 폭발력
    //@param _maxTemperament 최대 기질
    function _createPony(
        uint8 _relocate,
        uint256[2] _parent, // 0-_matronId, 1-_sireId        
        uint8[2] _age,        
        bytes22 _genes,
        uint256 _retiredAge,
        address _owner,
        uint8[5] _ability,
        uint8[5] _maxAbility        
    )
    internal
    returns (uint)
    {
        require(_parent[0] == uint256(uint32(_parent[0])));
        require(_parent[1] == uint256(uint32(_parent[1])));
        require(_retiredAge == uint256(uint32(_retiredAge)));

        Pony memory _pony = Pony({
            birthTime : uint64(now),
            cooldownEndBlock : 0,
            matronId : uint32(_parent[0]),
            sireId : uint32(_parent[1]),            
            age : _age[0],
            month : _age[1],
            retiredAge : uint8(_retiredAge),            
            genes : _genes      
            });


        Ability memory _newAbility = Ability({
            speed : _ability[0],
            stamina : _ability[1],
            start : _ability[2],
            burst : _ability[3],
            temperament : _ability[4],
            maxSpeed : _maxAbility[0],
            maxStamina : _maxAbility[1],
            maxStart : _maxAbility[2],
            maxBurst : _maxAbility[3],
            maxTemperament : _maxAbility[4]
            });
       

        uint256 newPonyId = ponies.push(_pony) - 1;
        uint newAbilityId = ability.push(_newAbility) - 1;
        require(newPonyId == uint256(uint32(newPonyId)));
        require(newAbilityId == uint256(uint32(newAbilityId)));
        require(newPonyId == newAbilityId);

        if( _relocate == 1)
        {
            emit Relocate(_owner, newPonyId, _pony.genes);
        }
        else
        {
            emit Birth(
                _owner,
                newPonyId,
                uint256(_pony.matronId),
                uint256(_pony.sireId),
                _pony.genes
            );
        }
        _transfer(0, _owner, newPonyId);

        return newPonyId;
    }    

    //@dev 블록체인에서 새로운 블록이 생성되는데 소요되는 평균 시간을 지정
    //@param _secs 블록 생성 시간
    //modifier : COO 만 실행 가능
    function setSecondsPerBlock(uint256 _secs)
    external
    onlyCOO
    {
        require(_secs < cooldowns[0]);
        secondsPerBlock = _secs;
    }
}


/*import "./ERC721Metadata.sol";*/

//@title non-Fungible 토큰에 대한 트랙잭션 지원을 위해 필요한 컨트렉트

contract PonyOwnership is PonyBase, ERC721 {

    //@dev PonyId에 해당하는 포니가 from부터 to로 이전되었을 때 발생하는 이벤트
    event Transfer(address from, address to, uint256 tokenId);
    //@dev PonyId에 해당하는 포니의 소유권 이전을 승인하였을 때 발생하는 이벤트 (onwer -> approved)
    event Approval(address owner, address approved, uint256 tokenId);

    string public constant name = "GoPony";
    string public constant symbol = "GP";

/*    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));*/

    bytes4 constant InterfaceSignature_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tokensOfOwner(address)')) ^
    bytes4(keccak256('tokenMetadata(uint256,string)'));

    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return (_interfaceID == InterfaceSignature_ERC721);
    }

    /*    
    function setMetadataAddress(address _contractAddress)
    public
    onlyCOO
    {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }
    */

    //@dev 요청한 주소가 PonyId를 소유하고 있는지 확인하는 Internal Method
    //@Param _calimant 요청자의 주소
    //@param _tokenId 포니의 아이디
    function _owns(address _claimant, uint256 _tokenId)
    internal
    view
    returns (bool)
    {
        return ponyIndexToOwner[_tokenId] == _claimant;
    }

    //@dev 요청한 주소로 PonyId를 소유권 이전을 승인하였는지 확인하는 internal Method
    //@Param _calimant 요청자의 주소
    //@param _tokenId 포니의 아이디
    function _approvedFor(address _claimant, uint256 _tokenId)
    internal
    view
    returns (bool)
    {
        return ponyIndexToApproved[_tokenId] == _claimant;
    }

    //@dev  PonyId의 소유권 이전을 승인하는 Internal Method
    //@param _tokenId 포니의 아이디
    //@Param _approved 이전할 소유자의 주소
    function _approve(uint256 _tokenId, address _approved)
    internal
    {
        ponyIndexToApproved[_tokenId] = _approved;
    }

    //@dev  주소의 소유자가 가진 Pony의 개수를 리턴
    //@Param _owner 소유자의 주소
    function balanceOf(address _owner)
    public
    view
    returns (uint256 count)
    {
        return ownershipTokenCount[_owner];
    }

    //@dev 소유권을 이전하는 Method
    //@Param _owner 소유자의 주소
    //@param _tokenId 포니의 아이디
    function transfer(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_to != address(saleAuction));
        require(_to != address(siringAuction));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }

    //@dev  PonyId의 소유권 이전을 승인하는 Method
    //@param _tokenId 포니의 아이디
    //@Param _approved 이전할 소유자의 주소
    function approve(
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        require(_owns(msg.sender, _tokenId));

        _approve(_tokenId, _to);
        emit Approval(msg.sender, _to, _tokenId);
    }

    //@dev  이전 소유자로부터 포니의 소유권을 이전 받아옴
    //@Param _from 이전 소유자 주소
    //@Param _to 신규 소유자 주소
    //@param _tokenId 포니의 아이디
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external
    whenNotPaused
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        _transfer(_from, _to, _tokenId);
    }

    //@dev 존재하는 모든 포니의 개수를 가져옴
    function totalSupply()
    public
    view
    returns (uint)
    {
        return ponies.length - 1;
    }

    //@dev 포니 아이디에 대한 소유자 정보를 가져옴
    //@param _tokenId  포니의 아이디
    function ownerOf(uint256 _tokenId)
    external
    view
    returns (address owner)
    {
        owner = ponyIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    //@dev 소유자의 모든 포니 아이디를 가져옴
    //@param _owner 포니의 소유자
    function tokensOfOwner(address _owner)
    external
    view
    returns (uint256[] ownerTokens)
    {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalPonies = totalSupply();
            uint256 resultIndex = 0;

            uint256 ponyId;

            for (ponyId = 1; ponyId <= totalPonies; ponyId++) {
                if (ponyIndexToOwner[ponyId] == _owner) {
                    result[resultIndex] = ponyId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

}


//@title 포니의 교배, 임심, 출생을 관리하는 컨트렉트
//@dev 외부의 SaleClockAuction과 SiringClockAuction에 대한 컨트렉트를 설정

contract PonyBreeding is PonyOwnership {


    //@dev 포니가 임신되면 발생하는 이벤트
    event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 matronCooldownEndBlock, uint256 sireCooldownEndBlock);

    //교배가 이루어지는데 필요한 비용
    uint256 public autoBirthFee = 13 finney;

    //@dev 유전자 정보를 생성하는 컨트렉트의 주소를 지정하는 method
    //modifier COO
    function setGeneScienceAddress(address _address)
    external
    onlyCOO
    {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        require(candidateContract.isGeneScience());

        geneScience = candidateContract;
    }

    //@dev 유전자 정보를 생성하는 컨트렉트의 주소를 지정하는 method
    //modifier COO
    function setPonyAbilityAddress(address _address)
    external
    onlyCOO
    {
        PonyAbilityInterface candidateContract = PonyAbilityInterface(_address);

        require(candidateContract.isPonyAbility());

        ponyAbility = candidateContract;
    }



    //@dev 교배가 가능한지 확인하는 internal method
    //@param _pony 포니 정보
    function _isReadyToBreed(Pony _pony)
    internal
    view
    returns (bool)
    {
        return (_pony.cooldownEndBlock <= uint64(block.number));
    }

    //@dev 셀프 교배 확인용
    //@param _sireId  교배할 암놈의 아이디
    //@param _matronId 교배할 숫놈의 아이디
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId)
    internal
    view
    returns (bool)
    {
        address matronOwner = ponyIndexToOwner[_matronId];
        address sireOwner = ponyIndexToOwner[_sireId];

        return (matronOwner == sireOwner);
    }


    //@dev 포니에 대해서 쿨다운을 적용하는 internal method
    //@param _pony 포니 정보
    function _triggerCooldown(Pony storage _pony)
    internal
    {
        if (_pony.age < 14) {
            _pony.cooldownEndBlock = uint64((cooldowns[_pony.age] / secondsPerBlock) + block.number);
        } else {
            _pony.cooldownEndBlock = uint64((cooldowns[14] / secondsPerBlock) + block.number);
        }

    }
    //@dev 포니 교배에 따라 나이를 6개월 증가시키는 internal method
    //@param _pony 포니 정보
    function _triggerAgeSixMonth(Pony storage _pony)
    internal
    {
        uint8 sumMonth = _pony.month + 6;
        if (sumMonth >= 12) {
            _pony.age = _pony.age + 1;
            _pony.month = sumMonth - 12;
        } else {
            _pony.month = sumMonth;
        }
    }
    //@dev 포니 교배에 따라 나이를 1개월 증가시키는 internal method
    //@param _pony 포니 정보
    function _triggerAgeOneMonth(Pony storage _pony)
    internal
    {
        uint8 sumMonth = _pony.month + 1;
        if (sumMonth >= 12) {
            _pony.age = _pony.age + 1;
            _pony.month = sumMonth - 12;
        } else {
            _pony.month = sumMonth;
        }
    }    

    //@dev 포니가 교배할때 수수료를 지정
    //@param val  수수료율
    //@modifier COO
    function setAutoBirthFee(uint256 val)
    external
    onlyCOO {
        autoBirthFee = val;
    }    

    //@dev 교배가 가능한지 확인
    //@param _ponyId 포니의 아이디
    function isReadyToBreed(uint256 _ponyId)
    public
    view
    returns (bool)
    {
        require(_ponyId > 0);
        Pony storage pony = ponies[_ponyId];
        return _isReadyToBreed(pony);
    }    

    //@dev 교배가 가능한지 확인하는 method
    //@param _matron 암놈의 정보
    //@param _matronId 모의 아이디
    //@param _sire 숫놈의 정보
    //@param _sireId 부의 아이디
    function _isValidMatingPair(
        Pony storage _matron,
        uint256 _matronId,
        Pony storage _sire,
        uint256 _sireId
    )
    private
    view
    returns (bool)
    {
        if (_matronId == _sireId) {
            return false;
        }

        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        return true;
    }

    //@dev 경매를 통해서 교배가 가능한지 확인하는 internal method
    //@param _matronId 암놈의 아이디
    //@param _sireId 숫놈의 아이디
    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
    internal
    view
    returns (bool)
    {
        Pony storage matron = ponies[_matronId];
        Pony storage sire = ponies[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    //@dev 교배가 가능한지 확인하는 method
    //@param _matronId 암놈의 아이디
    //@param _sireId 숫놈의 아이디
    function canBreedWith(uint256 _matronId, uint256 _sireId)
    external
    view
    returns (bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        Pony storage matron = ponies[_matronId];
        Pony storage sire = ponies[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
        _isSiringPermitted(_sireId, _matronId);
    }

    //@dev 교배하는 method
    //@param _matronId 암놈의 아이디
    //@param _sireId 숫놈의 아이디
    function _breedWith(uint256 _matronId, uint256 _sireId) internal {
        Pony storage sire = ponies[_sireId];
        Pony storage matron = ponies[_matronId];        

        _triggerCooldown(sire);
        _triggerCooldown(matron);
        _triggerAgeSixMonth(sire);
        _triggerAgeSixMonth(matron);            
        emit Pregnant(ponyIndexToOwner[_matronId], _matronId, _sireId, matron.cooldownEndBlock, sire.cooldownEndBlock);
        _giveBirth(_matronId, _sireId);
    }

    //@dev 소유하고 있는 암놈과 숫놈을 이용하여 교배를 시키는 method
    //@param _matronId 암놈의 아이디
    //@param _sireId 숫놈의 아이디
    function breedWithAuto(uint256 _matronId, uint256 _sireId)
    external
    payable
    whenNotPaused
    {
        require(msg.value >= autoBirthFee);

        require(_owns(msg.sender, _matronId));

        require(_isSiringPermitted(_sireId, _matronId));

        Pony storage matron = ponies[_matronId];

        require(_isReadyToBreed(matron));

        Pony storage sire = ponies[_sireId];

        require(_isReadyToBreed(sire));

        require(_isValidMatingPair(
                matron,
                _matronId,
                sire,
                _sireId
            ));

        _breedWith(_matronId, _sireId);
    }

    //@dev 포니를 출생시키는 method
    //@param _matronId 암놈의 아이디 (임신한)
    function _giveBirth(uint256 _matronId, uint256 _sireId)
    internal    
    returns (uint256)
    {
        Pony storage matron = ponies[_matronId];
        require(matron.birthTime != 0);
        
        Pony storage sire = ponies[_sireId];

        bytes22 childGenes;
        uint retiredAge;
        (childGenes, retiredAge) = geneScience.createNewGen(matron.genes, sire.genes);

        address owner = ponyIndexToOwner[_matronId];
        
        uint8[5] memory ability = [0,0,0,0,0];
        uint8[5] memory maxAbility = [0,0,0,0,0];
        uint[2] memory parent = [_matronId, _sireId];
        uint8[2] memory age = [0,0];
        

        (ability[0], ability[1], ability[2], ability[3], ability[4]) = ponyAbility.getBasicAbility(childGenes);

        //maxAbility = _getMaxAbility(_matronId, _sireId, matron.derbyAttendCount, matron.rankingScore, sire.derbyAttendCount, sire.rankingScore, childGenes);        
        uint256 ponyId = _createPony(0, parent, age, childGenes, retiredAge, owner, ability, maxAbility);                

        return ponyId;
    }
}





//@title 포니의 Siring 및 Sale 옥션의 생성을 담담
//@dev 외부의 SaleClockAuction과 SiringClockAuction에 대한 컨트렉트를 설정
contract PonyAuction is PonyBreeding {

    //@dev SaleAuction의 주소를 지정
    //@param _address SaleAuction의 주소
    //modifier COO
    function setSaleAuctionAddress(address _address) external onlyCOO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);
        require(candidateContract.isSaleClockAuction());
        saleAuction = candidateContract;
    }

    //@dev SaleAuction의 주소를 지정
    //@param _address SiringAuction의 주소
    //modifier COO
    function setSiringAuctionAddress(address _address) external onlyCOO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);
        require(candidateContract.isSiringClockAuction());
        siringAuction = candidateContract;
    }

    //@dev  판매용 경매 생성
    //@param _ponyId 포니의 아이디
    //@param _startingPrice 경매의 시작 가격
    //@param _endingPrice  경매의 종료 가격
    //@param _duration 경매 기간
    function createSaleAuction(
        uint _ponyId,
        uint _startingPrice,
        uint _endingPrice,
        uint _duration
    )
    external
    whenNotPaused
    {
        require(_owns(msg.sender, _ponyId));
        require(isReadyToBreed(_ponyId));
        _approve(_ponyId, saleAuction);
        saleAuction.createAuction(
            _ponyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    //@dev 교배용 경매 생성
    //@param _ponyId 포니의 아이디
    //@param _startingPrice 경매의 시작 가격
    //@param _endingPrice  경매의 종료 가격
    //@param _duration 경매 기간
    function createSiringAuction(
        uint _ponyId,
        uint _startingPrice,
        uint _endingPrice,
        uint _duration
    )
    external
    whenNotPaused
    {
        require(_owns(msg.sender, _ponyId));
        require(isReadyToBreed(_ponyId));
        _approve(_ponyId, siringAuction);
        siringAuction.createAuction(
            _ponyId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }


    //@dev 교배 경매에 참여
    //@param _sireId 경매에 등록한 숫놈 Id
    //@param _matronId 교배한 암놈의 Id
    function bidOnSiringAuction(
        uint _sireId,
        uint _matronId
    )
    external
    payable
    whenNotPaused
    {
        require(_owns(msg.sender, _matronId));
        require(isReadyToBreed(_matronId));
        require(_canBreedWithViaAuction(_matronId, _sireId));

        uint currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);
        siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
        _breedWith(uint32(_matronId), uint32(_sireId));
    }

    //@dev ether를 PonyCore로 출금
    //modifier CLevel
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
    }
}


//@title 포니의 생성과 관련된 컨트렉트

contract PonyMinting is PonyAuction {


    //@dev 프로모션용 포니의 최대 생성 개수
    //uint256 public constant PROMO_CREATION_LIMIT = 10000;
    //@dev GEN0용 포니의 최대 생성 개수
    //uint256 public constant GEN0_CREATION_LIMIT = 40000;

    //@dev GEN0포니의 최소 시작 가격
    uint256 public GEN0_MINIMUM_STARTING_PRICE = 90 finney;

    //@dev GEN0포니의 최대 시작 가격
    uint256 public GEN0_MAXIMUM_STARTING_PRICE = 500 finney;

    //@dev 다음Gen0판매시작가격 상승율 ( 10000 => 100 % )
    uint256 public nextGen0PriceRate = 1000;

    //@dev GEN0용 포니의 경매 기간
    uint256 public gen0AuctionDuration = 30 days;

    //@dev 생성된 프로모션용 포니 카운트 개수
    uint256 public promoCreatedCount;
    //@dev 생성된 GEN0용 포니 카운트 개수
    uint256 public gen0CreatedCount;

    //@dev 주어진 유전자 정보와 coolDownIndex로 포니를 생성하고, 지정된 주소로 자동할당
    //@param _genes  유전자 정보
    //@param _coolDownIndex  genes에 해당하는 cooldown Index 값
    //@param _owner Pony를 소유할 사용자의 주소
    //@param _maxSpeed 최대 능력치
    //@param _maxStamina 최대 스테미너
    //@param _maxStart 최대 스타트
    //@param _maxBurst 최대 폭발력
    //@param _maxTemperament 최대 기질
    //@modifier COO
    function createPromoPony(bytes22 _genes, uint256 _retiredAge, address _owner, uint8[5] _maxStats) external onlyCOO {
        address ponyOwner = _owner;
        if (ponyOwner == address(0)) {
            ponyOwner = cooAddress;
        }
        //require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;

        uint zero = uint(0);
        uint8[5] memory ability;        
        uint8[2] memory age = [0,0];
        uint[2] memory parents = [zero, zero];
        
        
        (ability[0],ability[1],ability[2],ability[3],ability[4]) = ponyAbility.getBasicAbility(_genes);
        _createPony(0, parents, age, _genes, _retiredAge, ponyOwner,ability,_maxStats);
    }

    //@dev 이전 코어의 포니 정보를 새로 생성    
    //@modifier COO
    function createPreCorePony(bytes22 _genes, uint256 _retiredAge, address _owner, uint256 _matronId, uint256 _sireId, uint8 _age, uint8 _month, uint8[5] stats, uint8[5] maxStats) external onlyCOO {
        address ponyOwner = _owner;
        if (ponyOwner == address(0)) {
            ponyOwner = cooAddress;
        }
        uint8[2] memory age = [_age, _month];
        uint[2] memory parents = [_matronId, _sireId];        
        _createPony(1, parents, age, _genes, _retiredAge, ponyOwner, stats, maxStats);
    }

    //@dev 주어진 유전자 정보와 cooldownIndex 이용하여 GEN0용 포니를 생성
    //@param _genes  유전자 정보
    //@param _coolDownIndex  genes에 해당하는 cooldown Index 값
    //@param _maxSpeed 최대 능력치
    //@param _maxStamina 최대 스테미너
    //@param _maxStart 최대 스타트
    //@param _maxBurst 최대 폭발력
    //@param _maxTemperament 최대 기질
    //@modifier COO
    function createGen0Auction(bytes22 _genes) public onlyCOO {
        //require(gen0CreatedCount < GEN0_CREATION_LIMIT);
        uint zero = uint(0);
        uint8[5] memory ability;
        uint8[5] memory maxAbility = [gen0Stat.maxSpeed, gen0Stat.maxStamina, gen0Stat.maxStart, gen0Stat.maxBurst, gen0Stat.maxTemperament];
        uint8[2] memory age = [0, 0];
        uint[2] memory parents = [zero, zero];        

        (ability[0],ability[1],ability[2],ability[3],ability[4]) = ponyAbility.getBasicAbility(_genes);
        
        uint256 ponyId = _createPony(0, parents, age,_genes, gen0Stat.retiredAge, address(this),ability,maxAbility);
        _approve(ponyId, saleAuction);

        saleAuction.createAuction(
            ponyId,
            _computeNextGen0Price(),
            10 finney,
            gen0AuctionDuration,
            address(this)
        );

        gen0CreatedCount++;
    }

    //@dev 주어진 유전자 정보와 cooldownIndex 이용하여 GEN0용 포니를 생성
    //@param _genes  유전자 정보
    //@param _coolDownIndex  genes에 해당하는 cooldown Index 값
    //@param _maxSpeed 최대 능력치
    //@param _maxStamina 최대 스테미너
    //@param _maxStart 최대 스타트
    //@param _maxBurst 최대 폭발력
    //@param _maxTemperament 최대 기질
    //@param _startPrice 경매 시작가격
    //@modifier COO
    function createCustomGen0Auction(bytes22 _genes, uint256 _retiredAge, uint8[5] _maxStats, uint8 _startPrice, uint _endPrice) external onlyCOO {
        require(10 finney < _startPrice);
        require(10 finney < _endPrice);

        uint zero = uint(0);
        uint8[5] memory ability;        
        uint8[2] memory age = [0, 0];
        uint[2] memory parents = [zero, zero];
        
        (ability[0],ability[1],ability[2],ability[3],ability[4]) = ponyAbility.getBasicAbility(_genes);
        
        uint256 ponyId = _createPony(0, parents, age, _genes, _retiredAge, address(this),ability,_maxStats);
        _approve(ponyId, saleAuction);

        saleAuction.createAuction(
            ponyId,
            _startPrice,
            _endPrice,
            gen0AuctionDuration,
            address(this)
        );

        gen0CreatedCount++;
    }  

    //@dev 새로운 Gen0의 가격 산정하는 internal Method
    //(최근에 판매된 gen0 5개의 평균가격)*1.5+0.0.1
    function _computeNextGen0Price()
    internal
    view
    returns (uint256)
    {
        uint256 avePrice = saleAuction.averageGen0SalePrice();
        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice * nextGen0PriceRate / 10000);

        if (nextPrice < GEN0_MINIMUM_STARTING_PRICE) {
            nextPrice = GEN0_MINIMUM_STARTING_PRICE;
        }else if (nextPrice > GEN0_MAXIMUM_STARTING_PRICE) {
            nextPrice = GEN0_MAXIMUM_STARTING_PRICE;
        }

        return nextPrice;
    }
    
    function setAuctionDuration(uint256 _duration)
    external
    onlyCOO
    {
        gen0AuctionDuration=_duration * 1 days;
    }

    //Gen0 Pony Max능력치 Setting
    function setGen0Stat(uint256[6] _gen0Stat) 
    public 
    onlyCOO
    {
        gen0Stat = Gen0Stat({
            retiredAge : uint8(_gen0Stat[0]),
            maxSpeed : uint8(_gen0Stat[1]),
            maxStamina : uint8(_gen0Stat[2]),
            maxStart : uint8(_gen0Stat[3]),
            maxBurst : uint8(_gen0Stat[4]),
            maxTemperament : uint8(_gen0Stat[5])
        });
    }

    //@dev 최소시작판매가격을 변경
    //@param _minPrice 최소시작판매가격
    function setMinStartingPrice(uint256 _minPrice)
    public
    onlyCOO
    {
        GEN0_MINIMUM_STARTING_PRICE = _minPrice;
    }

    //@dev 최대시작판매가격을 변경
    //@param _maxPrice 최대시작판매가격
    function setMaxStartingPrice(uint256 _maxPrice)
    public
    onlyCOO
    {
        GEN0_MAXIMUM_STARTING_PRICE = _maxPrice;
    }    

    //@dev setNextGen0Price 상승율을 변경
    //@param _increaseRate 가격상승율
    function setNextGen0PriceRate(uint256 _increaseRate)
    public
    onlyCOO
    {
        require(_increaseRate <= 10000);
        nextGen0PriceRate = _increaseRate;
    }
    
}


//@title 포니 경마에 대한 처리를 지원하는 컨트렉트

contract PonyDerby is PonyMinting {
    //@dev 은퇴한 포니 인가를 조회하는 메소드
    //@param _pony 포니 정보
    //@returns 은퇴 : true, 은퇴하지 않은 경우 false
    function isPonyRetired(uint256 _id)
    external
    view
    returns (
        bool isRetired

    ) {
        Pony storage pony = ponies[_id];
        if (pony.age >= pony.retiredAge) {
            isRetired = true;
        } else {
            isRetired = false;
        }
    }

    //@dev 포니 정보 업데이트
    function setPonyInfo(uint _id, uint8 age, uint8 month, uint8 speed, uint8 stamina, uint8 start, uint8 burst, uint8 temperament)
    public
    onlyDerbyAdress
    {       
        Pony storage pony = ponies[_id];
        pony.age = age;
        pony.month = month;

        Ability storage _ability = ability[_id];        
        _ability.speed = speed;
        _ability.stamina = stamina;
        _ability.start = start;
        _ability.burst = burst;
        _ability.temperament = temperament;
    }

    //@dev 포니 maxStat 업데이트
    function setPonyMaxStat(uint _id, uint8 maxSpeed, uint8 maxStamina, uint8 maxStart, uint8 maxBurst, uint8 maxTemperament)
    public
    onlyDerbyAdress
    {   
        Ability storage _ability = ability[_id];        
        _ability.maxSpeed = maxSpeed;
        _ability.maxStamina = maxStamina;
        _ability.maxStart = maxStart;
        _ability.maxBurst = maxBurst;
        _ability.maxTemperament = maxTemperament;
    }

    //@dev 포니별 능력치 정보를 가져옴
    //@param id 포니 아이디
    //@return speed 속도
    //@return stamina  스태미나
    //@return start  스타트
    //@return burst 폭발력
    //@return temperament  기질
    //@return maxSpeed 최대 스피드
    //@return maxStamina  최대 스태미나
    //@return maxBurst  최대 폭발력
    //@return maxStart  최대 스타트
    //@return maxTemperament  최대 기질

    function getAbility(uint _id)
    public
    view
    returns (
        uint8 speed,
        uint8 stamina,
        uint8 start,
        uint8 burst,
        uint8 temperament,
        uint8 maxSpeed,
        uint8 maxStamina,
        uint8 maxBurst,
        uint8 maxStart,
        uint8 maxTemperament

    ){
        Ability memory _ability = ability[_id];
        speed = _ability.speed;
        stamina = _ability.stamina;
        start = _ability.start;
        burst = _ability.burst;
        temperament = _ability.temperament;
        maxSpeed = _ability.maxSpeed;
        maxStamina = _ability.maxStamina;
        maxBurst = _ability.maxBurst;
        maxStart = _ability.maxStart;
        maxTemperament = _ability.maxTemperament;
    }


}

//@title 포니의 모든 작업을 처리하는 컨트렉트
//@dev 포니 생성시 초기 유전자 코드 설정 필요

contract PonyCore is PonyDerby {

    address public newContractAddress;

    //@dev PonyCore의 생성자 (최초 한번만 실행됨)
    constructor() public payable {
        paused = true;
        cfoAddress = msg.sender;
        cooAddress = msg.sender;
    }

    //@param gensis gensis에 대한 유전자 코드
    function genesisPonyInit(bytes22 _gensis, uint8[5] _ability, uint8[5] _maxAbility, uint[6] _gen0Stat) external onlyCOO whenPaused {
        require(ponies.length==0);
        uint zero = uint(0);
        uint[2] memory parents = [zero, zero];
        uint8[2] memory age = [0, 0];                
        _createPony(0, parents, age, _gensis, 100, address(0),_ability,_maxAbility);
        setGen0Stat(_gen0Stat);
    }

    function setNewAddress(address _v2Address)
    external
    onlyCOO whenPaused
    {
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }


    function() external payable {
        /*
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
        */
    }

    //@ 포니의 아이디에 해당하는 포니의 정보를 가져옴
    //@param _id 포니의 아이디
    function getPony(uint256 _id)
    external
    view
    returns (        
        bool isReady,
        uint256 cooldownEndBlock,        
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        bytes22 genes,
        uint256 age,
        uint256 month,
        uint256 retiredAge        
    ) {
        Pony storage pony = ponies[_id];        
        isReady = (pony.cooldownEndBlock <= block.number);
        cooldownEndBlock = pony.cooldownEndBlock;        
        birthTime = uint256(pony.birthTime);
        matronId = uint256(pony.matronId);
        sireId = uint256(pony.sireId);
        genes =  pony.genes;
        age = uint256(pony.age);
        month = uint256(pony.month);
        retiredAge = uint256(pony.retiredAge);        
    }

    //@dev 컨트렉트를 작동시키는 method
    //(SaleAuction, SiringAuction, GeneScience 지정되어 있어야하며, newContractAddress가 지정 되어 있지 않아야 함)
    //modifier COO
    function unPause()
    public
    onlyCOO
    whenPaused
    {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(ponyAbility != address(0));
        require(newContractAddress == address(0));

        super.unPause();
    }

    //@dev 잔액을 인출하는 Method
    //modifier CFO
    function withdrawBalance(uint256 _value)
    external
    onlyCLevel
    {
        uint256 balance = address(this).balance;
        require(balance >= _value);        
        cfoAddress.transfer(_value);
    }

    function buyCarrot(uint256 carrotCount)
    external
    payable
    whenNotPaused
    {
        emit carrotPurchased(msg.sender, msg.value, carrotCount);
    }

    event RewardSendSuccessful(address from, address to, uint value);    

    function sendRankingReward(address[] _recipients, uint256[] _rewards)
    external
    payable
    onlyRewardAdress
    {
        for(uint i = 0; i < _recipients.length; i++){
            _recipients[i].transfer(_rewards[i]);
            emit RewardSendSuccessful(this, _recipients[i], _rewards[i]);
        }
    }

    event CarrotToETHSuccessful(address to, uint256 count, uint value);

    function sendCarrotToETH(address _recipient, uint256 _carrotCount, uint256 _value)
    external
    payable
    onlyRewardAdress
    {        
        _recipient.transfer(_value);
        emit CarrotToETHSuccessful(_recipient, _carrotCount, _value);     
    }

}