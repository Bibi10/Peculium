/*
Contract for the airdrop
*/


import "./SafeMath.sol";

import "./Ownable.sol";

import "./Peculium.sol";

pragma solidity ^0.4.8;


contract Airdrop is Ownable{
	using SafeMath for uint256;
	
	uint256 public Airdropsamount;
	uint256 public decimals;
	
	Peculium public pecul;
	bool initPecul;

	event AirdropOne(address airdropaddress,uint256 nbTokenSendAirdrop);
	event AirdropList(address[] airdropListAddress,uint256[] listTokenSendAirdrop);
	event CancelledAirDrop(uint256 Total,uint256 AirdropsamountTotal);
	
	address PeculiumContractAdress;
	
	function Airdrop(){
		Airdropsamount = SafeMath.mul(50000000,(10**8));
		initPecul = false;
	}
	
	function InitPeculiumAdress(address peculAdress) onlyOwner{
		PeculiumContractAdress = peculAdress;
		pecul = Peculium(PeculiumContractAdress);
		decimals = pecul.decimals();
		initPecul = true;
	}
	

	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner Initialize NotEmpty { // need to test the cost, need to optimize
		require (Airdropsamount >0);
		require ( _vaddr.length == _vamounts.length );
		//Looping into input arrays to assign target amount to each given address 
		uint256 amountToSendTotal = 0;
		for (uint256 indexTest=0; indexTest<_vaddr.length; indexTest++) // We first test that we have enough token to send
		{
			amountToSendTotal.add(_vamounts[indexTest].mul(10 ** decimals)); 
		}
		
		require(amountToSendTotal>Airdropsamount); // If no enough token, cancel the sell 
		
		for (uint256 index=0; index<_vaddr.length; index++) {
			address toAddress = _vaddr[index];
			uint256 amountTo_Send = _vamounts[index].mul(10 ** decimals);
		
	                pecul.transfer(toAddress,amountTo_Send); // maybe doesn't work because of owner, need tests
			
			Airdropsamount.sub(amountTo_Send);
			AirdropOne(toAddress,amountTo_Send);
		}
		AirdropList(_vaddr,_vamounts);
	      
		}
	

		modifier NotEmpty {
		require (Airdropsamount>0);
		_;
    		}
    		modifier Initialize {
		require (initPecul==true);
		_;
    	} 

    
    }
