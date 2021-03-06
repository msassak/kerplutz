Feature: Kerplutz

  Command-line option parser for executables with sub-commands
  (like git or svn) that will not make developers feel kerplutz.

  Background: Option parsing configuration
    Given an executable named "my-bin" with:
      """
      require 'kerplutz'

      kerplutz = Kerplutz.build "my-bin" do |base|
        base.banner = "Usage: #{base.name} [OPTIONS] COMMAND [ARGS]"

        base.switch :blinkenlights, "Enable or disable the blinkenlights", abbrev: :b
        base.flag   :frobnicate,    "Frobnicate the furtwangler", optional: :target

        base.action :my_action, "Execute my action" do
          puts "This is my action!"
        end

        base.action :version, "Show the version", abbrev: :V do
          puts "#{base.name} version 1.2.3"
        end

        base.command :start, "Start the reactor!" do |command|
          command.banner = "Usage: #{base.name} #{command.name} [ARGS]"

          command.switch :lightbulb, "Turn the lightbulb on or off"
          command.flag   :dry_run,   "Look, but don't touch", abbrev: :d
        end

        base.command :open, "Open your mind, Quaid" do |command|
          command.flag   :kuato,     "High-level summon",        abbrev: :k, required: :host
          command.switch :backtrace, "Print the full backtrace", abbrev: :b
        end
      end

      kerplutz.parse(ARGV.dup)
      """

  Scenario: help
    When I run `./my-bin help`
    Then the output should contain exactly:
      """
      Usage: my-bin [OPTIONS] COMMAND [ARGS]

          -b, --[no-]blinkenlights         Enable or disable the blinkenlights
              --frobnicate [TARGET]        Frobnicate the furtwangler
              --my-action                  Execute my action
          -V, --version                    Show the version

       Commands:
        start Start the reactor!
        open Open your mind, Quaid

      Type 'my-bin help COMMAND' for help with a specific command.

      """

  Scenario: no arguments
    When I run `./my-bin`
    Then the output should contain:
      """
      Type 'my-bin help COMMAND' for help with a specific command.

      """

  Scenario: Known flag to executable
    When I run `./my-bin --version`
    Then the output should contain exactly:
      """
      my-bin version 1.2.3

      """

  Scenario: Only first action is executed
    When I run `./my-bin --my-action --version`
    Then the output should contain exactly:
      """
      This is my action!

      """

  Scenario: Get help about a command
    When I run `./my-bin help start`
    Then the output should contain exactly:
      """
      Usage: my-bin start [ARGS]

              --[no-]lightbulb             Turn the lightbulb on or off
          -d, --dry-run                    Look, but don't touch

      """

  Scenario: Get help about a command with a default banner
    When I run `./my-bin help open`
    Then the output should contain exactly:
      """
      Usage: my-bin open [OPTIONS]

          -k, --kuato HOST                 High-level summon
          -b, --[no-]backtrace             Print the full backtrace

      """

  @todo
  Scenario: Invoke a flag with required argument without an argument

  @todo
  Scenario: Invoke an unknown option
