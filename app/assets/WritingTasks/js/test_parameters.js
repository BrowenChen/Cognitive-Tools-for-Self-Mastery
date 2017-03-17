nr_actions=2;

var transition_matrices = new Array(nr_actions);

transition_matrices[0]=[[0,1,0,0,0,0],[0,0,1,0,0,0],[0,0,0,1,0,0],[0,0,0,0,1,0],[0,0,0,0,0,1],[1,0,0,0,0,0]]
transition_matrices[1]=[[0,0,0,0,0,1],[1,0,0,0,0,0],[0,1,0,0,0,0],[0,0,1,0,0,0],[0,0,0,1,0,0],[0,0,0,0,1,0]]




reward_types=[[small_negative,small_positive],[large_positive,large_negative]];
p_reward_magnitude=[0.8,0.2];
p_reward_valence=[0.5,0.5];



var rewards=new Array()

for (from=0;from<nr_states;from++){
    rewards[from]=new Array();
    for (to=0;to<nr_states;to++){
                        
        magnitude=sampleDiscreteDistribution(p_reward_magnitude);
        valence=sampleDiscreteDistribution(p_reward_valence);
                
        rewards[from][to]=reward_types[magnitude][valence];
    }
}