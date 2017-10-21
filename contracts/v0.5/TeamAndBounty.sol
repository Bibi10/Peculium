/*
This Token Contract implements the Peculium token (beta)
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract TeamAndBounty  is MintableToken{
	uint256 public START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public START_ICO_TIMESTAMP=START_PRE_ICO_TIMESTAMP+ 10* 1 days ;
	uint256 public END_ICO_TIMESTAMP   =1514764800; //end date of ICO 
	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	using SafeMath for uint256;
	uint256 public teamShare; //token for the dev team
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public bountyFinal;
	uint256 public dateOfPayment_TimeStamp;
	uint256 public constant END_PAYMENTE_TIMESTAMP=1533074400;
	uint256 public Airdropsamount;
	uint256 public beginICOdate;	
	uint256 amount;
	
	//Constructor
	function TeamAndBounty(uint256 _amount) {
		amount=_amount;
		teamShare=amount*12/100;
		bountyShare=amount*3/100-Airdropsamount;
		bountymanagerShare = 72000000*10**8; // we allocate 72 million token to the bounty manager
		bountyFinal= bountyShare - bountymanagerShare;
		dateOfPayment_TimeStamp=END_ICO_TIMESTAMP;
	}





        
	

	address bountymanager ; // public key of the bounty manager 
	
	function change_bounty_manager (address public_key) onlyOwner{ // to change the bounty manager
		bountymanager = public_key;
	}
	
	bool First_pay_bountymanager=true;
	uint256 first_pay = 40*bountymanagerShare/100;
	uint256 montly_pay = 10*bountymanagerShare/100;
	function payBounty() { // to pay the bountymanager
		
		if(msg.sender==bountymanager ){ 
			if((First_pay_bountymanager==true) && (now > END_ICO_TIMESTAMP)){ 
			balances[msg.sender] += first_pay; // The first payment is 40% of the total money due to the bounty manager
			bountymanagerShare -= first_pay;
			First_pay_bountymanager = false;
			uint256 pay_day = END_ICO_TIMESTAMP + 30 * 1 days;
			}
			else if( (First_pay_bountymanager==false) && (now > pay_day)){
			balances[msg.sender] += montly_pay; // Every month , the bounty manager receive 10% of the total money due to him.
			bountymanagerShare -= montly_pay;
			pay_day = pay_day + 30 * 1 days; // Can only be called once a month		
			
			}
		}
	
	
	}

	function teamPayment(address teamaddr) onlyOwner{
		if(now>dateOfPayment_TimeStamp && now< END_PAYMENTE_TIMESTAMP){
			uint256 wages=teamShare*10/100;
		    	if(dateOfPayment_TimeStamp<END_ICO_TIMESTAMP+ 30 * 1 days){
		     		wages=teamShare*40/100;
				dateOfPayment_TimeStamp+=30*1 days; //second payement two months from the first one.
		     	}
                     	balances[teamaddr]+=wages;
		     	dateOfPayment_TimeStamp+=30*1 days;

		}
	}
}
