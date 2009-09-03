# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{flareshow}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Will Bailey"]
  s.date = %q{2009-09-03}
  s.description = %q{TODO: a ruby gem for interacting with the shareflow collaboration service by Zenbe}
  s.email = %q{will.bailey@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.txt"
  ]
  s.files = [
    "Flareshow.gemspec",
     "LICENSE",
     "Rakefile",
     "TODO",
     "VERSION",
     "lib/base.rb",
     "lib/comment.rb",
     "lib/exceptions.rb",
     "lib/file_attachment.rb",
     "lib/flareshow.rb",
     "lib/flow.rb",
     "lib/invitation.rb",
     "lib/membership.rb",
     "lib/post.rb",
     "lib/server.rb",
     "lib/user.rb",
     "lib/util.rb",
     "test/flareshow_test.rb",
     "test/test_helper.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/willbailey/flareshow}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{flareshow}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO: a ruby gem for interacting with the shareflow collaboration service}
  s.test_files = [
    "test/flareshow_test.rb",
     "test/test_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<curb>, [">= 0"])
      s.add_development_dependency(%q<facets>, [">= 0"])
      s.add_development_dependency(%q<facets/dictionary>, [">= 0"])
      s.add_development_dependency(%q<uuid>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<curb>, [">= 0"])
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<facets/dictionary>, [">= 0"])
      s.add_dependency(%q<uuid>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<curb>, [">= 0"])
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<facets/dictionary>, [">= 0"])
    s.add_dependency(%q<uuid>, [">= 0"])
  end
end