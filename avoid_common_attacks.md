#Common Attacks
1. Reentrancy
- in withdrawStoreBalance: store balance is set to 0 before transferring funds to the store owner

2. Overflow/underflow
- SafeMath is used when calculating total price when buying a product
- uint is used so there is a smaller chance of overflow/underflow
- for future improvements, implement SafeMath in more places and look into not just using uint256 to save on space 

3. Deprecated code
- using .transfer() over .send()
- using selfdestruct over suicide

4. No external calls 

5. Lock pragmas to specific compiler version
  - used ^0.4.23
  
  
