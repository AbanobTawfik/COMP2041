const Person = require('./objects');
const name = process.argv[2];
const age = parseInt(process.argv[3]);
const drinksJson = process.argv[4]
if (name === undefined || age === undefined || drinksJson === undefined) {
  throw new Error(`input not supplied`);
}
const drinks = require(`./${drinksJson}`);
const p = new Person(name,age);
for(let drink of drinks)
  p.buyDrink(drink)
console.log(p.getRecipt());
