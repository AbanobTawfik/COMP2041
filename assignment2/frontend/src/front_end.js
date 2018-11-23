////////////////////////////////////////////////
//                z5075490                    //
//                Instacram                   //
//                Abanob Tawfik               //
////////////////////////////////////////////////
//making session token + other variables for infinite load, upload global variables
//references
//for scorllbar inside a document element (modal)
//https://stackoverflow.com/questions/25874001/how-to-put-scrollbar-only-for-modal-body-in-bootstrap-modal-dialog
//for detecting if user scrolled to bottom of page for infinite scroll
//https://stackoverflow.com/questions/9439725/javascript-how-to-detect-if-browser-window-is-scrolled-to-bottom
//finally using fetch to request from backend server and receive responses
//https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API/Using_Fetch
//reference for converting epoch time to formatted date string
//https://stackoverflow.com/questions/4631928/convert-utc-epoch-to-local-date
//reference for posting requests to the http server
//https://www.youtube.com/watch?v=tVQgfKqbX3M
//reference for adding event listener to elements with very similair id's
//https://stackoverflow.com/questions/40956717/how-to-addeventlistener-to-multiple-elements-in-a-single-line
//ayush sharma's excellent answer helped me really understand how to add one event listener to multiple elements
let token;
let post_comment_id;
let post_image;
let post_scroll_index = 0;
let logged_in_username;
let first_load = false;

//bootstrapped call for our page dynamic elements
(function () {
    operate();
}());

//this method will be used to add multiple event listeners to the page elements in order to
//hide or show elements or submit forms
function operate() {
    //we want to display the login form when the user clicks on the login button
    const login = document.getElementById("login_button");
    login.addEventListener("click", display_login);
    //in the login form if the user clicks cancel login we want to hide the form still saving the details
    const cancel_login = document.getElementById("cancel_login");
    cancel_login.addEventListener("click", hide_login);
    //we want to display the register form when the user clicks on the login button
    const register = document.getElementById("register_button");
    register.addEventListener("click", display_register);
    //in the login form if the user clicks cancel register we want to hide the form still saving the details
    const cancel_register = document.getElementById("cancel_register");
    cancel_register.addEventListener("click", hide_register);
    //when the user clicks submit on the login form we want to run it through the backend
    const login_form_button = document.getElementById("confirm_login");
    login_form_button.addEventListener("click", submit_json_form_login);
    //for the registration we want to add an event listener whenever user lifts from a keypress on keyboard
    //to check if the confirm password and create password fields match
    const matching_password_check1 = document.getElementById('register_password1');
    const matching_password_check2 = document.getElementById('register_password2');
    matching_password_check1.addEventListener("keyup", matching_password_check);
    matching_password_check2.addEventListener("keyup", matching_password_check);
    //when the user clicks submit on the register form we want to run it through the backend
    const register_form_button = document.getElementById("confirm_register");
    register_form_button.addEventListener("click", submit_json_form_register);
    //when the user clicks the logout button we want to prompt logout
    const logout_button = document.getElementById('logout_button');
    logout_button.addEventListener("click", logout_from_site);
    //when the user clicks on create post button we want to show the form for creating a post
    const create_post_button = document.getElementById('create_post_button');
    create_post_button.addEventListener("click", display_create_post);
    //when the user clicks on the cancel button within the create post form, we want to hide the form saving details
    const cancel_create_post = document.getElementById("cancel_create_post");
    cancel_create_post.addEventListener("click", hide_create_post)
    //when the user clicks on the submit button we want to run the form through the backend
    const submit_create_post_button = document.getElementById('confirm_create_post');
    submit_create_post_button.addEventListener("click", create_post);
    //when the user clicks on follow users button we want a form where they can enter who they want to follow
    const follow_user_button = document.getElementById('follow_user_button');
    follow_user_button.addEventListener("click", display_follow);
    //if the user clicks on the cancel button within the form, we want to hide the form for follow user
    const cancel_follow_user_button = document.getElementById('cancel_follow_user');
    cancel_follow_user_button.addEventListener("click", hide_follow);
    //when the user clicks confirm follow button we want to run their details in the backend
    const follow = document.getElementById('confirm_follow_user');
    follow.addEventListener("click", follow_user);
    //when the user clicks on unfollow users button we want a form where they can enter who they want to unfollow users
    const unfollow_user_button = document.getElementById('unfollow_user_button');
    unfollow_user_button.addEventListener("click", display_unfollow);
    //if the user clicks on the cancel button within the form, we want to hide the form for unfollow user
    const cancel_unfollow_user_button = document.getElementById('cancel_unfollow_user');
    cancel_unfollow_user_button.addEventListener("click", hide_unfollow);
    //if the user clicks on the submit button within the unfollow form we want to runt he form through the backend
    const unfollow = document.getElementById('confirm_unfollow_user');
    unfollow.addEventListener("click", unfollow_user);
    //if the user clicks on the comment button whenever creating a comment on a post
    //we want to run the comment through the backend before submitting it
    const comment = document.getElementById('confirm_comment');
    comment.addEventListener("click", add_comment);
    //if the user clicks on cancel their comment we want to close the form for adding a comment
    const cancel_comment = document.getElementById('cancel_comment');
    cancel_comment.addEventListener("click", hide_comment_box);
    //when the user clicks on their profile button we want to display their profile details
    const my_profile = document.getElementById('my_profile_button');
    my_profile.addEventListener("click", show_my_profile);
    //if the user clicks on the edit profile button we want to bring up the form for editing a profile
    const edit_profile = document.getElementById('edit_profile_button');
    edit_profile.addEventListener("click", display_edit_profile);
    //if the user clicks on cancel edit profile button we want to hide the edit profile form saving their details
    const cancel_edit_profile = document.getElementById('cancel_edit_profile');
    cancel_edit_profile.addEventListener("click", hide_edit_profile);
    //otherwise if the user clicks on submit button on the edit form, we want to pass the form through to the backend
    const edit_profile_submit = document.getElementById('edit_profile_submit');
    edit_profile_submit.addEventListener("click", edit_profile_submit_form);
    //this is a implementation from the example to set an event listener for any file input
    //this will return the base64 encoding of an image from file input taken from the supplied API.js
    const post_image_input = document.querySelector('input[type="file"]');
    post_image_input.addEventListener('change', uploadImage);
}

