var state_labels=['Smithsville', 'Willliamsville', 'Jonesville', 'Brownsville', 'Clarksville', 'Bakersville'];

var badges = ['Trainee','Junior Flight Officer','Flight Officer',' First Officer','Captain','Senior Captain','Commercial First Officer','Commercial Captain','Commercial Senior Captain','Commercial Commander','Commercial Senior Commander','ATP First Officer',' ATP Captain','ATP Senior Captain','ATP Commander','ATP Senior Commander'];

level=0;
level_scores = _.range(50,2350,150);
level_scores_money = _.range(1,17.25,1);

bonus_for_stars=true;

points_per_dollar = 100

var correct_answers=[-1,1,0,1,-1,0,-1,1];


nr_levels=level_scores.length;
level_scores[level_scores.length]=Infinity;

gamified=Math.random()<1;


if (gamified){    
    
    pseudoreward_rate=14.83
    
    //point_values=[0,10,100];
    points_per_star= 0
    
    test_images=['test1.png','test2.png','test3.png','test4.png','test5.png','test1.png']
    //pseudoreward_type=_.sample([10,11,12])
    pseudoreward_type=10;
    if (pseudoreward_type==10){
    var state_images=['GamifiedMapsType10/Slide1.png','GamifiedMapsType10/Slide2.png','GamifiedMapsType10/Slide3.png','GamifiedMapsType10/Slide4.png','GamifiedMapsType10/Slide5.png','GamifiedMapsType10/Slide6.png']
    gamified_flight_map='<div align="center"><img src="images/GamifiedMapsType10/Slide1.png" width=400></div>'
    max_reward_rate=0.25
    min_reward_rate=-7/3
    }
    else if (pseudoreward_type==11){
        var state_images= ['GamifiedMapsType11/Slide1.png','GamifiedMapsType11/Slide2.png','GamifiedMapsType11/Slide3.png','GamifiedMapsType11/Slide4.png','GamifiedMapsType11/Slide5.png','GamifiedMapsType11/Slide6.png']
    gamified_flight_map='<div align="center"><img src="images/GamifiedMapsType11/Slide1.png" width=400></div>'        
    max_reward_rate=0.25
    min_reward_rate=-7/3
    }
    else if (pseudoreward_type==12){
        var state_images= ['GamifiedMapsType12/Slide1.png','GamifiedMapsType12/Slide2.png','GamifiedMapsType12/Slide3.png','GamifiedMapsType12/Slide4.png','GamifiedMapsType12/Slide5.png','GamifiedMapsType12/Slide6.png']
    gamified_flight_map='<div align="center"><img src="images/GamifiedMapsType12/Slide1.png" width=400></div>'
    
    max_reward_rate=0.25
    min_reward_rate=-7/3
    
    }
}
else{
    pseudoreward_type=0;
    pseudoreward_rate=0
    var state_images=['Maps/Slide1.png','Maps/Slide2.png','Maps/Slide3.png','Maps/Slide4.png','Maps/Slide5.png','Maps/Slide6.png']    
    max_reward_rate=0.25 //The highest possible reward rate in the un-gamified MDP is 10 points per 4 moves
    min_reward_rate=-7/3 //The worst policy converges on a cycle with reward rate -70 points per 3 moves
    test_images=['test1_no_stars.png','test2_no_stars.png','test3_no_stars.png', 'test4_no_stars.png', 'test5_no_stars.png', 'test1_no_stars.png']
}
flight_map='<div align="center"><img src="images/Maps/Slide1.png" width=400></div>'
    
var storyline = '<h1>Instructions</h1> <p class="block-text"> Congratulations! You have secured a new job as Trainee flight planner for Oceanic Airlines. You are now in charge of flying aircraft <i>Skyfleet S570</i> across the world. Oceanic Airlines operates between 6 different locations. From each location, there are two possible destinations, and <b>you have to choose which one to fly to</b>. Some flights are more profitable than others and you earn a small fraction of the profit or loss of each of your flights. <b>The map below shows the six different locations, the flights that connect them and how much extra money you earn or lose for flying them.</b></p>' + flight_map;

