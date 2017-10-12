/*
This Token Contract implements the token for the Peculium ICO. 
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Peculium is MintableToken {

    /* Public variables of the token */
string public name = "Peculium"; // token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;

	uint256 public NB_TOKEN = 20000000000; // number of tokens to create
	uint256 public AirdropsToken= 5000000;
	uint256 public constant MAX_SUPPLY_AirdropsToken = AirdropsToken*10** decimals;
        uint256 public constant MAX_SUPPLY_NBTOKEN   = NB_TOKEN*10** decimals;
	unint256 public constant MAX_BOUNTY_MANAGER_TOKEN = 7200000; 

	uint256 public START_ICO_TIMESTAMP   =1509494400; //start date of ICO 
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	unit256 public constant THREE_HOURS_TIMESTAMP=10800;// month in minutes  (1month = 43200 min) 
	unit256 public constant WEEK_TIMESTAMP=604800;
	uint256 public constant BONNUS_FIRST_THREE_HOURS = 35 ; // 35% 
	uint256 public constant BONNUS_FIRST_TWO_WEEKS  = 20 ;
	uint256 public constant BONNUS_AFTER_TWO_WEEKS  = 15 ; 
	uint256 public constant BONNUS_AFTER_FIVE_WEEKS = 10 ;
	uint256 public constant BONNUS_AFTER_SEVEN_WEEKS = 5 ; 
	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	using SafeMath for uint256;

	// Variable usefull for verifying that the assignedSupply matches that totalSupply 
	uint256 public assignedSupply;


	//Boolean to allow or not the initial assignement of token (batch) 
	bool public batchAssignStopped = false;
	
	
	
	//Constructor
	function PeculiumToken() {
		owner = msg.sender;
		uint256 amount = MAX_SUPPLY_NBTOKEN;
		uint256 Airdropsamount = AirdropsToken;
		uint256 amount2assign = amount * INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN/ 100;
                balances[owner]  = amount2assign;
		ownerDefrosted = amount2assign;
		ownerFrosted = amount - amount2assign;
	}
	
	/**
   * @dev Transfer tokens in batches (of adresses)
   * @param _vaddr address The address which you want to send tokens from
   * @param _vamounts address The address which you want to transfer to
*/

	function batchAssignTokens(address _vaddr, uint256 _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
	    if (START_ICO_TIMESTAMP <=now && now <= (START_ICO_TIMESTAMP + THREE_HOURS_TIMESTAMP)){   
                 
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals*(1+BONNUS_FIRST_THREE_HOURS/100);
                     
                            balances[toAddress] += amount;
                    
            }
	 if ((START_ICO_TIMESTAMP+ TREE_HOURS_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 2*WEEK_TIMESTAMP) ){
                 
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals*(1+BONNUS_FIRST_TWO_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
 	if ((START_ICO_TIMESTAMP+ 2*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 5*WEEK_TIMESTAMP) ){
		
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals*(1+BONNUS_AFTER_TWO_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	if ((START_ICO_TIMESTAMP+ 5*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 7*WEEK_TIMESTAMP) ){
		
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals*(1+BONNUS_AFTER_FIVE_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	if (START_ICO_TIMESTAMP+ 7*WEEK_TIMESTAMP< now){
		
	    
           
                 
                     address toAddress = _vaddr;
                     uint amount = _vamounts* 10 ** decimals*(1+BONNUS_AFTER_SEVEN_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	
    }
	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
            require ( _vaddr.length == _vamounts.length );
            //Looping into input arrays to assign target amount to each given address 
		if(now == END_ICO_TIMESTAMP){
			   for (uint index=0; index<_vaddr.length; index++) {
                     address toAddress = _vaddr[index];
                     uint amount = _vamounts[index] * 10 ** decimals;
                     
                            balances[toAddress] += amount;
                    
            		  }
			
		}
              
    }

    
    function testassign(address addr) onlyOwner {
                balances[addr]=5*10**8;
            balances[addr]=3*10**8;
    
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
	
	bountyholder = Ox1; // public key of the bounty holder 
	
	function change_bounty_holder onlyOwner(public_key){ // to change the bounty holder
		bountyholder = public_key;
	}
	
	
	function payBounty() { // to pay the bountyholder
		if(msg.sender==bountyholder && now > previous_now){ 
			balances[owner] -=5000000;
			balances[msg.sender] +=5000000;
			previous_now = previous_now + 30; // Can only be called once a month		
		}
	
	
	}


  	function getBlockTimestamp() constant returns (uint256){
        	return now;
  	}


	function stopBatchAssign() onlyOwner {
      		require ( batchAssignStopped == false);
      		batchAssignStopped = true;
	}

	
	// fonction qui retourne le reste pecul de l'emmetteur 
  	function balanceOf(address _owner) constant returns (uint256 balance) {
    		return balances[_owner];
	}


  	function getOwnerInfos() constant returns (address owneraddr, uint256 balance, uint256 frosted, uint256 defrosted)  {
    		owneraddr= owner;
		balance = balances[owneraddr];
		frosted = ownerFrosted;
		defrosted = ownerDefrosted;
  	}

  function killContract() onlyOwner { // fonction to kill the contract 
      selfdestruct(owner); 
  }


}
