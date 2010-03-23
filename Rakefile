require 'rake'
require "rake/rdoctask"
require 'rake/gempackagetask'
require File.join(File.expand_path(File.dirname(__FILE__)),'lib','googletastic')

begin
  require 'spec/rake/spectask'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
  exit(0)
end

APP_ROOT = File.dirname(__FILE__)

# http://docs.rubygems.org/read/chapter/20
spec = Gem::Specification.new do |s|
  s.name              = "googletastic"
  s.author            = "Lance Pollard"
  s.version           = Googletastic::VERSION
  s.date              = "Mon Mar 22 20:12:47 -0700 2010"
  s.summary           = "More than Syncing Rails Apps with the Google Data API"
  s.homepage          = "http://github.com/viatropos/googletastic"
  s.email             = "lancejpollard@gmail.com"
  s.description       = "Googletastic: A New Way of Googling"
  s.has_rdoc          = true
  s.rubyforge_project = "googletastic"
  s.platform          = Gem::Platform::RUBY
  s.files             = %w(README.textile Rakefile) + 
                          Dir["{googletastic,lib,spec}/**/*"] - 
                          Dir["spec/tmp"]
  s.extra_rdoc_files  = %w(README.textile)
  s.require_path      = "lib"
  s.add_dependency("nokogiri")
  s.add_dependency("activesupport", ">= 2.3.5")
  s.add_dependency("activerecord", ">= 2.3.5")
  s.add_dependency("gdata")
end

desc "Create .gemspec file (useful for github)"
task :gemspec do
  File.open("#{spec.name}.gemspec", "w") do |f|
    f.puts spec.to_ruby
  end
end

desc "Build the gem into the current directory"
task :gem => :gemspec do
  `gem build #{spec.name}.gemspec`
end

desc "Print a list of the files to be put into the gem"
task :manifest => :clean do
  File.open("Manifest", "w") do |f|
    spec.files.each do |file|
      f.puts file
    end
  end
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install the gem locally"
task :install => [:package] do
  sh %{sudo gem install pkg/googletastic-#{Googletastic::VERSION} --no-ri --no-rdoc}
end

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
	t.spec_opts = ["--color"]
	t.spec_files = FileList['spec/**/*_spec.rb']
end

desc "Print specdocs"
Spec::Rake::SpecTask.new(:doc) do |t|
	t.spec_opts = ["--format", "specdoc"]
	t.spec_files = FileList['spec/*_spec.rb']
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  files = ["README.textile", "lib/**/*.rb"]
  rdoc.rdoc_files.add(files)
  rdoc.main = "README.textile"
  rdoc.title = "Googletastic: A New Way of Googling"
end

desc "Run the rspec"
task :default => :spec