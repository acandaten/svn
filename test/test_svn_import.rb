#!/usr/bin/env ruby
# Import a directory into the newly created SVN repo : $HOME/repo-qdoc
#-------------------------------------------------------------------
#  ensure SVN libs in LD_LIBRARY_PATH
#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn zlib rubygems/package}.each {|l| require l} #Load libraries

def each_directory_entry(directory, &block)
  Dir[directory + "/**/*"].each {|f|
    next if test(?d, f)
    name = f[/\/DocumentLibrary.*/]
    yield name, f
  }
end

repo = Svn::Repo.create(ENV['HOME'] + "/repo-qdoc")
r = repo.youngest #repo.revision(4)
tx_root = r.transaction_root

each_directory_entry(ENV['HOME'] + "/DocumentLibrary") {|name, entry|
  filename = name
  printf "Importing %s\n", name
  tx_root.make_file(filename)
  if filename =~ /\.(txt|adoc)$/
    tx_root.change_prop_for(filename, "svn:mime-type", "text/text")
  else
    tx_root.change_prop_for(filename, "svn:mime-type", "application/octet-stream")
  end
  data = File.open(entry, "rb") {|fd| fd.read}
  # puts data.inspect
  tx_root.change_file_content(filename, data) if not data.nil?
}
tx_root.author = "YourName"
tx_root.log = "Initial commit from migration"
puts "Committing"
tx_root.commit

