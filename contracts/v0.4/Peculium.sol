/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Peculium is MintableToken {

    /* Public variables of the token */
string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;

	uint256 public NB_TOKEN = 20000000000; // number of token to create
	uint256 public constant MONTHLY_SEND_BOUNTY_MANAGER = 20;
        uint256 public constant MAX_SUPPLY_NBTOKEN   = NB_TOKEN*10** decimals;
        
	
	uint256 public START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public START_ICO_TIMESTAMP=START_PRE_ICO_TIMESTAMP+ 10* 1 days ;
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public constant THREE_HOURS_TIMESTAMP=10800;// month in minutes  (1month =43200min)  mois en minutes (1 mois = 43200 minutes)
	uint256 public constant WEEK_TIMESTAMP=604800;
	uint256 public constant BONNUS_FIRST_THREE_HOURS_PRE_ICO = 35 ; // 35%
	uint256 public constant BONNUS_FIRST_TEN_DAYS_PRE_ICO = 30 ; // 35% 
	uint256 public constant BONNUS_FIRST_TWO_WEEKS_ICO  = 20 ;
	uint256 public constant BONNUS_AFTER_TWO_WEEKS_ICO  = 15 ; 
	uint256 public constant BONNUS_AFTER_FIVE_WEEKS_ICO = 10 ;
	uint256 public constant BONNUS_AFTER_SEVEN_WEEKS_ICO = 5 ; 
	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	using SafeMath for uint256;
	//samir
	uint256 teamShare; //la part pour l'equipe
	uint256 bountyShare;
	uint256 tokenAviableForIco; //LES TOKEN POUR L'ICO ET LA PRÉS ICO
	uint256 tokenAviableAfterIco;
	uint256 dateOfPayment_TimeStamp;
	uint256 Airdropsamount;
	uint256 public constant END_PAYMENTE_TIMESTAMP=1533074400;
	// Variable usefull for verifying that the assignedSupply matches that totalSupply // variable utile pour vérifier que le assignedSupply marche avec le totalSupply
	uint256 public assignedSupply;


	//Boolean to allow or not the initial assignement of token (batch) // Booléen qui autorise ou non le transfert initial de token (par lots)
	
	bool public batchAssignStopped = false;
	
	
	
	//constructeur de nos Tokens
	function Peculium() {
		owner = msg.sender;
		uint256 amount = MAX_SUPPLY_NBTOKEN;
		tokenAviableForIco = amount * INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN/ 100;
		Airdropsamount = 50000000*10**8;
		teamShare=amount*12/100;
		bountyShare=amount*3/100-Airdropsamount;
		dateOfPayment_TimeStamp=END_ICO_TIMESTAMP;
		tokenAviableAfterIco=amount-(tokenAviableForIco+teamShare+bountyShare);
                balances[owner]  = tokenAviableForIco;
	}

	function buyTokenPreIco(address toAddress, uint256 _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
	    if (START_PRE_ICO_TIMESTAMP <=now && now <= (START_PRE_ICO_TIMESTAMP + THREE_HOURS_TIMESTAMP)){   
                 
                     
                     uint256 amount = _vamounts*10**decimals *(1+BONNUS_FIRST_THREE_HOURS_PRE_ICO/100);
                     
                            balances[toAddress] += amount;
                    
            }
	     if (START_PRE_ICO_TIMESTAMP+ THREE_HOURS_TIMESTAMP <=now && now <= (START_PRE_ICO_TIMESTAMP + 10* 1 days)){   
                 
                     
                     uint256 amount = _vamounts*10**decimals *(1+BONNUS_FIRST_TEN_DAYS_PRE_ICO/100);
                     
                            balances[toAddress] += amount;
                    
            }
	}
	function buyTokenIco(address toAddress, uint256 _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
	 if ((START_ICO_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 2*WEEK_TIMESTAMP) ){
                 
                     
                     	    amount = _vamounts* 10**decimals *(1+BONNUS_FIRST_TWO_WEEKS_ICO/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
 	if ((START_ICO_TIMESTAMP+ 2*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 5*WEEK_TIMESTAMP) ){
		
                     
                     	    amount = _vamounts*10**decimals *(1+BONNUS_AFTER_TWO_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	if ((START_ICO_TIMESTAMP+ 5*WEEK_TIMESTAMP) < now && now <= (START_ICO_TIMESTAMP + 7*WEEK_TIMESTAMP) ){
		
                     
                     	    amount = _vamounts*10**decimals *(1+BONNUS_AFTER_FIVE_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	if (START_ICO_TIMESTAMP+ 7*WEEK_TIMESTAMP< now){
		
                     	    amount = _vamounts*10**decimals *(1+BONNUS_AFTER_SEVEN_WEEKS/100);
                     
                       
                            balances[toAddress] += amount;
                    
            }
	
    }
	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
            require ( _vaddr.length == _vamounts.length );
            //Looping into input arrays to assign target amount to each given address // boucler sur l'entrée pour assigner la somme cible pour chaque adresse
		if(now == END_ICO_TIMESTAMP){
			   for (uint index=0; index<_vaddr.length; index++) {
                     address toAddress = _vaddr[index];
                     uint amount = _vamounts[index] * 10 ** decimals;
                     
                            balances[toAddress] += amount;
                    
            		  }
			
		}
              
    }
	address bountyholder = Ox1; // public key of the bounty holder 
	
	function change_bounty_holder (address public_key) onlyOwner{ // to change the bounty holder
		bountyholder = public_key;
	}
	
	
	function payBounty() { // to pay the bountyholder
		if(msg.sender==bountyholder && now > previous_now){ 
			bountymanagertoken -=MONTHLY_SEND_BOUNTY_MANAGER * bountymanagertoken/100;
			balances[msg.sender] +=MONTHLY_SEND_BOUNTY_MANAGER * bountymanagertoken/100;
			previous_now = previous_now + 30; // Can only be called once a month		
		}
	
	
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

	function teamPayment(address teamaddr) onlyOwner{
		if(now>dateOfPayment_TimeStamp && now< END_PAYMENTE_TIMESTAMP){
		    uint256 wages=teamShare*10/100;
		    if(dateOfPayment_TimeStamp<END_ICO_TIMESTAMP+ 30 * 1 days){
		     	wages=teamShare*40/100;
		     }
                     balances[teamaddr]+=wages;
		     dateOfPayment_TimeStamp+=30*1 days;

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
  	}

  function killContract() onlyOwner { // fonction pour stoper le contract définitivement. Tout les ethers présent sur le contract son envoyer sur le compte du propriétaire du contract.
      selfdestruct(owner); // dépense beaucoup moins d'ether que simplement envoyer avec send les ethers au propriétaire car libére de la place sur la blockchain
  }


}
