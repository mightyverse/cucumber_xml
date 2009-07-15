require 'rubygems'
gem 'actionpack'
require 'erb'
include ERB::Util

doc_dir = '../doc/'    # note: code below relies on trailing slash
Dir::mkdir(doc_dir) unless FileTest::directory?(doc_dir)

index = '<html><body>'
index << '<h1>XML API documentation</h1>'
index << '<ul>'
basedir = ".."
Dir.new(basedir).entries.each do |fname|

  shortname = String.new(fname).gsub!(/_xml.feature$/, '') 
  if (shortname != nil)
    html_fname = String.new(fname) + '.html'
    
    # write html file for this
    contents = ""
    File.open('../'+fname, 'r') { |f| contents << f.read }

    html = "<html><body>" + h(contents)
    # note: since we just html escaped the contents, we need to search for &quot; instead of "
    html.gsub!(/file:\s*(?:&quot;)?(.*?)(?:&quot;)?\s*$/, 'file: <a href="../\1">\1</a>')
    html.gsub!(/$/, "<br/>")
    html << "</body></html>"
    File.open(doc_dir + html_fname, 'w') {|f| f.write(html) }
    
    # add it to the doc index
    index << "<li><a href='#{html_fname}'>#{shortname}</a></li>"
  end
end
index << '</ul>'
index << '</body></html>'

File.open(doc_dir + 'index.html', 'w') {|f| f.write(index) }
