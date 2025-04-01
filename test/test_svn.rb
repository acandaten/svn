#!/usr/bin/env ruby
#-------------------------------------------------------------------
#  ensure SVN libs in LD_LIBRARY_PATH
#--------------------------------------------------------------------
$LOAD_PATH << File.expand_path(File.dirname(__FILE__) + "/../lib")
%w{svn}.each {|l| require l} #Load libraries

repo = Svn::Repo.open('/samba/ivase/lavetdba/repos.svn/qvasdoc')

file_interest ="/trunk/DocumentLibrary/Manuals/ManualsRegister.docx" 


puts repo.youngest.num #public_methods.sort

r = repo.youngest #repo.revision(4)


puts r.props.class
puts r.props.inspect
puts "revision #{r.to_i}, by #{r.author} (on #{r.timestamp.strftime('%Y-%m-%d %H:%M')}) Log: #{r.log}"

r.changes.each_pair { |path, changes| puts path }

File.open("ManualsRegister.docx", "wb") {|fd| fd.write r.file_content(file_interest).read }

puts "\n== HISTORY =="
repo.history(file_interest).each{|h| puts h.inspect}

puts "\n== HISTORY with options =="
tm = Time.now
repo.history(file_interest).each{|h| puts h.inspect}
tm = Time.now - tm
puts "timing: %.5f" % tm

puts "\n== PROPERTIES =="
puts r.props_for(file_interest).inspect


# tx_root = r.transaction_root
# # puts tx_root
# tx_root.change_prop_for( "/trunk/DocumentLibrary/Manuals/ManualsRegister.docx", "svn:mime-type", "application/octet-stream")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# tx_root.change_txn_prop( "svn:log", "Changing prop of ManualsRegister.doc to octet-stream")
# tx_root.change_txn_prop( "svn:author", "CandatenA")

# # puts "svn:log=" + tx_root.txn_prop( "svn:log").to_s

# puts tx_root.commit.inspect

# puts `sleep 1; pfiles #{$$}`



