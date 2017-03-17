function sampleDiscreteDistribution(probabilities){
    //sample outcome from outcome distribution by the inverse distribution function method
    //returns an integer between 0 and probabilities.length-1
    var p=Math.random();
    var nr_outcomes=probabilities.length;
    var cdf=new Array(nr_outcomes);
    cdf[0]=probabilities[0];
    if (cdf[0]>=p){
        first_greater=0;
    }
    else{
        first_greater=nr_outcomes;
    }
    for (o=1;o<nr_outcomes;o++){
        cdf[o]=cdf[o-1]+probabilities[o];
        
        if (cdf[o]>=p && o<first_greater){
            first_greater=o;
        }
    }
    
    var sampled_outcome=first_greater;
    return sampled_outcome;
}

function sum(vector){
    
    sum_of_elements=0;
    for (i=0; i<vector.length; i++){
        sum_of_elements+=vector[i];
    }
    return sum_of_elements
    
}