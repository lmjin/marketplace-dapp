#Design Patterns
1. Fail early and fail loud
  - used require instead of if statements through Marketplace.sol
  - wrote modifiers to test specific requirements before running the function
  - prevents unnecessary code from running if require statement is not met

2. Restricting access
  - used modifiers to restrict access to certain functions
    - store owner functionality
    - admin functionality
    - enough ether sent and quantity enough for buy product
    - future improvements, look at changing functions from public to private
    
3. Mortal
  - openzeppelin Destructible is used
  - allows ownwer of the contrac to selfdestruct function
  - future improvements, implement a circuit breaker such as the Pausible.sol from openzeppelin
