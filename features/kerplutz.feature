Feature: Kerplutz

  Command-line option parser with support for sub-commands
  (like git or svn) that will not make developers feel kerplutz.

  Background: Option parsing configuration
    Given an executable named "my_bin" with:
      """
      require 'kerplutz'

      Kerplutz.configure do |config|
        config.bin_name = 'my_bin'
        config.banner   = "Usage: #{config.bin_name} [command] [options]"

        config.command "exec", "x" do |command|
          command.banner = "Execute something"
        end
      end

      Kerplutz.parse!(ARGV.dup)
      """

  Scenario: no arguments
    When I run `./my_bin`
    Then the output should contain exactly:
      """
      For help, type: my_bin -h

      """

  Scenario: -h, --help
    When I run `./my_bin -h`
    Then the output should contain exactly:
      """
      Usage: my_bin [command] [options]

       Commands:
        exec, x Execute something

      """
