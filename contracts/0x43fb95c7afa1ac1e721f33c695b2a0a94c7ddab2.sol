pragma solidity ^0.4.11;

contract LunarToken {

  struct LunarPlot {
    address owner;
    uint price;
    bool forSale;
    string metadata;
    bool disabled;
    uint8 subdivision;
    uint parentID;
  }

  address owner;
  address beneficiary;
  uint public numPlots;
  uint public totalOwned;
  uint public totalPurchases;
  uint public initialPrice;
  uint8 public feePercentage;
  bool public tradingEnabled;
  bool public subdivisionEnabled;
  uint8 public maxSubdivisions;

  // ERC20-compatible fields
  uint public totalSupply;
  string public symbol = "LUNA";
  string public name = "lunars";

  mapping (uint => LunarPlot) public plots;
  mapping (address => uint[]) public plotsOwned;

  event Transfer(address indexed _from, address indexed _to, uint id);
  event Purchase(address _from, uint id, uint256 price);
  event PriceChanged(address _from, uint id, uint256 newPrice);
  event MetadataUpdated(address _from, uint id, string newData);

  modifier validID(uint id) {
    require(id < numPlots);
    require(!plots[id].disabled);
    _;
  }

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  modifier isOwnerOf(uint id) {
    require(msg.sender == ownerOf(id));
    _;
  }

  modifier tradingIsEnabled() {
    require(tradingEnabled);
    _;
  }

  modifier subdivisionIsEnabled() {
    require(subdivisionEnabled);
    _;
  }

  function LunarToken(
    uint _numPlots,
    uint _initialPriceInWei,
    uint8 _feePercentage,
    bool _tradingEnabled,
    bool _subdivisionEnabled,
    uint8 _maxSubdivisions
  ) {
    numPlots = _numPlots;
    totalSupply = _numPlots;
    initialPrice = _initialPriceInWei;
    feePercentage = _feePercentage > 100 ? 100 : _feePercentage;
    tradingEnabled = _tradingEnabled;
    subdivisionEnabled = _subdivisionEnabled;
    maxSubdivisions = _maxSubdivisions;
    owner = msg.sender;
    beneficiary = msg.sender;
  }

  /** An ERC20-compatible balance that returns the number of plots owned */
  function balanceOf(address addr) constant returns(uint) {
    return plotsOwned[addr].length;
  }

  function tokensOfOwnerByIndex(address addr, uint idx) constant returns(uint) {
    return plotsOwned[addr][idx];
  }

  function ownerOf(uint id) constant validID(id) returns (address) {
    return plots[id].owner;
  }

  function isUnowned(uint id) constant validID(id) returns(bool) {
    return plots[id].owner == 0x0;
  }

  function transfer(uint id, address newOwner, string newData)
    validID(id) isOwnerOf(id) tradingIsEnabled returns(bool)
  {
    plots[id].owner = newOwner;

    if (bytes(newData).length != 0) {
      plots[id].metadata = newData;
    }

    Transfer(msg.sender, newOwner, id);
    addPlot(newOwner, id);
    removePlot(msg.sender, id);
    return true;
  }

  function purchase(uint id, string metadata, bool forSale, uint newPrice)
    validID(id) tradingIsEnabled payable returns(bool)
  {
    LunarPlot plot = plots[id];

    if (isUnowned(id)) {
      require(msg.value >= initialPrice);
    } else {
      require(plot.forSale && msg.value >= plot.price);
    }

    if (plot.owner != 0x0) {
      // We only send money to owner if the owner is set
      uint fee = plot.price * feePercentage / 100;
      uint saleProceeds = plot.price - fee;
      plot.owner.transfer(saleProceeds);
      removePlot(plot.owner, id);
    } else {
      totalOwned++;
    }

    addPlot(msg.sender, id);
    plot.owner = msg.sender;
    plot.forSale = forSale;
    plot.price = newPrice;

    if (bytes(metadata).length != 0) {
      plot.metadata = metadata;
    }

    Purchase(msg.sender, id, msg.value);
    totalPurchases++;
    return true;
  }

  function subdivide(
    uint id,
    bool forSale1,
    bool forSale2,
    uint price1,
    uint price2,
    string metadata1,
    string metadata2
  ) isOwnerOf(id) subdivisionIsEnabled {
    // Prevent more subdivisions than max
    require(plots[id].subdivision < maxSubdivisions);

    LunarPlot storage oldPlot = plots[id];

    uint id1 = numPlots++;
    plots[id1] = LunarPlot({
      owner: msg.sender,
      price: price1,
      forSale: forSale1,
      metadata: metadata1,
      disabled: false,
      parentID: id,
      subdivision: oldPlot.subdivision + 1
    });

    uint id2 = numPlots++;
    plots[id2] = LunarPlot({
      owner: msg.sender,
      price: price2,
      forSale: forSale2,
      metadata: metadata2,
      disabled: false,
      parentID: id,
      subdivision: oldPlot.subdivision + 1
    });

    // Disable old plot and add new plots
    plots[id].disabled = true;
    totalOwned += 1;
    totalSupply += 1;

    removePlot(msg.sender, id);
    addPlot(msg.sender, id1);
    addPlot(msg.sender, id2);
  }

  function setPrice(uint id, bool forSale, uint newPrice) validID(id) isOwnerOf(id) {
    plots[id].price = newPrice;
    plots[id].forSale = forSale;
    PriceChanged(msg.sender, id, newPrice);
  }

  function setMetadata(uint id, string newData) validID(id) isOwnerOf(id) {
    plots[id].metadata = newData;
    MetadataUpdated(msg.sender, id, newData);
  }

  // Private methods

  function removePlot(address addr, uint id) private {
    // Copy the last entry to id and then delete the last one
    uint n = plotsOwned[addr].length;
    for (uint8 i = 0; i < n; i++) {
      if (plotsOwned[addr][i] == id) {
        // If found, copy the last element to the idx and then delete last element
        plotsOwned[addr][i] = plotsOwned[addr][n - 1];
        delete plotsOwned[addr][n - 1];
        plotsOwned[addr].length--;
        break;
      }
    }
  }

  function addPlot(address addr, uint id) private {
    plotsOwned[addr].push(id);
  }

  // Contract management methods

  function setOwner(address newOwner) ownerOnly {
    owner = newOwner;
  }

  function setBeneficiary(address newBeneficiary) ownerOnly {
    beneficiary = newBeneficiary;
  }

  function setSubdivisionEnabled(bool enabled) ownerOnly {
    subdivisionEnabled = enabled;
  }

  function setTradingEnabled(bool enabled) ownerOnly {
    tradingEnabled = enabled;
  }

  function setFeePercentage(uint8 _percentage) ownerOnly {
    feePercentage = _percentage > 100 ? 100 : _percentage;
  }

  function setInitialPrice(uint _priceInWei) ownerOnly {
    initialPrice = _priceInWei;
  }

  function withdraw() ownerOnly {
    beneficiary.transfer(this.balance);
  }
}