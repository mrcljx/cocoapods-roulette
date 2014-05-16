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

      def initialize(argv)
        @update = argv.flag?('update')
        super
      end

      def clear_prev_line(value = nil)
        print "\r\e[A\e[K"
        value
      end

      def yesno(question, default = false)
        UI.print question
        UI.print(default ? ' (Y/n) ' : ' (y/N) ')
        answer = UI.gets.chomp

        if answer.empty?
          clear_prev_line default
        elsif /^y$/i =~ answer
          clear_prev_line true
        elsif /^n$/i =~ answer
          clear_prev_line false
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

      def humanize_pod_name(name)
        name = name.gsub /(^|\W)(\w)/ do |match|
          Regexp.last_match[2].upcase
        end
        name = name.gsub /[^a-z]/i, ''
        name.gsub /^[A-Z]*([A-Z][^A-Z].*)$/, '\1'
      end

      def tweet_text(project_name)
        random_emoji = [0x1F602, 0x1F604, 0x1F60D, 0x1F61C, 0x1F62E, 0x1F62F, 0x1F633, 0x1F640].pack("U*").split("").sample
        "#{random_emoji}  got '#{project_name}' from `pod roulette` by @sirlantis and @hbehrens - fun stuff from @uikonf"
      end

      def pod_file_content(project_name, specs)
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

      def create_liftoff_templates(project_name, specs)
        path = '.liftoff/templates'
        FileUtils.mkdir_p path
        File.open(path+'/Podfile', 'w') do |f|
          f.puts pod_file_content(project_name, specs)
        end
      end

      def create_project(project_name, specs)
        create_liftoff_templates project_name, specs
        system "liftoff", "-n", project_name, '--cocoapods', '--strict-prompts', out: $stdout, in: $stdin
      end

      def run
        update_if_necessary!

        @all_specs = Pod::SourcesManager.all_sets

        catch :done do
          while true do
            next_round
          end
        end
      end

      def next_round

        picked_specs = []
        # yes, this looks ugly but filtering all_specs before takes 10s on a MBP 2011
        while picked_specs.length < 3
          picked_spec = @all_specs.sample
          unless picked_specs.include? picked_spec
            if picked_spec.specification.available_platforms.map(&:name).include?(:ios)
              picked_specs << picked_spec
            end
          end
        end

        project_name = picked_specs.map do |random_spec|
          humanize_pod_name random_spec.name
        end.join ''

        UI.puts "\n" + project_name.green

        if yesno "Are you happy with that project?"
          if create_project project_name, picked_specs
            sleep 0.1 # make sure all output from liftoff has been flushed
            UI.puts "\n\n" + tweet_text(project_name) + "\n\n"
          end

          throw :done
        else
          clear_prev_line
          clear_prev_line
          UI.puts project_name.cyan
        end

      end
      
      def update_if_necessary!
        Repo.new(ARGV.new(["update"])).run if @update
      end
    end
  end
end
