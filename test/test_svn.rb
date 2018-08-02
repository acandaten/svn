#!/usr/bin/env ruby
#-------------------------------------------------------------------
#  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/contaxc/apps/subversion/lib

#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn}.each {|l| require l} #Load libraries

repo = Svn::Repo.open('/home/contaxc/repos/qvasdoc')

# puts repo.public_methods.sort


puts repo.youngest.num #public_methods.sort

r = repo.youngest #repo.revision(4)


puts r.props.class
puts r.props.inspect
puts "revision #{r.to_i}, by #{r.author} (on #{r.timestamp.strftime('%Y-%m-%d %H:%M')}) Log: #{r.log}"

# r.changes.each_pair { |path, changes| puts path }

#File.open("ManualsRegister.doc", "wb") {|fd| fd.write r.file_content_stream("/trunk/DocumentLibrary/Manuals/ManualsRegister.doc").to_counted_string }
#File.open("ManualsRegister.doc", "wb") {|fd| fd.write r.file_content_stream("/trunk/DocumentLibrary/Manuals/ManualsRegister.doc").to_s }
# File.open("ManualsRegister.doc", "wb") {|fd| fd.write r.file_content("/trunk/DocumentLibrary/Manuals/ManualsRegister.doc").read }

puts "\n== HISTORY =="
repo.history("/trunk/DocumentLibrary/Manuals/ManualsRegister.doc").each{|h| puts h.inspect}

puts "\n== PROPERTIES =="
puts r.props_for("/trunk/DocumentLibrary/Manuals/ManualsRegister.doc").inspect


# tx_root = r.transaction_root
# # puts tx_root
# tx_root.change_prop_for( "/trunk/DocumentLibrary/Manuals/ManualsRegister.doc", "svn:mime-type", "application/octet-stream")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# tx_root.change_txn_prop( "svn:log", "Changing prop of ManualsRegister.doc to octet-stream")
# tx_root.change_txn_prop( "svn:author", "CandatenA")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# puts tx_root.commit.inspect



