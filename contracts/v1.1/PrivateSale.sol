/*
Contract for the privateSale of the Peculium campaign

Need to add :
- database access
- end of crowdsale : if goal not raised, refund people
- more security , and tests

*/

import "./Peculium.sol";

pragma solidity ^0.4.15;


contract PrivateSale is Ownable{
	using SafeMath for uint256;
	
	uint256 public PrivateSalesAmount; // Airdrop total amount
	uint256 public decimals; // decimal of the token
	
	Peculium public pecul; // token Peculium
	bool public initPecul; // We need first to init the Peculium Token address


 	// minimum amount of funds to be raised in weis
	uint256 public goal;


	//Boolean to allow or not the sale of tokens
	bool public sales_stopped;	
	
	
	mapping (address => uint256) PrivateSaleEthers; // for now I use a mapping, will be changed with database access
	
	uint256 rate; // 1 ether = 25 000 PCL, maybe to change
	
	event Finalized();
	event Stopsale();
	event Restartsale();
  	
  	event PrivateSalesSale(address receiverToken,uint256 nbTokenSend);
	
	event TakeEther(uint256 nb);
	
	event InitializedToken(address contractToken);
	//Constructor
	function PrivateSale(){
		rate = 25000;
		sales_stopped = false;
		PrivateSalesAmount = 1000000000; // We allocate 1 Billion token for the privatesale (maybe to change) 
		initPecul = false;
	}
	
	
	/***  Functions of the contract ***/
	
	
	function InitPeculiumAdress(address peculAdress) onlyOwner
	{ // We init the Peculium token address
	
		pecul = Peculium(peculAdress);
		decimals = pecul.decimals();
		initPecul = true;
		InitializedToken(peculAdress);
	}
	
	function() payable {
	
		BuyTokens();
	
	}
	
	function BuyTokens() payable NotEmpty Initialize SaleNotStopped{ // do we need to make it internal or not ?
		require(PrivateSaleEthers[msg.sender]>0);
		require(msg.value <= PrivateSaleEthers[msg.sender]); // to replace with database access
		
		uint256 tokenToSend = (msg.value).mul(rate);
		
		require(tokenToSend <= PrivateSalesAmount); 
		
		pecul.transfer(msg.sender,tokenToSend*10**decimals);
		PrivateSaleEthers[msg.sender] = PrivateSaleEthers[msg.sender].sub(msg.value); 
		PrivateSalesAmount = PrivateSalesAmount.sub(tokenToSend);
		PrivateSalesSale(msg.sender,tokenToSend);
		
	}
	
	
	function Send_ether(uint256 nbEther) onlyOwner {
	
		owner.transfer(nbEther * 1 ether);
		TakeEther( nbEther * 1 ether);
	
	}
	
	function Send_All() onlyOwner {
	
		owner.transfer(this.balance);
		TakeEther(this.balance);
	
	}

	function stopSale() onlyOwner
	{
		require ( sales_stopped == false);
		sales_stopped = true;
		Stopsale();
	}
	
	function restartSale() onlyOwner 
	{
      		require ( sales_stopped == true);
      		sales_stopped = false;
      		Restartsale();
	}
	
	/***  Modifiers of the contract ***/

	modifier NotEmpty {
		require (PrivateSalesAmount>0);
		_;
	}
	
	modifier Initialize {
	require (initPecul==true);
	_;
	} 
	
	modifier SaleNotStopped {
        require (!sales_stopped);
        _;
    	}
    
  }











	  
	  
	  
	

