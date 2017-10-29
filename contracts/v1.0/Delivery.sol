/*
Contract for the airdrop of the Peculium campaign
*/

import "./Peculium.sol";

pragma solidity ^0.4.15;


contract Delivery is Ownable{
	using SafeMath for uint256;
	
	uint256 public Airdropsamount; // Airdrop total amount
	uint256 public decimals; // decimal of the token
	
	Peculium public pecul; // token Peculium
	bool initPecul; // We need first to init the Peculium Token address

	event AirdropOne(address airdropaddress,uint256 nbTokenSendAirdrop); // Event for one airdrop
	event AirdropList(address[] airdropListAddress,uint256[] listTokenSendAirdrop); // Event for all the airdrop
	
	address PeculiumContractAdress; // address of the Peculium Token Contract
	
	//Constructor
	function Delivery(){
	
		Airdropsamount = SafeMath.mul(28000000,(10**8)); // We allocate 28 Millions token for the airdrop (maybe to change) 
		initPecul = false;
	}
	
	
	/***  Functions of the contract ***/
	
	
	function InitPeculiumAdress(address peculAdress) onlyOwner
	{ // We init the Peculium token address
	
		PeculiumContractAdress = peculAdress;
		pecul = Peculium(PeculiumContractAdress);
		decimals = pecul.decimals();
		initPecul = true;
		
	}
	

	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner Initialize NotEmpty 
	{ 
		
		require (Airdropsamount >0);
		require ( _vaddr.length == _vamounts.length );
		//Looping into input arrays to assign target amount to each given address 
		uint256 amountToSendTotal = 0;
		
		for (uint256 indexTest=0; indexTest<_vaddr.length; indexTest++) // We first test that we have enough token to send
		{
		
			amountToSendTotal.add(_vamounts[indexTest].mul(10 ** decimals)); 
		
		}
		
		require(amountToSendTotal<=Airdropsamount); // If no enough token, cancel the sell 
		
		for (uint256 index=0; index<_vaddr.length; index++) 
		{
			
			address toAddress = _vaddr[index];
			uint256 amountTo_Send = _vamounts[index].mul(10 ** decimals);
		
	                pecul.transfer(toAddress,amountTo_Send);
			
			Airdropsamount.sub(amountTo_Send);
			AirdropOne(toAddress,amountTo_Send);
			
		}
			
		AirdropList(_vaddr,_vamounts);
	      
	}
	
	/***  Modifiers of the contract ***/

	modifier NotEmpty {
		require (Airdropsamount>0);
		_;
	}
	
	modifier Initialize {
	require (initPecul==true);
	_;
	} 

    
    }
