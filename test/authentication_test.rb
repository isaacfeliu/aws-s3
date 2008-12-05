require File.dirname(__FILE__) + '/test_helper'

class HeaderAuthenticationTest < Test::Unit::TestCase  
  def test_encoded_canonical
    signature = Authentication::Signature.new(request, key_id, secret, current_host)
    assert_equal AmazonDocExampleData::Example1.canonical_string, signature.send(:canonical_string)
    assert_equal AmazonDocExampleData::Example1.signature, signature.send(:encoded_canonical)
  end
  
  def test_authorization_header
    header = Authentication::Header.new(request, key_id, secret, current_host)
    assert_equal AmazonDocExampleData::Example1.canonical_string, header.send(:canonical_string)
    assert_equal AmazonDocExampleData::Example1.authorization_header, header
  end
  
  private
    def request     ; AmazonDocExampleData::Example1.request end
    def key_id      ; AmazonDocExampleData::Example1.access_key_id end
    def secret      ; AmazonDocExampleData::Example1.secret_access_key end
    def current_host; AmazonDocExampleData::Example1.current_host end
end

class QueryStringAuthenticationTest < Test::Unit::TestCase
  def test_query_string
    query_string = Authentication::QueryString.new(request, key_id, secret, current_host, :expires_in => 60)
    assert_equal AmazonDocExampleData::Example3.canonical_string, query_string.send(:canonical_string)
    assert_equal AmazonDocExampleData::Example3.query_string, query_string
  end
  
  def test_query_string_with_explicit_expiry
    query_string = Authentication::QueryString.new(request, key_id, secret, current_host, :expires => expires)
    assert_equal expires, query_string.send(:canonical_string).instance_variable_get(:@options)[:expires]
    assert_equal AmazonDocExampleData::Example3.query_string, query_string
  end    
  
  private
    def request     ; AmazonDocExampleData::Example3.request end
    def key_id      ; AmazonDocExampleData::Example3.access_key_id end
    def secret      ; AmazonDocExampleData::Example3.secret_access_key end
    def expires     ; AmazonDocExampleData::Example3.expires end
    def current_host; AmazonDocExampleData::Example3.current_host end
end

class CanonicalStringTest < Test::Unit::TestCase  
  def setup
    @request = Net::HTTP::Post.new('/test')
    @current_host = 'quotes'
    @canonical_string = Authentication::CanonicalString.new(@request, @current_host)
  end
  
  def test_path_does_not_include_query_string
    request = Net::HTTP::Get.new('/test/query/string?foo=bar&baz=quux')
    assert_equal '/quotes/test/query/string', Authentication::CanonicalString.new(request, @current_host).send(:path)
    
    # Make sure things still work when there is *no* query string
    request = Net::HTTP::Get.new('/')
    assert_equal '/quotes/', Authentication::CanonicalString.new(request, @current_host).send(:path)
    request = Net::HTTP::Get.new('/foo/bar')
    assert_equal '/quotes/foo/bar', Authentication::CanonicalString.new(request, @current_host).send(:path)
  end
  
  def test_path_includes_significant_query_strings
    significant_query_strings = [
      ['/test/query/string?acl',             '/quotes/test/query/string?acl'],
      ['/test/query/string?acl&foo=bar',     '/quotes/test/query/string?acl'],
      ['/test/query/string?foo=bar&acl',     '/quotes/test/query/string?acl'],
      ['/test/query/string?acl=foo',         '/quotes/test/query/string?acl'],
      ['/test/query/string?torrent=foo',     '/quotes/test/query/string?torrent'],
      ['/test/query/string?logging=foo',     '/quotes/test/query/string?logging'],
      ['/test/query/string?bar=baz&acl=foo', '/quotes/test/query/string?acl']
    ]
    
    significant_query_strings.each do |uncleaned_path, expected_cleaned_path|
      assert_equal expected_cleaned_path, Authentication::CanonicalString.new(Net::HTTP::Get.new(uncleaned_path), @current_host).send(:path)
    end
  end
  
  def test_default_headers_set
    Authentication::CanonicalString.default_headers.each do |header|
      assert @canonical_string.headers.include?(header)
    end
  end
  
  def test_interesting_headers_are_copied_over
    an_interesting_header = 'content-md5'
    string_without_interesting_header = Authentication::CanonicalString.new(@request, @current_host)
    assert string_without_interesting_header.headers[an_interesting_header].empty?
    
    # Add an interesting header
    @request[an_interesting_header] = 'foo'
    string_with_interesting_header = Authentication::CanonicalString.new(@request, @current_host)
    assert_equal 'foo', string_with_interesting_header.headers[an_interesting_header]
  end
  
  def test_canonical_string
    request = AmazonDocExampleData::Example1.request
    assert_equal AmazonDocExampleData::Example1.canonical_string, Authentication::CanonicalString.new(request, @current_host)
  end
end