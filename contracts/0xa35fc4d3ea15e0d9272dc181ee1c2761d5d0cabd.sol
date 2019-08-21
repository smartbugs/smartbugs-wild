contract UsernameRegistry {

  mapping(address => string) addr_to_str;
  mapping(string => address) str_to_addr;

  function register(string username) {
    if (str_to_addr[username] != address(0)) {
      // username taken
      throw;
    }
    str_to_addr[addr_to_str[msg.sender]] = address(0);
    addr_to_str[msg.sender] = username;
    str_to_addr[username] = msg.sender;
  }

  function get_username(address addr) constant returns (string) {
    return addr_to_str[addr];
  }

  function get_address(string username) constant returns (address) {
    return str_to_addr[username];
  }
}