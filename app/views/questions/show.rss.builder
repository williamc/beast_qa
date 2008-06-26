xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"

xml.rss "version" => "2.0",
  'xmlns:opensearch' => "http://a9.com/-/spec/opensearch/1.1/",
  'xmlns:atom'       => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Recent Answers in '{question}' | Beast"[:recent_answers_in_question,@question.title]
    xml.link question_url(@category, @question)
    xml.language "en-us"[:feed_language]
    xml.ttl "60"
    xml.tag! "atom:link", :rel => 'search', :type => 'application/opensearchdescription+xml', :href => "http://#{request.host_with_port+request.relative_url_root}/open_search.xml"
    xml.description @question.body

    render :partial => "layouts/answer", :collection => @answers, :locals => {:xm => xml}
  end
end
