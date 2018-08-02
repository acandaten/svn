#!/usr/bin/env ruby
# Test reading and writing a wiki entry
#-------------------------------------------------------------------
#  export LD_LIBRARY_PATH=/home/contaxc/apps/subversion/lib:$LD_LIBRARY_PATH
#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn}.each {|l| require l} #Load libraries

Svn::Repo.create("/home/contaxc/repos/test2")
exit

test_repo_dir = ENV['SVN_TEST_REPO'] || raise("Need to set env: SVN_TEST_REPO")
repo = Svn::Repo.open(test_repo_dir)

r = repo.youngest #repo.revision(4)

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



