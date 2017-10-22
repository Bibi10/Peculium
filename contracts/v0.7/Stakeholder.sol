/*
This Token Contract pay the stakeholder
.*/


import "./Ownable.sol";
import "./StandardToken.sol";
pragma solidity ^0.4.8;

contract Stakeholder is StandardToken,Ownable {
	using SafeMath for uint256;
	uint256 public START_PRE_ICO_TIMESTAMP   =1509494400; //start date of PRE_ICO 
        uint256 public START_ICO_TIMESTAMP=(START_PRE_ICO_TIMESTAMP).add( SafeMath.mul(10, 1 days)) ;

	uint256 public constant INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN = 25 ; 
	uint256 public constant END_PAYMENTE_TIMESTAMP=1533074400;
	uint256 public END_ICO_TIMESTAMP   =1514764800;
	uint256 public stakeholderShare; //token for the stakeholder
	uint256 public dateOfPayment_TimeStamp;

	
	//Constructor
	function Stakeholder(uint256 amount) {
		stakeholderShare=amount;
	}
	

    /* 
	function for paying wages of our stakeholder from the end of ico to six months after the end
	first payement= 40% of stakeholderShare 
	then six payments of 10% of stakeholderShare

*/
	function stakeholderPayment(address stakeholderaddr) onlyOwner{
		if(now>dateOfPayment_TimeStamp && now< END_PAYMENTE_TIMESTAMP){
			uint256 wages=(stakeholderShare.mul(10)).div(100);
		    	if(dateOfPayment_TimeStamp< (END_ICO_TIMESTAMP).add(SafeMath.mul(30,1 days))){
		     		wages=(stakeholderShare.mul(40)).div(100);
				dateOfPayment_TimeStamp.add(SafeMath.mul(60,1 days)); //second payement two months from the first one.
		     	}
                     	balances[stakeholderaddr].add(wages);
		     	dateOfPayment_TimeStamp.add(SafeMath.mul(30,1 days));
		}
	}
}
