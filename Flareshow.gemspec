# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{Flareshow}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Will Bailey"]
  s.date = %q{2009-09-02}
  s.description = %q{Flareshow is a ruby library for interacting with the Shareflow collaboration service from Zenbe}
  s.email = %q{will.bailey@gmail.com}
  s.extra_rdoc_files = ["README.txt"]
  s.files = %w(
    init.rb
    README.txt
    lib/base.rb
    lib/comment.rb
    lib/exceptions.rb
    lib/file_attachment.rb
    lib/flow.rb
    lib/invitation.rb
    lib/membership.rb
    lib/post.rb
    lib/server.rb
    lib/user.rb
    lib/util.rb
  )
  s.has_rdoc = true
  s.homepage = %q{http://github.com/will_bailey/Flareshow}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Flareshow is a ruby library for interacting with the Shareflow collaboration service from Zenbe}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<curb>, [">= 0"])
      s.add_runtime_dependency(%q<facets>, [">= 0"])
      s.add_runtime_dependency(%q<uuid>, [">= 0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<curb>, [">= 0"])
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<uuid>, [">= 0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<curb>, [">= 0"])
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<uuid>, [">= 0"])
  end
end