//this method will hide the logout button, reset the scroll start post to begin loading
//posts from the initial point and still infinite scroll, it will also hide the feed and show the
//home page and login/register button
function logout_from_site() {
    //we want to add a confirmation popup incase the user accidently clicks logout
    //if the user wants to logout
    if (confirm('Are you certain you want to logout')) {
        //reset where to begin loading posts from
        post_scroll_index = 0;
        //hide the logout button
        document.getElementById('logout_button').style.display = 'none';
        //show the login + register button
        document.getElementById('login_button').style.display = 'block';
        document.getElementById('register_button').style.display = 'block';
        //hide the users feed
        document.getElementById('large-feed').style.display = 'none';
        //show the home page element
        document.getElementById('home_page').style.display = 'block';
        //reset the posts element in html since user wont necessarily load the exact same feed state
        document.getElementById('posts').innerHTML = '';
    } else {
        //otherwise return it was a misclick
        return;
    }
}

//this function will check on registration if the passwords supplied are matching by comparing the two different
//form fields. if they are not equal an error message will be displayed in red, else it will be green passwords match!
function matching_password_check() {
    //we want to get the two passwords to compare from the form
    const matching_password_check1 = document.getElementById('register_password1');
    const matching_password_check2 = document.getElementById('register_password2');
    //here we want to get the error message in order to change its property
    const register_matching_password_warning = document.getElementById('matching_register_passwords');
    //now we want to show the warning and change the property based on the two fields
    register_matching_password_warning.style.display = "block";
    //if the fields have differing values
    if (matching_password_check1.value != matching_password_check2.value) {
        //we want to change the color of the element to red indicating warning with message passwords dont match
        register_matching_password_warning.style.color = 'red';
        register_matching_password_warning.innerText = "passwords do not match!"
    }
    //if the fields have the same value and that value is not empty
    else if (matching_password_check1.value == matching_password_check2.value &&
        matching_password_check1.value != '' && matching_password_check2.value != '') {
        //we want to change the color of th element to green indicating success with message passwords match
        register_matching_password_warning.style.color = 'green';
        register_matching_password_warning.innerText = "passwords match!"
    }
    //otherwise we want to completely hide the field because the fields are both empty
    else {
        register_matching_password_warning.style.color = "transparent";
    }
}

//this function will display the users profile modal
function show_my_profile() {
    //first we dynamically load for live feed the detail of the user from backend
    load_my_profile(logged_in_username);
    //then we want to load the element containing the loaded information and set it to visible
    const my_profile_popup = document.getElementById("profile_page");
    my_profile_popup.style.display = "block";
}

//this function will display the edit profile form
function display_edit_profile() {
    //we want to set the form from hidden to invisible
    const edit_profile_popup = document.getElementById("edit_profile_form");
    edit_profile_popup.style.display = "block";
}

//this function will display the login form
function display_login() {
    //we want to set the login form from hidden to visible
    const login_popup = document.getElementById("login_form");
    login_popup.style.display = "block";
}

//this function will display the comment box modal
function display_comment_box() {
    //we want to set the comment form from hidden to visible
    const comment_popup = document.getElementById("comment_post_form");
    comment_popup.style.display = "block";
}

//this function will display the follow user form
function display_follow() {
    //we want to set the follow user form from hidden to visible
    const display_element = document.getElementById('follow_user_form');
    display_element.style.display = "block";
}

//this function will display the unfollow user form
function display_unfollow() {
    //we want to set the unfollow form from hidden to visible
    const display_element = document.getElementById('unfollow_user_form');
    display_element.style.display = "block";
}

//this function will display the register form modal
function display_register() {
    //we want to set the register form modal from hidden to visible
    const register_popup = document.getElementById("register_form");
    register_popup.style.display = "block";
}

//this function will display the create post form
function display_create_post() {
    //we want to set the create post form from hidden to visible
    const register_popup = document.getElementById("create_post_form");
    register_popup.style.display = "block";
}

//this function will display the list of users who have liked a post
function show_liked_users(id) {
    //we want to load the list of users who have liked the post
    console.log('call likes' + id);
    load_liked_users_list(id);
    //then we want to display the modal containing the list of users who liked the post
    const show = document.getElementById('like_list');
    show.style.display = "block";
}

//this functionw will display the list of comments on a post
function show_comments(id) {
    //first we want to load comments into the comment section element
    console.log('call comments' + id);
    load_comments_display(id);
    //now we want to display the comments that were loaded
    const show = document.getElementById('comment_section');
    show.style.display = "block";

}

//this function will hide the form on the edit profile modal through the cancel button
function hide_edit_profile() {
    //we want to set the edit profile modal from visible to hidden
    const edit_profile_popup = document.getElementById("edit_profile_form");
    edit_profile_popup.style.display = "none";
}

//this function will hide the form on the login modal through the cancel button
function hide_login() {
    //we want to set the login modal from visible to hidden
    const login_popup = document.getElementById("login_form");
    login_popup.style.display = "none";
}

//this function will hide the form on the register modal through the cancel button
function hide_register() {
    //we want to set the register form modal from visible to hidden
    const login_popup = document.getElementById("register_form");
    login_popup.style.display = "none";
}

//this function will hide the form on the follow modal through the cancel button
function hide_follow() {
    //we want to set the follow modal from visible to hidden
    const display_element = document.getElementById('follow_user_form');
    display_element.style.display = "none";
}

//this function will hide the form on the unfollow modal through the cancel button
function hide_unfollow() {
    //we want to set the visibility ont he unfollow modal from visible to hidden
    const display_element = document.getElementById('unfollow_user_form');
    display_element.style.display = "none";
}

