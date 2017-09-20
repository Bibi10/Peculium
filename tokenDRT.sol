pragma solidity ^0.4.11;

import "./StandardToken.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

// This is just a simple example of a coin-like contract. Ceci est juste un simple exemple d'un contrat de type création de token.
// It is not standards compatible and cannot be expected to talk to other. Il n'est pas compatible avec les standards et ne peux pas communiquer avec // les autres contracts de token.
// coin/token contracts. If you want to create a standards-compliant . Si vous voulez creer votre contract qui respecte les standards,
// token, see: https://github.com/ConsenSys/Tokens. Cheers! // regarder  https://github.com/ConsenSys/Tokens

contract DRTCoin is StandardToken, Ownable {

	/* Overriding some ERC20 variables */ // Reecriture de certaines variables ERC20
	string public constant name      = "DomRaider Coin";
	string public constant symbol    = "DRT";
	uint256 public constant decimals = 8;
	/* DRT specific variables */ // variables specifiques pour DRT
	// Max amount of tokens minted - Exact value inputed avec strech goals and before deploying contract
	uint256 public constant MAX_SUPPLY_NBTOKEN    = 1000000000 * 10 ** decimals; // Maximum de token qui peuvent être creer. Valeur exacte.
	// Freeze duration for advisors accounts // Durée du gel pour les comptes de token des gérants.
	// uint256 public constant START_ICO_TIMESTAMP   = 1501595111;
	uint256 public START_ICO_TIMESTAMP   = 1501595111; // not constant for testing (overwritten in the constructor) // Non constant pour les tests (reecrit dans le contructeur)
	uint public constant DEFROST_PERIOD           = 6; // month in minutes  (1month = 43200 min) // mois en minutes (1 mois = 43200 minutes)
	uint public constant DEFROST_MONTHLY_PERCENT_OWNER  = 5 ; // 5% per month is automaticaly defrosted // 5% sont automatiquement dégeler
	uint public constant DEFROST_INITIAL_PERCENT_OWNER  = 10 ; // 90% locked // 90% bloqués
	uint public constant DEFROST_MONTHLY_PERCENT  = 10 ; // 10% per month is automaticaly defrosted //  10% par mois sont automatiquement dégeler
	uint public constant DEFROST_INITIAL_PERCENT  = 20 ; // 80% locked // 80% bloqué

	// Fields that can be changed by functions // champs qui peuvent être changer par les fonctions
	address[] icedBalances ;
  // mapping (address => bool) icedBalances; //Initial implementation as a mapping // implémentation initiale comme un mapping
	mapping (address => uint256) icedBalances_frosted;
	mapping (address => uint256) icedBalances_defrosted;
	uint256 ownerFrosted;
	uint256 ownerDefrosted;

	// Variable usefull for verifying that the assignedSupply matches that totalSupply // variable utile pour vérifier que le assignedSupply marche avec le totalSupply
	uint256 public assignedSupply;
	//Boolean to allow or not the initial assignement of token (batch) // Booléen qui autorise ou non le transfert initial de token (par lots)
	bool public batchAssignStopped = false;

	/**
	* @dev Contructor that gives msg.sender all of existing tokens. // Contructeur qui donne msg.sender tout les token créer
	*/
	function DRTCoin() {
		owner                = msg.sender;
		uint256 amount       = MAX_SUPPLY_NBTOKEN / 2;
		uint256 amount2assign = amount * DEFROST_INITIAL_PERCENT_OWNER / 100;
		balances[owner]  = amount2assign;
		ownerDefrosted = amount2assign;
		ownerFrosted   = amount - amount2assign;

		totalSupply          = MAX_SUPPLY_NBTOKEN;
		assignedSupply       = MAX_SUPPLY_NBTOKEN / 2;
		// for test only: set START_ICO to contract creation timestamp // Pour le test seulement : mettre START_ICO comme date de la création du contract
		// +600 => add 10 minutes (so defrost start 10 min later, too) // ajout de 10 minutes (le dégel commence 10 minutes plus tard également)
		START_ICO_TIMESTAMP = now + 600;
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

  function canDefrost() onlyOwner constant returns (bool bCanDefrost){
		bCanDefrost = now > START_ICO_TIMESTAMP;
  }


  function getBlockTimestamp() constant returns (uint256){
        return now;
  }


	/**
   	* @dev Defrost token (for advisors)
	 Method called by the owner once per defrost period (1 month) // Méthode appelé par le propriétaire par période de dégel
   	*/
	function defrostToken() onlyOwner {

		require(now > START_ICO_TIMESTAMP) ;
		// Looping into the iced accounts // Boucle sur les comptes gelés
		for (uint index=0; index<icedBalances.length; index++) {
			address currentAddress  = icedBalances[index];
			uint256 amountTotal     = icedBalances_frosted[currentAddress]+ icedBalances_defrosted[currentAddress];
			//uint256 amountToRelease = amountTotal * DEFROST_MONTHLY_PERCENT / 100;
			uint256 targetDeFrosted = (SafeMath.minimum(100,DEFROST_INITIAL_PERCENT + elapedMonthsFromICOStart()*DEFROST_MONTHLY_PERCENT)) * amountTotal / 100;
			uint256 amountToRelease = targetDeFrosted - icedBalances_defrosted[currentAddress];
			if ( amountToRelease > 0 ) {
				icedBalances_frosted[currentAddress]   = icedBalances_frosted[currentAddress] - amountToRelease;
				icedBalances_defrosted[currentAddress] = icedBalances_defrosted[currentAddress] + amountToRelease;
				balances[currentAddress]               = balances[currentAddress] + amountToRelease;
			}
		}

	}

 	function defrostOwner() onlyOwner {
		if(now<START_ICO_TIMESTAMP){
			return;
		}

		uint256 amountTotal     = ownerFrosted + ownerDefrosted;
		uint256 targetDeFrosted = (SafeMath.minimum(100,DEFROST_INITIAL_PERCENT_OWNER + elapedMonthsFromICOStart()*DEFROST_MONTHLY_PERCENT_OWNER)) * amountTotal / 100;
		uint256 amountToRelease = targetDeFrosted - ownerDefrosted;
		if ( amountToRelease > 0 ) {
			ownerFrosted   = ownerFrosted - amountToRelease;
			ownerDefrosted = ownerDefrosted + amountToRelease;
			balances[owner]               = balances[owner] + amountToRelease;
		}
	}


	function elapedMonthsFromICOStart() constant returns (uint elapsed) {
		elapsed = ((now-START_ICO_TIMESTAMP)/60)/DEFROST_PERIOD ;
	}

  function stopBatchAssign() onlyOwner {
      	require ( batchAssignStopped == false);
      	batchAssignStopped = true;
  }

  function getAddressBalance(address addr) constant returns (uint256 balance)  {
      	balance = balances[addr];
  }

  function getAddressAndBalance(address addr) constant returns (address _address, uint256 _amount)  {
	_address = addr;
      	_amount = balances[addr];
  }

  function getIcedAddresses() constant returns (address[] vaddr)  {
      	vaddr = icedBalances;
  }

  function getIcedInfos(address addr) constant returns (address icedaddr, uint256 balance, uint256 frosted, uint256 defrosted)  {
    	icedaddr = addr;
	balance = balances[addr];
	frosted = icedBalances_frosted[addr];
	defrosted = icedBalances_defrosted[addr];
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

	/*
  modifier max_num_token_not_reached(uint amount) {
        assert(safeAdd(totalSupply, amount) <= MAX_SUPPLY_NBTOKEN);
        _;
  }
	*/

}