if (points_per_star>0){
    var incentives = '<h1>Your Bonus Payment</h1><p class="block-text">Your task in this HIT is to score as high as possible. Your score depends on the amount of money you have earned and the number of &#9734;s you have collected. </p><p class="hint">You receive '+points_per_dollar+' points per &#36; and '+points_per_star+' points per &#9734;. Hence, in terms of points, <u><b>1&#9734; is worth &#36;'+Math.round(100*points_per_star/points_per_dollar)/100+'</u></b>.</p> <p class="block-text"> When you submit the HIT you will receive a bonus payment that reflects how much money you made in the game.<b>The more money you make in the game the more money you will get.</b> The top 1 percent of the players will receive &#36;2, the second percentile will receive &#36;1.98 ,..., the 50th percentile will receive &#36;1, ... , and the worst 1 percent will receive a bonus of 2 cents. <b>If you play well the pilot will earn about &#36;1.5 and 100&#9734;s per trial <u>on average</u></b>, but since the starting point and the end of the game are determined at random, you will sometimes lose points even if you do the best thing possible. </p> <p class="block-text">'
}
else{
    var incentives = '<p class="block-text">When you submit the HIT, <b>you will receive a bonus payment that reflects how much money you managed to earn relative to the performance of other players</b>. The top 1 percent of the players will receive &#36;2, the second percentile will receive &#36;1.98 ,..., the 50th percentile will receive &#36;1, ... , and the worst 1 percent will receive a bonus of 2 cents. <b>If you play well the pilot will earn about &#36;1.5 per trial <u>on average</u></b>, but since the starting point and the end of the game are determined at random, you will sometimes lose points even if you do the best thing possible. </p> <p class="hint"> Please note that <b>we will determine your financial bonus solely based on how much money you win in the game</b>. The number of stars you collect and Hoban\'s rank do <u>not</u> influence your bonus.</p>'
}//Your performance will be evaluated relative to the performance of other people playing the same version of the game. Hence, as long as you play as well as possible you will receive a high bonus even if you are constantly losing points. Conversely, winning points does not guarantee that you will receive a high bonus. To receive a high bonus you have to play better than the other people.

if (gamified){
    star_story='<h2>Become a star by collecting &#9734;s</h2><p class="block-text"> Pilots sometimes make poor, short-sighted decisions by avoiding costly flights to destinations from which profitable routes are available. To help the pilots make more money and avoid such errors the airline has hired experts on human performance to design a decision support system. The system rates each flight by a certain number of &#9734;s based on the profit of the best flight available from its destination, the best flight available after that, and so on. The map below shows how many &#9734;s you receive for each flight:</p>' + gamified_flight_map + '<p class="block-text"><b>The stars are there to help <u>you</u>. The difference between the number of &#9734;s for flying to A versus B tells you how many more &#36; you can earn starting from A than from B.</b> The amount of money you earn is the sum of the money you get for flying to A or B plus the money you can earn from there. Therefore please consider the following hint: </b> </p> <p class="hint">The best flight is the one for which the sum of &#9734;s + &#36;s is highest. Hence, to earn the most simply <b>add the stars to the dollars and choose the flight for which the sum is highest</b>.</p>'+ '<p class="block-text"> To encourage pilots to pay attention to the stars the company promotes pilots who collect many &#9734;s. Hoban is currently a <i>'+badges[level]+'</i> but if he collects enough &#9734;s he can rise up to the rank of <i>'+badges[badges.length-1]+'</i>.</p> ' 
    //Pilots sometimes make poor, short-sighted decisions by avoiding flights that are helpful in the long run just because they are individually costly. To help the pilots avoid such errors and make more money, the airline has hired experts on human performance to design a star system that rates flights based on how valuable they will be to the pilot in the long run. If a route has 10 ☆s, for example, it means that by taking the flight you can earn $10."
    
    //If flying to A earns more &#9734;s than flying to B then the flights available from A allow you to make more money than the flights available from B, either immediately or several steps later. For instance, if one flight earns 5 &#9734;s more than the other, then you can make &#36;5 more starting from its destination than if you started from the other destination. Conversely, if flying to A earned 3 &#9734;s less than flying to B, then being in A is &#36;3 less valuable than being in B. In brief, 
}
else{
}

incentives+='<p class="block-text"> Have fun and good luck!</p>'

