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

	uint256 public constant NB_TOKEN = 20000000000; // number of token to create
        uint256 public constant MAX_SUPPLY_NBTOKEN   = NB_TOKEN*10** decimals;
	// uint256 public constant START_ICO_TIMESTAMP   = 1501595111;
	uint256 public START_ICO_TIMESTAMP   = 1501595111; // not constant for testing 	(overwritten in the constructor) // Non constant pour les tests (reecrit dans le contructeur)
	uint256 public constant DEFROST_PERIOD           = 6; // month in minutes  (1month = 43200 min) // mois en minutes (1 mois = 43200 minutes)
	uint256 public constant DEFROST_MONTHLY_PERCENT_OWNER  = 25 ; // 25% per month is automaticaly defrosted // 5% sont automatiquement dégeler
	uint256 public constant DEFROST_INITIAL_PERCENT_OWNER  = 10 ; // 90% locked // 90% bloqués
	uint256 public constant DEFROST_MONTHLY_PERCENT  = 10 ; // 10% per month is automaticaly defrosted //  10% par mois sont automatiquement dégeler
	uint256 public constant DEFROST_INITIAL_PERCENT = 25 ; // 75% locked // 75% bloqué
	using SafeMath for uint256;
	//mapping(address => uint256) balances;


// Fields that can be changed by functions // champs qui peuvent être changer par les fonctions
	address[] icedBalances ;
  // mapping (address => bool) icedBalances; //Initial implementation as a mapping // implémentation initiale comme un mapping
	mapping (address => uint256) icedBalances_frosted;
	mapping (address => uint256) icedBalances_defrosted;
	uint256 ownerFrosted;
	uint256 ownerDefrosted;
	uint256	bonus_Percent=35;

	// Variable usefull for verifying that the assignedSupply matches that totalSupply // variable utile pour vérifier que le assignedSupply marche avec le totalSupply
	uint256 public assignedSupply;


	//Boolean to allow or not the initial assignement of token (batch) // Booléen qui autorise ou non le transfert initial de token (par lots)
	
	bool public batchAssignStopped = false;
	
	
	//constructeur de nos Tokens
	function PeculiumToken() {
		owner = msg.sender;
		uint256 amount = MAX_SUPPLY_NBTOKEN;
		uint256 amount2assign = amount * DEFROST_MONTHLY_PERCENT_OWNER/ 100;
                balances[owner]  = amount2assign;
		ownerDefrosted = amount2assign;
		ownerFrosted = amount - amount2assign;
	}
	
	/**
   * @dev Transfer tokens in batches (of adresses)
   * @param _vaddr address The address which you want to send tokens from
   * @param _vamounts address The address which you want to transfer to
*/

	function batchAssignTokens(address[] _vaddr, uint[] _vamounts) onlyOwner {
            require ( batchAssignStopped == false );
            require ( _vaddr.length == _vamounts.length );
            //Looping into input arrays to assign target amount to each given address // boucler sur l'entrée pour assigner la somme cible pour chaque adresse
                 for (uint index=0; index<_vaddr.length; index++) {
                     address toAddress = _vaddr[index];
                     uint amount = _vamounts[index] * 10 ** decimals;
                     //if (balances[toAddress] == 0) {
                        // In case it's filled two times, it only increments once // dans le cas où c'est rempli 2 fois, on incrémente que de 1.
                        // Assigns the balance // On assigne le solde
                        assignedSupply += amount ;
                            balances[toAddress] += amount;
                    //}
            }
    }


//fonction qui change le montant du bonus a modifier  pour que se soit automatique en fonction du temps pour que ca colle au white paper
    function setBonus(uint256 _bonus_Percent) onlyOwner{
            bonus_Percent=_bonus_Percent;
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


	function canDefrost() onlyOwner constant returns (bool bCanDefrost){
		bCanDefrost = now > START_ICO_TIMESTAMP;
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

  function killContract() onlyOwner { // fonction pour stoper le contract définitivement. Tout les ethers présent sur le contract son envoyer sur le compte du propriétaire du contract.
      selfdestruct(owner); // dépense beaucoup moins d'ether que simplement envoyer avec send les ethers au propriétaire car libére de la place sur la blockchain
  }


}
