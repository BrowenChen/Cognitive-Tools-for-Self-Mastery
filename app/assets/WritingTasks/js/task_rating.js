//Set Parameters

task_names=['Arrows','Color Words','Tetris','Target Detection','Card Sorting','Card Sorting']
task_paths=['Flanker/index.html','Stroop/templates/index.html','Tetris/index.html','Vigilance/index.html','WCST/wisconsin.html','WCST2/wisconsin.html']

codes=new Array()
for (t=0;t<task_names.length;t++)
    codes.push(generateCode())

task1_name=task_names[task1];
task2_name=task_names[task2];
task1_path=task_paths[task1];
task2_path=task_paths[task2];
code_task1=codes[task1];
code_task2=codes[task2];


//Set values according to parameters
$('#task1_iframe').attr('src',task1_path+'?duration='+duration1+'&code=\"'+code_task1+'\"')
$('#task2_iframe').attr('src',task2_path+'?duration='+duration2+'&code=\"'+code_task2+'\"')
$('#button1').html(task1_name)
$('#button2').html(task2_name)
$('#task1_name').html(task1_name)
$('#task2_name').html(task2_name)

task_nr=1;
nr_tasks=2
var nr_items=[3,3,3]
completed=[false,false]
answers=new Array();

delta_min=0
delta_max=1;
delta=delta_max;

function checkConsent(){
    
    if ($('#consent_checkbox').is(':checked')) {
        startExperiment()
    }
    else {
            alert("If you wish to participate, you must check the box next to the statement 'I agree to participate in this study.'");
            return false;
    }
    return false;

}

function startExperiment(){
    $("#consent").hide()
    $("#instructions").show()
}

function startTask(task_number){
    $("#instructions").hide()
    $("#task"+task_number).show()
    $("#afterTask").show()
}

function submitCode(){
    entered_code=$("#code").val()
    $("#code").val('')

    if ( (entered_code==code_task1 && task_nr==1) || (entered_code==code_task2 && task_nr==2)){
        
        
        if (entered_code==code_task1){
            completed[0]=true;
            $("#task1").hide()
            $("#button1").prop("disabled",true)
            for (i=0; i<survey_ids.length;i++)
                survey_ids[i]='task1_'+survey_id_stems[i]
            
            $("#button2").removeAttr('disabled')
            $("#button1").attr('disabled',true)
        }
        else if (entered_code==code_task2){
            completed[1]=true;
            $("#task2").hide()
            $("#button2").prop("disabled",true)
            
            for (i=0; i<survey_ids.length;i++)
                survey_ids[i]='task2_'+survey_id_stems[i]

            $("#button2").attr('disabled',true)
        }
        
        if (completed[0] && completed[1]){
            $("#instruction_text").html('Please tell us which task you preferred and by how much.')
            $("#task_buttons").hide()                        
        }
        else{        
            $("#instruction_text").html('Congratulations! You have completed one of the tasks. Now please complete another task you have not completed before.')
        }
        
        
        //$("#survey1").html(likertSurvey('',survey_ids[0],entertainment_items,labels_entertaining))
        $("#survey1").html(likertSurvey('',survey_ids[0],enjoyment_items,labels_enjoyable))
        $("#survey2").html(likertSurvey('',survey_ids[1],frustration_items,labels_frustration))
        $("#survey3").html(likertSurvey('',survey_ids[2],boredom_items,labels_boring))
        $("#survey4").html(likertSurvey('',survey_ids[3],unpleasant_items,labels_unpleasant))
        $("#survey5").html(likertSurvey('',survey_ids[4],annoyance_items,labels_annoying))
        $("#survey6").html(likertSurvey('',survey_ids[5],procrastination_question,labels_procrastination))
        
        $("#rating_survey").show()
                
        $("#after_task").hide()
        //$("#instructions").show()
        $("#afterTask").hide()
                
    }
}

function startElicitation(){
           
    if (!$("input:radio[name='Preference']").is(":checked"))
        alert('To proceed please select which task you liked better!')
    else{
       preferred_task=$(":input[id='Preference']:checked").val()
       if (preferred_task==1){
           $('.preferred_task').html(task1_name)
            $('.disliked_task').html(task2_name)
        }
        else{
            $('.preferred_task').html(task2_name)
            $('.disliked_task').html(task1_name)
        }
    
        $("#delta_text").html(delta)
        $("#elicitation").show()
        $("#preference_question").hide()
    }
}

function elicit(){
    
    if (!$("input:radio[name='PreferenceWithBonus']").is(":checked"))
        alert('To proceed please select the option that you would prefer!')
    else{        
        preference_with_bonus=$(":input[id='PreferenceWithBonus']:checked").val()
        delta_old=delta
        if (preference_with_bonus==-1){
            //no change
            delta_min=delta;
            if (delta==delta_max){
                delta_max*=2
                delta=delta_max
            }
            else{
                delta=delta+(delta_max-delta)/2
            }            
        }
    
        if (preference_with_bonus==0){//indifference point found
            indifference_point=delta
            finish()
        }
    
        if (preference_with_bonus==1){//delta > difference in preferences
            delta_max=delta
            delta=delta_min+(delta-delta_min)/2
        }
    
        if (Math.abs(delta-delta_old)<0.01){
            indifference_point=delta
            finish()
        }
    
        $("#delta_text").html(delta)
        $("input:radio[name='PreferenceWithBonus']").prop('checked', false)
    }
}

function finish(){
    
    preferred_task=$(":input[id='Preference']:checked").val()
    difference_dollars=$("#utility_difference_dollars").val()
    difference_cents=  $("#utility_difference_cents").val()
    
    //answers.push(new Array())        
    //answers[nr_tasks].push(preferred_task)
    //answers[nr_tasks].push(difference_dollars)
    //answers[nr_tasks].push(difference_cents)
    
    data={
        answers: answers,
        survey_questions: survey_id_stems,
        task1: task1_path,
        task2: task2_path,
        duration1: duration1,
        duration2: duration2,
        preferred_task: preferred_task,
        indifference_point: indifference_point
    }
    
    //$("#instruction_text").html('Congratulations! This was our last question. Please copy the following code and paste it into our HIT on Mechanical and you are all set: <strong>'+generateCode()+'</strong>')
    
    turk.submit(data)
    
}

function generateCode(){
    var code_length=5
    var code = "";
    var checksum = 0
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for( var i=1; i <= code_length; i++ ){
        number = Math.floor(Math.random() * possible.length)
        code += possible.charAt(number);
        checksum+=number;
    }
    code += 'T'+checksum +'V7';

    return code;
}

function recordAnswers(t){
    
        //Check if questions have been answered
        //1. Check if all questions have been answered
        all_checked=true;
        for (i=1;i<=nr_items[t];i++){
            if(!$("input:radio[name='"+survey_ids[i-1]+"_item"+1+"']").is(":checked")){
                all_checked=false;
            }
        }
    
        if (!all_checked){
            alert('Before you can proceed you have to answer all questions.')
            return;
        }

        answers.push(new Array());

        for (i=1;i<=nr_items[t];i++){
            response = $('input[id='+survey_ids[i-1]+'_item'+1+']:checked', '#'+survey_ids[i-1]).val()
            answers[t-1].push(response)  
        }
    task_nr++;
    
    if (task_nr==3){
        $('#task_comparison').show()
    }
    
    $('#instructions').show();
    $('#rating_survey').hide()
}