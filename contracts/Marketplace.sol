pragma solidity ^0.4.23;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";

/** @dev This is the Marketplace contract
  * Admins, store owners, shoppers interact with contract to maintain and use the Marketplace
  * Ownable, SafeMath, Destructible from openzeppelin

=============================ADMIN FUNCTIONALITY====================================
This is where admin and store owner rights are given and maintained
  */

contract Marketplace is Ownable, Destructible {

  /** @dev declare owner of contract variable
    * declare array of approved store owners
    */
  address owner;
  address[] approvedStoreOwners;

  /** @dev constructor that sets owner to msg.sender upon deployment of contracts
    * msg.sender is also set to an admin in the Marketplace
    */
  constructor () public {
    owner = msg.sender;
    admins[msg.sender] = true;
  }

  /** @dev mapping of addresss to true/false to record whether or not they are admins/store owners
    */
  mapping (address => bool) public admins;
  mapping (address => bool) public storeOwners;

  /** @dev modifiers that require users calling a function to be an admin/store owner on the Marketplace
    */
  modifier isAdmin() {
    require(admins[msg.sender] == true);
    _;
  }

  modifier isStoreOwner() {
    require(storeOwners[msg.sender] == true);
    _;
  }

  event AddedAdmin(address adminAddress);
  event RemovedAdmin(address adminAddress);
  event AddedOwner(address ownerAddress);
  event RemovedOwner(address ownerAddress);

  /** @dev sets a new addresss as an admin and emits event respective to function
    * @notice can only be called by owner of the Marketplace
    * @param newAdmin The address of the new admin
    */
  function addAdmin(address newAdmin) onlyOwner public {
    admins[newAdmin] = true;
    emit AddedAdmin(newAdmin);
  }

  /** @dev turns off admin privileges for a certain addresss and emits event respective to function
    * @param adminAddress The address having admin rights revoked
    * @notice can only be called by owner of Marketplace
    */
  function removeAdmin(address adminAddress) onlyOwner public {
    admins[adminAddress] = false;
    emit RemovedAdmin(adminAddress);
  }

  /** @dev sets a new address as a store owner and emits event respective to function
    * @dev adds address
    * @param ownerAddress The address of new store owner
    * @notice can only be called by an admin
    */
  function addStoreOwner(address ownerAddress) isAdmin public {
    storeOwners[ownerAddress] = true;
    approvedStoreOwners.push(ownerAddress);
    emit AddedOwner(ownerAddress);
  }

  /** @dev revokes store owner privileges and emits event respective to function
    * @param ownerAddress The address of store owner losing privileges
    */
  function removeStoreOwner(address ownerAddress) isAdmin public {
    storeOwners[ownerAddress] = false;
    emit RemovedOwner(ownerAddress);
  }

  /** @dev used to test store owner status
    * @param ownerAddress Address being tested for owner privileges
    * @return true/false
    */
  function checkOwnerStatus(address ownerAddress) constant public returns(bool) {
    return storeOwners[ownerAddress];
  }

  /** @dev used to test Admin status
    * @param adminAddress Address being tested for admin privileges
    * @return true/false
    */
  function checkAdminStatus(address adminAddress) constant public returns(bool) {
    return admins[adminAddress];
  }

/* ====================================MARKETPLACE FUNCTIONALITY =============================
This portion of the contract is related to the user functionality of the Marketplace

SafeMath is used for uint from openzeppelin
storeCount and productCount declared*/

  uint storeCount;
  uint productCount;
  using SafeMath for uint;

  /** @dev struct that stores Storefront data
    * @param sid Storefront ID
    * @param storeName Store Name
    * @param storeOwner Address of Store Owner
    * @param storeBalance Balance the store currently has
    */
  struct Storefront {
    uint sid;
    string storeName;
    address storeOwner;
    uint storeBalance;
  }

  /** @dev struct that stores Product data
    * @param pid Product ID
    * @param productName Product Name
    * @param productQuantity Quantity of the Product
    * @param price Price of the product
    * @param sid Storefront ID of store the Product belongs to
    */
  struct Product {
    uint pid;
    string productName;
    uint productQuantity;
    uint price;
    uint sid;
  }

  // Events related to store functionality
  event StoreFrontAdded(uint sid, string storeName, address storeOwner);
  event ProductAdded(uint pid, string productName, uint price, uint productQuantity, uint sid);
  event ProductRemoved(uint pid,uint sid);
  event ProductPriceChange(uint pid, string productName, uint price);
  event BalanceWithdrawn(uint sid, string storeName, address storeOwner, uint balance);
  event ProductBought(uint pid, uint sid, uint totalPrice, address buyer);

  // Mapping of an array of storefront IDs to their owner address
  mapping (address => uint[]) public storefrontIDsByOwnerAddress;
  // Mapping of storefront IDs to the Storefront struct
  mapping (uint => Storefront) public storefrontByIDs;
  // Mapping of an array of product IDs to the respective storefront ID
  mapping (uint => uint[]) public productListBySIDs;
  // Mapping of an array of product IDs to the Product struct
  mapping (uint => Product) public productByIDs;

  /** @dev modifier that requires msg.sender owns the store
    * @param _sid Storefront ID of store
    */
  modifier ownsStore(uint _sid) {
    require(storefrontByIDs[_sid].storeOwner == msg.sender);
    _;
  }

  /** @dev modifier that requires quantity being bought is available in the store
    * @param _pid Product ID of product being bought
    * @param _quantity Quantity of product being bought
    */
  modifier enoughToSell(uint _pid, uint _quantity) {
    require(productByIDs[_pid].productQuantity >= _quantity);
    _;
  }

  /** @dev modifier that requires msg.valye to be greater than or equal to total price
  * @param _pid Product ID of product being bought
  * @param _quantity Quantity of product being bought
  */
  modifier paidEnough(uint _pid, uint _quantity) {
    uint totalPrice = productByIDs[_pid].price * _quantity;
    require(msg.value >= totalPrice);
    _;
  }

  /** @dev modifier that refunds buyer if too much ether sent
  * @param _pid Product ID of product being bought
  * @param _quantity Quantity of product being bought
  */
  modifier checkValue(uint _pid, uint _quantity) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint totalPrice = productByIDs[_pid].price * _quantity;
    uint amountToRefund = msg.value - totalPrice;
    msg.sender.transfer(amountToRefund);
  }

  /** @dev opens new storefront and can only be called by a store owner
    * @dev
    * @param _storeName Name of the new storefront
    */
  function addStorefront(string _storeName) public isStoreOwner() {
    storeCount++;
    uint sid = storeCount;
    Storefront memory newStorefront = Storefront(sid, _storeName, msg.sender, 0);
    storefrontIDsByOwnerAddress[msg.sender].push(newStorefront.sid);
    storefrontByIDs[sid] = newStorefront;
    emit StoreFrontAdded(sid, _storeName, msg.sender);
  }

  /** @dev gets balance of the storefront and can only be called by the owner of the Storefront
    * @param _sid storefront ID
    * @return Balance of the storefront
    */
  function getStoreBalance(uint _sid) constant public ownsStore(_sid) returns(uint) {
    return storefrontByIDs[_sid].storeBalance;
  }

  /** @dev withdraw balance of storefront and can only be called by owner of the Storefront
    * @param _sid Storefront ID of storefront being withdrawn from
    */
  function withdrawStoreBalance(uint _sid) public ownsStore(_sid) {
    require(storefrontByIDs[_sid].storeBalance > 0);
    storefrontByIDs[_sid].storeBalance = 0;
    msg.sender.transfer(storefrontByIDs[_sid].storeBalance);
    emit BalanceWithdrawn(_sid, storefrontByIDs[_sid].storeName, msg.sender, storefrontByIDs[_sid].storeBalance);

  }

  /** @dev returns all store information
    * @param _sid storefront ID
    * @return sid, store name, store owner, store balance
    */
  function getStore(uint _sid) constant public returns (uint, string, address, uint) {
    return(storefrontByIDs[_sid].sid,
           storefrontByIDs[_sid].storeName,
           storefrontByIDs[_sid].storeOwner,
           storefrontByIDs[_sid].storeBalance);
  }

  /** @dev adds product to storefront, assigns pid to product, and adds product to array of products by storefront
    * @dev can only be called by store owner
    * @param _sid storefront ID
    * @param _productName name of product
    * @param _price price of product
    * @param _productQuantity quantity of product
    */
  function addProduct(uint _sid, string _productName, uint _price, uint _productQuantity) public ownsStore(_sid) {
    productCount++;
    uint pid = productCount;
    Product memory newProduct = Product(pid, _productName, _price, _productQuantity, _sid);
    productByIDs[pid] = newProduct;
    productListBySIDs[_sid].push(pid);
    emit ProductAdded(pid, _productName, _price, _productQuantity, _sid);
  }

  /** @dev removes product from storefront and call only be called by store owener
    * @dev loops through array of products by storefront ID and deletes the one matching product ID
    * @param _sid storefront ID
    * @param _pid product ID
    */
  function removeProduct(uint _sid, uint _pid) public ownsStore(_sid) {
    for(uint index=0; index < productListBySIDs[_sid].length; index++) {
      if(productListBySIDs[_sid][index] == _pid) {
        delete productListBySIDs[_sid][index];
        delete productByIDs[_pid];
        emit ProductRemoved(_pid, _sid);
      }
    }
  }

  /** @dev update price of product based on product ID and can only be called by store owner
    * @param _sid storefront ID
    * @param _pid product ID
    * @param newPrice new price of product
    */
  function updatePrice(uint _sid, uint _pid, uint newPrice) ownsStore(_sid) public {
    productByIDs[_pid].price = newPrice;
    emit ProductPriceChange(_pid, productByIDs[_pid].productName, newPrice);
  }

  /** @dev allow shopper to buy product and uses modifiers to check that quantity is enough, buyer paid enough
            and will be refunded if overpaid
    * @dev store balance is increased and quantity left on storefront is decreased
    * @param _sid storefront ID
    * @param _pid product ID
    * @param _quantity quantity buyer wants
    */
  function buyProduct(uint _sid, uint _pid, uint _quantity)
  public payable
  enoughToSell(_pid, _quantity) paidEnough(_pid, _quantity) checkValue(_pid, _quantity) {
    productByIDs[_pid].productQuantity -= _quantity;
    uint totalPrice = productByIDs[_pid].price.mul(_quantity);
    storefrontByIDs[_sid].storeBalance += totalPrice;
    emit ProductBought(_pid, _sid, totalPrice, msg.sender);
  }

  /** @dev gets all product information
    * @param _pid product ID
    * @return pid, product name, product quantity, price, sid
    */
  function getProduct(uint _pid) constant public returns (uint, string, uint, uint, uint) {
    return (productByIDs[_pid].pid,
            productByIDs[_pid].productName,
            productByIDs[_pid].productQuantity,
            productByIDs[_pid].price,
            productByIDs[_pid].sid);
  }

  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

}
