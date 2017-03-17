code_task1='XTDG793GHJ'
code_task2='CDSF263DF'
code_task3='GWEFA1452'

completed=[false,false,false]

function startTask(task_number){
    $("#instructions").hide()
    $("#task"+task_number).show()
    $("#afterTask").show()
}

window.addEventListener("message", receiveMessage, false);

function receiveMessage(event)
{
  alert(event.message)
}

function submitCode(){
    entered_code=$("#code").val()
    if (entered_code==code_task1 || entered_code==code_task2 || entered_code==code_task3){
        
        if (entered_code==code_task1){
            completed[0]=true;
            $("#task1").hide()
            $("#button1").prop("disabled",true)
        }
        else if (entered_code==code_task2){
            completed[1]=true;
            $("#task2").hide()
            $("#button2").prop("disabled",true)
        }
        else{
            completed[2]=true;
            $("#task3").hide()
            $("#button3").prop("disabled",true)            
        }
        
        if (completed[0] && completed[1]){
            $("#instruction_text").html('Congratulations! You have completed both tasks. Please copy the following code and paste it into our HIT on Mechanical and you are all set: <strong>'+generateCode()+'</strong>')
            $("#task_buttons").hide()
            $("#code")
        }
        else{        
            $("#instruction_text").html('Congratulations! You have completed one of the tasks. Now please complete another task you have not completed before.')
        }
        
        $("#after_task").hide()
        $("#instructions").show()
        $("#afterTask").hide()

    }
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