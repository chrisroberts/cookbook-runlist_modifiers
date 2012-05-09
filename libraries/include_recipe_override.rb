module RunlistModifiers
  module IncludeRecipe

    # include_recipe override that provide modifier functionality before
    # letting recipes continue on to proper inclusion
    def modifier_include_recipe(*recipe_names)
      modifier_notification unless @_modifier_noticed
      recipe_names.collect{|recipe_name|
        begin
          unless(recipe_name.start_with?('runlist_modifiers'))
            if(self.is_a?(Chef::RunContext))
              if(!_fetch_recipes(:allowed_recipes).empty? && !_fetch_recipes(:allowed_recipes).include?(recipe_name.to_s))
                Chef::Log.warn("Recipe encountered not found in allowed recipe set: #{recipe_name}")
                raise Chef::Exceptions::RestrictedRecipe.new(recipe_name)
              end
            end
            if(!_fetch_recipes(:restricted_recipes).empty? && _fetch_recipes(:restricted_recipes).include?(recipe_name.to_s))
              raise Chef::Exceptions::RestrictedRecipe.new(recipe_name)
            end
          end
          original_include_recipe(recipe_name)
        rescue Chef::Exceptions::RestrictedRecipe => e
          if(e.recipe_name == recipe_name)
            msg = 'Restricted recipe encountered:'
          else
            msg = "Restricted recipe dependency found. (#{recipe_name} depends on #{e.recipe_name})."
          end
          Chef::Log.warn msg << " #{recipe_name} -> Not Loaded"
          raise e unless self.is_a?(Chef::RunContext)
        end
      }.compact
    end

    # Provide output about modifiers
    def modifier_notification
      @_modifier_noticed = true
      unless(_fetch_recipes(:allowed_recipes).empty?)  
        Chef::Log.warn "Allowed recipes modifier is enabled " <<
          "[#{_fetch_recipes(:allowed_recipes).join(', ')}]"
      end
      unless(_fetch_recipes(:restricted_recipes).empty?)
        Chef::Log.warn "Restricted recipes modifier is enabled "<<
          "[#{_fetch_recipes(:restricted_recipes).join(', ')}]"
      end
    end

    # key:: :allowed_recipes or :restricted_recipes
    # Runs items through RunListItem instances to ensure only recipes
    def _fetch_recipes(key)
      @_mod_recipe_cache ||= {}
      unless(@_mod_recipe_cache[key.to_sym])
        @_mod_recipe_cache[key.to_sym] = [node[key.to_sym]].flatten.compact.map{|item|
          ri = Chef::RunList::RunListItem.new(item)
          if(ri.type == :recipe)
            if(ri.name.include?('::'))
              ri.name
            else
              [ri.name, "#{ri.name}::default"]
            end
          end
        }.flatten.compact.map(&:to_s)
      end
      @_mod_recipe_cache[key.to_sym]
    end
    
    def self.included(base)
      if(base == Chef::Recipe)
        base.class_eval do
          alias_method :original_include_recipe, :include_recipe
          alias_method :include_recipe, :modifier_include_recipe
        end
      end
    end
  end
end

# Let the override be applied to any new instantiations
Chef::Mixin::LanguageIncludeRecipe.send(:include, RunlistModifiers::IncludeRecipe)
Chef::Recipe.send(:include, RunlistModifiers::IncludeRecipe)

# Force the override into any existing instantiations
ObjectSpace.each_object(Chef::RunContext) do |instance|
  instance.extend(RunlistModifiers::IncludeRecipe)
  instance.instance_eval do
    alias :original_include_recipe :include_recipe
    alias :include_recipe :modifier_include_recipe
  end
end
