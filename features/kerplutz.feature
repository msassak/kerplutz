Feature: Kerplutz
  Command-line option parser with support for sub-commands
  (like git or svn) that will not make developers
  feel kerplutz.

  Scenario: Builder API
    Given an executable named "my_command" with:
      """
      require 'kerplutz'

      Kerplutz.configure do |config|
      end
      """
    When I run `ruby my_command`
    Then the output should contain exactly:
      """
      Blah
      """
