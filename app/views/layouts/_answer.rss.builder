xm.item do
  key = answer.question.answers.size == 1 ? :question_answered_by : :question_replied_by
  xm.title "{title} answered by {user} @ {date}"[key, h(answer.respond_to?(:question_title) ? answer.question_title : answer.question.title), h(answer.user.login), answer.created_at.rfc822]
  xm.description answer.body_html
  xm.pubDate answer.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, answer.category_id.to_s, answer.question_id.to_s, answer.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{answer.user.login}"
  xm.link question_url(answer.category_id, answer.question_id)
end
