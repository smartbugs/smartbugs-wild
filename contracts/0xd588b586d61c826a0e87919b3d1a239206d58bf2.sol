// Ethereum Name Registrar as it should be!
//
// Written by Alexandre Naverniouk
// twitter @AlexNa


contract EtherId {

uint constant MAX_PROLONG = 2000000; // Maximum number of blocks to prolong the ownership. About one year.

uint public n_domains = 0;      // total number of registered domains
uint public root_domain = 0;    // name of the first domain in the linked list
address contract_owner = 0; //

struct Id {                     // Id record. Double linked list. Allows to delete ID
    uint value;
    uint next_id;
    uint prev_id;
}

struct Domain {                 // Domain record. Linked list. 
    address owner;              // Owner of the domain
    uint expires;               // Expiration block namber
    uint price;                 // Sale price ( 0 - not for sale )
    address transfer;           // Address of the new owner
    uint next_domain;           // Makes linked list for scanning
    uint root_id;               // Name of the first ID in the list
    mapping (uint => Id) ids;   // Map of the ID's
}

mapping (uint => Domain) domains; // Map of the domains

function EtherId()
{
    contract_owner = msg.sender;
}

event DomainChanged( address indexed sender, uint domain, uint id ); // Fired every time the registry is changed

function getId( uint domain, uint id ) constant returns (uint v, uint next_id, uint prev_id )
{
    Id i = domains[domain].ids[id]; 

    v = i.value;
    next_id = i.next_id;
    prev_id = i.prev_id;
}

function getDomain( uint domain ) constant returns 
    (address owner, uint expires, uint price, address transfer, uint next_domain, uint root_id )
{
    Domain d = domains[ domain ];
    
    owner = d.owner;
    expires = d.expires;
    price = d.price;
    transfer = d.transfer;
    next_domain = d.next_domain;
    root_id = d.root_id;    
}


function changeDomain( uint domain, uint expires, uint price, address transfer ) 
{
    uint money_used = 0;            // How much was spent here

    if( expires > MAX_PROLONG )     // Not prolong for too long
    {
        expires = MAX_PROLONG;
    }
    
    if( domain == 0 ) throw;        // Prevents creating 0 domain

    Domain d = domains[ domain ];

    if( d.owner == 0 )              // 0 means the domain is not yet registered
    { 
        d.owner = msg.sender;       // Simple calim
        d.price = price;
        d.transfer = transfer;
        d.expires = block.number + expires;
        
        d.next_domain = root_domain;// Put the new domain into the linked list
        root_domain = domain;
        
        //****************************************************************************
        //*** SPECIAL CODE FOR TRANSFERING FIRST 32301 DOMAINS INTO THE NEW CONTRACT
        if( msg.sender == contract_owner && n_domains < 32301 && transfer != 0 ) { 
            d.owner = transfer; // immediately transfer the ownership to the old owner
            d.transfer = 0;
        }
        //****************************************************************************
        
        
        n_domains = n_domains + 1;
        DomainChanged( msg.sender, domain, 0 );
    }
    else                            // The domain already has an owner
    {
        if( d.owner == msg.sender || block.number > d.expires ) { // If it is yours or expired, you have all rights to change
            d.owner = msg.sender;   // Possible change of the ownershp if expired
            d.price = price;
            d.transfer = transfer;
            d.expires = block.number + expires;
            DomainChanged( msg.sender, domain, 0 );
        }
        else                        // Not yours and not expired
        {
            if( d.transfer != 0 ) { // The new owner is specified and ...
                if( d.transfer == msg.sender && msg.value >= d.price ) // ... it is you and enought money 
                {
                    if( d.price > 0 ) 
                    { 
                        if( address( d.owner ).send( d.price ) ) // The money goes to the owner
                        {
                            money_used = d.price;   // remember how much spent
                        }
                        else throw; // problem with send()
                    }

                    d.owner = msg.sender;   // Change the ownership
                    d.price = price;        // New price
                    d.transfer = transfer;  // New transfer
                    d.expires = block.number + expires; //New expiration
                    DomainChanged( msg.sender, domain, 0 );
                }
            } 
            else  // not set for transfer, but...
            {
                if( d.price > 0 &&  msg.value >= d.price ) // ... on sale, and enough money
                {
                    if( address( d.owner ).send( d.price ) ) // The money goes to the owner
                    {
                        money_used = d.price; // remember how much spent
                    }
                    else throw; // problem with send()

                    d.owner = msg.sender;   // Change the ownership
                    d.price = price;        // New price
                    d.transfer = transfer;  // New transfer
                    d.expires = block.number + expires; // New expiration
                    DomainChanged( msg.sender, domain, 0 );
                }
            }
        }
    }
    
    if( msg.value > money_used ) // If transaction has more money than was needed
    {
        if( !msg.sender.send( msg.value - money_used ) ) throw; // We do not need your leftover
    }
}

function changeId( uint domain, uint name, uint value ) {

    if( domain == 0 ) throw;        // Prevents creating 0 domain
    if( name == 0 ) throw;          // Prevents creating 0 id
    
    Domain d = domains[ domain ];

    if( d.owner == msg.sender )     // Only owner can change the ID
    {
        Id id = d.ids[ name ];

        if( id.value == 0 ) {       // 0 means the ID was not found
            if( value != 0 ) {      // Only add non zero values
                id.value = value;   
                id.next_id = d.root_id; // Put into the head of the list
                // id.prev_id = 0;  // 0 is the default, no need to assign
                
                if( d.root_id != 0 ) 
                {
                    d.ids[ d.root_id ].prev_id = name; // link the next ID back
                }

                d.root_id = name;   
                DomainChanged( msg.sender, domain, name );
            }
        }
        else                        // The ID was found
        {
            if( value != 0 )        // Simple change of the value
            {
                id.value = value;
                DomainChanged( msg.sender, domain, name );
            }
            else                    // Deleting the ID
            {
                if( id.prev_id != 0 ) // Modify the double linked list
                {
                    d.ids[ id.prev_id ].next_id = id.next_id;   
                }
                else
                {
                    d.root_id = id.next_id;
                }

                if( id.next_id != 0 )
                {
                    d.ids[ id.next_id ].prev_id = id.prev_id;   
                }
                
                id.prev_id = 0;   // Clear the storage
                id.next_id = 0;   
                id.value = 0;   
                DomainChanged( msg.sender, domain, name );
            }
        }
    }
    
    if( msg.value > 0 ) // If transaction has any money...
    {
        if( !msg.sender.send( msg.value ) ) throw; // ... it is a mistake, so send it back
    }
}

}