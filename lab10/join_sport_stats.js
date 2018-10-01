/*
* Given a list of career stats for a team of rugby players,
* a list of player names, and a list of team names, in the format below:
*
* players
* {
*     "players": [
*         {
*             "id": 112814,
*             "matches": "123",
*             "tries": "11"
*         }
*     ],
*     "team": {
*         "id": 10,
*         "coach": "John Simmons"
*     }
* }
* names
* {
*     "names": [
*         {
*             "id": 112814,
*             "name": "Greg Growden"
*         }
*     ]
* }
* teams
* {
*     "teams": [
*         {
*             "id": 10,
*             "team": "NSW Waratahs"
*         }
*     ]
* }
* Write a program that returns a 'team sheet' that lists
* the team, coach, players in that order in the following list format.
*
* [
*     "Team Name, coached by CoachName",
*     "1. PlayerName",
*     "2. PlayerName"
*     ....
* ]
*
* Where each element is a string, and the order of the players
* is ordered by the most number of matches played to the least number of matches played.
*
* For example, the following input should match the
* following output exactly.
*
* input data
* {
*     "players": [
*         {"id": 1,"matches": "123", "tries": "11"},
*         {"id": 2,"matches": "1",   "tries": "1"},
*         {"id": 3,"matches": "2",   "tries": "5"}
*     ],
*     "team": {
*         "id": 10,
*         "coach": "John Simmons"
*     }
* }
*
* {
*     "names": [
*         {"id": 1, "John Fake"},
*         {"id": 2, "Jimmy Alsofake"},
*         {"id": 3, "Jason Fakest"}
*     ]
* }
*
* {
*     "teams": [
*         {"id": 10, "Greenbay Packers"},
*     ]
* }
*
* output
* [
*     "Greenbay Packers, coached by John Simmons",
*     "1. John Fake",
*     "2. Jason Fakest",
*     "3. Jimmy Alsofake"
* ]
*
* test with
* `node test.js team.json names.json teams.json`
*/

function makeTeamList(teamData, namesData, teamsData) {
    // Take it step by step.
    //step 1 get the coach and his team 
    var coachName = teamData.team.coach;
    var coachId = teamData.team.id;
    var coachTeam;
    //to find team coach is on, we want to match the id in list of teams assosciated
    //with the coach
    for(var i = 0; i < teamsData.length;i++){
    	if(teamsData[i].id == coachId){
    		coachTeam = teamsData[i].team;
    	}
    }
    //now we want to sort the players by number of matches (Descending)
    teamData.players.sort(function(a,b) {
    	return b.matches - a.matches;
    })
    //create our final team array
    var team = [];
    //first index in array will be the coach and the team he coaches
    team[0] = coachTeam + ", coached by " + coachName;
    //scan through the team and the name spreadsheet
    for(var i = 0; i < teamData.players.length; i++){
    	for(var j =  0; j < namesData.length; j++){
    		//if the ids match, we want to put the id + player into array next index
    		if(teamData.players[i].id == namesData[j].id){
    			team[i+1] = (i+1) +". " + namesData[j].name;
    		}
    	}
    }
    //return the team list
    return team;
}

module.exports = makeTeamList;
