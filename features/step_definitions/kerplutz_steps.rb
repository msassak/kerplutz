Given /^an executable named "(\w+)" with:$/ do |name, body|
  contents = <<EOF
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../lib'))

#{body}
EOF

  write_file(name, contents)
end
