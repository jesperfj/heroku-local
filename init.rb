require "fileutils"
require "heroku/helpers"

class Heroku::Command::Local < Heroku::Command::Base
 
  # build
  #
  # build an app using a local docker builder
  #
  def build
    c = cache_dir
    b = build_dir
    system("docker run --rm -i -v /var/heroku/build/#{b}:/app -v /var/heroku/build/#{c}:/var/cache/buildpack -t heroku-nodejs-builder /buildpack/bin/compile /app /var/cache/buildpack")

    puts "Build completed."
    puts "Cache dir: #{File.join(local_builds_dir,c)}"
    puts "Build dir: #{File.join(local_builds_dir,b)}"

  end

protected


  def build_dir
    d = Dir.mktmpdir(nil,local_builds_dir)
    FileUtils.cp(git("ls-files -o -c -X .gitignore #{project_root}").split,d)
    return File.basename(d)
  end

  def cache_dir
    f = File.join(project_root,".buildcache")
    if !File.exists?(f)
      d = Dir.mktmpdir(nil,local_builds_dir)
      File.open(f, 'w') { |file| file.write(d) }
      return File.basename(d)
    else
      File.basename(File.open(f, 'r').read)
    end
  end

  # TODO
  def env_dir
  end

  def project_root
    git("rev-parse --show-toplevel")
  end

  def local_builds_dir
    d = File.join(Heroku::Helpers.home_directory, ".heroku", "build")
    if !File.exists?(d)
      FileUtils.mkdir_p(d)
    end
    if !File.directory?(d)
      Heroku::Helpers.error "#{d} is not a directory"
    end
    return d
  end

end
