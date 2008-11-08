Gem::Specification.new do |s|
  s.name = %q{ubc_monitor}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Christian Johansen"]
  s.date = %q{2008-11-09}
  s.default_executable = %q{ubc_monitor}
  s.description = %q{ubc_monitor monitors resource usage in virtual servers run by OpenVz.  Monitor /proc/user_beancounters and send an email to the systems administrator if failcnt has increased since last time ubc_monitor was run.  ubc_monitor uses a file (by default ~/.ubc_monitor) to keep track of user_beancounter fail counts. When running without this file (such as the first run) any fail count except 0 will be reported.}
  s.email = ["christian@cjohansen.no"]
  s.executables = ["ubc_monitor"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "Rakefile", "bin/ubc_monitor", "lib/ubc_monitor.rb", "lib/ubc_monitor/cli.rb", "lib/ubc_monitor/monitor.rb", "lib/ubc_monitor/report.rb", "script/console", "script/destroy", "script/generate", "test/test_helper.rb", "test/test_ubc_monitor.rb", "test/test_ubc_report.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.cjohansen.no/projects/ubc_monitor}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ubc_monitor}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{ubc_monitor monitors resource usage in virtual servers run by OpenVz}
  s.test_files = ["test/test_helper.rb", "test/test_ubc_monitor.rb", "test/test_ubc_report.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<newgem>, [">= 1.0.6"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.0.6"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.0.6"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
