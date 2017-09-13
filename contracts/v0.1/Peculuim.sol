pragma solidity ^0.4.15;
import './StandardToken.sol';
import './Ownable.sol';

contract Peculium is StandardToken,Ownable {
string public name = "PeculiumToken"; //token name 
uint public INITIAL_SUPPLY = 10000; // number of token to create
using SafeMath for uint256;
mapping(address => uint256) balances;
function PeculiumToken() {// constructor initialisation 
totalSupply = INITIAL_SUPPLY;
balances[msg.sender] = INITIAL_SUPPLY;
}
// fonction sert a transmettre de pecul
function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
}
// fonction qui retourne le reste pecul de l'emmetteur 
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
}
}
