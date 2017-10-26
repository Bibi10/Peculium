/*
This Token Contract pay the bounty holder and the airdrop
.*/
import "./SafeMath.sol";
import "./Ownable.sol";

import "./Peculium.sol";

pragma solidity ^0.4.8;

contract BountyManager is Ownable  {
	using SafeMath for uint256;
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public bountyRemaining;

	bool First_pay_bountymanager;
	
	bool initPecul;
	bool bountyInit;
	uint256 first_pay;
	uint256 montly_pay;
	
	uint256 payday;
	
	Peculium public pecul;

	address bountymanager ; // public key of the bounty manager 
	
	address PeculiumContractAdress;
//contract_address.call(bytes4(sha3("function_name(types)")),parameters_values) To call a contract


	//Constructor
	function BountyManager() {
		bountymanagerShare = SafeMath.mul(72000000,(10**8)); // we allocate 72 million token to the bounty manager
		first_pay = SafeMath.div(SafeMath.mul(40,bountymanagerShare),100);
		montly_pay = SafeMath.div(SafeMath.mul(10,bountymanagerShare),100);
		First_pay_bountymanager=true;
		initPecul = false;
		bountyInit==false;
		

	}
	
	function InitPeculiumAdress(address peculAdress) onlyOwner{
		PeculiumContractAdress = peculAdress;
		pecul = Peculium(PeculiumContractAdress);
		payday = pecul.dateDefrost();
		initPecul = true;
	}
	
	function change_bounty_manager (address public_key) onlyOwner{ // to change the bounty manager
		bountymanager = public_key;
		bountyInit=true;
	}
	
	function allocateManager() onlyOwner Initialize BountyManagerInit { // Allocate pecul for the Bounty manager, after this call, the manager can take the token by calling transferFrom 
		require(now > payday);
		if(First_pay_bountymanager==true)
		{

		
		pecul.approve(bountymanager,first_pay);
		
		payday = payday + 4 weeks;
		First_pay_bountymanager==false;
		}
		if(First_pay_bountymanager==false)
		{
		pecul.approve(bountymanager,montly_pay);

		payday = payday + 4 weeks;
		
		}
		
	}
	
	modifier Initialize {
		require (initPecul==true);
		_;
    	}
    	modifier BountyManagerInit {
		require (bountyInit==true);
		_;
    	} 

}

