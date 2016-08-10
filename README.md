# Active Record Enum Extensions

## Installation

Add it to your Gemfile:

```ruby
gem 'enum_extensions'
```

Then:

`bundle`

## Simple enum

ActiveRecord's `enum` creates scopes, and bang and query methods. `simple_enum` doesn't. It just adds the enum values to the attribute. So, following [Rails docs' `enum` example](http://api.rubyonrails.org/classes/ActiveRecord/Enum.html), this is what we get:

```ruby
class Conversation < ActiveRecord::Base
  simple_enum status: [ :active, :archived ]
end

# conversation.update! status: 0
conversation.status = 0
conversation.status     # => "active"

# conversation.update! status: 1
conversation.status = 1
conversation.status     # => "archived"

# conversation.update! status: 1
conversation.status = "archived"

# conversation.update! status: nil
conversation.status = nil
conversation.status.nil?  # => true
conversation.status       # => nil

# mapping values
Conversation.statuses # => { "active" => 0, "archived" => 1 }
```

This is useful when the scopes and added methods are not only ambiguous, or clashing with other enum attributes with the same values, but useless.

## String enums

ActiveRecord's `enum` allows us to create enums attributes with string values, like this:

```ruby
enum status: { :active => 'active', :archived => 'archived' }
```

Don't you hate those duplicated symbols/strings? I do. So this gem allows you to do:

```ruby
enum_s status: [ :active, :archived ]
```

resulting in the enum attribute having string values. Also, can be applied to the `simple_enum`:

```ruby
simple_enum_s status: [ :active, :archived ]
```

## Compatibility/Requirements

This gem has been tested and is known to work with ActiveRecord 5, using Ruby 2.3.

## Credits

* `simple_enum` is simply a copy of Rails's `enum` code, with the scope and query attributes code removed.
