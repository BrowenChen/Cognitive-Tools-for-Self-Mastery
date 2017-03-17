function likertScale(question,id,labels){
    
    nr_points=labels.length

    likert_scale_html=' <label class="statement">' +question+ '</label>'    
    likert_scale_html+= '<ul class="likert">'
    
    for (p=1;p<=nr_points;p++){
        likert_scale_html+='<li>'
        
        likert_item_html='<input type="radio" id="'+id+'" name="'+id+'" value="'+p+'">'
        likert_item_html+='<label>'+labels[p-1]+'</label>'
        
        likert_scale_html+=likert_item_html+'</li>'
    }
        
    likert_scale_html+='</ul>'
    
    return likert_scale_html;

}

function likertSurvey(question,question_id,items,labels){
    
    var nr_items=items.length
    
    likert_survey_html='<div class="wrap">'
    likert_survey_html+='<h1 class="likert-header">'+question+'</h1>'
    likert_survey_html+='<form id="'+question_id+'" action="">'
    
    for (q=1;q<=nr_items;q++){
        id=question_id+'_item'+q
        likert_survey_html+=likertScale(items[q-1],id,labels)
    }
    
    likert_survey_html+='</form>'
    likert_survey_html+='</div>'
    return likert_survey_html
    
}