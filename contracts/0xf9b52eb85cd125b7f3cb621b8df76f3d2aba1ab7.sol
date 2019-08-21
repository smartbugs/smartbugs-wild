pragma solidity ^0.4.4;

contract BlockSpeech {

    event Keynote(address indexed _from, uint _speech_id, string _speech_title);
    event Like(address indexed _from, address _addr, uint _speech_id);
    event Reward(address indexed _from, address _addr, uint _speech_id, uint _value);

    struct Speech {
        uint speech_id;
        uint speech_type; // 1, for TA; 2, for the world
        string speech_title;
        string speech_content;
        uint likes;
        uint reward;
        mapping(address=>uint) reward_detail;
        mapping(address=>bool) is_like;
    }

    mapping (address => mapping (uint => Speech)) _speeches;
    mapping (address => uint[]) _speech_list;
    address[] _writers;
    mapping(address=>uint) _writer_num;
    uint[] _speech_num;
    uint _speech_total_likes;
    mapping(address=>uint) _total_likes;
    mapping(address=>uint) _total_reward;

    mapping(uint=>address[]) _like_addrs;
    mapping(uint=>address[]) _reward_addrs;

    uint public DEV_TAX_DIVISOR;
    address public blockAppAddr;

    function BlockSpeech(uint _tax_rate) public {
        blockAppAddr = msg.sender;
        DEV_TAX_DIVISOR = _tax_rate;
    }

    function keynote(uint _speech_id, uint _speech_type, string _speech_title, string _speech_content) public returns(bool) {

        require(_speech_id > 0);
        require(bytes(_speech_title).length > 0);
        require(bytes(_speech_content).length > 0);

        if(_writer_num[msg.sender] == 0) {
            uint num = _writers.length++;
            _writers[num] = msg.sender;
            _writer_num[msg.sender] = num;
        }

        Speech memory speech = Speech(_speech_id, _speech_type, _speech_title, _speech_content, 0, 0);

        _speeches[msg.sender][_speech_id] = speech;
        _speech_list[msg.sender][_speech_list[msg.sender].length++] = _speech_id;

        _speech_num[_speech_num.length++] = _speech_num.length++;

        emit Keynote(msg.sender, _speech_id, _speech_title);
        return true;
    }

    function like(address _addr, uint _speech_id) public returns(bool) {
        require(_speech_id > 0);
        require(_addr != address(0));

        Speech storage speech = _speeches[_addr][_speech_id];
        require(speech.speech_id > 0);
        require(!speech.is_like[msg.sender]);

        speech.is_like[msg.sender] = true;
        speech.likes++;

        _like_addrs[_speech_id][_like_addrs[_speech_id].length++] = msg.sender;
        _total_likes[_addr] = SafeMath.add(_total_likes[_addr], 1);
        _speech_total_likes = SafeMath.add(_speech_total_likes, 1);

        emit Like(msg.sender, _addr, _speech_id);
        return true;
    }

    function reward(address _addr, uint _speech_id) public payable returns(bool) {
        require(_speech_id > 0);
        require(_addr != address(0));
        require(msg.value > 0);

        Speech storage speech = _speeches[_addr][_speech_id];
        require(speech.speech_id > 0);

        speech.reward = SafeMath.add(speech.reward, msg.value);
        _reward_addrs[_speech_id][_reward_addrs[_speech_id].length++] = msg.sender;
        _total_reward[_addr] = SafeMath.add(_total_reward[_addr], msg.value);

        uint devTax = SafeMath.div(msg.value, DEV_TAX_DIVISOR);
        uint finalValue = SafeMath.sub(msg.value, devTax);

        assert(finalValue>0 && devTax>0);

        blockAppAddr.transfer(devTax);
        _addr.transfer(finalValue);

        emit Reward(msg.sender, _addr, _speech_id, msg.value);
        return true;
    }

    function getMySpeechList() public constant returns (uint[] speech_list, uint[] speech_rewards, uint[] speech_likes, bool[] is_likes){

        speech_rewards = new uint[](_speech_list[msg.sender].length);
        speech_likes = new uint[](_speech_list[msg.sender].length);
        is_likes = new bool[](_speech_list[msg.sender].length);

        for(uint i=0; i<_speech_list[msg.sender].length; i++) {
            Speech storage speech = _speeches[msg.sender][_speech_list[msg.sender][i]];
            speech_rewards[i] = speech.reward;
            speech_likes[i] = speech.likes;
            is_likes[i] = speech.is_like[msg.sender];
        }

        return (_speech_list[msg.sender], speech_rewards, speech_likes, is_likes);
    }

    function getMySpeechList(address _addr) public constant returns (uint[] speech_list, uint[] speech_rewards, uint[] speech_likes, bool[] is_likes, uint[] speech_types){
        require(_addr != address(0));

        speech_types = new uint[](_speech_list[_addr].length);
        speech_rewards = new uint[](_speech_list[_addr].length);
        speech_likes = new uint[](_speech_list[_addr].length);
        is_likes = new bool[](_speech_list[_addr].length);

        for(uint i=0; i<_speech_list[_addr].length; i++) {
            Speech storage speech = _speeches[_addr][_speech_list[_addr][i]];
            speech_types[i] = speech.speech_type;
            speech_rewards[i] = speech.reward;
            speech_likes[i] = speech.likes;
            is_likes[i] = speech.is_like[_addr];
        }

        return (_speech_list[_addr], speech_rewards, speech_likes, is_likes, speech_types);
    }

    function getMySpeech(uint _speech_id) public constant returns (uint speech_type, string speech_title, string speech_content, uint likes, uint rewards){
        require(_speech_id > 0);

        Speech storage speech = _speeches[msg.sender][_speech_id];
        assert(speech.speech_id > 0);

        return (speech.speech_type, speech.speech_title, speech.speech_content, speech.likes, speech.reward);
    }

    function getMySpeech(uint _speech_id, address _addr) public constant returns (uint speech_type, string speech_title, string speech_content, uint likes, uint rewards){
        require(_speech_id > 0);

        Speech storage speech = _speeches[_addr][_speech_id];
        assert(speech.speech_id > 0);

        return (speech.speech_type, speech.speech_title, speech.speech_content, speech.likes, speech.reward);
    }

    function getMe() public constant returns (uint num_writer, uint num_speech, uint total_likes, uint total_reward) {
        return (_writer_num[msg.sender], _speech_list[msg.sender].length, _total_likes[msg.sender], _total_reward[msg.sender]);
    }

    function getWriter(address _addr) public constant returns (uint num_writer, uint num_speech, uint total_likes, uint total_reward) {
        require(_addr != address(0));
        return (_writer_num[_addr], _speech_list[_addr].length, _total_likes[_addr], _total_reward[_addr]);
    }

    function getWriter(address[] _addrs) public constant returns (uint[] num_writer, uint[] num_speech, uint[] total_likes, uint[] total_reward) {

        for(uint i=0; i<_addrs.length; i++) {
            num_writer[i] = _writer_num[_addrs[i]];
            num_speech[i] = _speech_list[_addrs[i]].length;
            total_likes[i] = _total_likes[_addrs[i]];
            total_reward[i] = _total_reward[_addrs[i]];
        }
        return (num_writer, num_speech, total_likes, total_reward);
    }

    function getBlockSpeech() public constant returns (uint num_writers, uint num_speechs, uint speech_total_likes) {
        return (_writers.length, _speech_num.length, _speech_total_likes);
    }

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function isInArray(uint a, uint[] b) internal pure returns (bool) {

        for(uint i = 0; i < b.length; i++) {
            if(b[i] == a) return true;
        }

        return false;
    }
}