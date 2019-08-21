pragma solidity ^0.4.24;

contract OurPlace500{
    bytes9[250000] public pixels;
    address public owner;
    address public manager;
    bool public isPaused;
    uint public pixelCost;
    uint256 public CANVAS_HEIGHT;
    uint256 public CANVAS_WIDTH;
    uint public totalChangedPixels;
    struct Terms{
        string foreword;
        string rules;
        string youShouldKnow;
        string dataCollection;
        uint versionForeword;
        uint versionRules;
        uint versionYouShouldKnow;
        uint versionDataCollection;
    }
    Terms public termsAndConditions;
    string public terms;
    mapping (address => uint) txMap;

    constructor(address ownerAddress) public{
        owner = ownerAddress;
        manager = msg.sender;
        isPaused = false;
        pixelCost = .000021 ether;
        CANVAS_WIDTH = 500;
        CANVAS_HEIGHT = 500;
        totalChangedPixels = 0;
        termsAndConditions = Terms({
            foreword: "Welcome to ourPlace! \n \n Here you can change a pixel to any color on the Hex #RRGGBB scale for a small fee. \n Below you will find the general *rules* of the contract and other terms and conditions written in plain English. \n \n We highly suggest you give it a quick read, enjoy!",
            versionForeword: 1,
            rules: "The contract will only function properly if: \n \n i)  You have not changed any other pixels on this ETH block -- only one pixel is allowed to be changed per address per block, \n ii)  The Hex code, X & Y coordinate are valid values, \n iii)  The transfer value is correct (this is automatically set), \n iv)  You have accepted the Terms & Conditions. \n \n *Please note* However unlikely, it is possible that two different people could change the same pixel in the same block. The most recently processed transaction *wins* the pixel. Allow all your pixel transactions to complete before attempting again. Order of transactions is randomly chosen by ETH miners.",
            versionRules: 1,
            youShouldKnow: "You should know that: \n \n i) Changing a pixel costs ETH, \n ii)  We make no guarantees to keep the website running forever (obviously we will do our best), \n iii)  We may choose to permanently pause the contract, or clear large blocks of pixels if the canvas is misused, \n iv)  We may choose to point our website to an updated, empty, contract instead of the current contract. \n \n In addition we want to remind you: \n \n i) To check MetaMask and clear all errors/warnings before submitting a transaction, \n ii)You are responsible for the designs that you make, \n iii)To be on alert for look-alike websites and malicious pop-ups, \n iv)That you are solely responsible for the safety of your accounts.",
            versionYouShouldKnow: 1,
            dataCollection: "Our official website will contain: \n \n i)  A Google Tag Manager cookie with both Analytics and Adwords tags installed. Currently there is no intention to use this data for anything other than interest's sake and sharing generic aggregated data. \n ii)  All transactions are recorded on the Ethereum blockchain, everyone has public access to this data. We, or others, may analyze this data to see which accounts interact with this contract.",
            versionDataCollection: 1
        });
    }

    modifier isManager(){
        require(msg.sender == manager, "Only The Contract Manager Can Call This Function");
        _;
    }

    modifier isOwner(){
        require(msg.sender == owner, "Only The Contract Owner Can Call This Function");
        _;
    }

    function changePixel(string pixelHex, uint pixelX, uint pixelY, bool acceptedTerms) public payable{
        require(!isPaused, 'Contract Is Paused');
        require(acceptedTerms, 'Must Accept Terms To Proceed');
        require(msg.value >= pixelCost, 'Transaction Value Is Incorrect');
        require(RGBAHexRegex.matches(pixelHex), 'Not A Valid Hex #RRGGBBAA Color Value');
        require(pixelX > 0 && pixelX <= CANVAS_WIDTH, 'Invalid X Coordinate Value');
        require(pixelY > 0 && pixelY <= CANVAS_HEIGHT, 'Invalid Y Coordinate Value');
        require(txMap[msg.sender] != block.number, 'One Transaction Allowed Per Block');
        txMap[msg.sender] = block.number;
        uint index = CANVAS_WIDTH * (pixelY-1) + (pixelX-1);
        bytes9 pixelHexBytes = stringToBytes9(pixelHex);
        pixels[index] = pixelHexBytes;
        totalChangedPixels = totalChangedPixels + 1;
    }

    function changeTerms(string termsKey, string termsValue) public isManager {
        if(compareStrings(termsKey,'foreword')){
            termsAndConditions.foreword = termsValue;
            termsAndConditions.versionForeword++;
        }
        else if(compareStrings(termsKey,'rules')){
            termsAndConditions.rules = termsValue;
            termsAndConditions.versionRules++;
        }
        else if(compareStrings(termsKey,'youShouldKnow')){
            termsAndConditions.youShouldKnow = termsValue;
            termsAndConditions.versionForeword++;
        }
        else if(compareStrings(termsKey,'dataCollection')){
            termsAndConditions.dataCollection = termsValue;
            termsAndConditions.versionDataCollection++;
        }
        else {
            revert('Invalid Section Key');
        }
    }

    function changePixelCost(uint newPixelCost) public isManager{
        pixelCost = newPixelCost;
    }

    function clearPixels(uint xTopL, uint yTopL, uint xBottomR, uint yBottomR) public isManager{
        require(xTopL > 0 && xTopL <= CANVAS_WIDTH, 'Invalid X Coordinate Value');
        require(yTopL > 0 && yTopL <= CANVAS_HEIGHT, 'Invalid Y Coordinate Value');
        require(xBottomR > 0 && xBottomR <= CANVAS_WIDTH, 'Invalid X Coordinate Value');
        require(yBottomR > 0 && yBottomR <= CANVAS_HEIGHT, 'Invalid Y Coordinate Value');
        require(xTopL < xBottomR, 'Double Check Corner Coordinates');
        require(yTopL > yBottomR, 'Double Check Corner Coordinates');
        for(uint y = yTopL; y <= yBottomR; y++)
        {
            for(uint x = xTopL; x <= xBottomR; x++)
            {
                uint index = CANVAS_WIDTH * (y-1) + (x-1);
                bytes9 pixelHexBytes = stringToBytes9('');
                pixels[index] = pixelHexBytes;
            }
        }
    }

    function changeManager(address newManager) public isOwner{
        manager=newManager;
    }

    function changeOwner(address newOwner) public isOwner{
        owner=newOwner;
    }

    function withdraw() public isOwner{
        owner.transfer(address(this).balance);
    }

    function pauseContract() public isManager{
        isPaused = !isPaused;
    }

    function getPixelArray() public view returns(bytes9[250000]){
        return pixels;
    }

    function compareStrings (string a, string b) private pure returns (bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

    function stringToBytes9(string memory source) private pure returns (bytes9 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
}

library RGBAHexRegex {
    struct State {
        bool accepts;
        function (byte) pure internal returns (State memory) func;
    }

    string public constant regex = "#(([0-9a-fA-F]{2}){4})";

    function s0(byte c) pure internal returns (State memory) {
        c = c;
        return State(false, s0);
    }

    function s1(byte c) pure internal returns (State memory) {
        if (c == 35) {
            return State(false, s2);
        }
        return State(false, s0);
    }

    function s2(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s3);
        }
        return State(false, s0);
    }

    function s3(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s4);
        }
        return State(false, s0);
    }

    function s4(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s5);
        }
        return State(false, s0);
    }

    function s5(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s6);
        }
        return State(false, s0);
    }

    function s6(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s7);
        }
        return State(false, s0);
    }

    function s7(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s8);
        }
        return State(false, s0);
    }

    function s8(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(false, s9);
        }
        return State(false, s0);
    }

    function s9(byte c) pure internal returns (State memory) {
        if (c >= 48 && c <= 57 || c >= 65 && c <= 70 || c >= 97 && c <= 102) {
            return State(true, s10);
        }
        return State(false, s0);
    }

    function s10(byte c) pure internal returns (State memory) {
        // silence unused var warning
        c = c;
        return State(false, s0);
    }

    function matches(string input) public pure returns (bool) {
        State memory cur = State(false, s1);
        for (uint i = 0; i < bytes(input).length; i++) {
            byte c = bytes(input)[i];
            cur = cur.func(c);
        }
        return cur.accepts;
    }
}