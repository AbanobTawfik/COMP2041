/*
 * Write a function called buildPipe that returns a function
 * which runs all of it's input functions in a pipeline
 * let timesTwo = (a) => a*2;
 * let timesThree = (a) => a*3;
 * let minusTwo = (a) => a - 2;
 * let pipeline = buildPipe(timesTwo, timesThree, minusTwo);
 *
 * pipeline(6) == 34
 *
 * pipeline(x) in this case is the same as minusTwo(timesThree(timesTwo(x)))
 *
 * test with `node test.js`
 */
//our pipe takes in 3 functions as parameter
function buildPipe(func1,func2,func3) {
	//now when pipe is called on an input, we want to pass down (sort of like a filter)
	//our result from the functions, so we pass the result of func1 into func2 and then 
	//pass that result into func3.
	return(input) => {
		return func3(func2(func1(input)));
	}
}

module.exports = buildPipe;
