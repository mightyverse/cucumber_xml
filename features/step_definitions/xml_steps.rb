# (c) 2009 Mightyverse, Inc.  Use is subject to license terms.
Given /^an XML post body "(\w+)" defined as follows:$/ do |post_body_var, post_body_data|
  instance_variable_set('@'+post_body_var, post_body_data)  # set an @... variable
end

def expand_url(url)
  while url =~ /<([^>]+)>/ do # substitute and eval inlined expresssions like <@variable.method>
    url.sub!(/<#{Regexp.escape($1)}>/, eval($1).to_s)
  end
  url
end

def send_request content_type, method, url, params, http_header_key, http_header_value, post_body
  case content_type
  when 'XML'
    http_content_type = 'application/xml'
  when 'HTML'
    http_content_type = 'text/html'
  else
    raise "Unsupported content type: must be HTML or XML"
  end
  if method.upcase == 'POST' || method.upcase == 'PUT'
    # Don't set content type for GET or DELETE; it confuses the parser
    # and is not needed as there shouldn't be a post body anyway for GET or DELETE
    header('Content-Type', http_content_type)
  end

  if !http_header_key.blank?
    http_header_hash_key = http_header_key.downcase.underscore
    header(http_header_hash_key, http_header_value)
  end

  url = expand_url(url)

  while params =~ /<([^>]+)>/ do # substitute and eval inlined expresssions like <@variable.method>
    params.sub!(/<#{Regexp.escape($1)}>/, eval($1).to_s)
  end

  url += '?'+params unless params.blank?
  announce "Sending a #{method} request to #{url}" + (post_body.blank? ? '' : " with post body: #{post_body}")
  request_page(url, method.downcase.to_sym, post_body)
end

When %r{^I send an (\w+) (GET|POST|PUT|DELETE) to ([^ ]+)(?: with parameters: (\S+?))?(?: and HTTP header: ([^=]+)=(\S+))? and post body:$} do |content_type, method, url, params, http_header_key, http_header_value, post_body|
  send_request content_type, method, url, params, http_header_key, http_header_value, post_body
end

When %r{^I send an (\w+) (GET|POST|PUT|DELETE) to ([^ ]+)(?: with parameters: (\S+?))?(?: and HTTP header: ([^=]+)=(\S+))? and post body from file: "([^\"]+)"$} do |content_type, method, url, params, http_header_key, http_header_value, post_body_file|
  path = File.join(File.dirname(__FILE__), '..', post_body_file)

  send_request content_type, method, url, params, http_header_key, http_header_value, File.open(path).read
end

When %r{^I send an (\w+) (GET|POST|PUT|DELETE) to ([^ ]+)(?: with parameters: (\S+?))?(?: and HTTP header: ([^=]+)=(\S+))?(?: and post body "([^\"]+)")?$} do |content_type, method, url, params, http_header_key, http_header_value, post_body_var|
  post_body = instance_variable_get('@'+post_body_var) unless post_body_var.blank?
  send_request content_type, method, url, params, http_header_key, http_header_value, post_body
end


Then /^I get a (\d+) \(([\s\w]+)\) status result$/ do |code, description|
  response.response_code.should == code.to_i
end

Then %r{^I get an '([/\w]+)' response$} do |content_type|
  response.content_type.should == content_type
end

Then /^a (\w+) instance with (\w+)="([^"]+)" exists on the server$/ do |klass, key, val|
  klass.constantize.exists?(key => val).should be_true
end

Given /^a (\w+) instance with (\w+)="([^\"]+)"(?: and (\w+)="([^\"]+)")? is created on the server$/ do |klass, key1, val1, key2, val2|
  key1.downcase!
  key2.downcase! unless key2.blank?
  method = 'find_or_create_by_' + key1
  method += '_and_' + key2 unless key2.blank?
  args = [val1]
  args << val2 unless val2.blank?
  klass.constantize.send(method,*args)
end

Then /^I get a response header ([^=]+)=(.*)$/ do |http_header_key, http_header_value|
  if http_header_value =~ /\.{3}/
    # can use '...' in the value to mean a .* regular expression
    http_header_value.gsub!(/\.{3}/,'.*')
    response.headers[http_header_key].should match(%r{#{http_header_value}})
  else
    response.headers[http_header_key].should == http_header_value
  end
end

Then /^the (\w+) instance with UUID="([^\"]+)" now has an? (\w+) instance with (\w+)="([^\"]+)"(?: and (\w+)="([^\"]+)")?$/ do |klass, uuid, assoc, key1, val1, key2, val2|
  key1.downcase!
  conds = {key1 => val1}
  unless key2.blank?
    key2.downcase!
    conds.merge!(key2 => val2)
  end
  klass.constantize.find_by_uuid(uuid).send(assoc).count(:all, :conditions => conds).should == 1
end

Given /^a (\w+) fixture "([^\"]*)"$/ do |model, fixture_name|
  # lets you use fixtures as usual in rspec/test framework such as media(:second)
  instance_variable_set('@'+fixture_name, send(model.pluralize.downcase.underscore, fixture_name))
end

And /^the response has an? <(\S+)> tag$/ do |tag|
  response.should have_tag(tag)
end

Then /^the response header Content-Type matches ([\/\w]+)$/ do |content_type|
  response.headers['Content-Type'].should match(%r{#{content_type}})
end

Then /^the response should be a superset of the post body "(\w+)"$/ do |post_body_var|
  post_body = instance_variable_get('@'+post_body_var)
  post_body.should be_xml_subset_of(response.body)
end

Then /^the response should be a superset of:$/ do |xml_body|
  xml_body.should be_xml_subset_of(response.body)
end

Then /^the response should be a superset of the file: "?([^"]+)"?$/ do |path|
  path = File.join(File.dirname(__FILE__), '..', path)
  announce path
  File.exists?(path).should be_true
  File.open(path) do |f|
    file_body = f.read
    file_body.should_not be_blank
    file_body.should be_xml_subset_of(response.body)
  end
end
