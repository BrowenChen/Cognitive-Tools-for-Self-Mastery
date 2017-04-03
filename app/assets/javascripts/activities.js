// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

required_lengths=[100,100,100,100,50]

$(document).on('ready page:load', function() {
  $('.input-controls').hide();
  $('#completion-code').html('');

  var changeLinks = function() {
    ['youtube', 'reddit', 'news'].forEach(function(site) {
      var anchor = $('.' + site + '-link');
      var index = (anchor.data('link-index') + 1) % 10;
      var link = window.links[site][index];

      anchor
        .attr('href', link[0])
        .attr('title', link[1])
        .data('link-index', index);
    });
  };

  setInterval(changeLinks, 60000);
  changeLinks();

  $('.retry-button').on('click', function() {
    $('#fail-message').hide();
    $('.input-controls').show();
  });

  $('.activity-item').on('click', function() {
    $('#update_score_btn').hide();

    var activityId = $(this).parent().data('activity-id');
    var questionId = $(this).parent().data('question-id');

    $('.activity-number').html(questionId);
    $('#requiredLength').html(required_lengths[questionId-1])
    $('#answer_activity_id').val(activityId);

    $.getJSON('/activity_detail/' + activityId, function(activity) {
      $('.input-controls').show();

      var http_link = "https://cocosci.berkeley.edu/mturk/falk/writingTaskRating/WritingTasks/procrastination_task.html?number=" + questionId + "&code=%22" + activity.code + "%22";

      $(".game-content").html('<object id="vigilance" data="' + http_link + '" style="display:table; width:100%; height:100%; overflow:hidden;"/>');
    });

    $.post('/start_activity/' + activityId);
  });
});
