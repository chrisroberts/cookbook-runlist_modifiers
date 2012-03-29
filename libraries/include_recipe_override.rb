module RunlistModifiers
  module IncludeRecipe
    def include_recipe(*recipe_names)
      result_recipes = Array.new
      recipe_names.flatten.each do |recipe_name|
        if node.run_state[:seen_recipes].has_key?(recipe_name)
          Chef::Log.debug("I am not loading #{recipe_name}, because I have already seen it.")
          next
        end
        node.run_state[:seen_recipes][recipe_name] = true
        begin
          if(node[:restricted_recipes] && [node[:restricted_recipes]].flatten.include?(recipe_name))
            raise Chef::Exceptions::RestrictedRecipe.new(recipe_name)
          end

          if(self.is_a?(Chef::RunContext) && node[:allowed_recipes] && ![node[:allowed_recipes]].flatten.include?(recipe_name))
            Chef::Log.warn("Recipe encountered not found in allowed recipe set: #{recipe_name}")
            raise Chef::Exceptions::RestrictedRecipe.new(recipe_name)
          end

          Chef::Log.debug("Loading Recipe #{recipe_name} via include_recipe")

          cookbook_name, recipe_short_name = Chef::Recipe.parse_recipe_name(recipe_name)
          
          run_context = self.is_a?(Chef::RunContext) ? self : self.run_context
          cookbook = run_context.cookbook_collection[cookbook_name]
          result_recipes << cookbook.load_recipe(recipe_short_name, run_context)
        rescue Chef::Exceptions::RestrictedRecipe => e
          if(e.recipe_name == recipe_name)
            msg = 'Restricted recipe encountered:'
          else
            msg = "Restricted recipe dependency found. (#{recipe_name} depends on #{e.recipe_name})."
          end
          Chef::Log.warn msg << " #{recipe_name} -> Not Loaded"
        end
      end
      result_recipes
    end
  end
end

Chef::Mixin::LanguageIncludeRecipe.send(:include, RunlistModifiers::IncludeRecipe)

ObjectSpace.each_object(Chef::RunContext) do |instance|
  instance.extend(RunlistModifiers::IncludeRecipe)
end
