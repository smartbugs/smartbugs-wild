pragma solidity ^0.4.25;

/*                                                                                                                   
                                                                                                                                                            
                  :$%`                                                                                                                                      
                .!|':$:                                                                                                                                     
               '%;   `%!.                                                                                                                                   
      .'.     ;%'      !%`     '`                                               '!'                :|||!;`                             .;|'       .;|'      
      '$$$$!:||.        :$;:%$$$!           '$;         :$'      '`       '.    :$:               .!%' .:%$:                             :$%`    ;$|.       
      ;%%%';$$$!`      :%$$%:!%%%`          :$;                :%'      ;|`     :$:               .!%`   :$;                               !$! '%%'         
     .|;.;$|`  .;%$$$$|'   :$|`'%:          :$;         :$'  `!$$%|;. '|$$||:   :$:    :$%;!%%`   .!$!;!%$:     .|$|;|$;    `|$!;|$;        `|$$;           
     '%::$$%' `|$$!`'|$$;..!$$|:!!          :$;         :$'    !|`     .|!.     :$:   :$;...'|!.  .!%:``'!$%`  .!%'...;$:  .||'...;$:       ;$$$|`          
     ;$$|':%$%:         .!$$|';$$%`         :$;         :$'    !|`     .|!.     :$:   :$:         .!%`    '%|. .!|.        .|!.           '%%'  !$;         
    .!$$$|` '%:         .|!. :%$$$:         :$!`....    :$'    ;$: ''  .!%' `.  :$:    !$!` .;;.  .!%' .`;%$:   '%%:. `!'   '$%:. '!'   .!$;     `%$:       
    .!$!.    '%;       `|!.    '%$:         `!!!!!!`    '!`     `;!:.    `;!'   `!`      '!!;`     :!!!!!:.       .;!!:.      `;!;'    `!;.        '!:      
       '%%:   '%;     `|!   .!$!.                                                                                                                           
          ;$|. `%;   `%;  '%%'                                                                                                                              
            `%$:'|! '%;`|$!                 `;....''... `''':``. .`;`  .'`.`:'`''''''```.'..'``. .':``'..  ::`. .''.  ''`.  ':`.`'..:` `'......` .`'`..     
               ;$$$$$$$%`                   .'.`'``..'. .. ''```'`.'.  .'`.`''`. .`. .``'..' ..  .''``..'  .. . .''.  `:'``.''`.`'.`'`.`'.`..``````..'`     
                 `|$$;                                                                                                                                      
                                                                                                                                                            

*/                                                                                                                                                   

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);
    }
}

contract ERC20 {
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function balanceOf(address owner) public view returns (uint256);
     
    function symbol() public view returns (string);
      
    function decimals() public view returns (uint);  
      
    function totalSupply() public view returns (uint256);
}


contract LittleBeeX_Sender is Ownable {
    function multisend(address _tokenAddr, address[] dests, uint256[] values) public onlyOwner returns (uint256) {
        uint256 i = 0;
        while (i < dests.length) {
           ERC20(_tokenAddr).transferFrom(msg.sender, dests[i], values[i]);
           i += 1;
        }
        return(i);
    }
    
    function searchTokenMsg ( address _tokenAddr ) public view returns (string,uint256,uint256,uint256){
        uint size = (10 ** ERC20(_tokenAddr).decimals());
        return( ERC20(_tokenAddr).symbol(),ERC20(_tokenAddr).totalSupply() / size,ERC20(_tokenAddr).balanceOf(msg.sender) / size,ERC20(_tokenAddr).allowance(msg.sender,this) / size);
    }
}