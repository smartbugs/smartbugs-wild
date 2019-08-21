pragma solidity ^0.4.24;

/**
 * @title EnsRegistry
 * @dev Extract of the interface for ENS Registry
 */
contract EnsRegistry {
	function setOwner(bytes32 node, address owner) public;
	function setSubnodeOwner(bytes32 node, bytes32 label, address owner) public;
	function setResolver(bytes32 node, address resolver) public;
	function owner(bytes32 node) public view returns (address);
	function resolver(bytes32 node) public view returns (address);
}

/**
 * @title EnsResolver
 * @dev Extract of the interface for ENS Resolver
 */
contract EnsResolver {
	function setAddr(bytes32 node, address addr) public;
	function addr(bytes32 node) public view returns (address);
}

/**
 * @title Portal Network SubdomainRegistrar
 * @dev Allows to claim and configure a subdomain for Ethereum ENS in one call.
 */
contract SubdomainRegistrar {
	address public owner;
	bool public locked;
    bytes32 emptyNamehash = 0x00;

	mapping (string => EnsRegistry) registries;
	mapping (string => EnsResolver) resolvers;

	event SubdomainCreated(address indexed creator, address indexed owner, string subdomain, string domain, string topdomain);
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	event RegistryUpdated(address indexed previousRegistry, address indexed newRegistry);
	event ResolverUpdated(address indexed previousResolver, address indexed newResolver);
	event DomainTransfersLocked();
	event DomainTransfersUnlocked();

	constructor(string tld, EnsRegistry _registry, EnsResolver _resolver) public {
		owner = msg.sender;
		registries[tld] = _registry;
		resolvers[tld] = _resolver;
		locked = false;

	}

	/**
	 * @dev Throws if called by any account other than the owner.
	 *
	 */
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier supportedTLD(string tld) {
		require(registries[tld] != address(0) && resolvers[tld] != address(0));
		_;
	}

	/**
	 * @dev Allows to create a subdomain (e.g. "hello.portalnetwork.eth"),
	 * set its resolver and set its target address
	 * @param _subdomain - sub domain name only e.g. "hello"
	 * @param _domain - domain name e.g. "portalnetwork"
	 * @param _topdomain - parent domain name e.g. "eth", "etc"
	 * @param _owner - address that will become owner of this new subdomain
	 * @param _target - address that this new domain will resolve to
	 */
	function newSubdomain(string _subdomain, string _domain, string _topdomain, address _owner, address _target) public supportedTLD(_topdomain) {
		//create namehash for the topdomain
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		//create namehash for the domain
		bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		//make sure this contract owns the domain
		require(registries[_topdomain].owner(domainNamehash) == address(this), "this contract should own the domain");
		//create labelhash for the sub domain
		bytes32 subdomainLabelhash = keccak256(abi.encodePacked(_subdomain));
		//create namehash for the sub domain
		bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, subdomainLabelhash));
		//make sure it is free or owned by the sender
		require(registries[_topdomain].owner(subdomainNamehash) == address(0) ||
			registries[_topdomain].owner(subdomainNamehash) == msg.sender, "sub domain already owned");
		//create new subdomain, temporarily this smartcontract is the owner
		registries[_topdomain].setSubnodeOwner(domainNamehash, subdomainLabelhash, address(this));
		//set public resolver for this domain
		registries[_topdomain].setResolver(subdomainNamehash, resolvers[_topdomain]);
		//set the destination address
		resolvers[_topdomain].setAddr(subdomainNamehash, _target);
		//change the ownership back to requested owner
		registries[_topdomain].setOwner(subdomainNamehash, _owner);

		emit SubdomainCreated(msg.sender, _owner, _subdomain, _domain, _topdomain);
	}

	/**
	 * @dev Returns the owner of a domain (e.g. "portalnetwork.eth"),
	 * @param _domain - domain name e.g. "portalnetwork"
	 * @param _topdomain - parent domain name e.g. "eth" or "etc"
	 */
	function domainOwner(string _domain, string _topdomain) public view returns (address) {
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		bytes32 namehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		return registries[_topdomain].owner(namehash);
	}

	/**
	 * @dev Return the owner of a subdomain (e.g. "hello.portalnetwork.eth"),
	 * @param _subdomain - sub domain name only e.g. "hello"
	 * @param _domain - parent domain name e.g. "portalnetwork"
	 * @param _topdomain - parent domain name e.g. "eth", "etc"
	 */
	function subdomainOwner(string _subdomain, string _domain, string _topdomain) public view returns (address) {
		bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
		bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
		bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));
		return registries[_topdomain].owner(subdomainNamehash);
	}

    /**
    * @dev Return the target address where the subdomain is pointing to (e.g. "0x12345..."),
    * @param _subdomain - sub domain name only e.g. "hello"
    * @param _domain - parent domain name e.g. "portalnetwork"
    * @param _topdomain - parent domain name e.g. "eth", "etc"
    */
    function subdomainTarget(string _subdomain, string _domain, string _topdomain) public view returns (address) {
        bytes32 topdomainNamehash = keccak256(abi.encodePacked(emptyNamehash, keccak256(abi.encodePacked(_topdomain))));
        bytes32 domainNamehash = keccak256(abi.encodePacked(topdomainNamehash, keccak256(abi.encodePacked(_domain))));
        bytes32 subdomainNamehash = keccak256(abi.encodePacked(domainNamehash, keccak256(abi.encodePacked(_subdomain))));
        address currentResolver = registries[_topdomain].resolver(subdomainNamehash);
        return EnsResolver(currentResolver).addr(subdomainNamehash);
    }

	/**
	 * @dev The contract owner can take away the ownership of any domain owned by this contract.
	 * @param _node - namehash of the domain
	 * @param _owner - new owner for the domain
	 */
	function transferDomainOwnership(string tld, bytes32 _node, address _owner) public supportedTLD(tld) onlyOwner {
		require(!locked);
		registries[tld].setOwner(_node, _owner);
	}

	/**
	 * @dev The contract owner can lock and prevent any future domain ownership transfers.
	 */
	function lockDomainOwnershipTransfers() public onlyOwner {
		require(!locked);
		locked = true;
		emit DomainTransfersLocked();
	}

	function unlockDomainOwnershipTransfer() public onlyOwner {
		require(locked);
		locked = false;
		emit DomainTransfersUnlocked();
	}

	/**
	 * @dev Allows to update to new ENS registry.
	 * @param _registry The address of new ENS registry to use.
	 */
	function updateRegistry(string tld, EnsRegistry _registry) public onlyOwner {
		require(registries[tld] != _registry, "new registry should be different from old");
		emit RegistryUpdated(registries[tld], _registry);
		registries[tld] = _registry;
	}

	/**
	 * @dev Allows to update to new ENS resolver.
	 * @param _resolver The address of new ENS resolver to use.
	 */
	function updateResolver(string tld, EnsResolver _resolver) public onlyOwner {
		require(resolvers[tld] != _resolver, "new resolver should be different from old");
		emit ResolverUpdated(resolvers[tld], _resolver);
		resolvers[tld] = _resolver;
	}

	/**
	 * @dev Allows the current owner to transfer control of the contract to a new owner.
	 * @param _owner The address to transfer ownership to.
	 */
	function transferContractOwnership(address _owner) public onlyOwner {
		require(_owner != address(0), "cannot transfer to address(0)");
		emit OwnershipTransferred(owner, _owner);
		owner = _owner;
	}
}