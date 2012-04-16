RunlistModifiers
================

This cookbook provides helpers to allow or disallow recipes from being loaded
via the run list based on node attributes.

Repository:
----------

https://github.com/heavywater/chef-runlist_modifiers

Attributes:
-----------

* `node[:restricted_recipes] = %w(users::sysadmins)`
* `node[:allowed_recipes] = %w(sudo)`

These are the two attributes available for modifying the run list. The
behavior of each is similar but slightly different.

Restricted Recipes:
-------------------

Restricted recipes are recipes which are not allowed to be run. This means
that if a recipe in the run list depends on a recipe within the restricted
recipes setting, neither recipe will be loaded. 

Allowed Recipes:
----------------

Allowed recipes are recipes which are allowed to be loaded within the run
list. This is the important distinction between the restricted and allowed
recipes. The allowed recipes will remove any recipes execpt those specified
from the initial run list. Any dependencies those recipes require will then
be free to be loaded. 

Combinations:
-------------

These attributes can be combined. This means that if a recipe in the allowed
recipes depends on a recipe specified within the restricted recipes, it will
not be loaded. The restricted recipes always have precedence.

History:
--------

Some history on the origins of this cookbook can be found here:

http://lists.opscode.com/sympa/arc/chef-dev/2012-03/msg00022.html
