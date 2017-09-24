pragma solidity ^0.4.15;
import './StandardToken.sol';
import './Ownable.sol';

contract Peculium is StandardToken,Ownable {

	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;

	uint public NB_TOKEN = 200000000000; // number of token to create
        int256 public constant MAX_SUPPLY_NBTOKEN   = NB_TOKEN*10** decimals;
	// uint256 public constant START_ICO_TIMESTAMP   = 1501595111;
	uint256 public START_ICO_TIMESTAMP   = 1501595111; // not constant for testing 	(overwritten in the constructor) // Non constant pour les tests (reecrit dans le contructeur)
	uint public constant DEFROST_PERIOD           = 6; // month in minutes  (1month = 43200 min) // mois en minutes (1 mois = 43200 minutes)
	uint public constant DEFROST_MONTHLY_PERCENT_OWNER  = 25 ; // 25% per month is automaticaly defrosted // 5% sont automatiquement dégeler
	uint public constant DEFROST_INITIAL_PERCENT_OWNER  = 10 ; // 90% locked // 90% bloqués
	uint public constant DEFROST_MONTHLY_PERCENT  = 10 ; // 10% per month is automaticaly defrosted //  10% par mois sont automatiquement dégeler
	uint public constant DEFROST_INITIAL_PERCENT = 25 ; // 75% locked // 75% bloqué
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
		uint256 amount2assign = amount * DEFROST_INITIAL_PERCENT_OWNER/ 100;
                balances[owner]  = amount2assign;
		ownerDefrosted = amount2assign;
		ownerFrosted = amount - amount2assign;
	}


/**
   * @dev Transfer tokens in batches (of adresses) // Transfer de tokens par lots (d'adresses)
   * @param _vaddr address The address which you want to send tokens from //l'adresse où d'où provienne les tokens que vous allez envoyer
   * @param _vamounts address The address which you want to transfer to // L'adresse d'envoie du transfert
   */
  	function batchAssignTokens(address[] _vaddr, uint[] _vamounts, bool[] _vIcedBalance ) onlyOwner {
			require ( batchAssignStopped == false );
			require ( _vaddr.length == _vamounts.length );
			//Looping into input arrays to assign target amount to each given address // boucler sur l'entrée pour assigner la somme cible pour chaque adresse
      			
			for (uint index=0; index<_vaddr.length; index++) {
			          address toAddress = _vaddr[index];
			          uint amount = _vamounts[index] * 10 ** decimals;
				  bool isIced = _vIcedBalance[index];
			          if (balances[toAddress] == 0) {
						// In case it's filled two times, it only increments once // dans le cas où c'est rempli 2 fois, on incrémente que de 1.
						// Assigns the balance // On assigne le solde
						assignedSupply += amount ;
						if (  isIced  == false ) {
							// Normal account // Compte normal
							balances[toAddress] = amount;
							// TODO allowance ??
						}
						else {
							// Iced account. The balance is not affected here // Compte gelé. Le solde n'est pas affecté ici.
							icedBalances.push(toAddress) ;
							uint256 amount2assign 		  = amount * DEFROST_INITIAL_PERCENT / 100;
							balances[toAddress]               = amount2assign;
							icedBalances_defrosted[toAddress] = amount2assign;
							icedBalances_frosted[toAddress]   = amount - amount2assign;
						}
					}
			}
	}


        //fonction qui change le montant du bonus a modifier  pour que se soit automatique en fonction du temps pour que ca colle au white paper
	function setBonus(_bonus_Percent) onlyOwner{
             bonus_Percent=_bonus_Percent;
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

	
	/ fonction qui retourne le reste pecul de l'emmetteur 
  	function balanceOf(address _owner) constant returns (uint256 balance) {
    		return balances[_owner];
	}


  	function getOwnerInfos() constant returns (address owneraddr, uint256 balance, uint256 frosted, uint256 defrosted)  {
    		owneraddr= owner;
		balance = balances[owneraddr];
		frosted = ownerFrosted;
		defrosted = ownerDefrosted;
  	}


  	function killContract() onlyOwner {
      		suicide(owner);
  	}

}
