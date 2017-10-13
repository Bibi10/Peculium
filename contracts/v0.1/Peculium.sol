/*
This Token Contract implements the Peculium token (beta)
.*/

import "./MintableToken.sol";

pragma solidity ^0.4.8;

contract Peculium is MintableToken {

    /* Public variables of the token */
	string public name = "Peculium"; //token name 
    	string public symbol = "PCL";
    	uint256 public decimals = 8;
}
