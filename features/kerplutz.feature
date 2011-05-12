Feature: Kerplutz

  Command-line option parser for executables with sub-commands
  (like git or svn) that will not make developers feel kerplutz.

  Background: Option parsing configuration
    Given an executable named "my_bin" with:
      """
      require 'kerplutz'

      kerplutz = Kerplutz.build do |base|
        base.program_name = 'my_bin'
        base.banner       = "Usage: #{base.program_name} COMMAND [ARGS]"

        base.action :version do
          puts "#{base.program_name} version 1.2.3"
          exit
        end

        base.command "exec", "x" do |command|
          command.banner = "Execute something"
        end
      end

      kerplutz.parse(ARGV.dup)
      """

  Scenario: no arguments
    When I run `./my_bin`
    Then the output should contain:
      """
      Type 'my_bin help COMMAND' for help with a specific command.

      """

  Scenario: help
    When I run `./my_bin help`
    Then the output should contain exactly:
      """
      Usage: my_bin COMMAND [ARGS]
              --version

       Commands:
        exec, x Execute something

      Type 'my_bin help COMMAND' for help with a specific command.

      """

  Scenario: Known flag to executable
    When I run `./my_bin --version`
    Then the output should contain exactly:
      """
      my_bin version 1.2.3

      """
