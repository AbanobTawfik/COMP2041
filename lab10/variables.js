/*
 * This code is broken! Can you figure out why
 * and fix it?
 */

function doubleIfEven(n) {
  if(even(n)) return double(n);
  return n;
}

function even(a) {
  if(a%2==0)
  	return true;
  return false;
}

function double(a) {
    return a*2;
}


module.exports = doubleIfEven;
