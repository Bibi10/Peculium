/*
Contract for the privateSale of the Peculium campaign

Need to add :
- database access
- end of crowdsale : if goal not raised, refund people
- more security , and tests

*/

import "./Peculium.sol";
import "./RefundVault.sol";



pragma solidity ^0.4.15;


contract PrivateSale is Ownable{
	using SafeMath for uint256;
	
	uint256 public privateSalesAmount; // Airdrop total amount
	uint256 public decimals; // decimal of the token
	
	Peculium public pecul; // token Peculium
	bool public initPecul; // We need first to init the Peculium Token address
  	bool public initPrivate;

 	// minimum amount of funds to be raised in weis
	uint256 public goal;

	mapping (address => uint256) privateSaleEthers; // for now I use a mapping
	
	uint256 rate; // 1 ether = 25 000 PCL, maybe to change
	
	// start and end timestamps where investments are allowed (both inclusive)
 	uint256 public startTime;
  	uint256 public endTime;

	  // address where funds are collected
	  address public wallet;
 	 // amount of raised money in wei
  	uint256 public weiRaised;
	
	// refund vault used to hold funds while crowdsale is running
  	RefundVault public vault;

  	bool public isFinalized = false;

	event Finalized();

  	event PrivateSalesSale(address receiverToken,uint256 nbTokenSend);
	
	event InitializedToken(address contractToken);
	
	event InitializedSale();
	//Constructor
	function PrivateSale(){
		rate = 25000;
		privateSalesAmount = 1000000000; // We allocate 1 Billion token for the privatesale (maybe to change) 
		initPecul = false;
		initPrivate = false;
		startTime = now; // to change
    		endTime = startTime + 10 days; //investors have 10 days to confirm their transactions
    		wallet = owner;
    		
    		goal = 300000 ether;
		
		vault = new RefundVault(wallet);


	}
	
	
	/***  Functions of the contract ***/
	
	
	function initPeculiumAdress(address peculAdress) onlyOwner
	{ // We init the Peculium token address
	
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
	}
	
	function initPrivateSale(address[] _vaddr, uint256[] _vamounts) onlyOwner Initialize NotEmpty 
	{ // We use this function to initialise the list of the private sale investors
	
		require ( _vaddr.length == _vamounts.length );
		for (uint256 indexTest=0; indexTest<_vaddr.length; indexTest++) 
		{
		privateSaleEthers[_vaddr[indexTest]] = _vamounts[indexTest];
		}
		initPecul = true;
		InitializedSale();
	}
	
	function() payable {
	
		buyTokens(msg.sender);
	
	}
	
	function buyTokens(address beneficiary) payable NotEmpty Initialize InitializeSale SaleNotStopped{ // do we need to make it internal or not ?
	    	require(beneficiary != address(0));
    		require(now >= startTime && now <= endTime);
    		require(msg.value != 0); // In fact more, to determine


		require(privateSaleEthers[msg.sender]>0);
		require(msg.value <= privateSaleEthers[msg.sender]); // to replace with database access
		
		uint256 tokenToSend = (msg.value).mul(rate);
		
		require(tokenToSend <= privateSalesAmount); 
		weiRaised = weiRaised.add(msg.value);

		pecul.transfer(msg.sender,tokenToSend*10**decimals);
		privateSaleEthers[msg.sender] = privateSaleEthers[msg.sender].sub(msg.value); 
		privateSalesAmount = privateSalesAmount.sub(tokenToSend);
		PrivateSalesSale(msg.sender,tokenToSend);
		
		forwardFunds();

	}
	
	function forwardFunds() internal 
	{
    		vault.deposit.value(msg.value*9/10)(msg.sender);
    		wallet.transfer(msg.value/10);
  	}


	  // if crowdsale is unsuccessful, investors can claim refunds here
	  function claimRefund() public {
	    require(isFinalized);
	    require(!goalReached());

	    vault.refund(msg.sender);
	  }
	



	 function goalReached() public constant returns (bool) 
	 { // Return true if the goal of the crowdsale has been reached (goal in ether)
	 
    		return (weiRaised / 1 ether) >= goal;
  	 
  	 }

	 function finalize() onlyOwner public 
	 {
	
		    require(!isFinalized);
		    require(now > endTime);

		    finalization();
		    Finalized();

		    isFinalized = true;
	  
	  }

  // vault finalization task, called when owner calls finalize()

	  function finalization() internal 
	  {
	  
	    if (goalReached()) {
	      vault.close();
	    } else {
	      vault.enableRefunds();
	    }

	  }

	
	
	/***  Modifiers of the contract ***/

	modifier NotEmpty {
		require (privateSalesAmount>0);
		_;
	}
	
	modifier Initialize {
	require (initPecul==true);
	_;
	} 
	
	modifier InitializeSale {
	require (initPrivate==true);
	_;
	
	} 
	modifier SaleNotStopped {
        require (!isFinalized);
        _;
    	}
    	
    	
    
  }











	  
	  
	  
	

