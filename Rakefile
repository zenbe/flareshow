require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "flareshow"
    gem.summary = %Q{a ruby gem for interacting with the shareflow collaboration service}
    gem.description = %Q{a ruby gem for interacting with the shareflow collaboration service by Zenbe}
    gem.email = "will.bailey@gmail.com"
    gem.homepage = "http://github.com/zenbe/flareshow"
    gem.authors = ["Will Bailey"]
    gem.add_development_dependency "thoughtbot-shoulda", "> 0"
    gem.add_dependency "json", "> 0"
    gem.add_dependency "curb", "> 0"
    gem.add_dependency "facets", "> 0"
    gem.add_dependency "uuid", "> 0"
    gem.add_dependency "nokogiri", "> 0"
    gem.rubyforge_project = "flareshow"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "flareshow #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
