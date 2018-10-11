(function () {
    'use strict';
    //flag to check if the object is hidden/visible
    var hidden = true;
    //set on a 2000ms interval a on/off toggle based on current object state
    setInterval(toggle, 2000);

    //function will toggle the display on if its hidden, or off its visible
    function toggle() {
        //if the object is current hidden
        if (hidden) {
            //set display to be on in block form
            document.getElementById('output').style.display = 'block';
            //and set the status to currently visible
            hidden = false;
        }
        //otherwise it is implied that it is visible
        else {
            //set the status to hidden
            hidden = true;
            //set the objects display to be off
            document.getElementById('output').style.display = 'none';
        }
    }
}());