//this function will hide the form on the create post modal through the cancel button
function hide_create_post() {
    //we want to set the create post modal from visible to hidden
    const login_popup = document.getElementById("create_post_form");
    login_popup.style.display = "none";
}

//this function will hide the form on the create comment modal through the cancel button
function hide_comment_box() {
    //set the comment modal from visible to hidden
    const comment_popup = document.getElementById("comment_post_form");
    comment_popup.style.display = "none";
}

//this function will hide  the comment section modal through the cancel button
function hide_comments() {
    //we want to set the comment section modal from visible to hidden
    const show = document.getElementById('comment_section');
    show.style.display = "none";
}

//this function will hide on the create post modal through the cancel button
function hide_liked_users() {
    //set like list modal from visible to hidden
    const show = document.getElementById('like_list');
    show.style.display = "none";
}

//this function will hide the profile modal through the cancel button
function hide_my_profile() {
    //set the profile modal from visible to hidden
    const my_profile_popup = document.getElementById("profile_page");
    my_profile_popup.style.display = "none";
}

//this function will pass the login form details into the backend and see if the information provided is valid
//if the information provided is valid it will load the feed and keep track of the session token to authenticate
//future api requests
function submit_json_form_login() {
    //we want to get the form that was filled out by the user
    const form = document.getElementById("login");
    //create our object to send through to backend
    const submit = {};
    //now we retrieve the username and password from the form (note element 0 = username element 1 = password on form)
    submit.username = form.elements[0].value;
    submit.password = form.elements[1].value;
    //now we want to call our wrapper for fetch that will pass the details into the backend
    const usr = use_api_method('http://127.0.0.1:5000/auth/login', submit, "POST", 'undefined')
        .then(usr => {
            //if the response is invalid username/password
            if (usr.message === "Invalid Username/Password") {
                //we want to set incorrect login error message as red and visible
                document.getElementById('incorrect_login').style.color = 'red';
            } else {
                //otherwise we have a valid login session
                //hide the login form
                hide_login();
                //now we wasnt to remove the login/register button and home page
                //we also want to clear the error incase user logs out
                //we finally want to set the feed to be visible
                document.getElementById('incorrect_login').style.color = 'transparent';
                document.getElementById('login_button').style.display = 'none';
                document.getElementById('register_button').style.display = 'none';
                document.getElementById('home_page').style.display = 'none';
                document.getElementById('large-feed').style.display = 'block';
                document.getElementById('logout_button').style.display = 'block';
                //retrieve the token from the backend response and set it to the global variable
                token = usr.token;
                //load an initial feed for the user (note infinite scroll is now working)
                load_feed();
                //we also want to keep track of the current logged in users username for profile reasons
                logged_in_username = submit.username;
            }
        });
}

//this function will pass the registration form details into the backend and see if the information provided is valid
//if the information provided is valid it will load the feed and keep track of the session token to authenticate
//future api requests
function submit_json_form_register() {
    //we want to get the form that was filled out by the user for registration
    const form = document.getElementById("register");
    //now we will create our submission form object to pass into the backend request
    const submit = {};
    //now we want to retrieve all registration information from the form please note
    //element 0 = username, element 1 = password, element 2 = email, element 3 = name and this is how it is displayed
    //in the form
    submit.username = form.elements[0].value;
    submit.password = form.elements[1].value;
    submit.email = form.elements[3].value;
    submit.name = form.elements[4].value;
    //now we want to call our wrapper for fetch that will pass the details into the backend
    const usr = use_api_method('http://127.0.0.1:5000/auth/signup', submit, "POST", undefined)
        .then(usr => {
            //if the response from the backend is that the username is taken
            //we want to display the error message in red to the user int he form
            if (usr.message === "Username Taken") {
                document.getElementById('incorrect_register').style.color = 'red';
            } else {
                //otherwise we want to alert the user their account has been created (for feedback)
                alert("your account has been successfully created!");
                //hide the registration form
                hide_register();
                //now we wasnt to remove the login/register button and home page
                //we also want to clear the error incase user logs out
                //we finally want to set the feed to be visible
                document.getElementById('incorrect_register').style.color = 'transparent';
                document.getElementById('login_button').style.display = 'none';
                document.getElementById('register_button').style.display = 'none';
                document.getElementById('home_page').style.display = 'none';
                document.getElementById('large-feed').style.display = 'block';
                document.getElementById('logout_button').style.display = 'block';
                //retrieve the token from the backend response and set it to the global variable
                token = usr.token;
                //load an initial feed for the user (note infinite scroll is now working)
                load_feed();
                //we also want to keep track of the current logged in users username for profile reasons
                logged_in_username = submit.username;

            }
        });
}

//reference for posting requests to the http server
//https://www.youtube.com/watch?v=tVQgfKqbX3M
//reference for using await to get promise value
//https://softwareengineering.stackexchange.com/questions/279898/how-do-i-make-a-javascript-promise-return-something-other-than-a-promise
async function use_api_method(path, content, method, authorization) {
    //first we want to create our object that is passed into
    //the backend request (similair to http payload/header format)
    //the method will be the GET/PUT/POST etc
    //the body will be a json'd version of the content
    //and the header for the request will contain the authentication and the content type
    const form_post_settings = {
        method: method,
        body: JSON.stringify(content),
        headers: new Headers({
            'Authorization': authorization,
            'Content-Type': 'application/json'
        })
    };
    //now we want to attempt fetch response from server from our request
    try {
        //wait for the response from the server, and return a json object of the response
        return await fetch(path, form_post_settings).then(res => res.json());
    }
        //catch any exception from the fetch and log it to console
    catch (e) {
        console.log(e);
    }
}

