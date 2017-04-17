// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

required_lengths=[100,100,100,100,50]

$(document).on('ready page:load', function() {
  $('.input-controls').hide();
  $('#completion-code').html('');

  window.activityResponses = {};

  var changeLinks = function() {
    var wrapper = $('.link-wrapper');
    var linkIndex = wrapper.data('link-index') % 10;
    var iconIndex = wrapper.data('index') % 4;
    var icon, title, href, link;

    if (iconIndex == 0) {
      if (linkIndex != 0) {
        iconIndex++;
      } else {
        href = 'http://www.echalk.co.uk/amusements/Games/Tetrominoes/tetrominoes.html';
        title = 'Play Tetris!';
      }
    }

    icon = window.linkImages[iconIndex];

    if (iconIndex != 0) {
      link = window.links[icon[0]][linkIndex];

      href = link[0];
      title = link[1];
    }

    wrapper
      .data('index', iconIndex + 1)
      .html('<a class="external-link" target="_blank" href="' + href + '"><img src="' + icon[1] + '"/><div>' + title + '</div></a>');

    if (iconIndex == 3) {
      wrapper.data('link-index', linkIndex + 1)
    }
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
    var formActivityField = $('#answer_activity_id');
    var currentActivityId = formActivityField.val();
    var formerQuestionId = $('.activity-number').html();
    var textarea = $('#answer_answer');

    if (currentActivityId.length && currentActivityId != activityId) {
      window.activityResponses[formerQuestionId] = textarea.val();
      $.post('/activities/abandon_activity', { a_id: formerQuestionId });
    }

    if (window.activityResponses[questionId]) {
      textarea.val(window.activityResponses[questionId]);
    } else {
      textarea.val('');
    }

    $('.activity-number').html(questionId);
    $('#requiredLength').html(required_lengths[questionId-1])
    formActivityField.val(activityId);

    $.getJSON('/activity_detail/' + activityId, function(activity) {
      $('.input-controls').show();

      var http_link = "https://cocosci.berkeley.edu/mturk/falk/writingTaskRating/WritingTasks/procrastination_task.html?number=" + questionId + "&code=%22" + activity.code + "%22";

      $(".game-content").html('<object id="vigilance" data="' + http_link + '" style="display:table; width:100%; height:100%; overflow:hidden;"/>');
    });

    $.post('/start_activity/' + activityId);
  });

  $('.link-wrapper a').on('click', function() {
    $.post('/start_activity/0', { qid: ($('.link-wrapper').data('index') % 4) + 6 });
  });
});
