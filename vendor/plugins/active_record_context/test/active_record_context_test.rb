require File.join(File.dirname(__FILE__), 'abstract_unit')

class ActiveRecordContextTest < Test::Unit::TestCase
  def setup
    Answer.destroy_all
    @answers = []
    @question = Question.create! :title => 'test'
    @answers << NormalAnswer.create!(:body => 'normal body', :question => @question)
    @answers << PolymorphAnswer.create!(:body => 'polymorph body', :question => @question)
    assert_equal 2, @answers.size
    assert_equal 2, Answer.count
    assert_nil Answer.context_cache
  end

  def test_should_initialize_context_cache_hash
    Answer.with_context do
      assert_kind_of Hash, Answer.context_cache
      assert_equal 0, Answer.context_cache.size
    end
    assert_nil Answer.context_cache
  end

  def test_should_store_records_in_cache
    Answer.with_context do
      records = Answer.find(:all)
      assert_equal 2, Answer.context_cache[Answer].size
      assert_equal @answers[0], Answer.cached[@answers[0].id]
      assert_equal @answers[1], Answer.cached[@answers[1].id]
    end
  end

  def test_should_store_records_in_base_class_cache
    Answer.with_context do
      records = NormalAnswer.find(:all)
      assert Answer.context_cache[NormalAnswer].nil?
      assert_equal @answers[0], NormalAnswer.cached[@answers[0].id]
      assert_equal 1, Answer.context_cache[Answer].size
      assert_equal @answers[0], Answer.cached[@answers[0].id]
    end
  end

  def test_should_find_records_in_context
    Answer.with_context do
      records = Answer.find(:all)
      Answer.destroy_all
      assert_equal @answers[0], Answer.find(@answers.first.id)
      assert_equal @answers[1], Answer.find(@answers.last.id)
    end
    
    assert_raise ActiveRecord::RecordNotFound do
      Answer.find 1
    end
  end
  
  def test_should_find_belongs_to_record
    Answer.with_context do
      Question.find :all ; Question.delete_all
      assert_equal @question, @answers[0].question(true)
    end
    
    assert_equal @question, @answers[0].question
    assert_nil @answers[0].question(true)
  end
  
  def test_should_find_belongs_to_polymorphic_record
    Answer.with_context do
      Question.find :all ; Question.delete_all
      assert_equal @question, @answers[1].question(true)
    end
    
    assert_equal @question, @answers[1].question
    assert_nil @answers[1].question(true)
  end
  
  def test_default_prefetch_methods
    {Question => 'question_id', Answer => 'answer_id'}.each do |klass, expected|
      assert_equal expected, klass.prefetch_default
    end
  end
  
  def test_should_prefetch_ids
    Question.expects(:find).with(:all, :conditions => {:id => [1,2,3]})
    Question.prefetch [1,2,3]
  end
  
  def test_should_prefetch_by_parent_records
    Question.expects(:find).with(:all, :conditions => {:id => [@question.id]})
    Question.prefetch @answers
  end
  
  def test_should_reload_record
    Answer.with_context do
      @answer = Answer.find @answers.first.id
      assert_equal 'normal body', @answer.body
      Answer.update_all ['body = ?', 'foo bar']
      assert_equal 'foo bar', @answer.reload.body
    end
  end
end
