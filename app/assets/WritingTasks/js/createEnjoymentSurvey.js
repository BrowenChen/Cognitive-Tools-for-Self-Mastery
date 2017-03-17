labels_enjoyable=['much less enjoyable','','','','equally enjoyable','','','','much more enjoyable']
//labels_entertaining=['not at all entertaining','','','','somewhat entertaining','','','','extremely entertaining']
labels_boring=['much less boring','','','','equally boring','','','','much more boring']
labels_annoying=['much less annoying','','','','equally annoying','','','','much more annoying']
labels_unpleasant=['much less unpleasant','','','','equally unpleasant','','','','much more unpleasant']
labels_frustration=['much less frustrating','','','','equally frustrating','','','','much more frustrating']
labels_procrastination=['not at all','','','','maybe','','','','definitely']

enjoyment_items=['How enjoyable was the task compared to a typical HIT on MTurk?']
//entertainment_items=['How entertaining was the task?']
boredom_items=['How boring was the task compared to a typical HIT on MTurk?']
unpleasant_items=['How unpleasant was the task compared to a typical HIT on MTurk?']
frustration_items=['How frustrating was this task compared to a typical HIT on MTurk?']
annoyance_items=['How annoying was this task compared to a typical HIT on MTurk?']
procrastination_question=['If I had to do this task again I would postpone it.']

survey_id_stems=['enjoyment','frustration','boredom','unpleasantness','annoyance','procrastination']
survey_ids=['enjoyment','frustration','boredom','unpleasantness','annoyance','procrastination']

enjoyment_survey=likertSurvey('',survey_ids[0],enjoyment_items,labels_enjoyable)
//affect_survey=likertSurvey(affect_question,affect_items,labels)
//engagement_survey=likertSurvey(fullfilment_question,fulllfilment_items,labels)

//$("#survey1").html(enjoyment_survey)
//$("#survey2").html(likertSurvey('',survey_ids[1],entertainment_items,labels_entertaining))
//$("#survey3").html(likertSurvey('',survey_ids[2],boredom_items,labels_boring))

nr_items=[6,6,6]

survey_nr=1;
nr_surveys=3