//this method will retrieve 5 psots for the user beginning at the post count index
//upon loading it will also increment the post count index by 5
//posts will be placed in a border with all attributes and shown in the order received
//as user scrolls down this function will be called and loading further posts
//on logout and follow/unfollow to simulate live feed the post_Scroll_index is reset and feed is cleared
//and this is called again to simulate live feed
function load_feed() {
    let id;
    //we want to create a backend request to load posts from post_scroll_index to post_scroll_index + 5
    const path = 'http://127.0.0.1:5000/user/feed?p=' + post_scroll_index + '&n=5';
    const usr = use_api_method(path, undefined, "GET", 'Token ' + token)
        .then(usr => {
            //update where the post load counter is pointing to by 5 (how many posts loaded)
            post_scroll_index += 5;
            //now we want to sort the posts by their id to get most recent post
            let scan_array = usr.posts;
            scan_array.sort(sort_by_id);
            //now we want to retrieve our posts element in the html file to augment
            const feed = document.getElementById('posts');
            //DEBUG LINES
            console.log("length - " + usr.posts.length);
            console.log("index - " + post_scroll_index);
            //if the number of posts returned is 0 and the post scroll index is somehow >= 5
            //we want to deduct 5
            if (usr.posts.length == 0 && post_scroll_index >= 5) {
                post_scroll_index -= 5;
            }
            //otherwise if the number of posts returned and our index is <= 5
            //we want to deduct 5
            else if (usr.posts.length == 0 && posts_scroll_index < 5) {
                post_scroll_index = 0;
            }
            //otherwise if the number of posts returned is less than 5
            //we want to subtract the difference from the number of posts returned with 5
            else if (usr.posts.length < 5) {
                post_scroll_index -= (5 - usr.posts.length);
            }
            //for each post returned
            for (var i = 0; i < usr.posts.length; i++) {
                //we want to create a new post element
                const post = document.createElement('div');
                //create a smooth alligned rounded border for our post
                post.style.border = '2px solid black';
                post.style.borderStyle = 'groove';
                post.style.borderRadius = '15px';
                post.style.paddingLeft = '15px';
                post.style.width = '43%';
                //create the like/comment/view/unlike buttons for the post
                const like_button = document.createElement('button');
                const view_likes_button = document.createElement('button');
                const view_comments_button = document.createElement('button');
                const add_comments_button = document.createElement('button');
                const unlike_button = document.createElement('button');
                //we also want to create the image element to hold our base64 encoded image
                const image = document.createElement('img');
                const buttons = document.createElement('div');
                //set the image src to be in base 64 and the hexdump from the post image
                //format our image
                image.src = 'data:image/png;base64,';
                image.src += usr.posts[i].src;
                image.style.width = '500px';
                image.style.height = '500px';
                //now we want to add and format the like button and provide an id for the like button
                like_button.className = "btn btn-primary";
                like_button.style.marginLeft = "1%";
                like_button.style.marginTop = "-30px";
                like_button.id = "like_button_" + usr.posts[i].id;
                like_button.innerText = "Like";
                //now we want to add and format the unlike button and provide an id for the unlike button
                unlike_button.className = "btn btn-danger";
                unlike_button.style.marginLeft = "1%";
                unlike_button.style.marginTop = "-30px";
                unlike_button.id = "unlike_button_" + usr.posts[i].id;
                unlike_button.innerText = "Unlike";
                //now we want to add and format the view like button and provide an id for the view like button
                view_likes_button.className = "btn btn-primary";
                view_likes_button.style.marginLeft = "1%";
                view_likes_button.style.marginTop = "-30px";
                view_likes_button.id = "view_like_button_" + usr.posts[i].id;
                view_likes_button.innerText = "view Likes  " + usr.posts[i].meta.likes.length;
                //now we want to add and format the view comment button and provide an id for the ciew comment button
                view_comments_button.className = "btn btn-primary";
                view_comments_button.style.marginLeft = "1%";
                view_comments_button.style.marginTop = "-30px";
                view_comments_button.id = "view_comments_" + usr.posts[i].id;
                view_comments_button.innerText = "view comments    " + usr.posts[i].comments.length;
                //now we want to add and format the comment button and provide an id for the comment button
                add_comments_button.className = "btn btn-primary";
                add_comments_button.style.marginLeft = "25%";
                add_comments_button.style.marginTop = "-30px";
                add_comments_button.id = "add_comments_" + usr.posts[i].id;
                add_comments_button.innerText = "add comments!";
                //now we want to add the buttons created into the button container element for our post
                buttons.appendChild(add_comments_button);
                buttons.appendChild(view_comments_button);
                buttons.appendChild(like_button);
                buttons.append(view_likes_button);
                buttons.append(unlike_button);
                //centre the post around the page
                post.style.marginLeft = "28%";
                //add the post creator + date and description
                post.innerHTML += '<hr/>';
                post.innerHTML += '<b>Post By&nbsp&nbsp</b>' + usr.posts[i].meta.author;
                post.appendChild(buttons);
                post.innerHTML += '\t<b>Date Posted&nbsp&nbsp</b> ' + time_stamp(usr.posts[i].meta.published) + '<br/>';
                post.innerHTML += '<b>Caption&nbsp&nbsp</b>' + usr.posts[i].meta.description_text + '<br/>';
                post.innerHTML += '<br/>';
                //finally append the image to the post
                post.appendChild(image);
                post.innerHTML += '<br/><br/><br/><hr/>';
                //finally append the post to the feed
                feed.appendChild(post);
                feed.innerHTML += "<br/>";
            }
        });
    //if this is the first time we are calling load we want to add all event listeners
    if (first_load == false) {
        add_post_event_listener();
        first_load = true;
    }
}