instruction_text='<p class="block-text">You will play the game for 24 rounds. In each round, you start from a different random location. Your task is to choose a sequence of flights that maximizes your earnings until the end of the game.</p> <p class="block-text"> Oceanic Airlines is trying to sell <i>Skyfleet S570</i> and other airplanes to consolidate its finances. After each flight there is a 1 in 6 chance that the airplane you just flew will be sold. Hence, every flight has a 1 in 6 chance of being your last flight. Conversely, there will always be a 5 in 6 chance that there will be at least one more flight. Therefore, <b>the game can end at any time, but it is always five times more likely to continue</b>.</p>'


var max_bonus=2;

var states=[1,2,3,4,5,6];
nr_states=states.length;

function randomState(){
    return _.sample(states)
}


//Transition matrix
nr_actions=2;

transition_matrices = new Array(nr_actions);

transition_matrices[0]=[[0,1,0,0,0,0],[0,0,1,0,0,0],[0,0,0,1,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1],[1,0,0,0,0,0]]
transition_matrices[1]=[[0,0,0,1,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1],[0,1,0,0,0,0],[1,0,0,0,0,0],[0,0,1,0,0,0]]


//Rewards
small_positive=3
small_negative=-3
large_positive=14
large_negative=-7

rewards = new Array()
rewards[0] = [0,large_positive,0,small_positive,0,0]
rewards[1] = [0,0,small_negative,0,large_negative,0]
rewards[2] = [0,0,0,small_negative,0,large_negative]
rewards[3] = [0,small_positive,0,0,small_negative,0]
rewards[4] = [large_negative,0,0,0,0,small_negative]
rewards[5] = [small_negative,0,small_positive,0,0,0]

//Optimal pseudorewards
optimal_pseudorewards=new Array();
optimal_pseudorewards.push([13,1,3,4,6,10]); optimal_pseudorewards.push([28,16,18,19,21,25]); optimal_pseudorewards.push([26,13,15,17,19,22]); optimal_pseudorewards.push([24,12,14,15,17,21]); optimal_pseudorewards.push([22,9,11,13,15,18]); optimal_pseudorewards.push([18,6,8,9,11,14]);


//Pseudorewards that violate the shaping theorem
heuristic_pseudorewards=new Array();
heuristic_pseudorewards.push([0,0,0,0,0,0]); heuristic_pseudorewards.push([36,0,0,0,36,36]); heuristic_pseudorewards.push([36,0,0,0,36,36]); heuristic_pseudorewards.push([36,0,0,0,36,36]); heuristic_pseudorewards.push([36,0,0,0,0,0]); heuristic_pseudorewards.push([36,0,0,0,0,0]);


//Approximate pseudorewards that respect the shaping theorem
approximate_pseudorewards=new Array();
approximate_pseudorewards.push([13,2,2,2,7,7]); approximate_pseudorewards.push([27,16,16,16,21,21]); approximate_pseudorewards.push([27,16,16,16,21,21]); approximate_pseudorewards.push([27,16,16,16,21,21]); approximate_pseudorewards.push([20,9,9,9,14,14]); approximate_pseudorewards.push([20,9,9,9,14,14]);


if (pseudoreward_type==10){
    pseudorewards=optimal_pseudorewards
}
else if (pseudoreward_type==11) {
    pseudorewards=heuristic_pseudorewards
}
else if (pseudoreward_type==12) {
    pseudorewards=approximate_pseudorewards
}


//General parameters
block1={
    training: true,
    has_goal_state: false,
    nr_trials:24,
    p_end: 1/6,
    required_performance: 0,
    has_reward: true,
    p_require_sequence: 0,
    transition_probabilities: transition_matrices,
    rewards: rewards,
    points_per_dollar: points_per_dollar,
    points_per_star: points_per_star,
    pseudoreward_type: pseudoreward_type,
    task: function() {return 'Maximize your earnings!'},
    finished: function() {return trial>this.nr_trials},
    instructions: instruction_text,    
    data: {start: [], states: [], moves: [], reaction_times: [], real_reward:[], pseudo_reward:[], total_reward: [], flight_plans: [], failed_quiz: []}
}

experiment = new Array()
experiment.push(block1)