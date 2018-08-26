var Marketplace = artifacts.require('Marketplace')

contract('Marketplace', function (accounts) {
  const owner = accounts[0]
  const storeOwner = accounts[1]
  const shopper = accounts[2]

  var marketplaceInstance

  it("should initialize with the deployer as an admin", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      assert(instance.checkAdminStatus(owner), true, "owner is not an admin")
    })
  })

  it("should allow admin to add new store owner", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.addStoreOwner(storeOwner, {from: owner})
    }).then(function() {
      assert(marketplaceInstance.checkOwnerStatus(storeOwner), true, "store owner is not a store owner");
    })
  })

  it("should allow store owner to create new storefront", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.addStorefront('New Store', {from: storeOwner})
    }).then(function(storefrontByIDs) {
      return marketplaceInstance.storefrontByIDs(1)
    }).then(function(storefrontByIDs) {
      assert(storefrontByIDs[0], '1', "sid is not 1")
      assert(storefrontByIDs[1], 'New Store', "product name is not 'New Store'")
      assert(storefrontByIDs[2], storeOwner, "wrong store owner address")
      assert(storefrontByIDs[3], 0, "store balance is not 0")
    })
  })

  it("should allow store owner to add new product", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.addProduct(1, 'New Product', 5, 1, {from: storeOwner})
    }).then(function() {
      return marketplaceInstance.productByIDs(1)
    }).then(function(productByIDs) {
      assert(productByIDs[0], 1, "pid is incorrect")
      assert(productByIDs[1], 'New Product', "product name is incorrect")
      assert(productByIDs[2], 1, "product quantity is incorrect")
      assert(productByIDs[3], 5, "price is incorrect")
      assert(productByIDs[4], 1, "sid is incorrect")
    })
  })

  it("should allow shopper to buy a product", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.buyProduct(1, 1, 1, {from: shopper, value: 10})
    }).then(function() {
      return marketplaceInstance.productByIDs(1)
    }).then(function(productByIDs) {
      assert(productByIDs[2], 0, "quantity of product should be 0")
    }).then(function() {
      return marketplaceInstance.storefrontByIDs(1)
    }).then(function(storefrontByIDs) {
      assert(storefrontByIDs[3], 5, "storefront balance should be 5")
    })
  })

  it("should withdraw store balance to store owner", function() {
    return Marketplace.deployed()
    .then(function(instance) {
      marketplaceInstance = instance;
      return marketplaceInstance.withdrawStoreBalance(1, {from: storeOwner})
    }).then(function(getStoreBalance) {
      return marketplaceInstance.getStoreBalance(1, {from: storeOwner})
    }).then(function(balance) {
      assert(balance, 0, "store balance should be 0")
    })
  })
})
