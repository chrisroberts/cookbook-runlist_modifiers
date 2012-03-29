class Chef
  class Exceptions
    class RestrictedRecipe < StandardError
      attr_reader :recipe_name
      
      def initialize(recipe_name, msg=nil)
        @recipe_name = recipe_name
        super(msg || "Restricted recipe encountered: #{recipe_name}")
      end
    end
  end
end
