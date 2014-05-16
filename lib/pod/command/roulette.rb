module Pod
  class Command
    class Roulette < Command
      self.summary = "Creates a new iOS project with three random pods."

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

      def run
        update_if_necessary!
        puts 42
      end
      
      def update_if_necessary!
        Repo.new(ARGV.new(["update"])).run if @update
      end
    end
  end
end
