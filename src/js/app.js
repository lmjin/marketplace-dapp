App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
    // If a web3 instance is already provided by Meta Mask.
    App.web3Provider = web3.currentProvider;
    web3 = new Web3(web3.currentProvider);
  } else {
    // Specify default instance if no web3 instance provided
    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    web3 = new Web3(App.web3Provider);
  }
  App.displayAccountInfo();
  return App.initContract();
},

  displayAccountInfo: function() {
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#account").text(account);
        web3.eth.getBalance(account, function(err, balance) {
          if (err === null) {
            $("#accountBalance").text(web3.fromWei(balance, "ether") + " ETH");
          }
        });
      }
    });
} ,

  initContract: function() {
    $.getJSON("Marketplace.json", function(data) {
      // Instantiate a new truffle contract from the artifact
      var MarketplaceArtifcat = data;
      App.contracts.Marketplace = TruffleContract(Marketplace);
      // Connect provider to interact with contract
      App.contracts.Marketplace.setProvider(App.web3Provider);

      return App.addStoreOwner();
    });
  },

  addStoreOwner: function() {
    let address;
    var marketplaceInstance;

    $('#addStoreOwner').submit(function( event ) {
      address = $("input#adminAddress").val();
      console.log(address);
      web3.eth.getAccounts(function(error, accounts) {
        if (error) {
          console.log(error);
        }

        var account = accounts[0];
        App.contracts.Marketplace.deployed().then(function(instance) {
          MarketplaceInstance = instance;
          console.log(addr)
          return MarketplaceInstance.addStoreOwner(address, {from: account});
        });
      });
    });
  },
render: function() {
  var marketplaceInstance;
  var loader = $("#loader");
  var content = $("#content");

  loader.show();
  content.hide();

  // Load account data
  web3.eth.getCoinbase(function(err, account) {
    if (err === null) {
      App.account = account;
      $("#accountAddress").html("Your Account: " + account);
    }


  });

  // Load contract data
  App.contracts.Marketplace.deployed().then(function(instance) {
    marketInstance = instance;
    return marketInstance.storeCount();
  }).then(function(storeCount) {
    var storeResults = $("#storeResults");
    storeResults.empty();

    for (var i = 1; i <= storeCount; i++) {
      marketInstance.storefrontByIDs(i).then(function(storefrontByIDs) {
        var sid = storefrontByIDs[0];
        var name = storefrontByIDs[1];
        var owner = storefrontByIDs[2];
        var balance = storefrontByIDs[3];

        // Render candidate Result
        var Template = "<tr><th>" + id + "</th><td>" + name + "</td><td>" + owner + "</td><td>" + balance + "</td></tr>"
        storeResults.append(storefrontTemplate);

      });
    }
    loader.hide();
    content.show();
  }).catch(function(error) {
    console.warn(error);
  });
}


}