//this method will first clear the liked user list
//then it will create a new liked user list in the element 'like_list'
//this will be placed in the modal like_list
function load_liked_users_list(id) {
    //first we want to create a variable for holding the number of likes
    let likes;
    //now we want to reset the like_list from any potential previous view like request
    const like_list = document.getElementById('like_list');
    like_list.innerHTML = '';
    //now we want to fetch the post from the backend using our api_method above
    const path = 'http://127.0.0.1:5000/post/?id=' + id;
    let update_likes = use_api_method(path, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            //console.log(update_likes);
            //we want to set our likes to be the list of likes returned from the request
            likes = update_likes.meta.likes;
            //now we want to create a container for the list of liked users
            const like_list = document.getElementById('like_list');
            //style our like_list and add scroll bar on overflow
            like_list.className = "fullscreen centered_backdrop";
            like_list.style.overflowY = "scroll";
            //first we want to see if the element exists already
            let liked_user_list = document.getElementById('likes_' + id);
            //if the element does not exist
            if (liked_user_list == null) {
                //create a new container for storing a list of liked users
                liked_user_list = document.createElement('div');
                //set the id + style for the list
                liked_user_list.id = 'likes_' + id;
                liked_user_list.className = "centered_backdrop_content";
                liked_user_list.style.height = (100 + (100 * likes.length)) + "px";
            }
            //add a initial message to the list
            liked_user_list.innerHTML = '<b> users who like this post! </b><br/>';
            //for each like in the list we want to create a like object
            for (var i = 0; i < likes.length; i++) {
                //create a like "element"
                const like = document.createElement('div');
                //add a border + allign the like to the modal
                like.style.border = '2px solid black';
                like.style.borderStyle = 'groove';
                like.style.borderRadius = '15px';
                like.style.textAlign = 'left';
                like.style.paddingLeft = "20px";
                //set the id for the like
                like.id = "like_" + likes[i];
                //now for the current like we want to make a request to see the name of the user
                //who made the like since likes is an array of integer id's
                const path = "http://127.0.0.1:5000/user/?id=" + likes[i];
                //make a backend request to get the used with the ID
                const usr = use_api_method(path, undefined, "GET", 'Token ' + token)
                    .then(usr => {
                        //add the name and a message of the usr saying they like the post
                        like.innerHTML = '<b>' + usr.username + '</b>' + ' likes this post!<br/>';
                        //add the like to the list of users who like
                        liked_user_list.appendChild(like);
                        //add a new line for spacing
                        liked_user_list.innerHTML += '<br/>'
                    })
            }
            //now we want to make an exit button so user can stop viewing the likes on the post
            const cancel_button = document.createElement('button');
            //style the button with red for warning and set the id on the button
            //add the test and align the button
            cancel_button.className = 'btn btn-danger';
            cancel_button.id = "close_liked_user_list_" + id;
            cancel_button.innerText = "close";
            cancel_button.style.marginLeft = "322px";
            cancel_button.style.marginTop = "-24px";
            //add the cancel button to the end of the list
            liked_user_list.appendChild(cancel_button);
            //add the list to the like element
            like_list.appendChild(liked_user_list);
        });
}

//this method will first clear the comment section
//then it will create a new comment section view for the post clicked on
//this will be placed in the modal comment section
function load_comments_display(id) {
    //creating a variable to hold the comments
    let comments;
    //now we want to get our comment section element to add comments to
    const comment_list = document.getElementById('comment_section');
    //first reset the comment section
    comment_list.innerHTML = '';
    //now we want to get from the backend the post with the id supplied
    const path = 'http://127.0.0.1:5000/post/?id=' + id;
    let update_comments = use_api_method(path, undefined, "GET", 'Token ' + token)
        .then(update_comments => {
            //we can to retrieve the comments from the response fromt he backend
            comments = update_comments.comments;
            //style the comment section to be a modal with scroll
            comment_list.className = "fullscreen centered_backdrop";
            comment_list.style.overflowY = "scroll";
            //now we want to create a container for our comments, first we check if the element exists
            let comment_section_comments = document.getElementById('comments_' + id);
            //if the element does not exist
            if (comment_section_comments == null) {
                //we want to create our container
                comment_section_comments = document.createElement('div');
                //style the comment section and add the id
                comment_section_comments.className = "centered_backdrop_content";
                comment_section_comments.style.height = (100 + (100 * comments.length)) + "px";
                comment_section_comments.id = "comments_" + id;
            }
            //add a heading indicating comment section
            comment_section_comments.innerHTML = '<b> comment section! </b><br/>';
            //for eachc omment in the comment list
            for (var i = 0; i < comments.length; i++) {
                //create a container for our comment
                const comment = document.createElement('div');
                //add a border and position the comment
                comment.style.border = '2px solid black';
                comment.style.borderStyle = 'groove';
                comment.style.borderRadius = '15px';
                comment.style.textAlign = 'left';
                comment.style.paddingLeft = "20px";
                //now we want to add who wrote the comment and when it was made and the comment
                comment.innerHTML = 'comment by ' + '<b>' + comments[i].author + '</b>' + '<br/>on <b>' +
                    time_stamp(comments[i].published) + '</b><hr/>';
                comment.innerHTML += comments[i].comment;
                //add the comment to the comment section with a new line for spacing
                comment_section_comments.appendChild(comment);
                comment_section_comments.innerHTML += '<br/>';
            }
            //now we want to create a button to exit the modal display
            const cancel_button = document.createElement('button');
            //style the button red and give it it's id
            cancel_button.className = 'btn btn-danger';
            cancel_button.id = "close_comments_" + id;
            cancel_button.innerText = "close";
            cancel_button.style.marginLeft = "-10px";
            cancel_button.style.marginTop = "1px";
            //add the cancel button finally to the comment section
            comment_section_comments.appendChild(cancel_button);
            //add the comment section to the html page
            comment_list.appendChild(comment_section_comments);
        });
}

