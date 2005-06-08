require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'

PKG_VERSION = "1.3.2"
PKG_NAME = "money"
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

RUBY_FORGE_PROJECT = 'money'
RUBY_FORGE_USER = 'xal'
RELEASE_NAME  = "REL #{PKG_VERSION}"

PKG_FILES = FileList[
    "lib/**/*", "tests/*", "[A-Z]*", "rakefile"
].exclude(/\bCVS\b|~$/)

desc "Default Task"
task :default => [ :test ]

desc "Delete tar.gz / zip / rdoc"
task :cleanup => [ :rm_packages, :clobber_rdoc ]

# Run the unit tests

Rake::TestTask.new("test") { |t|
  t.libs << "test"
  t.pattern = 'tests/*_test.rb'
  t.verbose = false
}

task :install => [:package] do
  `gem install pkg/#{PKG_FILE_NAME}.gem`
end

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
  `rm -rf pkg/`
  `rm -rf doc/`
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

# --- Ruby forge release manager by florian gross -------------------------------------------------

RUBY_FORGE_PROJECT = 'money'
RUBY_FORGE_USER = 'xal'
RELEASE_NAME  = "REL #{PKG_VERSION}"


desc "Publish the release files to RubyForge."
task :release => [:gem] do
  files = ["gem"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

  if RUBY_FORGE_PROJECT then
    require 'net/http'
    require 'open-uri'

    project_uri = "http://rubyforge.org/projects/#{RUBY_FORGE_PROJECT}/"
    project_data = open(project_uri) { |data| data.read }
    group_id = project_data[/[?&]group_id=(\d+)/, 1]
    raise "Couldn't get group id" unless group_id

    # This echos password to shell which is a bit sucky
    if ENV["RUBY_FORGE_PASSWORD"]
      password = ENV["RUBY_FORGE_PASSWORD"]
    else
      print "#{RUBY_FORGE_USER}@rubyforge.org's password: "
      password = STDIN.gets.chomp
    end

    login_response = Net::HTTP.start("rubyforge.org", 80) do |http|
      data = [
        "login=1",
        "form_loginname=#{RUBY_FORGE_USER}",
        "form_pw=#{password}"
      ].join("&")
      http.post("/account/login.php", data)
    end

    cookie = login_response["set-cookie"]
    raise "Login failed" unless cookie
    headers = { "Cookie" => cookie }

    release_uri = "http://rubyforge.org/frs/admin/?group_id=#{group_id}"
    release_data = open(release_uri, headers) { |data| data.read }
    package_id = release_data[/[?&]package_id=(\d+)/, 1]
    raise "Couldn't get package id" unless package_id

    first_file = true
    release_id = ""

    files.each do |filename|
      basename  = File.basename(filename)
      file_ext  = File.extname(filename)
      file_data = File.open(filename, "rb") { |file| file.read }

      puts "Releasing #{basename}..."

      release_response = Net::HTTP.start("rubyforge.org", 80) do |http|
        release_date = Time.now.strftime("%Y-%m-%d %H:%M")
        type_map = {
          ".zip"    => "3000",
          ".tgz"    => "3110",
          ".gz"     => "3110",
          ".gem"    => "1400"
        }; type_map.default = "9999"
        type = type_map[file_ext]
        boundary = "rubyqMY6QN9bp6e4kS21H4y0zxcvoor"

        query_hash = if first_file then
          {
            "group_id" => group_id,
            "package_id" => package_id,
            "release_name" => RELEASE_NAME,
            "release_date" => release_date,
            "type_id" => type,
            "processor_id" => "8000", # Any
            "release_notes" => "",
            "release_changes" => "",
            "preformatted" => "1",
            "submit" => "1"
          }
        else
          {
            "group_id" => group_id,
            "release_id" => release_id,
            "package_id" => package_id,
            "step2" => "1",
            "type_id" => type,
            "processor_id" => "8000", # Any
            "submit" => "Add This File"
          }
        end

        query = "?" + query_hash.map do |(name, value)|
          [name, URI.encode(value)].join("=")
        end.join("&")

        data = [
          "--" + boundary,
          "Content-Disposition: form-data; name=\"userfile\"; filename=\"#{basename}\"",
          "Content-Type: application/octet-stream",
          "Content-Transfer-Encoding: binary",
          "", file_data, ""
          ].join("\x0D\x0A")

        release_headers = headers.merge(
          "Content-Type" => "multipart/form-data; boundary=#{boundary}"
        )

        target = first_file ? "/frs/admin/qrs.php" : "/frs/admin/editrelease.php"
        http.post(target + query, data, release_headers)
      end

      if first_file then
        release_id = release_response.body[/release_id=(\d+)/, 1]
        raise("Couldn't get release id") unless release_id
      end

      first_file = false
    end
  end
end
