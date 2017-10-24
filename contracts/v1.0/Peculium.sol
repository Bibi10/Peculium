/*
This Token Contract implements the Peculium token (beta)
.*/


import "./BurnableToken.sol";
import "./Ownable.sol";

import "./SafeERC20.sol";

pragma solidity ^0.4.8;


contract Peculium is BurnableToken,Ownable {

	using SafeMath for uint256;
	using SafeERC20 for ERC20Basic;

    	/* Public variables of the token */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; 
	
	uint256 public constant INITIAL_PERCENT_PRIVATE_SALE = 5;
	
	uint256 public rate;
	
	uint256 public dateStartContract;
	uint256 public dateDefrost;
	
	uint256 totalwei;
	
	uint256 public Airdropsamount;
	uint256 public amount;
	uint256 public reserveToken;
	uint256 public tokenAvailableForPrivateSale;
	
	//Boolean to allow or not the sale of tokens
	bool public sales_stopped = false;	
	bool public isFinalized = false;
	
	uint256 public tokenAvailableForIco;

	  event NewRate(uint256 rateUpdate);
	  event ReceiveEther(uint256 nbEther);
	  event SendEther(address receiver,uint256 nbEther);
	  
	  event PrivateSalesSale(address receiverToken,uint256 nbTokenSend);
	  
	  event AirdropOne(address airdropaddress,uint256 nbTokenSendAirdrop);
	  event AirdropList(address[] airdropListAddress,uint256[] listTokenSendAirdrop);
	  
	  event Finalized();
	  event Stopsale();
	  event Restartsale();
	  
 	  event FrozenFunds(address target, bool frozen);
    	  event Froze(address msgAdd, bool freeze);
	
	  event CancelledAirDrop(uint256 Total,uint256 AirdropsamountTotal);
	
	  mapping(address => bool) balancesCanSell;
   
	//Constructor
	function Peculium() {

		rate = 30000; // 1 ether = 30000 Peculium
		totalwei = 0;
		totalSupply = MAX_SUPPLY_NBTOKEN;
		amount = totalSupply;
		balances[owner] = amount;
		balancesCanSell[owner] = true; // The owner need to sell token for the private sale and for the preICO, ICO.
		tokenAvailableForPrivateSale = (amount.mul(INITIAL_PERCENT_PRIVATE_SALE)).div(100); 
		Airdropsamount = SafeMath.mul(50000000,(10**8));

		
		dateStartContract=now;
		dateDefrost = dateStartContract + 12 weeks; // everybody can defrost his own token after 4 months

	}
	
	function DefrostToken() public {
		require(now>dateDefrost);
		balancesCanSell[msg.sender]=true;
		Froze(msg.sender,true);
	}
		
	function transfer(address _to, uint256 _value) public returns (bool) {
		require(balancesCanSell[msg.sender]);
		
		return BasicToken.transfer(_to,_value);
	}
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(balancesCanSell[msg.sender]);
		
		return StandardToken.transferFrom(_from,_to,_value);
	
	
	}
	
	function() payable {
		receiveEtherFormOwner();
	}
	
	function receiveEtherFormOwner() payable onlyOwner {
		totalwei.add(msg.value);
		ReceiveEther(msg.value);
			
	}
	
	function sendEtherToOwner(uint256 moneyToSend) onlyOwner {
			uint256 moneyToSendEther = moneyToSend.div(1 ether);
			if(moneyToSendEther > 0.01 ether){
				owner.transfer(moneyToSendEther);
		      		SendEther(owner,moneyToSendEther);				
				}
			}
	
	function sendAllEtherToOwner() onlyOwner {
		uint256 moneyEther = (this.balance).div(1 ether);
		if(moneyEther > 0.01 ether){ // we keep some ether to pay the transaction in gas
		      owner.transfer(this.balance);
		      totalwei.sub(this.balance);
		      SendEther(owner,this.balance);
		      }
		
	}

	function sendTokensPrivateSale(address beneficiary, uint256 amountTo_Send) onlyOwner SaleNotStopped NotEmpty PrivateSale_Fund_NotEmpty
	{
	                    amount.sub(amountTo_Send);
	                    tokenAvailableForPrivateSale.sub(amountTo_Send);
	                    transfer(beneficiary,amountTo_Send);
	                    PrivateSalesSale(beneficiary,amountTo_Send);
	
	}	
	
	function airdropsTokens(address[] _vaddr, uint256[] _vamounts) onlyOwner NotEmpty{
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
		
	                transfer(toAddress,amountTo_Send);
			
	                amount.sub(amountTo_Send);		
			Airdropsamount.sub(amountTo_Send);
			AirdropOne(toAddress,amountTo_Send);
		}
		AirdropList(_vaddr,_vamounts);
	      
	}
	
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

  	function getBlockTimestamp() constant returns (uint256){
        	return now;
  	}


	function stopSale() onlyOwner public{
      		require ( sales_stopped == false);
      		sales_stopped = true;
      		Stopsale();
	}
	
	function restartSale() onlyOwner public{
      		require ( sales_stopped == true);
      		sales_stopped = false;
      		Restartsale();
	}
	
	function changeRage(uint256 newrate) onlyOwner public{
		rate = newrate;
		NewRate(rate);
	}
	
   	function freezeAccount(address target, bool freeze) onlyOwner {
        	balancesCanSell[target] = freeze;
        	FrozenFunds(target, freeze);
    	}

    modifier SaleNotStopped {
        require (!sales_stopped);
        _;
    }
        modifier NotEmpty {
        require (amount>0);
        _;
    }
        modifier PrivateSale_Fund_NotEmpty {
        require (tokenAvailableForPrivateSale > 0);
        _;
    }
    
  	function getOwnerInfos() constant returns (address ownerAddr, uint256 ownerBalance)  {
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	}
	  function finalize() onlyOwner public {
	    require(!isFinalized);
	    require(sales_stopped);

	    Finalized();

	    isFinalized = true;
	  }
	  
   	 function getEtherBalance() constant onlyOwner returns (uint256 balanceQuantity)  {
       	 	balanceQuantity = this.balance;
    		}


	function destroy() onlyOwner { // function to destruct the contract.
		selfdestruct(owner);
 	}
 	function destroyAndSend(address _recipient) onlyOwner public {
    		selfdestruct(_recipient);
	}

}
