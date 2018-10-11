(function () {
    //set a call to the function that prints the current time every 1000ms = 1 second
    setInterval(count, 1000);

    function count() {
        //create a new date object
        var counter = new Date();
        //write to the output the current date converted into time string
        document.getElementById('output').innerHTML = counter.toTimeString();
    }
}());
