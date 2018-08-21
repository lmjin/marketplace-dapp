pragma solidity ^0.4.23;

contract Marketplace {
  address owner;
  // constructor
  constructor () public {
    owner = msg.sender;
  }
}
