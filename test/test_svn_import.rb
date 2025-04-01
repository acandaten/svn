#!/usr/bin/env ruby
# Import a directory into the newly created SVN repo
#-------------------------------------------------------------------
#  export LD_LIBRARY_PATH=/home/contaxc/apps/subversion/lib:$LD_LIBRARY_PATH
#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn zlib rubygems/package}.each {|l| require l} #Load libraries


def each_entry_targz(filename, &block)
  tar_longlink = '././@LongLink'

  uncompressed = Gem::Package::TarReader.new(Zlib::GzipReader.open(filename))
  name = nil

  uncompressed.each{|entry|
    if entry.full_name == tar_longlink
      name = entry.read.strip
      next
    end
    name ||= entry.full_name
    yield name, entry
    # logging = true if name == "DocumentLibrary/Manuals/Man_209/resources/SVS Objection Process.vsd"
    # puts entry.inspect if logging
    name = nil
  }
end

def each_directory_entry(directory, &block)
  Dir[directory + "/**/*"].each {|f|
    next if test(?d, f)
    name = f[/\/DocumentLibrary.*/]
    yield name, f
  }
end

repo = Svn::Repo.create("/home/contaxc/repos/qdoc")
r = repo.youngest #repo.revision(4)
tx_root = r.transaction_root

each_directory_entry("/home/contaxc/DocumentLibrary") {|name, entry|
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
tx_root.author = "CandatenA"
tx_root.log = "Initial commit from VSS migration"
puts "Committing"
tx_root.commit


exit
puts "revision #{r.to_i}, by #{r.author} (on #{r.timestamp.strftime('%Y-%m-%d %H:%M')}) Log: #{r.log}"

file = "/trunk/DocumentLibrary/Wiki/test.txt"

puts "\n== #{file} =="
# puts "Props: " + r.props_for(file).inspect
puts "Content:"
# puts file_content = r.file_content(file).read

100.times {
  tx_root = repo.youngest.transaction_root
  # #  Add file
  # puts "check_path: " + r.check_path("/test").inspect
  # tx_root.make_file(file)
  # tx_root.author = "CandatenA"
  # tx_root.log =  "Added #{File.basename(file)}"
  # puts tx_root.commit.inspect
  # exit

  # Set file data
  tx_root.change_file_content(file, "Time = #{Time.now.strftime('%Y-%m-%d %H:%M:%S.%N')}")
  tx_root.author = "CandatenA"
  tx_root.log =  "Appending to #{File.basename(file)}"
  puts tx_root.commit.inspect
}

r_new = repo.youngest
raise "No change: #{r}" if r.to_i ==  r_new.to_i
r = r_new
puts "revision #{r.to_i}, by #{r.author} (on #{r.timestamp.strftime('%Y-%m-%d %H:%M:%S.%N')}) Log: #{r.log}"
puts "new Content:"
puts file_content = r.file_content(file).read



# # puts tx_root
# tx_root.change_prop_for( "/trunk/DocumentLibrary/Manuals/ManualsRegister.doc", "svn:mime-type", "application/octet-stream")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# tx_root.change_txn_prop( "svn:log", "Changing prop of ManualsRegister.doc to octet-stream")
# tx_root.change_txn_prop( "svn:author", "CandatenA")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# puts tx_root.commit.inspect



