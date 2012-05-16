
ruby_block "scrub_modifiers" do
  block do
    node.delete(:allowed_recipes)
    node.delete(:restricted_recipes)
  end
end

file "/opt/runlist_modifiers.json" do
  content(
    JSON.pretty_generate(
      :allowed_recipes => Array(node[:runlist_modifiers][:allowed_recipes]),
      :restricted_recipes => Array(node[:runlist_modifiers][:restricted_recipes])
    )
  )
  mode 0644
  not_if do
    File.exists?('/opt/runlist_modifiers.json') &&
    JSON.load(File.read('/opt/runlist_modifiers.json')) == {
      :allowed_recipes => Array(node[:runlist_modifiers][:allowed_recipes]),
      :restricted_recipes => Array(node[:runlist_modifiers][:restricted_recipes])
    }
  end
  only_if do
    node[:runlist_modifiers][:allowed_recipes] ||
    node[:runlist_modifiers][:restricted_recipes]
  end
end
