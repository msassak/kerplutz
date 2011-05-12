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

        base.switch :blinkenlights, "Enable or disable the blinkenlights"
        base.flag   :frobnicate,    "Frobnicate the furtwangler"

        base.action :version do
          puts "#{base.program_name} version 1.2.3"
          exit
        end

        base.command "start", "s" do |command|
          command.banner = "Start the reactor!"
        end

        base.command "open", "o" do |command|
          command.banner = "Open your mind, Quaid"
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
              --[no-]blinkenlights         Enable or disable the blinkenlights
              --frobnicate                 Frobnicate the furtwangler
              --version

       Commands:
        start, s Start the reactor!
        open, o Open your mind, Quaid

      Type 'my_bin help COMMAND' for help with a specific command.

      """

  Scenario: Known flag to executable
    When I run `./my_bin --version`
    Then the output should contain exactly:
      """
      my_bin version 1.2.3

      """
