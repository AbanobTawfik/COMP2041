(function () {
    //store into an array the list of the buttons to add event listeners to
    //and the list of extra contents
    var buttons = document.getElementsByClassName("material-icons");
    var content = document.getElementsByClassName("lead extra-info");


    //since we have an extra button at the start, start at the 2nd
    //set the onclick to first check if the content is being displayed (block)
    buttons[1].addEventListener("click", function () {
        //if content is displayed
        if (content[0].style.display == "block") {
            //change the up arrow to down arrow
            buttons[1].innerHTML = "expand_more";
            //hide the content
            content[0].style.display = "none";
        }
        //otherwise we can imply the content is hidden
        else {
            //change the down arrow to the up arrow
            buttons[1].innerHTML = "expand_less";
            //unhide the contnet
            content[0].style.display = "block";
        }
    });
    //perform the same with the second button on the next extra info section
    buttons[2].addEventListener("click", function () {
        if (content[1].style.display == "block") {
            buttons[1].innerHTML = "expand_more";
            content[1].style.display = "none";
        } else {
            buttons[1].innerHTML = "expand_less";
            content[1].style.display = "block";
        }
    });
}());