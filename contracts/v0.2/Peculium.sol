pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';

contract Peculium is MintableToken {

    string public name = "Peculium";
    string public symbol = "PCL";
    uint256 public decimals = 15;

}
