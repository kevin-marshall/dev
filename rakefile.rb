require 'rake/clean'

CLEAN.include('*.gem','rake.default')
CLOBBER.include('*.gem','lib/dev_*.rb')
build_product= "dev-#{Gem::Specification.load('dev.gemspec').version}.gem"

task :build do
	Dir.glob('*.gem'){|f|File.delete f}
	puts `gem build dev.gemspec`
	raise 'build failed' if($?.to_i != 0)
end

task :test do
	puts `rspec`
	raise 'rspec failed' if($?.to_i != 0)
end

task :add do
	puts `git add -A`
end 

task :commit =>[:add] do
	puts `git commit -m'all'`
end

task :pull do
	puts `git pull`
end

task :push do
	puts `git push`
end 

task :publish do
	if `git remote show origin`.include?('gitlab.com')
	  begin
	  	VERSION="#{Gem::Specification.load('dev.gemspec').version.to_s}"
	  	source=FileList.new('lib/**/*.rb','rakefile.rb','dev.gemspec','LICENSE','README.md','Gemfile')
	  	puts 'publishing to https://github.com/lou-parslow/dev.gem.git'
	  	require_relative('./lib/apps/git.rb')
		Git.publish "https://github.com/lou-parslow/dev.gem.git" ,File.dirname(__FILE__), source, VERSION
		puts `gem push dev-#{Gem::Specification.load('dev.gemspec').version.to_s}.gem`
	  rescue
	  end
    end
end

task :default => [:build,:test,:add,:commit,:publish,:push] do
	File.open('rake.default','w'){|f|f.puts 'a'}
end