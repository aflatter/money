require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'

PKG_VERSION = "1.0.0"
PKG_NAME = "money"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

PKG_FILES = FileList[
    "lib/**/*", "test/*", "[A-Z]*", "rakefile"
].exclude(/\bCVS\b|~$/)

desc "Default Task"
task :default => [ :test ]

desc "Delete tar.gz / zip / rdoc"
task :cleanup => [ :rm_packages, :clobber_rdoc ]

# Run the unit tests

Rake::TestTask.new("test") { |t|
#  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
}

# Genereate the RDoc documentation

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Money library"
  rdoc.options << '--line-numbers --inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
}

task :lines do
  lines = 0
  codelines = 0
  Dir.foreach("lib") { |file_name| 
    next unless file_name =~ /.*rb/
    
    f = File.open("lib/" + file_name)

    while line = f.gets
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  }
  puts "Lines #{lines}, LOC #{codelines}"
end


# Publish beta gem  
desc "Publish the gem on leetsoft"
task :publish => [:rdoc, :package] do
  Rake::SshFilePublisher.new("leetsoft.com", "dist/pkg", "pkg", "#{PKG_FILE_NAME}.zip").upload
  Rake::SshFilePublisher.new("leetsoft.com", "dist/pkg", "pkg", "#{PKG_FILE_NAME}.tgz").upload
  Rake::SshFilePublisher.new("leetsoft.com", "dist/gems", "pkg", "#{PKG_FILE_NAME}.gem").upload

  `ssh tobi@leetsoft.com "mkdir -p dist/api/#{PKG_NAME}"`
  Rake::SshDirPublisher.new("leetsoft.com", "dist/api/#{PKG_NAME}", "doc").upload
  `ssh tobi@leetsoft.com './gemupdate'`
end


spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.summary = "Class aiding in the handling of Money."
  s.description = "Can be used as composite in ActiveRecord tables."
  s.has_rdoc = true

  s.files = %w(README MIT-LICENSE) + Dir['lib/**/*']  

  s.require_path = 'lib'
  s.autorequire  = 'money'
  s.author = "Tobias Luetke"
  s.email = "tobi@leetsoft.com"
  s.homepage = "http://leetsoft.com/rails/money"  
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end


=begin
desc "Packing generator to tgz"
task :package => [:cleanup] do
  system %{ tar -czvf ../#{PKG_NAME}.tar.gz #{PKG_FILES} }
#  system %{ cd ..; zip -r #{PKG_NAME}.zip #{PKG_NAME} }
end

desc "Sending package to server"
task :upload => [:package, :rdoc] do
  publisher = Rake::CompositePublisher.new
  publisher.add Rake::SshFilePublisher.new("leetsoft.com", "leetsoft.com/htdocs/rails/money", "..", "#{PKG_NAME}.tar.gz")
#  publisher.add Rake::SshFilePublisher.new("leetsoft.com", "leetsoft.com/htdocs/rails/money", "..", "#{PKG_NAME}.zip")
  publisher.add Rake::SshDirPublisher.new("leetsoft.com", "leetsoft.com/htdocs/rails/money", "doc")
  publisher.upload
end

task :rm_packages do
  system %{ cd ..; rm #{PKG_NAME}.tar.gz }
#  system %{ cd ..; rm #{PKG_NAME}.zip }
end
=end
