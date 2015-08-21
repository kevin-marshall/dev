puts __FILE__ if defined?(DEBUG)

desc 'performs a git push'
task :push do Tasks.execute_task :push;end

class Push < Array
	def update
		if(File.exists?('.git') && `git config --list`.include?('user.name=') && `git branch`.include?('* master'))
			self <<  'git push'
			self <<  'git push --tags'
		end
	end
end