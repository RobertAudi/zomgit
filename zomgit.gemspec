require File.expand_path(File.join("lib","zomgit","version.rb"))
Gem::Specification.new do |s|
  s.name = "zomgit"
  s.version = Zomgit::VERSION
  s.author       = "Robert Audi"
  s.email         = "robert@audii.me"
  s.homepage = "https://github.com/RobertAudi/zomgit"
  s.summary = "A git wrapper for the Z shell"
  s.license       = "MIT"
  s.files         = `git ls-files -z`.split("\x0")

  s.require_paths << "lib"
  s.bindir = "bin"
  s.executables << "zomgit"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler", "~> 1.6"

  s.add_runtime_dependency "gli", "2.11.0"
end
