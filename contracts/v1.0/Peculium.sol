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
	
	uint256 public dateLaunchContract;
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
	  event Finalized();
	  event Stopsale();
	  event Restartsale();
	  event Finalized();
	
	  mapping(address => bool) balancesCanSell;
    event FrozenFunds(address target, bool frozen);


	//Constructor
	function Peculium() {

		rate = 30000; // 1 ether = 30000 Peculium
		totalwei = 0;
		totalSupply = MAX_SUPPLY_NBTOKEN;
		amount = totalSupply;
		balances[owner] = amount;
		balancesCanSell[owner] = true;
		tokenAvailableForPrivateSale = (amount.mul(INITIAL_PERCENT_PRIVATE_SALE)).div(100); 
		//tokenAvailableForIco = (amount.mul(INITIAL_PERCENT_ICO_TOKEN_TO_ASSIGN)).div(100);
		
		dateLaunchContract=now;
		dateDefrost = dateLaunchContract + 12 weeks;

	}
	
	function DefrostToken() public {
		require(now>dateDefrost);
		balancesCanSell[msg.sender]=true;
	}
		
	function transferToken(address _to,uint256 _value) public {
		require(balancesCanSell[msg.sender]);
		
		transfer(_to,_value);
	}
	function transferTokenFrom(address _from, address _to, uint256 _value) public {
		require(balancesCanSell[msg.sender]);
		
		transferFrom(_from,_to,_value);
	
	
	}
	
	function receiveEtherFormOwner() payable onlyOwner {
		totalwei.add(msg.value);
			
	}
	function sendEtherToOwner() onlyOwner {
		uint256 moneyEther = (this.balance).div(1 ether);
		if(moneyEther > 0.01 ether){
		      owner.transfer(this.balance);
		      totalwei.sub(this.balance);
		      }
	}

	function buyTokens(address beneficiary, uint256 amountTo_Send) onlyOwner SaleNotStopped NotEmpty PrivateSale_Fund_NotEmpty
	{
	                    amount.sub(amountTo_Send);
	                    tokenAvailableForPrivateSale.sub(amountTo_Send);
	                    transferToken(beneficiary,amountTo_Send);
	
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
