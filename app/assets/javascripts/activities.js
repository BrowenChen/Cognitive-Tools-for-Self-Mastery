// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(document).on('ready page:load', function() {
  $('.input-controls').hide();
  $('#completion-code').html('');

  $('.retry-button').on('click', function() {
    $('#fail-message').hide();
    $('.input-controls').show();
  });

  $('.code-confirmation input').on('keyup', function() {
    $.getJSON('/activities/' + this.value + '/by_code', function(activity) {
      if (activity && activity.id.toString() == $('#answer_activity_id').val()) {
        $('.finish_container button').show();
      }
    });
  });

  $('.finish_container button').on('click', function() {
    var activityId = $('#answer_activity_id').val();

    $.get('/finish_cur_activity/' + activityId);
  });

  $('.activity-item').on('click', function() {
    $('#update_score_btn').hide();

    var activityId = $(this).parent().data('activity-id');
    var questionId = $(this).parent().data('question-id');

    $('.activity-number').html(questionId);
    $('#answer_activity_id').val(activityId);

    $.getJSON('/activity_detail/' + activityId, function(activity) {
      $('.input-controls').show();

      var http_link = "https://cocosci.berkeley.edu/mturk/falk/writingTaskRating/WritingTasks/procrastination_task.html?number=" + questionId + "&code=%22" + activity.code + "%22";

      $(".game-content").html('<object id="vigilance" data="' + http_link + '" style="display:table; width:100%; height:100%; overflow:hidden;"/>');
    });

    $.post('/start_activity/' + activityId);
  });
});
