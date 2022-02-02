// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

interface Factory {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function balanceOf(address account) external returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external ;
   
    
}

interface Accounting {

    function transferFrom(address sender, address recipient, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
    function increaseAllowance(address spender, uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    
}

contract silo {
    mapping(address => uint) storeManPasses;
    address public owner;
    address public currencyAddress;//set this to the currency address customers need to pay in eg usdc or usdt busd or something else
    uint256 public widgetPrice=3;
    uint256 public widgetsInStock;
    address public factoryAddress;//factory where the units can be made
    address public accountsAddress;//accounts department address so they can be sent moneyf rom customer orders and arrange payments to factories,suppliers,storeman,possibility for complete automation of payroll and supplier terms etc
    address public Warehouse;//address of warehouse, this is an account where widgets are stored from the factory and payment is stored from the customer
    uint256 public weiUnits = 10 ** 18;//use wei scaling factor


    constructor() {
        owner = msg.sender; // address that deploys contract will be the owner
        Warehouse=address(this);
    }
    

     /*change factory where widgets are being made, using a different factory will have a different token representation, so could be used to store a different sku or batch of items.
     these items will not be mixed with the original items
   the factory also needs to allow this warehouse to process a create request */  
    function setFactoryAddress(address _factoryAddress) public payable {
        require(msg.sender == owner, "Only the owner of contract can do this");
       factoryAddress = _factoryAddress;
    }
//change the warehouse, so can use a different address to send widgets too and take payment from customers
        function setWarehouseAddress(address _Warehouse) public payable {
            require(msg.sender == owner, "Only the owner of contract can do this");
       Warehouse = _Warehouse;
    }

        function setAccountsAddress(address _accountsAddress) public payable {
            require(msg.sender == owner, "Only the owner of contract can do this");
       accountsAddress = _accountsAddress;
    }

        function setCurrencyAddress(address _currencyAddress) public payable {
            require(msg.sender == owner, "Only the owner of contract can do this");
       currencyAddress = _currencyAddress;
    }

            function setWidgetPrice(uint256 _widgetPrice) public payable {
                require(msg.sender == owner, "Only the owner of contract can do this");
       widgetPrice = _widgetPrice;
    }

            function changeOwner(address _newOwner) public payable {
                require(msg.sender == owner, "Only the owner of contract can do this");
       owner = _newOwner;
    }


//contract owner can issue multiple passes at once so can transfer to other parties such as accounts,recruiters other senior storeman for distribution
    function issueStoreManPass(uint _toAdd) public returns(uint) {
        require(msg.sender == owner);
        storeManPasses[msg.sender] += _toAdd;
        return storeManPasses[msg.sender];
    }
    

    //check if you have a storemans pass
    function howManyPassesDoIHave() public view returns(uint) {
        return storeManPasses[msg.sender];
    }
    

    //check to see how many storeman passes a party such as a recruiter has
    function checkPassesAnPartyHas(address _PartysAddress) public view returns(uint) {
        return storeManPasses[_PartysAddress];
    }

    //allows transfer of passes from accounts or recruiters to new storeman
    function transferPass(address recipient, uint amount) public {
        require(storeManPasses[msg.sender]>=amount, "Insufficient Passes");
        require(msg.sender != recipient, "You can't send passes to yourself!");
        _transferPass(msg.sender, recipient, amount);
    }
    
    function _transferPass(address from, address to, uint amount) private {
        storeManPasses[from] -= amount;
        storeManPasses[to] += amount;
    }



        function checkWidgetStock() external returns(uint256){

        widgetsInStock=Factory(factoryAddress).balanceOf(Warehouse);
        return Factory(factoryAddress).balanceOf(Warehouse);
    }


    function createAtFactory(uint256 widgetNumber) external {
        
        require(storeManPasses[msg.sender]>=1, "need storemans pass to do this");
        
        uint256 factoredWidgetNumber=widgetNumber * weiUnits;
        Factory(factoryAddress).mint(Warehouse, factoredWidgetNumber);
        widgetsInStock=Factory(factoryAddress).balanceOf(Warehouse);

    }
    
    function destroyWidgetsForRecycling(uint256 widgetNumber) external {
        require(storeManPasses[msg.sender]>=1, "need storemans pass to do this");
        uint256 factoredWidgetNumber=widgetNumber*weiUnits;
        Factory(factoryAddress).burn(factoredWidgetNumber);
       widgetsInStock=Factory(factoryAddress).balanceOf(Warehouse);
    }
 
    function customerPurchase(uint256 widgetNumber) external{
       uint256 factoredWidgetNumber=widgetNumber*weiUnits;
       require(widgetsInStock>=factoredWidgetNumber, "not enough stock reduce qty please");
        uint256 currencyAmount=widgetNumber*widgetPrice;
        
        /*Accounting(currencyAddress).approve(Warehouse, currencyAmount);//approve warehouse to spend customers funds activated from the front end which connects to the payment contract.
        
        This is the main vulnerability where a site can spoof us if the user does not check the approving address,obviously approval function here would only get this particular contracts approval for spending not the actual end users
        with ERC20 tokens like USDT you would need first the user to approve the spending of X tokens to your smart contract and then call the transferFrom function to access hs token and do the logic.
        this is like the customer has to give sign approval (eg cvc,dob,expiry date,card number etc) to their bank to allow them to release funds to the supplier, the supplier can't ask the bank to release funds on the customers behalf
        */

        
        Accounting(currencyAddress).transferFrom(msg.sender,Warehouse, currencyAmount);//send funds from customer straight to warehouse
     
          Factory(factoryAddress).transfer(msg.sender, factoredWidgetNumber);
        widgetsInStock=Factory(factoryAddress).balanceOf(Warehouse);
    }
    //withdraw funds from the warehouse to accounts
    function withdrawCashFromWarehouseToAccounts(uint256 withdrawalAmount) external{
        require(msg.sender == owner, "Only the owner of contract can do this");

        Accounting(currencyAddress).transfer(accountsAddress, withdrawalAmount);
    }
}
    

