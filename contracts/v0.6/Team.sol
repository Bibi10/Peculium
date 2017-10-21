/*
This Token Contract implements the Peculium token (beta)
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Team is MintableToken  {
	uint256 public START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public START_ICO_TIMESTAMP=START_PRE_ICO_TIMESTAMP+ 10* 1 days ;

	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	uint256 public constant END_PAYMENTE_TIMESTAMP=1533074400;
	uint256 public END_ICO_TIMESTAMP   =1514764800;
	using SafeMath for uint256;
	uint256 public teamShare; //token for the dev team
	uint256 public bountyShare;
	uint256 public bountymanagerShare;
	uint256 public bountyFinal;
	uint256 public dateOfPayment_TimeStamp;
	uint256 public Airdropsamount;
	uint256 public beginICOdate;	
	
	//Constructor
	function Team(uint256 amount) {
		teamShare=amount;
	}


    
	function teamPayment(address teamaddr) onlyOwner{
		if(now>dateOfPayment_TimeStamp && now< END_PAYMENTE_TIMESTAMP){
			uint256 wages=teamShare*10/100;
		    	if(dateOfPayment_TimeStamp<END_ICO_TIMESTAMP+ 30 * 1 days){
		     		wages=teamShare*40/100;
				dateOfPayment_TimeStamp+=60*1 days; //second payement two months from the first one.
		     	}
                     	balances[teamaddr]+=wages;
		     	dateOfPayment_TimeStamp+=30*1 days;
		}
	}
}
