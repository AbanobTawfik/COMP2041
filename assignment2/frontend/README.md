# Frontend

## Recommended Steps for tackling the assignment
1. Get something basic working with the data provided in `frontend/data`
2. Once you've got something basic working, start hitting the `/dummy/` API, which doesn't require authentication. See docs.
3. Finally, once you've got that working, transition over to use the real API.

## Quickstart

If you're using NPM the following simple scripts are avalable to you to help
your development. This is before you start using the dev server directly.

```bash
# install helper scripts
npm install

# start the dev server on first available port.. likely 8080
npm start

# run the linter to check your js 
npm run lint
```

In addition we've provided a basic project scaffold for you to build from.
You can use everything we've given you, although there's no requirement to use anything.
```bash
# scaffold
data
  - feed.json  # A sample feed data object
  - users.json # A sample list of user/profile objects
  - post.json  # A sample post object

src
  - main.js   # The main entrypoint for your app
  - api.js    # Some example code for your api logic
  - helper.js # Some helper functions, which you don't need to use

styles
  - provided.css  # some sample css we've provided goes (add more stylesheets as you please)
```

To make sure everything is working correctly we strongly suggest you read the instructions in both backend and frontend,
and try to start both servers (frontend and backend).
