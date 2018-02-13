/*
This Token Contract implements the Peculium token (beta)
.*/


import "./PeculiumOld.sol";

pragma solidity ^0.4.15;


contract Peculium is BurnableToken,Ownable { // Our token is a standard ERC20 Token with burnable and ownable aptitude

	/*Variables about the old token contract */	
	PeculiumOld public peculOld; // The Peculium token
	bool public initPeculOld; // boolean to know if the Peculium token address has been init
	
	event InitializedToken(address contractToken);


	using SafeMath for uint256; // We use safemath to do basic math operation (+,-,*,/)
	using SafeERC20 for ERC20Basic; 

    	/* Public variables of the token for ERC20 compliance */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL"; // token symbol
    	uint256 public decimals = 8; // token number of decimal
    	
    	/* Public variables specific for Peculium */
        uint256 public constant MAX_SUPPLY_NBTOKEN   = 20000000000*10**8; // The max cap is 20 Billion Peculium

	mapping(address => bool) public balancesCanSell; // The boolean variable, to frost the tokens


    	/* Event for the freeze of account */
 	event FrozenFunds(address target, bool frozen);
	event ChangedTokens(address changedTarget,uint256 amountToChanged);


   
	//Constructor
	function Peculium() public {
		totalSupply = MAX_SUPPLY_NBTOKEN;
	}
	
	function InitPeculiumOldAdress(address peculOldAdress) public onlyOwner 
	{ // We init the address of the token
	
		peculOld = PeculiumOld(peculOldAdress);
		initPeculOld = true;
		InitializedToken(peculOldAdress);
	
	}
	
	function UpgradeTokens() public
	{
		require(peculOld.totalSupply()>0);
		require(peculOld.allowance(msg.sender,address(this))>0);
		
		uint256 amountChanged = allowance(msg.sender,address(this));
		peculOld.transferFrom(msg.sender,address(this),amountChanged);
		peculOld.burn(amountChanged);
		balances[msg.sender] = balances[msg.sender] + amountChanged;
		ChangedTokens(msg.sender,amountChanged);
		
	}

	/*** Public Functions of the contract ***/	
				
	function transfer(address _to, uint256 _value) public returns (bool) 
	{ // We overright the transfer function to allow freeze possibility
	
		require(balancesCanSell[msg.sender]==false);
		return BasicToken.transfer(_to,_value);
	
	}
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{ // We overright the transferFrom function to allow freeze possibility (need to allow before)
	
		require(balancesCanSell[msg.sender]==false);	
		return StandardToken.transferFrom(_from,_to,_value);
	
	}

	/***  Owner Functions of the contract ***/	

   	function ChangeLicense(address target, bool canSell) public onlyOwner 
   	{
        
        	balancesCanSell[target] = canSell;
        	FrozenFunds(target, canSell);
    	
    	}


	/*** Others Functions of the contract ***/	
	
	/* Approves and then calls the receiving contract */
	function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);

		require(_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        	return true;
    }

  	function getBlockTimestamp() public constant returns (uint256)
  	{
        
        	return now;
  	
  	}

  	function getOwnerInfos() public constant returns (address ownerAddr, uint256 ownerBalance)  
  	{ // Return info about the public address and balance of the account of the owner of the contract
    	
    		ownerAddr = owner;
		ownerBalance = balanceOf(ownerAddr);
  	
  	}

}
