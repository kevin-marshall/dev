puts __FILE__ if defined?(DEBUG)

SOURCE=FileList.new('LICENSE','README','README.md',"Gemfile")
SOURCE.include('*.{gitignore,yml,gemspec}')
SOURCE.include('**/*.{rb}')
SOURCE.include('**/*.{cs,xaml,resx,settings}')
SOURCE.include('**/*.{c,h}')
SOURCE.include('**/*.{cpp,hpp}')
SOURCE.include('**/*.{swift}')
SOURCE.include('**/*.{xcodeproj,plist,storyboard,json}')
SOURCE.include('**/*.{csproj,sln,nuspec,config,snk}')
SOURCE.include('**/*.{saproj}')
SOURCE.include('**/*.{jpeg,jpg,png,bmp}')
SOURCE.include('**/*.{html,htm}')
SOURCE.include('**/*.{txt}')
SOURCE.include('**/*.{wxs}')
SOURCE.exclude('bin','obj','lib')
SOURCE.exclude('**/obj/**/*.*')
SOURCE.exclude('**/bin/**/*.*')
SOURCE.exclude('commit.message')
SOURCE.exclude('rakefile.default')