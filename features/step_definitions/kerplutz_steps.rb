Given /^an executable named "(.+)" with:$/ do |name, body|
  contents = <<EOF
#!/usr/bin/env ruby
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))

#{body}
EOF

  write_file(name, contents)
  File.open("tmp/aruba/#{name}") { |file| file.chmod(0755) }
end
