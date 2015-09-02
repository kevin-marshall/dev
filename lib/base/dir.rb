require 'fileutils'

class Dir
  def self.make directory
  	FileUtils.mkdir_p directory if !File.exists? directory
  end
  def self.remove directory, remove_empty_parents=false
    begin
      FileUtils.rm_rf directory if(!Dir.empty?(directory))
      FileUtils.rm_r directory  if(File.exists?(directory))
      if(remove_empty_parents)
        parent_dir=File.dirname(directory)
        Dir.remove parent_dir, true if(Dir.empty?(parent_dir))
      end
    rescue
    end
  end
  def self.empty? directory
    if((Dir.entries(directory) - %w{ . .. }).empty?)
      return true
    end
    false
  end

  def self.get_latest_mtime directory
    mtime=Time.new(1980)
    Dir.chdir(directory)  do
      latest_filename=''
      Dir.glob('**/*.*').each{|f|
        if mtime.nil? || File.mtime(f) > mtime
          mtime=File.mtime(f) 
          latest_filename=f
        end
      }
      puts "   latest_mtime #{mtime.to_s} #{latest_filename}" if Environment.default.debug?
    end
    mtime
  end
end