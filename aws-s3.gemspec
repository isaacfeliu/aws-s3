Gem::Specification.new do |s|
  s.name              = 'aws-s3'
  s.version           = "0.4.0"
  s.summary           = "Client library for Amazon's Simple Storage Service's REST API"
  s.description       = s.summary
  s.email             = 'marcel@vernix.org'
  s.author            = 'Marcel Molina Jr.'
  s.has_rdoc          = true
  s.extra_rdoc_files  = %w(README COPYING INSTALL)
  s.homepage          = 'http://amazon.rubyforge.org'
  s.rubyforge_project = 'amazon'
  s.files             = ['Rakefile', 'lib/aws/s3.rb', 'lib/aws/s3/acl.rb', 'lib/aws/s3/authentication.rb', 'lib/aws/s3/base.rb', 'lib/aws/s3/bittorrent.rb', 'lib/aws/s3/bucket.rb', 'lib/aws/s3/connection.rb', 'lib/aws/s3/error.rb', 'lib/aws/s3/exceptions.rb', 'lib/aws/s3/extensions.rb', 'lib/aws/s3/logging.rb', 'lib/aws/s3/object.rb', 'lib/aws/s3/owner.rb', 'lib/aws/s3/parsing.rb', 'lib/aws/s3/response.rb', 'lib/aws/s3/service.rb', 'lib/aws/s3/version.rb', 'bin/setup.rb', 'bin/s3sh']
  s.executables       << 's3sh'
  s.test_files        = ['test/acl_test.rb', 'test/authentication_test.rb', 'test/base_test.rb', 'test/bucket_test.rb', 'test/connection_test.rb', 'test/error_test.rb', 'test/extensions_test.rb', 'test/fixtures.rb', 'test/logging_test.rb', 'test/object_test.rb', 'test/parsing_test.rb', 'test/response_test.rb', 'test/service_test.rb', 'test/test_helper.rb']
  
  s.add_dependency 'xml-simple'
  s.add_dependency 'builder'
  s.add_dependency 'mime-types'
  s.rdoc_options  = ['--title', "AWS::S3 -- Support for Amazon S3's REST api",
                     '--main',  'README',
                     '--line-numbers', '--inline-source']
end


