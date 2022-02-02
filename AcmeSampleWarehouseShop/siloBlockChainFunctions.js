// start functions that read from block chain 0x6faDf5388239b99582AC8c1370f2108c14C1A7E3

function DisplayPasses() {
  var addressBeingChecked = document.getElementById(
    "addressToCheckForPass"
  ).value;
  siloContract.methods
    .checkPassesAnPartyHas(addressBeingChecked)
    .call(function (err, result) {
      console.log(err, result);
      $("#storemanPassesInPossession").html(result);
    });
}

function seeOwner() {
  siloContract.methods.owner().call(function (err, result) {
    console.log(err, result);
    $("#getMeTheManager").html(result);
  });
}

function seeAccountsDepartment() {
  siloContract.methods.accountsAddress().call(function (err, result) {
    console.log(err, result);
    $("#accountsDepartmentAddress").html(result);
  });
}
function seeFactoryAddress() {
  siloContract.methods.factoryAddress().call(function (err, result) {
    console.log(err, result);
    $("#widgetFactoryAddress").html(result);
  });
}
function seeWarehouseAddress() {
  siloContract.methods.Warehouse().call(function (err, result) {
    console.log(err, result);
    $("#warehouseAddress").html(result);
  });
}
function seeCurrencyAddress() {
  siloContract.methods.currencyAddress().call(function (err, result) {
    console.log(err, result);
    $("#currencyAddress").html(result);
  });
}
function howManyWidgetsInStock() {
  siloContract.methods.widgetsInStock().call(function (err, result) {
    console.log(err, result);
    scaledWidgets = result / 1000000000000000000; //scaled due to wei factor
    $("#widgetsAtSilo").html(scaledWidgets);
  });
}

// end functions that read from block chain

//start functions that write to block chain

function issuePass() {
  var passesToIssue = 1;

  web3.eth.getAccounts().then(function (accounts) {
    siloContract.methods
      .issueStoreManPass(passesToIssue)
      .send({ from: accounts[0] });
  });
}

function passTransfer() {
  var passesToIssue = 1;
  var addressToGivePass = 0xaa5b62083eb1979d115822c5554f16bf1b1e4b53;
  web3.eth.getAccounts().then(function (accounts) {
    siloContract.methods
      .transferPass(addressToGivePass, passesToTransfer)
      .send({ from: accounts[0] });
  });
}

function buyWidget() {
  var thingsBuy = document.getElementById("widgetsToBuy").value;

  web3.eth.getAccounts().then(function (accounts) {
    siloContract.methods
      .customerPurchase(thingsBuy)
      .send({ from: accounts[0] });
  });
}

function makeWidgets() {
  var itemsToMake = document.getElementById("widgetsToMake").value;

  web3.eth.getAccounts().then(function (accounts) {
    siloContract.methods
      .createAtFactory(itemsToMake)
      .send({ from: accounts[0] });
  });
}

function recycleWidgets() {
  var itemsToMake = document.getElementById("widgetsToRecycle").value;

  web3.eth.getAccounts().then(function (accounts) {
    siloContract.methods
      .destroyWidgetsForRecycling(itemsToMake)
      .send({ from: accounts[0] });
  });
}

// end functions that write to block chain
