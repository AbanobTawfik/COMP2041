/*
  Given a list of games, which are objects that look like:

  {
    "id": 112814,
    "matches": "123",
    "tries": "11"
  }

  return a object like such

  {
    "totalMatches": m,
    "totalTries": y
  }

  Where m is the sum of all matches for all games
  and t is the sum of all tries for all games.

  input = [
    {"id": 1,"matches": "123","tries": "11"},
    {"id": 2,"matches": "1","tries": "1"},
    {"id": 3,"matches": "2","tries": "5"}
  ]

  output = {
    matches: 126,
    tries: 17
  }

  test with `node test.js stats.json`
  or `node test.js stats_2.json`
*/

function countStats(list) {
  //start a cumulative sum for matches and tries
  var m = 0;
  var t = 0;
  //for each element in the list
  for (var i = 0; i < list.length; i++) {
      //add to the running sum the matches and tries
      m += parseInt(list[i].matches);
      t += parseInt(list[i].tries);
  }
  //return an object containing total matches + tries
  return{
    "matches": m,
    "tries": t
  };
}

module.exports = countStats;
