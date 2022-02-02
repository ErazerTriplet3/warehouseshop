      // Initialize Web3
      if (typeof web3 !== 'undefined') {
        web3 = new Web3(web3.currentProvider);
      } else {
        web3 = new Web3(new Web3.providers.HttpProvider('https://data-seed-prebsc-1-s1.binance.org:8545'));
      }


      // Set the Contract
      var siloContract = new web3.eth.Contract(siloAbi, siloAddress);


      var currentUser = web3.eth.accounts[0];