//reference for detecting if we have scrolled to bottom of page
//https://stackoverflow.com/questions/9439725/javascript-how-to-detect-if-browser-window-is-scrolled-to-bottom
//moorexa's answer helped set me in the right path for infinite scroll
//reference for adding event listener to elements with very similair id's
//https://stackoverflow.com/questions/40956717/how-to-addeventlistener-to-multiple-elements-in-a-single-line
//ayush sharma's excellent answer helped me really understand how to add one event listener to multiple elements
function add_post_event_listener() {
    //when the user scrolls we want to set the function to check if we are at the bottom of the page
    window.onscroll = function () {
        //create variables for both how much we have scrolled down and the documents height
        let scrolled_down_height, document_height;
        //the scrolled down height will be the documents scroll height which is the current position
        //at bottom for scroll bar
        scrolled_down_height = document.body.scrollHeight;
        //and document height is the scrolled down height + inner height of the current window
        document_height = window.scrollY + window.innerHeight;
        //if the document height is slightly larger than the scrolled down height
        if (document_height >= scrolled_down_height - 3) {
            //load more posts (infinite scroll)
            load_feed();
        }
    };
    //now we want to add a over-arching event listener on the document whenever a click occurs
    //for detecting if elements with similair id's have been clicked
    document.addEventListener('click', function (event) {
        //if the click was triggered on a id with like_button_(id number)
        if (event.target.matches('[id^=like_button_]')) {
            //we want to like the post passing in the id by removing the like_button_ part
            like_post(event.target.id.replace('like_button_', ''));
            //DEBUG
            console.log('like_button_' + event.target.id.replace('like_button_', ''));
        }
        //if the click was triggered on a id with unlike_button_(id number)
        else if (event.target.matches('[id^=unlike_button_]')) {
            //we want to unlike the post passing in the id by removing the unlike_button_ part
            unlike_post(event.target.id.replace('unlike_button_', ''));
        }
        //if the event was triggered on an id with add_comments_(id)
        else if (event.target.matches('[id^=add_comments_]')) {
            //we want to display the comment box for adding comments
            display_comment_box();
            post_comment_id = event.target.id.replace('add_comments_', '');
        }
        //if the event was triggered on an id with view_like_button_(id)
        else if (event.target.matches('[id^=view_like_button_]')) {
            //we want to show the list of users who liked the post passing in the id
            show_liked_users(event.target.id.replace('view_like_button_', ''));
        }
        //if the event was triggered on an id with close_liked_user_list_(id)
        else if (event.target.matches('[id^=close_liked_user_list_]')) {
            //we want to hide the modal with the list of liked users
            hide_liked_users(event.target.id.replace('close_liked_user_list_', ''));
        }
        //if the event was triggered on an id with view_comments_(id)
        else if (event.target.matches('[id^=view_comments_]')) {
            //we want to show the modal with the list oc comments
            show_comments(event.target.id.replace('view_comments_', ''));
        }
        //finally if the event was triggered on an id with close_comments_(id)
        else if (event.target.matches('[id^=close_comments_')) {
            //we want to hide the modal with the list of comments
            hide_comments(event.target.id.replace('close_comments_', ''));
        }
    });
}

//this method is a comparator for a sort on an array
//it will sort by ids in reverse chronological order
function sort_by_id(a, b) {
    if (a.id > b.id)
        return -1;
    if (a.id < b.id)
        return 1;
    return 0;
}

//this method will be used for creating a post
function create_post() {
    //we want to first create a new object to send to the backend api
    const submit = {};
    //now we want to get the form the user has entered the form details into
    const form = document.getElementById("create_post");
    //the description will be the first element of the form entered
    submit.description_text = form.elements[0].value;
    //if there is no image supplied from the global variable which is updated whenever a user uploads an image
    if (post_image == undefined) {
        //print our error message out in red and return
        document.getElementById('incorrect_upload_form').style.color = 'red';
        return;
    }
    //otherwise put the payload image as the base64 encoding hexdump of the image
    submit.src = post_image.result.replace('data:image/png;base64,', '');
    //now we want to sent the object to the backend under the create post
    const path = 'http://127.0.0.1:5000/post/';
    const usr = use_api_method(path, submit, "POST", 'Token ' + token)
        .then(usr => {
            //if the return from the backend is malformed request
            if (usr.message == "Malformed request") {
                //we want to put our error message in red
                document.getElementById('incorrect_upload_form').style.color = 'red';
            } else {
                //otherwise hide the form for creating post
                hide_create_post();
                //inform the user their post has been succesfully uploaded
                alert("your post has been succesfully uploaded");
                //and set the error message to transparent (invisible)
                document.getElementById('incorrect_upload_form').style.color = 'transparent';
            }
        });
}

// THIS CODE DOES NOT BELONG TO ME, IT IS A SLIGHTLY MODIFIED VERSION OF THE UPLOAD IMAGE IN HELPERS.JS
// THAT WILL RETURN THE IMAGE IN THE FORM OF A FILE READER AND DOES NOT APPEND THE IMAGE TO THE WINDOW
// PLEASE NOTE THIS IS NOT MY CODE IT WAS SUPPLIED IN HELPERS.JS
export function uploadImage(event) {
    const [file] = event.target.files;
    const validFileTypes = ['image/jpeg', 'image/png', 'image/jpg']
    const valid = validFileTypes.find(type => type === file.type);
    // bad data, let's walk away
    if (!valid)
        return false;
    // if we get here we have a valid image
    const reader = new FileReader();
    // this returns a base64 image
    reader.readAsDataURL(file);
    post_image = reader;
}

//this method will be used to follow a users post
//and since i have done live update, upon following your feed is reloaded to allow you to see the new feed with their
//posts
function follow_user() {
    //create an object to submit to the backend
    const submit = {};
    //now we want to get the form which contains the user we are trying to follow
    const form = document.getElementById("follow_user");
    //set the username value to be the only element in the form
    submit.username = form.elements[0].value;
    //pass the object to the backend asking for the user to be put as following
    const path = 'http://127.0.0.1:5000/user/follow?username=' + submit.username;
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token)
        .then(usr => {
            //if the response fromt he backend is malformed
            if (usr.message == "Malformed Request") {
                //put the error message in red
                document.getElementById('incorrect_follow_input').style.color = 'red';
            }
            //otherwise
            else {
                //hide the following form
                hide_follow();
                //alert the user who they are now following
                alert("You are now following " + submit.username);
                //hide the error message by making it transparent
                document.getElementById('incorrect_follow_input').style.color = 'transparent';
            }
            //(since we are resetting the feed)
            //reset all posts on the current feed
            document.getElementById('posts').innerHTML = '';
            //reset the post scroll index so we receive posts from 0 now
            post_scroll_index = 0;
            //load the initial feed note infinite scroll now works
            load_feed();
        });
}

