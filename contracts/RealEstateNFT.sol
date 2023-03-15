// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract RealEstateNFT {
    address payable public government;
    mapping (uint256 => Property) public properties;
    uint256 public propertyCounter;

    struct Property {
        address payable owner;
        uint256 price;
        uint256 tax;
        address approvedBuyer;
        bool isValid;
        // Transaction[] transactions;
    }

    mapping(uint256 => Transaction[]) public transactions;

    struct Transaction {
        address previousOwner;
        address newOwner;
        uint256 price;
        uint256 timestamp;
    }

    constructor(){
        government = payable(msg.sender);
    }

    function mint(address seller) public onlyGovernment{
        properties[propertyCounter] = Property({
            owner: payable(seller),
            price: 0,
            tax: 0,
            approvedBuyer: address(0),
            isValid: true
            // transactions: new Transaction[]
            
        });
        transactions[propertyCounter].push(Transaction({
                previousOwner: address(0),
                newOwner: seller,
                price: 0,
                timestamp: block.timestamp
            }));
        propertyCounter ++;
    }

    function approveSale(uint256 _propertyId, address _buyer) public onlyValid(_propertyId){
        Property storage property = properties[_propertyId];
        require(property.owner == msg.sender, "Only the owner can approve sale.");
        property.approvedBuyer = _buyer;
    }

    function transfer(uint256 _propertyId) public payable onlyValid(_propertyId){
        Property storage property = properties[_propertyId];
        require(property.approvedBuyer == msg.sender, "Buyer not approved.");
        require(msg.value >= property.price, "Insufficient payment.");

        property.tax=property.price<40000000000000000000? property.price/3: property.price/5;
        property.owner.transfer(property.price - property.tax);
        government.transfer(property.tax);
        transactions[_propertyId].push(Transaction({
            previousOwner: property.owner,
            newOwner: msg.sender,
            price: property.price,
            timestamp: block.timestamp
        }));
        property.owner = payable(msg.sender);
        property.approvedBuyer = address(0);
    }

    function getProperty(uint256 _propertyId) public view onlyValid(_propertyId) returns(address, uint256, uint256, address) {
        Property storage property = properties[_propertyId];
        return (property.owner, property.price, property.tax, property.approvedBuyer);
    }

    function getTransaction(uint256 _propertyId) public view returns (address, address, uint256, uint256) {
        Transaction[] memory transaction = transactions[_propertyId];
        return (transaction[1].newOwner, transaction[1].previousOwner,transaction[1].price,transaction[1].timestamp);
    }

    function changePrice(uint256 _propertyId, uint256 newPrice) public onlyValid(_propertyId){
        require(msg.sender == properties[_propertyId].owner, "you have to own the property");
        properties[_propertyId].price = newPrice;
    }

    function destroyProperty(uint256 _propertyId) public onlyGovernment{
        properties[_propertyId].isValid = false;
    }

    function makeValid(uint256 _propertyId) public onlyGovernment{
        properties[_propertyId].isValid = true;
    }

    modifier onlyGovernment() {
        require(msg.sender == government, "Only the government can perform this action.");
        _;
    }

    modifier onlyValid(uint256 _propertyId){
        require(properties[_propertyId].isValid== true, "Your property is not valid.");
        _;
    }


}