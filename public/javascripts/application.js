// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var QuestionForm = {
  editNewTitle: function(txtField) {
    $('new_question').innerHTML = (txtField.value.length > 5) ? txtField.value : 'New Question';
  }
}

var LoginForm = {
  setToPassword: function() {
    $('openid_fields').hide();
    $('password_fields').show();
  },
  
  setToOpenID: function() {
    $('password_fields').hide();
    $('openid_fields').show();
  }
}

var EditForm = {
  // show the form
  init: function(answerId) {
    $('edit-answer-' + answerId + '_spinner').show();
    this.clearReplyId();
  },

  // sets the current answer id we're editing
  setReplyId: function(answerId) {
    $('edit').setAttribute('answer_id', answerId.toString());
    $('answer_' + answerId + '-row').addClassName('editing');
    if($('reply')) $('reply').hide();
  },
  
  // clears the current answer id
  clearReplyId: function() {
    var currentId = this.currentReplyId()
    if(!currentId || currentId == '') return;

    var row = $('answer_' + currentId + '-row');
    if(row) row.removeClassName('editing');
    $('edit').setAttribute('answer_id', '');
  },
  
  // gets the current answer id we're editing
  currentReplyId: function() {
    return $('edit').getAttribute('answer_id');
  },
  
  // checks whether we're editing this answer already
  isEditing: function(answerId) {
    if (this.currentReplyId() == answerId.toString())
    {
      $('edit').show();
      $('edit_answer_body').focus();
      return true;
    }
    return false;
  },

  // close reply, clear current reply id
  cancel: function() {
    this.clearReplyId();
    $('edit').hide()
  }
}

var ReplyForm = {
  // yes, i use setTimeout for a reason
  init: function() {
    EditForm.cancel();
    $('reply').toggle();
    $('answer_body').focus();
    // for Safari which is sometime weird
//    setTimeout('$(\"answer_body\").focus();',50);
  }
}

Event.addBehavior({
  '#search,#monitor_submit': function() { this.hide(); }
})