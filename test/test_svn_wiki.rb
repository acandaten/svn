#!/usr/bin/env ruby
# Test reading and writing a wiki entry
#-------------------------------------------------------------------
#  ensure SVN libs in LD_LIBRARY_PATH
#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn}.each {|l| require l} #Load libraries

repo_dir = ENV['HOME'] + '/repos.svn/test2'

if test(?d, repo_dir)
  ENV['SVN_TEST_REPO'] = repo_dir
else
  puts "Create repo: #{repo_dir}"
  Svn::Repo.create(repo_dir)
end

puts Svn::CountedString.from_string("What!!!").inspect

test_repo_dir = ENV['SVN_TEST_REPO'] || raise("Need to set env: SVN_TEST_REPO")
repo = Svn::Repo.open(test_repo_dir)

r = repo.youngest #repo.revision(4)

puts "revision #{r.to_i}, by #{r.author} (on #{r.timestamp.strftime('%Y-%m-%d %H:%M')}) Log: #{r.log}"

file = "/trunk/DocumentLibrary/Wiki/test.txt"

puts "\n== #{file} =="
# puts "Props: " + r.props_for(file).inspect
puts "Content:"

if r.check_path(file) == 0
  tx_root = repo.youngest.transaction_root
  puts "Need to create file"
  tx_root.make_file(file)
  tx_root.author = "CandatenA"
  tx_root.log =  "Added #{File.basename(file)}"
  puts tx_root.commit.inspect
end


puts r.check_path(file).inspect
puts file_content = r.file_content(file).read

10.times {
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



