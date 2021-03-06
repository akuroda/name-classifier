require './web'
require 'minitest/unit'
require 'rack/test'

MiniTest::Unit.autorun

class ClassifierTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert last_response.ok?
    assert last_response.body.include? 'Bayesian Name Classifier'
  end

  def test_help
    get '/help'
    assert last_response.ok?
    assert last_response.body.include? 'Help'
  end

  def test_json
    get '/json?name=last,first'
    assert last_response.ok?
    assert_includes last_response.content_type, 'application/json'

    c = JSON.parse(last_response.body).fetch('country')
    assert_kind_of Hash, c

    s = JSON.parse(last_response.body).fetch('sex')
    assert_kind_of Hash, s
    assert s.fetch('M')
    assert s.fetch('F')
  end

  def test_json_error
    get '/json'
    assert last_response.status, 400
  end
end
