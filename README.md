# marketplace-dapp
There are a list of stores on a central marketplace where shoppers can purchase goods posted by the store owners.
 
The central marketplace is managed by a group of administrators. Admins allow store owners to add stores to the marketplace. Store owners can manage their store’s inventory and funds. Shoppers can visit stores and purchase goods that are in stock using cryptocurrency. 
 
User Stories:
An administrator opens the web app. The web app reads the address and identifies that the user is an admin, showing them admin only functions, such as managing store owners. An admin adds an address to the list of approved store owners, so if the owner of that address logs into the app, they have access to the store owner functions.
 
An approved store owner logs into the app. The web app recognizes their address and identifies them as a store owner. They are shown the store owner functions. They can create a new storefront that will be displayed on the marketplace. They can also see the storefronts that they have already created. They can click on a storefront to manage it. They can add/remove products to the storefront or change any of the products’ prices. They can also withdraw any funds that the store has collected from sales.
 
A shopper logs into the app. The web app does not recognize their address so they are shown the generic shopper application. From the main page they can browse all of the storefronts that have been created in the marketplace. Clicking on a storefront will take them to a product page. They can see a list of products offered by the store, including their price and quantity. Shoppers can purchase a product, which will debit their account and send it to the store. The quantity of the item in the store’s inventory will be reduced by the appropriate amount.

## How to Set Up
-Truffle (npm install -g truffle)
-Ganache CLI (npm install -g ganache-cli)
-MetaMask

1. Make a new folder
2. Clone this repository
3. Run ganache-cli in terminal
4. Open another terminal, navigate to root directory of the project and run 'truffle compile' and 'truffle migrate'
5. To test run 'truffle test'
6. To run UI run, take mnemonic seed phrase and create account in meta mask (running on localhost:8545), and run 'npm run dev' in terminal

## Project Requirements
  - Truffle project
  - Smart contract commented by specs
  - At least 5 passing tests with explanations
  - Development to serve front end**
  - design_patterns.md
  - avoid_common attacks.md
  - implement a library - used openzeppelin (SafeMath, Ownable, Destructible)

## Disclaimer 
- UI attempted but is not functional with application
   - UI still deploys but metamask does not interact with it
   - please send me an email if you can explain why the code isn't working (i'm very new to front end development)  
- don't use git push -f
