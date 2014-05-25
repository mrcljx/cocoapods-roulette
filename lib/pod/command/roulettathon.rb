# encoding: utf-8
module Pod
  class Command
    class Roulettathon < Command
      self.summary = "An easy entrypoint for taking part in a Roulettathon"

      self.description = <<-DESC
        Only asks a few times before you have to settle for a podroulette configuration.
      DESC
      
      WINK = [0x1f609].pack("U*")
      WEIRD_PROJECTS = %w(NotAGoodIdeaTableViewAspect)
      
      def self.options
        Roulette.options
      end
      
      attr_reader :roulette

      def initialize(argv)
        @roulette = Roulette.new argv
        
        def @roulette.last_chance=(last_chance)
          @last_chance = last_chance
        end
        
        def @roulette.yesno(question, default = false)
          question = "#{question} [#{'LAST CHANCE!'.red}]" if @last_chance
          super question, default
        end
        
        super
      end
      
      def tries
        3
      end

      def run
        roulette.update_if_necessary!
        
        UI.puts "Greetings, Roulettathon attendee!"
        UI.puts
        UI.puts "You have #{(tries.to_s + ' chances').green.underline} of finding you a project today."
        UI.puts "If you reject your first #{tries - 1} chances you have to go with the last one,"
        UI.puts "even if it's a #{WEIRD_PROJECTS.sample.magenta}. You've been warned! #{WINK}"
        UI.puts

        catch :done do
          (tries - 1).downto(0).each do |remaining|
            if remaining >= 1
              roulette.last_chance = (remaining == 1)
              roulette.next_round do |success, configuration|
                if success or remaining.zero?
                  configuration.create
                  throw :done
                end
              end
            else
              configuration = roulette.next_configuration
              roulette.announce configuration
              configuration.create
            end
          end
        end
      end
    end
  end
end