//this method will be used to unfollow a users post
//and since i have done live update, upon unfollowing your feed is reloaded to allow you to see the new feed with their
//posts
function unfollow_user() {
    //create an object to submit to the backend
    const submit = {};
    //now we want to get the form for twho we are unfollowing from the document
    const form = document.getElementById("unfollow_user");
    //set the username of who we are unfollowing as the first element in the form
    submit.username = form.elements[0].value;
    //now we want to pass our object into the backend requesting to unfollow the user
    const path = 'http://127.0.0.1:5000/user/unfollow?username=' + submit.username;
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token)
        .then(usr => {
            //if the response is a malformed request
            if (usr.message == "Malformed Request") {
                //we want to set the error message on and as red
                document.getElementById('incorrect_unfollow_input').style.color = 'red';
                document.getElementById('incorrect_unfollow_input').innerText = "Please supply a non empty " +
                    "string for the user you want to unfollow!";
            }
            //if the response is a malformed request or an unknown username
            else if (usr.message == "Malformed Request Or Unknown username") {
                //we want to set the second error message on and as red
                document.getElementById('incorrect_unfollow_input').style.color = 'red';
                document.getElementById('incorrect_unfollow_input').innerText = "Please make sure you are " +
                    "unfollowing a user you currently follow";

            }
            //otherwise its successful
            else {
                //now we want to hide the unfollow user form
                hide_unfollow();
                //alert the user that they are now unfollowing the user
                alert("You are now unfollowing " + submit.username);
                //and hide error message by making it transparent
                document.getElementById('incorrect_unfollow_input').style.color = 'transparent';
            }
            //finally we want to reset the posts
            document.getElementById('posts').innerHTML = '';
            //reset the index from where we load posts
            post_scroll_index = 0;
            //and load an initial feed essentially soft-refreshing the page
            load_feed();
        });
}

//reference for converting epoch time to formatted date string
//https://stackoverflow.com/questions/4631928/convert-utc-epoch-to-local-date
function time_stamp(epoch_time) {
    //first we want to initiallise a return
    let ret;
    //now we want to create a new date object
    let time_stamp = new Date(0);
    //next we want to create an array for each month of the year and each day of the week
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October',
        'November', 'December'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    //now we want to set the date objects time as the unix epoch time
    time_stamp.setUTCSeconds(epoch_time);
    //the hour/minute/second/year/month/day and day name can be extracted from this date
    let hour = time_stamp.getHours();
    const minute = time_stamp.getMinutes();
    const second = time_stamp.getSeconds();
    const year = time_stamp.getFullYear();
    const month = time_stamp.getUTCMonth();
    const day = time_stamp.getDate();
    const day_name = time_stamp.getDay();
    //finally we want to convert from 24h time to 12h time with am or pm
    let am_or_pm;
    //if hour > 12 we set it to pm, else its am
    if (hour > 12) {
        am_or_pm = "pm";
    } else {
        am_or_pm = "am"
    }
    //take the modulus of hour with 12 to get hour of the day
    hour = hour % 12;
    //return the formatted date string custom made
    ret = days[day_name] + '  ' + day + ' ' + months[month] + ' ' + year + ',  ' + hour + ':' + minute + ':' + second + ' ' + am_or_pm;
    return ret;
}

//this function will be used to like a post
//and will also update the UX and display to give a live feed
function like_post(id) {
    //first we want to create an object to pass to the backend as api request
    const submit = {};
    //set the id of the post to be the function arguement
    submit.id = id;
    const form = document.getElementById("unfollow_user");
    submit.username = form.elements[0].value;
    //now we want to pass in a put request to the backend to like the post with the id
    const path = 'http://127.0.0.1:5000/post/like?id=' + submit.id;
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token)
        .then(usr => {
        });
    //now we want to update the number of likes on the button to imitate a live feed
    const path2 = 'http://127.0.0.1:5000/post/?id=' + id;
    //we want to pass the id of the post to retrieve the post to the backend
    let update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            //finally we want to modify the view likes button text to contain the updated number
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
    //repeat a few times as it was buddy without
    update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
    update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
}

//this function will be used to unlike a post
//the number of likes will update automatically to implement live feed
function unlike_post(id) {
    //first create the object to pass through to the backend
    const submit = {};
    //set the id of the object as the function arguement
    submit.id = id;
    const form = document.getElementById("unfollow_user");
    submit.username = form.elements[0].value;
    //now we want to pass into the back-end the object and the request to unlike the following post id
    const path = 'http://127.0.0.1:5000/post/unlike?id=' + submit.id;
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token)
        .then(usr => {
        });
    //now to update the number of likes on the post
    const path2 = 'http://127.0.0.1:5000/post/?id=' + id;
    //make a request to retrieve the post
    let update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            //update the numebr of likes ont he view likes button
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
    //make multiple calls since its buggy without weird....
    update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
    update_likes = use_api_method(path2, undefined, "GET", 'Token ' + token)
        .then(update_likes => {
            document.getElementById('view_like_button_' + id).innerText = "view Likes  " + update_likes.meta.likes.length;
        });
}

