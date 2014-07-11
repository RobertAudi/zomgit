require "rake/clean"
require "rubygems"
require "rubygems/package_task"

spec = eval(File.read("zomgit.gemspec"))

Gem::PackageTask.new(spec) do |pkg|
end

task default: %i(clean clobber gem)
