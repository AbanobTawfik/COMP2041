## Introduction

JavaScript is used increasingly to provide a native-like application experience in the web. One
major avenue of this has been in the use of Single Page Applications or SPAs. SPAs
are generated, rendered, and updated using JavaScript. Because SPAs don't require a user
to navigate away from a page to do anything, they retain a degree of user and application state.

There are millions of websites that utilise SPAs in part of, or all of their web applications.

The assignment intends to teach students to build a simple SPA which can fetch dynamic data from a HTTP/S API.
Your task will be to provide an implemention of a SPA that can provide a number of key features.

Some of the skills/concepts this assignment aims to test (and build upon):

* Simple event handling (buttons)
* Advanced Mouse Events (Swipe)
* Fetching data from an API
* Infinite scroll
* CSS Animations
* Web Workers
* Push Notifications (Polling)
* Offline Support
* Routing (URL fragment based routing)

## API

The backend server will be where you'll be getting your data. Don't touch the code in the backend; although we've provided the source,
it's meant to be a black box. Final testing will be done with our own backend. Use the instructions provided in the backend/README.md
to get it started.

For the full docs on the API, start the backend server and navigate to the root (very likely to be `localhost:5000`). You'll see
all the endpoints, descriptions and expected responses.

## A Working Product
Your site should be compatible with 'modern' Chrome, Safari, and Mozilla browsers.
We will assume your browser has JavaScript enabled, and supports ES6 syntax.

## Restrictions
You cannot use more than _minimal_ amounts of external JavaScript. Do not use NPM except to
install the helper development libraries. We will allow you to use CSS from external sources as long as it properly attributed.

## Getting Started
Clone the repository provided. It has a whole bunch of code, documentation, and a whole working server you'll need for
developing your frontend applicaiton.

Please read the relevant docs for setup in the folders `/backend` and `/frontend` of the provided repository.
Each folder outlines basic steps to get started. There are also some comments provided in the frontend source code.

## Milestones
Level 0 focuses on the basic user interface and interaction building of the site.
There is no need to implement any integration with the backend for this level.

### Level 0

**Login**
The site presents a login form and a user can log in with pre-defined hard coded credentials.
You can use the provided users.json so you can create a internal non persistent list of users that you check against.

Once logged in, the user is presented with the home page which for now can be a blank page with a simple "Not Yet implemented" message.

**Registration**
An option to register for "Instacram" is presented on the login page allowing the user to sign up to the service.
This for now updates the internal state object described above.

**Feed Interface**

The application should present a "feed" of user content on the home page derived from the sample feed.json provided.
The posts should be displayed in reverse chronological order (most recent posts first). You can hardcode how this works for
this milestone.

Although this is not a graphic design exercise you should produce pages with a common and somewhat distinctive look-and-feel. You may find CSS useful for this.

Each post must include:
1. who the post was made by
2. when it was posted
3. The image itself
4. How many likes it has (or none)
5. The post description text
6. How many comments the post has

## Level 1
Level 1 focuses on fetching data from the API.

**Login**
The site presents a login form and verifies the provided credentials with the backend (`POST /login`). Once logged in, the user can see the home page.

**Registration**
An option to register for "Instacram" is presented allowing the user to sign up to the service. The user information is POSTed to the backend to create the user in the database. (`POST /signup`)

**Feed Interface**
The content shown in the user's feed is sourced from the backend. (`GET /user/feed`)

## Level 2
Level 2 focuses on a richer UX and will require some backend interaction.

**Show Likes**
Allow an option for a user to see a list of all users who have liked a post.
Possibly a modal but the design is up to you.

**Show Comments**
Allow an option for a user to see all the comments on a post.
same as above.

**Like user generated content**
A logged in user can like a post on their feed and trigger a api request (`PUT /post/like`)
For now it's ok if the like doesn't show up until the page is refreshed.

**Post new content**
Users can upload and post new content from a modal or seperate page via (`POST /post`)

**Pagination**
Users can page between sets of results in the feed using the position token with (`GET user/feed`).
Note users can ignore this if they properly implement Level 3's Infinite Scroll.

**Profile**
Users can see their own profile information such as username, number of posts, sum of likes they received on all their posts, etc. You may choose to utilise the information from the api in more creative ways such as displaying their most liked post etc. Get this information from (GET /user)

## Level 3
Level 3 focuses on more advanced features that will take time to implement and will
involve a more rigourously designed app to execute.

**Infinite Scroll**
Instead of pagination, users an infinitely scroll through results. For infinite scroll to be
properly implemented you need to progressively load posts as you scroll.

**Comments**
Users can write comments on "posts" via (`POST post/comment`)

**Live Update**
If a user likes a post or comments on a post, the posts likes and comments should
update without requiring a page reload/refresh.

**Update Profile**
Users can update their personal profile via (`PUT /user`) E.g:
* Update email address
* Update password
* Update name

**User Pages**
Let a user click on a user's name/picture from a post and see a page with the users name, and other info.
The user should also see on this page all posts made by that person.
The user should be able to see their own page as well.

This can be done as a modal or as a seperate page (url fragmentation can be implemented if wished.)

**Follow**
Let a user follow/unfollow another user too add/remove their posts to their feed via (`PUT user/follow`)
Add a list of everyone a user follows in their profile page.
Add just the count of followers / follows to everyones public user page

**Delete/Update Post**
Let a user update a post they made or delete it via (`DELETE /post`) or (`PUT /post`)

## Level 4

**Slick UI**
The user interface looks good, is performant, makes logical sense, and is usable.

**Push Notifications**
Users can receive push notifications when a user they follow posts an image. Notification can be accessed at (`GET /latest`)

**Offline Access**
Users can access the "Instacram" at all times by using Web Workers to cache the page (and previous content) locally.

**Fragment based URL routing**
Users can access different pages using URL fragments:

```
/#profile=me
/#feed
/#profile=janecitizen
```