//this function will be used to add a comment to a post
//the number of comments ont he post will update automatically and viewing will be a live update
function add_comment() {
    //first we want to create our object to pass into the backend
    const submit = {};
    //retrieve the form from the html file
    const form = document.getElementById("comment_post");
    //set the objects comment field to be the first element of the form
    submit.comment = form.elements[0].value;
    const path = 'http://127.0.0.1:5000/post/comment?id=' + post_comment_id;
    //now we want to make a backend request to put the comment onto the post (the id of the post is logged when user
    //chooses which post to comment on)
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token)
        .then(usr => {
            //if the return from the backend is a malformed request message
            if (usr.message == "Malformed Request") {
                //set the error message to be red and showing
                document.getElementById('incorrect_comment_input').style.color = 'red';
            }
            //otherwise
            else {
                //hide the comment box
                hide_comment_box();
                //inform the user their comment has been submitted
                alert("You are comment has been submitted!");
                //and set the error message to be hidden as transparent
                document.getElementById('incorrect_comment_input').style.color = 'transparent';
            }
            //now we want to update the number of comments ont he view comments button to implement live feed
            const path2 = 'http://127.0.0.1:5000/post/?id=' + post_comment_id;
            let update_comments = use_api_method(path2, undefined, "GET", 'Token ' + token)
                .then(update_comments => {
                    //now we want to update the number of comments on the view comments button
                    document.getElementById('view_comments_' + post_comment_id).innerText = "view comments    " +
                        update_comments.comments.length;

                });
            //a second call for saftey since its a bit buggy without
            update_comments = use_api_method(path2, undefined, "GET", 'Token ' + token)
                .then(update_comments => {
                    document.getElementById('view_comments_' + post_comment_id).innerText = "view comments    " +
                        update_comments.comments.length;
                });
        });
}

//this function will be used to display the current user profile page
function load_my_profile(user) {
    //we want to get the element in the html for the profile page
    const profile_page = document.getElementById('profile_page');
    //reset the current profile page contents (as a refresh)
    profile_page.innerHTML = '';
    //now we want to pass to the backend a get request for the user
    const path = 'http://127.0.0.1:5000/user/?username=' + user;
    const usr = use_api_method(path, undefined, "GET", 'Token ' + token)
        .then(usr => {
            //now we want to create a new container for our profile page
            const profile_page = document.getElementById('profile_page');
            //style the page to be a modal
            profile_page.className = "fullscreen centered_backdrop";
            //now we want to create a new element for the profile contents
            const profile_details = document.createElement('div');
            //style the profile contents
            profile_details.className = "centered_backdrop_content";
            //now we want to add a header showing who's profile it is
            profile_details.innerHTML = '<b>' + user + '\'s Profile! </b><br/>';
            //add the number of followers, user name, username, email and how many people they are following
            //and put the total number of posts created
            profile_details.innerHTML += '<br/><b> followers:    </b>' + usr.followed_num + '<br/>';
            profile_details.innerHTML += '<b> Username:    </b>' + usr.username + '<br/>';
            profile_details.innerHTML += '<b> Name:    </b>' + usr.name + '<br/>';
            profile_details.innerHTML += '<b> Email:    </b>' + usr.email + '<br/>';
            profile_details.innerHTML += '<b> Following:    </b>' + usr.following.length + '<br/>';
            profile_details.innerHTML += '<b> My Posts:    </b>' + usr.posts.length + '<br/>';
            //now we want to add the total number of likes accross all posts through our function
            const total_likes = calculate_total_likes(usr.posts).then(res => {
                //add the total likes received
                profile_details.innerHTML += '<b> Total Likes Received:    </b>' + res + '<br/>';
                profile_page.appendChild(profile_details);
                //now we want to add a close button so the user can xit fromt he model
                const cancel_button = document.createElement('button');
                cancel_button.className = "btn btn-danger";
                cancel_button.innerText = "Close";
                //add the event listener to hdie the modal on click of the cancel button
                cancel_button.addEventListener("click", hide_my_profile);
                //add the cancel button to the page
                profile_details.appendChild(cancel_button);
            });
        });
}

//this function will be used to calculate the total number of likes accross all posts of a user
//it is a asynchronous function meaning it will wait for the fetch result before continuing
async function calculate_total_likes(all_posts) {
    //start a running sum counter
    let sum = 0;
    //scan through all posts made by the user
    for (let i = 0; i < all_posts.length; i++) {
        //make a get request for the post
        const path = 'http://127.0.0.1:5000/post/?id=' + all_posts[i];
        await use_api_method(path, undefined, "GET", 'Token ' + token).then(usr => {
            //add the number of like son the post to the total sum
            sum += usr.meta.likes.length;
        });
    }
    //return the final cumulative sum
    return sum;
}

//this function will be used to edit a users profile details
function edit_profile_submit_form() {
    //first we want to get the form from the html documents
    const form = document.getElementById("edit_profile");
    //create an object to submit to the backend
    const submit = {};
    //if the first element which is the name is supplied
    if (form.elements[0].value != "" && form.elements[0].value != undefined) {
        //set the field to the object for the name
        submit.name = form.elements[0].value;
    }
    //if the second element which is the password is supplied
    if (form.elements[1].value != "" && form.elements[1].value != undefined) {
        //set the field for the object password
        submit.password = form.elements[1].value;
    }
    //if the third element which is the email is supplied
    if (form.elements[2].value != "" && form.elements[2].value != undefined) {
        //set the field for the object email
        submit.email = form.elements[2].value;
    }
    console.log(submit);
    //now we want to pass a PUT Request to modify user details to the backend using the object for modifications
    const path = 'http://127.0.0.1:5000/user/';
    const usr = use_api_method(path, submit, "PUT", 'Token ' + token).then(usr => {
        //if the response from the backend is success
        if (usr.msg == "success") {
            //alert the user their changes have been made
            alert("Your changes have been made!");
            //hide the error message incase it was displayed previously by setting its color to transparent
            document.getElementById('incorrect_edit_profile_input').style.color = 'transparent';
            //hide the edit profile form
            hide_edit_profile();
        }
        //otherwise
        else {
            //set the error message to be displaying in red
            document.getElementById('incorrect_edit_profile_input').style.color = 'red';
        }
    });
}