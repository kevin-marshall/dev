puts __FILE__ if defined?(DEBUG)
# Visual Studio 2008 version 9.0,  solution format version 10.00
# Visual Studio 2010 version 10.0, solution format version 11.00
# Visual Studio 2012 version 11.0, solution format version 12.00
# Visual Studio 2013 version 12.0, solution format version 12.00
# Visual Studio 2015 version 14.0, solution format version 12.00
class MSBuild < Hash

  def initialize
    if(File.exists?("C:\\Program Files (x86)\\MSBuild\\14.0\\bin\\msbuild.exe"))
      self[:vs14]="C:\\Program Files (x86)\\MSBuild\\14.0\\bin\\msbuild.exe" 
    else
      puts "C:\\Program Files (x86)\\MSBuild\\14.0\\bin\\msbuild.exe was not found." 
      puts "MSBUILD[:vs14]='PATH_TO_MSBUILD' may be used to specify msbuild path."
    end
    self[:vs9]="C:\\Windows\\Microsoft.NET\\Framework\\v3.5\\msbuild.exe"  if(File.exists?("C:\\Windows\\Microsoft.NET\\Framework\\v3.5\\msbuild.exe"))
    self[:vs10]="C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\msbuild.exe" if(File.exists?("C:\\Windows\\Microsoft.NET\\Framework\\v4.0.30319\\msbuild.exe"))
    self[:vs12]="C:\\Program Files (x86)\\MSBuild\\12.0\\bin\\msbuild.exe" if(File.exists?("C:\\Program Files (x86)\\MSBuild\\12.0\\bin\\msbuild.exe"))
  end
  
  def self.has_version? version
    if(defined?(MSBUILD))
      MSBUILD.has_key?(version)
    else
      msb=MSBuild.new
      return msb.has_key? version
    end
  end

  def self.in_path?
      command=Command.new('msbuild /version')
      command[:quiet]=true
      command[:ignore_failure]=true
      command.execute
      return true if(command[:exit_code] == 0) 
      false
  end

  def self.get_version version
    return "msbuild" if MSBuild.in_path?
    if(defined?(MSBUILD))
      MSBUILD[version]
    else
      msb=MSBuild.new
      return msb[version]
    end
  end

	def self.get_vs_version(sln_filename)
   		sln_text=File.read(sln_filename,:encoding=>'UTF-8')
    	return :vs9 if sln_text.include?('Format Version 10.00')
    	return :vs12 if sln_text.include?('12.0.30723.0')
      return :vs12 if sln_text.include?('Visual Studio 2013')
      return :vs12 if sln_text.include?('12.0.31101.0')
      return :vs14
  	end

  	def self.get_configurations(sln_filename)
    	configs=Array.new
	  	sln_text=File.read(sln_filename,:encoding=>'UTF-8')
    	sln_text.scan( /= ([\w]+)\|/ ).each{|m|
	  	c=m.first.to_s
	  	configs << c if !configs.include?(c)
		}
		return configs
  	end

  	def self.get_platforms(sln_filename)
    	platforms=Array.new
	  	sln_text=File.read(sln_filename,:encoding=>"UTF-8")
    	sln_text.scan( /= [\w]+\|([\w ]+)/ ).each{|m|
	    	p=m.first.to_s
	    	platforms << p if !platforms.include?(p)
	  	}
		  return platforms
  	end

    def self.get_build_commands sln_filename
      build_commands=nil
      vs_version=MSBuild.get_vs_version(sln_filename)
      if(MSBuild.has_version?(vs_version))
        MSBuild.get_configurations(sln_filename).each{ |configuration|
          MSBuild.get_platforms(sln_filename).each{|platform|
            build_commands=Array.new if build_commands.nil?
            msbuild_arg=MSBuild.get_version(vs_version)
            msbuild_arg="\"#{MSBuild.get_version(vs_version)}\"" if msbuild_arg.include?(' ')
            sln_arg=sln_filename
            sln_arg="\"#{sln_filename}\"" if sln_filename.include?(' ')
            platform_arg="/p:Platform=#{platform}"
            platform_arg="/p:Platform=\"#{platform}\"" if platform.include?(' ')
            build_commands << "#{msbuild_arg} #{sln_arg} /p:Configuration=#{configuration} #{platform_arg}"
          }
        }
      end
      build_commands
    end
end
