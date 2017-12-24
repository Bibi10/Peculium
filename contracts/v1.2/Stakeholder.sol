/*
This Token Contract pay the holder and the team
.*/



import "./Peculium.sol";
pragma solidity ^0.4.15;

contract Stakeholder is Ownable {
	using SafeMath for uint256;


	Peculium public pecul; // token Peculium
	uint256 public decimals; // decimal of the token
	bool public initPecul; // We need first to init the Peculium Token address
	
	
	uint256 amountStakeHolder;
	
	enum PaymentMode { First, Second }
	
	  struct Member
	{
	   bytes32 name;
	   address eth_address;
	   uint256 amount;
	   uint256 nb_payment;
	   PaymentMode pay_system;
	   uint256 nb_payment;
	   bool approval;
	}
	
	Member[] members;
	
	event InitializedToken(address contractToken);	
		
	//Constructor
	function Stakeholder(uint256 amountShared) {
		amountStakeHolder = amountShared;
		
		Member Mohamed = Member(mohamed,Ox1,10,First,0,true) //added by hand
		
		members.push(Mohamed) // added by hand
	}
	
	function InitPeculiumAdress(address peculAdress) onlyOwner
	{ // We init the Peculium token address
	
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
		uint256 pay_day = now;
		
	}

	function Change_approvePay(address eth_No_Approve,bool choice) onlyOwner
	{
		for(uint256 i=0; i<members.size;i++)
		{
			if(members[i].eth_address==eth_No_Approve)
			{
				members[i].approval = choise;
			}
		}
	}
	
	function Pay() onlyOwner
	{
	
		for(uint256 i=0; i<members.size;i++)
		{
			require(pay_day<now);
			sendPayment(members[i]);
		}
		pay_day = now;
	}

	
	function sendPayment(Member holder) internal
	{
		require(holder.approval==true);
		if(holder.pay_system==First)
		{
			sendPayment_First(holder);
		}
		else if(holder.pay_system==Second)
		{
			sendPayment_Second(holder);
		}
	}
	
	function sendPayment_First(Member holder) internal
	{
		if(holder.nb_payment==0)
		{
		
		first_amount = (40*holder.amount).div(100);
		pecul.transfer(holder.eth_address,first_amount)
		 
		}
		else if(holder.nb_payment>0 && holder.nb_payment<6)
		{
		
		month_amount = (10*holder.amount).div(100);
		pecul.transfer(holder.eth_address,month_amount)
		
		}
	
	
	holder.nb_payment = holder.nb_payment + 1;
	}
	
	function sendPayment_Second(Member holder) internal
	{
		if( holder.nb_payment<6)
		{
		
		month_amount = (8.5*holder.amount).div(100);
		pecul.transfer(holder.eth_address,month_amount)
		
		}
		
		if(holder.nb_payment==5)
		{
		bonus_amount = (10*holder.amount).div(100);
		pecul.transfer(holder.eth_address,bonus_amount)
		}
	
	
	holder.nb_payment = holder.nb_payment + 1;
	}


