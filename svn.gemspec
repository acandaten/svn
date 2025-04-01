require 'rubygems'

Gem::Specification.new do |s|
	s.name = 'svn'
	s.summary = 'Ruby bindings for subversion (SVN) based on FFI'
	s.version = '0.3.0'
	s.author = 'Ryan Blue'
	s.email = 'rdblue@gmail.com'
	s.homepage = 'http://github.com/codefoundry/svn'
	s.files = Dir['lib/**/*.rb']
	s.test_files = Dir['spec/**/*.rb']
  # commented out at loading ffi directly.	s.add_dependency 'ffi', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 2.8'
  s.add_development_dependency 'archive-tar-minitar', '~> 0.5'
  s.has_rdoc = true
	s.extra_rdoc_files = ['README']
end
