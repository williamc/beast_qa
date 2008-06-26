xm.item do
  key = post.question.posts.size == 1 ? :question_posted_by : :question_replied_by
  xm.title "{title} posted by {user} @ {date}"[key, h(post.respond_to?(:question_title) ? post.question_title : post.question.title), h(post.user.login), post.created_at.rfc822]
  xm.description post.body_html
  xm.pubDate post.created_at.rfc822
  xm.guid [request.host_with_port+request.relative_url_root, post.category_id.to_s, post.question_id.to_s, post.id.to_s].join(":"), "isPermaLink" => "false"
  xm.author "#{post.user.login}"
  xm.link question_url(post.category_id, post.question_id)
end
