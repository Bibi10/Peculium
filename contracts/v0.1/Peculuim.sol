pragma solidity ^0.4.15;
import './StandardToken.sol';
import './Ownable.sol';

contract Peculium is StandardToken,Ownable {
string public name = "PeculiumToken"; //token name 
string public constant symbol    = "PCL";
uint256 public constant decimals = 8;

uint public INITIAL_SUPPLY = 20 000 000 000; /* number of token to create : (mohamed: j'ai changé le nombre pour mettre 20 milliard) */
using SafeMath for uint256;
mapping(address => uint256) balances;


  event Mint(address indexed to, uint256 amount); // event qui signale une création supplémentaire de token sur le réseau
  event MintFinished(); // Event qui signale si l'ajout de token est encore possible

  bool public mintingFinished = false; // booléen pour savoir si l'ajout de token est encore possible


  modifier canMint() { // modifie la fonction canMint.
    require(!mintingFinished);
    _;


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

  function killContract() onlyOwner { // fonction pour stoper le contract définitivement. Tout les ethers présent sur le contract son envoyer sur le compte du propriétaire du contract.
      suicide(owner);
  }
  
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) { // Seul le propriétaire du smart contract peut ajouter des tokens
    totalSupply = totalSupply.add(_amount); // on ajoute une quantité de token au montant total
    balances[_to] = balances[_to].add(_amount); // On envoie ces token sur une adresse
    Mint(_to, _amount); // appel de l'event mint
    Transfer(0x0, _to, _amount); // appel de l'event transfert
    return true;
  }

  /**
   * @dev Function to stop minting new tokens. // Fonction pour stopper l'ajout de token
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) { // Seul le propriétaire peut stopper l'ajout de token
    mintingFinished = true;
    MintFinished(); // appel de l'event MintFinished
    return true;
  }


}
