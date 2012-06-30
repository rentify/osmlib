module OSMLib
  module OSMChange
    class Change

      # The list of actions
      attr_reader :actions

      def initialize
        @actions = []
      end

      def push(action)
        if action.class == Action
          @actions << action
        end
      end

      def actions=(actions)
        actions.each do |act|
          self.push(act)
        end
      end

      def objects
        @actions.collect {|a| a.objects }.flatten
      end

    end
  end
end