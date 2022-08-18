lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/paymob_accept/version'

Gem::Specification.new do |spec|
  spec.name          = 'paymob_accept'
  spec.version       = PaymobAccept::VERSION
  spec.authors       = ['OneOrder']
  spec.email         = ['hesham_magdy97@hotmail.com']

  spec.summary       = 'Easy integration of Paymob payment gateway'
  spec.description   = 'PaymobAccept is a Ruby gem created by OneOrder tech team for integrating Paymob payment solutions with your Ruby application.'
  spec.homepage      = "https://github.com/oneorder-tech/paymob"
  spec.license       = 'MIT'
  spec.homepage = 'https://github.com/oneorder-tech/paymob'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.0')


  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/oneorder-tech/paymob'
  spec.metadata['changelog_uri'] = 'https://github.com/oneorder-tech/paymob'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'faraday'
  spec.add_dependency 'json-schema'
end
