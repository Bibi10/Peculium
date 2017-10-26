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

	uint256 public dateStartContract;
	uint256 public dateDefrost;
	
	
	uint256 public amount;

 	event FrozenFunds(address target, bool frozen);
    	 
     	event Froze(address msgAdd, bool freeze);
	

	mapping(address => bool) balancesCanSell;
   
	//Constructor
	function Peculium() {
		totalSupply = MAX_SUPPLY_NBTOKEN;
		amount = totalSupply;
		balances[owner] = amount;
		balancesCanSell[owner] = true; // The owner need to sell token for the private sale and for the preICO, ICO.
		
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


   	function freezeAccount(address target, bool freeze) onlyOwner {
        	balancesCanSell[target] = freeze;
        	FrozenFunds(target, freeze);
    	}

  	function getOwnerInfos() constant returns (address ownerAddr, uint256 ownerBalance)  {
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	}

}
