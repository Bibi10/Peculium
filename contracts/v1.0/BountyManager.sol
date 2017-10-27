/*
This Token Contract pay the bounty holder of the Peculium campaign
.*/

import "./Peculium.sol";

pragma solidity ^0.4.15;

contract BountyManager is Ownable  {
	using SafeMath for uint256;

	

	
	/*Variables about the token contract */	
	Peculium public pecul; // The Peculium token
	address PeculiumContractAdress; // address of the Peculium token address
	bool initPecul; // boolean to know if the Peculium token address has been init
	
	event InitializedToken(address contractToken);
	
	/*Variables about the bounty manager */
	address bountymanager ; // address of the bounty manager 
	uint256 public bountymanagerShare; // nb token for the bountymanager
	bool First_pay_bountymanager; // boolean to test if the first pay has been send to the bountymanager
	uint256 first_pay; // pourcent of the first pay rate
	uint256 montly_pay; // pourcent of the montly pay rate
	bool bountyInit; // boolean to know if the bounty address has been init
	uint256 payday; // Day when the bounty manager is paid
	uint256 nbMonthsPay; // The montly pay is sent for 6 months

	event InitializedManager(address ManagerAdd);
	event FirstPaySend(uint256 first,address receiver);
	event MonthlyPaySend(uint256 monthPay,address receiverMonthly);
	
	
	//Constructor
	function BountyManager() {
		
		bountymanagerShare = SafeMath.mul(72000000,(10**8)); // we allocate 72 million token to the bounty manager (maybe to change)
		
		first_pay = SafeMath.div(SafeMath.mul(40,bountymanagerShare),100); // first pay is 40%
		montly_pay = SafeMath.div(SafeMath.mul(10,bountymanagerShare),100); // other pay are 10%
		nbMonthsPay = 0;
		
		First_pay_bountymanager=true;
		initPecul = false;
		bountyInit==false;
		

	}
	
	
	/***  Functions of the contract ***/
	
	function InitPeculiumAdress(address peculAdress) onlyOwner 
	{ // We init the address of the token
	
		PeculiumContractAdress = peculAdress;
		pecul = Peculium(PeculiumContractAdress);
		payday = pecul.dateDefrost();
		initPecul = true;
		InitializedToken(PeculiumContractAdress);
	
	}
	
	function change_bounty_manager (address public_key) onlyOwner 
	{ // to change the bounty manager address
	
		bountymanager = public_key;
		bountyInit=true;
		InitializedManager(public_key);
	
	}
	
	function allocateManager() onlyOwner Initialize BountyManagerInit 
	{ // Allocate pecul for the Bounty manager, after this call, the manager can take the token by calling transferFrom 
		
		require(now > payday);
		
		if(First_pay_bountymanager==true)
		{

			pecul.approve(bountymanager,first_pay);
			payday = payday + 4 weeks;
			First_pay_bountymanager==false;
			FirstPaySend(first_pay,bountymanager);
		
		}

		if(First_pay_bountymanager==false && nbMonthsPay < 6)
		{

			pecul.approve(bountymanager,montly_pay);
			payday = payday + 4 weeks;
			nbMonthsPay.add(1);
			MonthlyPaySend(montly_pay,bountymanager);
		
		}
		
	}
		/***  Modifiers of the contract ***/
	
	modifier Initialize { // We need to initialize first the token contract
		require (initPecul==true);
		_;
    	}
    	modifier BountyManagerInit { // We need to initialize first the address of the bountyManager
		require (bountyInit==true);
		_;
    	} 

}

