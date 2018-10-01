/*
 * Fill out the Person prototype
 * function "buyDrink" which given a drink object which looks like:
 * {
 *     name: "beer",
 *     cost: 8.50,
 *     alcohol: true
 * }
 * will add the cost to the person expences if the person
 * is
 *    1. old enough to drink (if the drink is alcohol)
 *    2. buying the drink will not push their tab over $1000
 *
 * in addition write a function "getRecipt" which returns a list as such
 * [
 *    {
 *        name: beer,
 *        count: 3,
 *        cost: 25.50
 *    }
 * ]
 *
 * which summaries all drinks a person bought by name in order
 * of when they were bought (duplicate buys are stacked)
 *
 * run with `node test.js <name> <age> <drinks file>`
 * i.e
 * `node test.js alex 76 drinks.json`
 */

function Person(name, age) {
    this.name = name;
    this.age = age;
    this.tab = 0;
    this.history = {};
    this.historyLen = 0;
    this.canDrink = function() {
      return this.age >= 18;
    };
    this.canSpend = function(cost) {
      return this.tab + cost <= 1000;
    }
}

// write me
Person.prototype.buyDrink = function(drink) {
    //if we have an alchoholic drink and the user cant drink, we return nothing
    if(drink.alcohol && !this.canDrink()){
        return;
    }
    //if the user can spend (passed above test aswell)
    if(this.canSpend(drink.cost)){
        //we want to add to their persons tab
        this.tab += drink.cost;
        //now we want to make an array to store our receipts
        var arr = [];
        //and now we want to create a new object for our receipts
        var obj = {};
        //if this the first transaction
        if(this.historyLen == 0){
            //we want to set the history object field to be our array of receipts
            this.history.arr = arr;
            //create our drink object based on the drink parsed in
            obj.name = drink.name;
            obj.count = 1;
            obj.total = drink.cost;
            //set the first element in the array of recipts to be the first drink
            this.history.arr[this.historyLen] = obj;
            //add 1 to the length
            this.historyLen++;
            //return from the function
            return;
        }
        //if the drink has been ordered before we want to modify the 
        //receipt for that drink index, so scan through all receipts
        for(var i = 0; i < this.history.arr.length; i++){
            //if the same drink has been ordered before eg. coke and coke
            if(this.history.arr[i].name == drink.name){
                //increment counter + total due
                this.history.arr[i].count++;
                this.history.arr[i].total += drink.cost;
                //return from function, dont increment out historylength as we didn't add a new drink to our array
                return;
            }
        }
        //otherwise
        //set the drink object parameters
        obj.name = drink.name;
        obj.count = 1;
        obj.total = drink.cost;
        //set the next array open index, to hold the current receipt
        this.history.arr[this.historyLen] = obj;
        //increment number of drink objects length
        this.historyLen++;
    }
}
// write me
Person.prototype.getRecipt = function() {
    //return our array of receipts
    return this.history.arr;
}

module.exports = Person;
