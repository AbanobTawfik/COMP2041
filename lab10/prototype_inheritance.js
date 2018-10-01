/*
 * given a name and a age make a Dog object
 * which stores this information
 * and which has a function called
 * toHumanYears which returns how old the
 * Dog is in human years (1 dog year is 7 human years) (not really but lets pretend)
 *
 * const me = Dog("sam",91)
 * me.name should be "sam"
 * me.age should be 91
 *
 * make Dog such that it is inheriting from the provided
 * Animal class
 *
 * me.__proto__ should be Animal
 * me.__proto__.__proto__ should be Animal
 * me.sayWoof() should return 'woof!'
 *
 */

function Animal(age) {
    this.age = age
}

Animal.prototype.makeSound = function() {
    console.log(this.sound)
}


function Dog(name,age) {
	//set the parent class to be animal
	Dog.prototype.constructor = Animal;
	//we want to construct our dog from age parsed in
	Animal.call(this,age);
	//set the name + sound for dog
	this.name = name;
	this.sound = "woof";
	//create our function to convert from dog to human years
	this.toHumanYears = function(){
		return 7*this.age;
	}

}
//creating our prototype function for dog makeSound
Dog.prototype.makeSound = function(){
	//here we use our parent class's makesound method called on this class dog
	//to make the woof sound using this classes sound
	Animal.prototype.makeSound.call(this);
}
module.exports = Dog;
