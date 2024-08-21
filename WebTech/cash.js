/*
Programer: Jeremy Saltz
Class: CSCI 4410
Program dicription:
This program has two functions and one object
The oject is cashRegister, it has to attributes ( total, and item)
it has one method that add to the total 
*/

// the cash register object
var cashRegister = {
    total: 0,// total to save the total for the print out
    item: 0,// item to save the user input

    // the add method for saving the total
    add: function(itemCost) {
        this.total += itemCost;
    }
};

// the scan function for getting the user input
// it then saves the total 
function scan() {
    // prompt the user to enter how many items to add to the total
    cashRegister.item = parseInt(prompt("Enter the total number of items: "), 10);

    // loop to add to the total for each item price entered
    for (var i = 0; i < cashRegister.item; i++) {
        var cost = parseFloat(prompt("Enter the cost of the item " + (i + 1)));
        cashRegister.add(cost);
    }
}

// the print fucntion
function print() {
    // if the total is 0 then asks for items
    if (cashRegister.total === 0) {
        confirm("Please enter your items cost first.");
    } else {
        confirm("Total items cost: $" + cashRegister.total.toFixed(2));
    }
}