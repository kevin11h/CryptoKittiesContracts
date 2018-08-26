// insired by article found on medium: https://medium.com/loom-network/how-to-code-your-own-cryptokitties-style-game-on-ethereum-7c8ac86a4eb3
// paraphrased reference: http://ethfiddle.com/09YbyJRfiI
// http://etherscan.io/address/0x06012c8cf97bead5deae237070f9587f8e7a266d#code

pragma solidity ^0.4.11;

/**
 *
 * @title Ownable
 * @dev The Ownable contract has owner address, and provides basic 
 * functions, this simplifies the implementation of "user permissions"
 */
 
contract Ownable {
  address public owner;
  
  /**
   * @dev the Owner contract sets the original `owner` of the contract account
   */
   
  function Ownable() {
    owner = msg.sender;
  }
  
  /**
   * @dev Throws if called by any account other than the owner.
   */
   modifier onlyOwner() {
      require(msg.sender == owner);
      _;
   }
   
}
