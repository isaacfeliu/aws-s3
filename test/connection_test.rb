require File.dirname(__FILE__) + '/test_helper'

class ConnectionTest < Test::Unit::TestCase
  def setup
    @keys = {:access_key_id => '123', :secret_access_key => 'abc'}
  end
  
  def test_creating_a_connection
    connection = Connection.new(@keys)
    assert_kind_of Net::HTTP, connection.http
  end
  
  def test_use_ssl_option_is_set_in_connection
    connection = Connection.new(@keys.merge(:use_ssl => true))
    assert connection.http.use_ssl?
  end
  
  def test_setting_port_to_443_implies_use_ssl
    connection = Connection.new(@keys.merge(:port => 443))
    assert connection.http.use_ssl?
  end
  
  def test_protocol
    connection = Connection.new(@keys)
    assert_equal 'http://', connection.protocol
    connection = Connection.new(@keys.merge(:use_ssl => true))
    assert_equal 'https://', connection.protocol
  end
  
  def test_connection_is_persistent_by_default
    connection = Connection.new(@keys)
    assert connection.persistent?
    
    connection = Connection.new(@keys.merge(:persistent => false))
    assert !connection.persistent?
  end
  
  def test_server_and_port_are_passed_onto_connection
    connection = Connection.new(@keys)
    options    = connection.instance_variable_get('@options')
    assert_equal connection.http.address, options[:server]
    assert_equal connection.http.port, options[:port]
  end
  
  def test_not_including_required_access_keys_raises
    assert_raises(MissingAccessKey) do
      Connection.new
    end
    
    assert_raises(MissingAccessKey) do
      Connection.new(:access_key_id => '123')
    end
    
    assert_nothing_raised do
      Connection.new(@keys)
    end
  end
  
  def test_access_keys_extracted
    connection = Connection.new(@keys)
    assert_equal '123', connection.access_key_id
    assert_equal 'abc', connection.secret_access_key
  end
  
  def test_request_method_class_lookup
    c = Connection.new(@keys)
    expectations = {
     :get  => Net::HTTP::Get, :post   => Net::HTTP::Post,
     :put  => Net::HTTP::Put, :delete => Net::HTTP::Delete,
     :head => Net::HTTP::Head
    }
    
    expectations.each do |verb, klass|
      assert_equal klass, c.send(:request_method, verb)
    end
  end

  def test_url_for_uses_default_protocol_server_and_port
    connection = Connection.new(:access_key_id => '123', :secret_access_key => 'abc', :port => 80)
    assert_match %r(^http://mybucket\.s3\.amazonaws\.com/foo\?), connection.url_for('/foo', 'mybucket')

    connection = Connection.new(:access_key_id => '123', :secret_access_key => 'abc', :use_ssl => true, :port => 443)
    assert_match %r(^https://mybucket\.s3\.amazonaws\.com/foo\?), connection.url_for('/foo', 'mybucket')
  end

  def test_url_for_remembers_custom_protocol_server_and_port
    connection = Connection.new(:access_key_id => '123', :secret_access_key => 'abc', :server => 'example.org', :port => 555, :use_ssl => true)
    assert_match %r(^https://mybucket\.example\.org:555/foo\?), connection.url_for('/foo', 'mybucket')
  end

  def test_url_for_with_and_without_authenticated_urls
    connection = Connection.new(:access_key_id => '123', :secret_access_key => 'abc', :server => 'example.org')
    authenticated = lambda {|url| url['?AWSAccessKeyId']}
    assert authenticated[connection.url_for('/foo', 'mybucket')]
    assert authenticated[connection.url_for('/foo', 'mybucket', :authenticated => true)]
    assert !authenticated[connection.url_for('/foo', 'mybucket', :authenticated => false)]
  end
  
  def test_connecting_through_a_proxy
    connection = nil
    assert_nothing_raised do
      connection = Connection.new(@keys.merge(:proxy => sample_proxy_settings))
    end
    assert connection.http.proxy?
  end
end

class ConnectionOptionsTest < Test::Unit::TestCase
  
  def setup
    @options = generate_options(:server => 'example.org', :port => 555)
    @default_options = generate_options
  end
  
  def test_server_extracted
    assert_key_transfered(:server, 'example.org', @options)
  end
  
  def test_port_extracted
    assert_key_transfered(:port, 555, @options)
  end
  
  def test_server_defaults_to_default_host
    assert_equal DEFAULT_HOST, @default_options[:server]
  end
  
  def test_port_defaults_to_80_if_use_ssl_is_false
    assert_equal 80, @default_options[:port]
  end
  
  def test_port_is_set_to_443_if_use_ssl_is_true
    options = generate_options(:use_ssl => true)
    assert_equal 443, options[:port]
  end
  
  def test_explicit_port_trumps_use_ssl
    options = generate_options(:port => 555, :use_ssl => true)
    assert_equal 555, options[:port]
  end
  
  def test_invalid_options_raise
    assert_raises(InvalidConnectionOption) do
      generate_options(:host => 'campfire.s3.amazonaws.com')
    end
  end
  
  def test_not_specifying_all_required_proxy_settings_raises
    assert_raises(ArgumentError) do
      generate_options(:proxy => {})
    end
  end
  
  def test_not_specifying_proxy_option_at_all_does_not_raise
    assert_nothing_raised do
      generate_options
    end
  end
  
  def test_specifying_all_required_proxy_settings
    assert_nothing_raised do
      generate_options(:proxy => sample_proxy_settings)
    end
  end
  
  def test_only_host_setting_is_required
    assert_nothing_raised do
      generate_options(:proxy => {:host => 'http://google.com'})
    end
  end
  
  def test_proxy_settings_are_extracted
    options = generate_options(:proxy => sample_proxy_settings)
    assert_equal sample_proxy_settings.values.map {|value| value.to_s}.sort, options.proxy_settings.map {|value| value.to_s}.sort
  end
  
  def test_recognizing_that_the_settings_want_to_connect_through_a_proxy
    options = generate_options(:proxy => sample_proxy_settings)
    assert options.connecting_through_proxy?
  end
  
  private
    def assert_key_transfered(key, value, options)
      assert_equal value, options[key]
      assert !options.instance_variable_get('@options').has_key?(key)
    end
      
    def generate_options(options = {})
      Connection::Options.new(options)
    end
end
