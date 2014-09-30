# encoding: utf-8
module Pod
  class Command
    class Roulette < Command
      self.summary = "Creates a new iOS project with three random pods"

      self.description = <<-DESC
        Creates a new iOS project with three random pods.
      DESC
      
      def self.options
        [[
          "--update", "Run `pod repo update` before rouletting",
        ]].concat(super)
      end
      
      EMOJIS = [0x1F602, 0x1F604, 0x1F60D, 0x1F61C, 0x1F62E, 0x1F62F, 0x1F633, 0x1F640].pack("U*").chars
      THINGS = [0x1f37a, 0x1f378, 0x1f377, 0x1f354, 0x1f35d, 0x1f368, 0x1f36d, 0x1f36c].pack("U*").chars

      def initialize(argv)
        @update = argv.flag?('update')
        super
      end

      def clear_prev_line
        print "\r\e[A\e[K"
      end

      def yesno(question, default = false)
        UI.print question
        UI.print(default ? ' (Y/n) ' : ' (y/N) ')
        answer = UI.gets.chomp

        if answer.empty?
          clear_prev_line
          default
        elsif /^y$/i =~ answer
          clear_prev_line 
          true
        elsif /^n$/i =~ answer
          false
        else
          UI.puts "Please answer with 'y' or 'n'.".red
          yesno question, default
        end
      end

      def liftoff_installed?
        `which liftoff`
        $?.exitstatus.zero?
      end

      def validate!
        super

        unless liftoff_installed?
          help! [
            'PodRoulette requires Liftoff (which has to be installed through Homebrew). Please install it first.',
            '',
            '$ brew tap thoughtbot/formulae',
            '$ brew install liftoff'
          ].join("\n")
        end
      end

      def all_specs
        @all_specs ||= Pod::SourcesManager.aggregate.all_sets
      end

      def run
        update_if_necessary!

        catch :done do
          while true do
            next_round do |success, configration|
              if success
                configration.create
                throw :done
              else
                # continue forever
              end
            end
          end
        end
      end
      
      class Configuration
        attr_reader :specs
        
        def initialize(specs)
          @specs = specs
        end
        
        def name
          specs.map do |spec|
            self.class.humanize_pod_name spec.name
          end.join ''          
        end
        
        def create
          UI.puts "\nPerfect, your project will use"
          UI.puts (specs.map(&:name).join ", ") + "."
          UI.puts "Just a few more questions before we start:\n\n"

          if create_project
            sleep 0.1 # make sure all output from liftoff has been flushed
            UI.puts "\n\n" + tweet_text(name) + "\n\n"
          end
        end
        
        def tweet_text(project_name)
          random_emoji = EMOJIS.sample
          "#{random_emoji}  got '#{name}' from `pod roulette` by @sirlantis and @hbehrens - fun stuff from @uikonf"
        end

        def pod_file_content
          s = "platform :ios, '7.0'\n\n"

          specs.each do |spec|
            pod = Pod::Specification::Set::Presenter.new spec
            s += "pod '#{pod.name}', '~> #{pod.version}'\n"
          end
          s+= <<END

target :unit_tests, :exclusive => true do
  link_with 'UnitTests'
  pod 'Specta'
  pod 'Expecta'
  pod 'OCMock'
  pod 'OHHTTPStubs'
end

END
        end

        def create_liftoff_templates
          # should we use Dir.home?
          path = File.join '.liftoff', 'templates'
          FileUtils.mkdir_p path
          
          File.open(File.join(path, 'Podfile'), 'w') do |f|
            f.puts pod_file_content
          end
        end

        def create_project
          create_liftoff_templates
          system "liftoff", "-n", name, '--cocoapods', '--strict-prompts', out: $stdout, in: $stdin
        end
        
        def self.humanize_pod_name(name)
          name = name.gsub /(^|\W)(\w)/ do |match|
            Regexp.last_match[2].upcase
          end
          name = name.gsub /[^a-z]/i, ''
          name.gsub /^[A-Z]*([A-Z][^A-Z].*)$/, '\1'
        end
      end
      
      def random_specs
        [].tap do |picked_specs|
          # yes, this looks ugly but filtering all_specs before takes 10s on a MBP 2011
          while picked_specs.length < 3
            picked_spec = all_specs.sample
            unless picked_specs.include? picked_spec
              if picked_spec.specification.available_platforms.map(&:name).include?(:ios)
                picked_specs << picked_spec
              end
            end
          end
        end
      end
      
      def next_configuration
        Configuration.new random_specs
      end
      
      def announce(configration)
        UI.puts "\n\n"
        
        20.times do |n|
          clear_prev_line
          line = (0..(configration.name.size/2)).map { THINGS.sample }
          UI.puts line.join("")
          sleep 0.02
        end
          
        clear_prev_line
        UI.puts configration.name.green
      end

      def next_round
        raise "requires block" unless block_given?

        configration = next_configuration
        announce configration

        if yesno "Are you happy with that project?"
          yield true, configration
        else
          clear_prev_line
          clear_prev_line
          UI.puts configration.name.cyan
          yield false, configration
        end
      end
            
      def update_if_necessary!
        Repo.new(ARGV.new(["update"])).run if @update
      end
    end
  end
end
