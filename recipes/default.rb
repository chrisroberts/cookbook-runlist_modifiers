
ruby_block "scrub_modifiers" do
  block do
    node.delete(:allowed_recipes)
    node.delete(:restricted_recipes)
  end
end
