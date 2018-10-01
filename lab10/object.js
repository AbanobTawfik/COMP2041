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
    if(drink.alcohol && !this.canDrink()){
        return;
    }
    if(this.canSpend(drink.cost)){
        this.tab += drink.cost;
        var arr = [];
        var obj = {};
        if(this.historyLen == 0){
            this.history.arr = arr;
            this.historyLen++;
            obj.name = drink.name;
            obj.count = 1;
            obj.total = drink.cost;
            this.history.arr[0] = obj;
            return;
        }
        this.historyLen++;

        for(var i = 0; i < this.history.arr.length; i++){
            //console.log(this.history.arr[i].name + " <===> " + drink.name);
            if(this.history.arr[i].name == drink.name){
                this.history.arr[i].count++;
                this.history.arr[i].total += drink.cost;
                return;
            }
        }

        obj.name = drink.name;
        obj.count = 1;
        obj.total = drink.cost;
        this.history.arr[this.historyLen] = obj;
        this.getRecipt();
    }
}
// write me
Person.prototype.getRecipt = function() {
    
    return this.history.arr;
}

module.exports = Person;
