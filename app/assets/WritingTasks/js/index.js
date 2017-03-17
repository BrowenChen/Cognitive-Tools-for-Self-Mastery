var stage=0;

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
    $("#recruitment").show()
    stage++
}

function next(){
    if (stage==1){
        
        code = $("#code").val()
        if (checkCode(code)){
            stage++
            $("#recruitment").hide()
            $("#choice").show()
        }
        else{
            alert('The code is incorrect. Please check again to make sure you copied it correctly from the website.')
        }
        
        
    }
    else if (stage==2){
        participate_part2=$("#partb_checkbox").val()=="yes"
            
        if (participate_part2==1){
            $("#choice").hide()
            $("#part2").show()
            stage++;
        }
        else{
            $("#finished").show()
        }
    }
    
    else if (stage==3){    
            
            if ($("#copied_URL").is(":checked")){
                $("#part2").hide()
                $("#finished").show()
                stage++
            }
            else{
                alert("Please open, write down, or bookmark the URL and check the corresponding box to confirm that you have done so.")
            }
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


function checkCode(code){
    code_length = 5
    var check_sum=0
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        
    
    code_end= code.slice(code.length-2,code.length)
    if (code_end != 'V7')
        return false;
    
    
    for (i=0;i<code_length;i++){
        number = possible.indexOf(code[i])
        check_sum += number
    }
    code_checksum=code.slice(code_length+1,code.length-2)
    
    if (code_checksum==check_sum){
        return true
    }
    else{
        return false
    }
}