require 'find'
require 'jcode' # For string.each_char

class File
  
  NON_TEXT_FILE_EXTENSIONS = [
    "jpg", "gif", "jpeg", "pdf", "swf", "swc", "psd", "ai", "ae", "png", "tiff", "mp3",
    "ttf", "otf", "bmp"
  ].collect! { |item| ".#{item}" }#.to_hash unless defined?(NON_TEXT_FILE_EXTENSIONS)
  
  # removes file content
  def self.clean(file)
    File.truncate(file, 0)
  end
  
  def self.touch(file)
    FileUtils.touch(file) unless File.exists?(file)
  end
  
  # sorts the names of files
  def self.sort(files)
    files.sort do |x,y|
      xs = x.before_last("/")
      ys = y.before_last("/")
      xs <=> ys
    end
  end
  
  # easier to read method to see if file's empty
  def self.empty?(file)
    File.zero?(file)
  end
  
  def self.uniq_dirs(paths)
    dirs = []
    paths.each do |file|
      dirs << file.before_last("/") if file =~ /\//
    end
    dirs.uniq!
    dirs
  end
  
  def self.template(target_path, template_path, bind)
    FileUtils.touch(target_path) unless File.exists?(target_path)
    File.clean(target_path)
    File.open(target_path, 'r+') do |f|
      # parse the template file into this
      f.print ERB.new(IO.read(template_path), nil, '-').result(bind) 
    end
  end
  
  def self.write(file, content)
    File.touch(file)
    File.clean(file)
    File.open(file, 'r+') do |f|
      f.print content
    end
  end
  
  def self.has_ext?(name)
    File::NON_TEXT_FILE_EXTENSIONS[name.downcase]
  end
  
  # Matches the file name
  def self.matches(target, files_only = true, includes = [".*"], excludes = nil)
    includes ||= [".*"]
    # need to test this to make sure it always works
    includes = includes.collect { |e| e.is_a?(Regexp) ? e : Regexp.new(e) }
    excludes = excludes.collect { |e| e.is_a?(Regexp) ? e : Regexp.new(Regexp.escape(e)) } unless excludes.nil?
    Find.find(target) do |path|
      if excludes and excludes.any? {|e| path.match e }
        next
      elsif FileTest.directory?(path)
       yield path if !files_only
       next
      else #we have a file
        #name = "." + File.basename(path.downcase).split(".").last
        yield path if includes.any? {|e| path.match e }
      end  
    end
  end
  
  def self.num_lines(target, files_only = true, includes = [".*"], excludes = nil)
    n = 0
    self.matches(target, files_only, includes, excludes) do |path|
      n += File.readlines(path).size
    end
    n
  end
  
  def self.num_words(target, files_only = true, includes = [".*"], excludes = nil)
    n = 0
    self.matches(target, files_only, includes, excludes) do |path|
      IO.read(path).scan(/\b\w+\b/) { n += 1 }
    end
    n
  end
  
  def self.num_files(target, files_only = true, includes = [".*"], excludes = nil)
    n = 0
    self.matches(target, files_only, includes, excludes) do |path|
      n += 1
    end
    n
  end
  
  # moves all files from random places to a single directory
  def self.move_all(target, includes = [".*"], excludes = nil)
    
  end
  
  def self.list_files(target, files_only = true, includes = [".*"], excludes = nil)
    files = []
    self.matches(target, files_only, includes, excludes) do |path|
      yield path if block_given?
      if !path.nil? and !path.eql?("") then files << path end
    end
    files
  end
  
  def self.list_directories(target, includes = [".*"], excludes = nil)
    dirs = []
    self.matches(target, false, includes, excludes) do |path|
      if FileTest.directory?(path)
        yield path if block_given?
        if !path.nil? and !path.eql?("") then dirs << path end
      end
    end
    dirs
  end
  
  def self.replace(a, b, target, includes = [".*"], excludes = [], &block)
    a = Regexp.new(Regexp.escape(a))
    self.replace_all(target, includes, excludes) do |line|
      if block_given?
        yield line, a, b
      else            # modify lines
        line.gsub!(a, b) unless line.match(a).nil?
      end           # truncate to new length
    end
  end
  
  def self.replace_all(target, includes = [".*"], excludes = [], &block)
  #  files = self.list_files(target, true, includes, excludes).sort do |a,b|
   #   Regexp.num_matches(a, "/") <=> Regexp.num_matches(b, "/")
  #  end
    self.list_files(target, true, includes, excludes) do |path|
      File.open(path, 'r+') do |f|    # open file for update
        lines = f.readlines.collect! { |line| yield path, line if block_given? }
        f.pos = 0                     # back to start
        f.print lines                 # write out modified lines
        f.truncate(f.pos)             # truncate to new length
      end
    end
  end
  
  def self.rename_all(target, files_only = false, includes = [".*"], excludes = [], &block)
    self.list_files(target, files_only, includes, excludes) do |path|
      dirname = File.dirname(path)
      filetype = File.basename(path).split(".").last
      filename = yield path, File.basename(path).split("/").last if block_given?
      new_path = dirname + "/" + filename
      File.rename(path, new_path)
    end
  end
  
  # Inserts lines into a file after a specified pattern's last occurrence.
  # This method first reads the file into memory as a string and checks to see if
  # any of the lines you're trying to add are already there.
  # If they are, it removes them from the inserts.
  # Then it goes through each line, finds the index of the last occurrence of that pattern,
  # and splices your inserts into the lines array, and writes them back to the file.
  def self.insert_lines(target, inserts, pattern, offset = 0, duplicates = false, &block)
    index = -1
    content = IO.read(target)
    accepted_inserts = []
    inserts.each_with_index do |insert, i|
      accepted_inserts << insert unless !duplicates and content.match(insert.strip)
    end
#    accepted_inserts[0] = "\n#{accepted_inserts[0]}" # next line
    File.open(target, 'r+') do |f|
      lines = f.readlines.each_with_index do |line, i|
        yield line if block_given?
        if pattern and line.match(pattern) then index = i end
      end
      index = index == -1 ? lines.length - 1 : index + offset
      lines = lines.splice(accepted_inserts, index)
      f.pos = 0
      f.print lines
      f.truncate(f.pos)
    end
  end
  
  def self.remove_lines(target, patterns)
    new_lines = []
    if !patterns.nil? and patterns.length > 0
      patterns.map! {|p| Regexp.escape(p) }
      pattern = Regexp.new(patterns.join("|"))
      File.open(target, 'r+') do |f|
        f.readlines.each { |line| new_lines << line unless line.match(pattern) }
        f.pos = 0
        f.print new_lines
        f.truncate(f.pos)
      end
    end
    new_lines
  end
  
  def self.scan(target, pattern, position = 0)
    new_lines = []
    File.open(target, 'r+') do |f|
      lines = f.readlines.each do |line|
        match = line.match(pattern)
        new_lines << match.captures[position] unless match.nil?
      end
    end
    new_lines
  end
end
