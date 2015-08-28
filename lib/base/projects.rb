puts __FILE__ if defined?(DEBUG)

require 'json'
require 'rake'
require_relative('environment.rb')
require_relative('project.rb')
require_relative('../apps/git.rb')
require_relative('../apps/svn.rb')

class Projects < Hash
	attr_accessor :env

	def initialize env=nil
		@env=env if env.kind_of?(Environment)
		@env=Environment.new if @env.nil?
		open
	end

	def filename
		"#{@env.root_dir}/data/Projects.json"
	end

    def update_state
    	self.each{|k,v|
    		self[k]=Project.new(v) if(v.is_a?(String))
    		#self[k]=Project.new(v) if(!v.is_a?(Project) && v.is_a?(Hash))
    		self[k][:fullname]=k
    	}
    end

	def save
		Dir.make File.dirname(filename) if !File.exists? File.dirname(filename)
		File.open(filename,'w'){|f|f.write(JSON.pretty_generate(self))}
	end

	def open
		if File.exists? filename
		  JSON.parse(IO.read(filename)).each{|k,v| self[k]=v}
		  update_state
	    end
	end

    def get_projects value=''
    	projects=Array.new
    	filter=''
    	filter=value.to_s if !value.nil? && value.kind_of?(String)
    	filter=value[0].to_s if !value.nil? && value.kind_of?(Array)
    	self.each{|k,v|
    		projects << v if(filter.length==0 || k.include?(filter))
    		v.env=@env
    	}
    	projects
    end

    def add args
    	puts "add #{args}\n" if @env.debug?
    	url=args[0]
    	puts "url #{url}\n" if @env.debug?
    	project=Project.new(url)
    	project[:fullname]=args[1] if args.length > 1
    	puts "fullname #{project[:fullname]}\n" if @env.debug?
    	if(!self.has_key?(project[:fullname]) && project[:fullname].length > 0)
    		puts "adding #{project.fullname}\n"
    		self[project.fullname]=project
    		self.save
    	end
    end

    def work args
    	get_projects(args).each{|project|
    		project.work
    	}
	end

    def list args #filter=''
    	get_projects(args).each{|project|
    		puts "#{project.status} #{project.fullname}"
    	}
	end

	def make args
		projects=get_projects args
		puts "making #{projects.length} projects..."
		get_projects(args).each{|project|
			project.make
		}
	end

	def update args
		filter=''
		filter=args[1] if !args.nil? && args.length > 0
		self.each{|k,v|
			if filter.nil? || filter.length==0 || k.include?(filter)
				puts "updating #{v.fullname}"
			 	v.update
		    end
		}
	end

	def self.user_projects_filename
		FileUtils.mkdir_p("#{Environment.dev_root}/data") if(!File.exists?("#{Environment.dev_root}/data"))
		"#{Environment.dev_root}/data/PROJECTS.json"
	end

	def self.current
		project=nil
		url=Git.remote_origin
		url=Svn.url if url.length==0
		if(Rake.application.original_dir.include?('/wrk/') &&
			   url.length > 0)
			project=Project.new(url)
			fullname=Rake.application.original_dir.gsub("#{Environment.dev_root}/wrk/",'')
			project[:fullname] = name if(name.length>0 && !name.include?(Environment.dev_root))
			if(defined?(PROJECTS))
				PROJECTS[name]=project if(!PROJECTS.has_key?(name))
				project.each{|k,v|PROJECTS[name][k]=v}
				PROJECTS.save
			else
				project[:fullname]=name
			end
		end			
		project
	end

	def pull
		self.each{|k,v| v.pull if v.respond_to?("pull".to_sym)}
	end
	def rake
		self.each{|k,v| v.rake if v.respond_to?("rake".to_sym)}
	end

    

	def import pattern=''
		wrk="#{Environment.dev_root}/wrk"
		if File.exists?(wrk)
		   Dir.chdir(wrk) do
		   		Dir.glob('**/rakefile.rb').each{|rakefile|
		   			rakedir=File.dirname(rakefile)
		   			url = Project.get_url rakedir
		   			#puts "checking #{url}"
		   			project = Project.new(Project.get_url(rakedir))
		   			project[:fullname]=Project.get_fullname rakedir if(project.fullname.include?(':'))
		   			if(pattern.length==0 || project.fullname.include?(pattern))
		   				if(project.fullname.length > 0 && !self.has_key?(project.fullname))
		   				    puts "importing #{project.fullname}"
		   				    self[project.fullname]=project
		   			    end
		   			end
		   		}
		   end
		   self.save #Projects.user_projects_filename
	    end
	end
end