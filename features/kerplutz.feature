Feature: Kerplutz

  Command-line option parser for executables with sub-commands
  (like git or svn) that will not make developers feel kerplutz.

  Background: Option parsing configuration
    Given an executable named "my_bin" with:
      """
      require 'kerplutz'

      kerplutz = Kerplutz.build "my_bin" do |base|
        base.banner = "Usage: #{base.name} [OPTIONS] COMMAND [ARGS]"

        base.switch :blinkenlights, "Enable or disable the blinkenlights"
        base.flag   :frobnicate,    "Frobnicate the furtwangler"

        base.action :my_action, "Execute my action" do
          puts "This is my action!"
        end

        base.action :version do
          puts "#{base.name} version 1.2.3"
        end

        base.command :start, "Start the reactor!" do |command|
          command.banner = "Usage: #{base.name} #{command.name} [ARGS]"

          command.switch :lightbulb, "Turn the lightbulb on or off", alias: :lb
          command.flag   :dry_run,   "Look, but don't touch"
        end

        base.command :open, "Open your mind, Quaid" do |command|
          command.flag   :kuato, "High-level summon", required: :host
          command.switch :b, "Print the full backtrace", alias: :backtrace
        end
      end

      kerplutz.parse(ARGV.dup)
      """

  Scenario: help
    When I run `./my_bin help`
    Then the output should contain exactly:
      """
      Usage: my_bin [OPTIONS] COMMAND [ARGS]

              --[no-]blinkenlights         Enable or disable the blinkenlights
              --frobnicate                 Frobnicate the furtwangler
              --my-action                  Execute my action
              --version

       Commands:
        start Start the reactor!
        open Open your mind, Quaid

      Type 'my_bin help COMMAND' for help with a specific command.

      """

  Scenario: no arguments
    When I run `./my_bin`
    Then the output should contain:
      """
      Type 'my_bin help COMMAND' for help with a specific command.

      """

  Scenario: Known flag to executable
    When I run `./my_bin --version`
    Then the output should contain exactly:
      """
      my_bin version 1.2.3

      """

  Scenario: Only first action is executed
    When I run `./my_bin --my-action --version`
    Then the output should contain exactly:
      """
      This is my action!

      """

  Scenario: Get help about a command
    When I run `./my_bin help start`
    Then the output should contain exactly:
      """
      Usage: my_bin start [ARGS]

              --[no-]lightbulb             Turn the lightbulb on or off
              --dry-run                    Look, but don't touch

      """
