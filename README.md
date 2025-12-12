# PowerGrid

**PowerGrid** is a production-ready, server-side processed table component for Rails applications. It combines the raw performance of Active Record with the responsiveness of modern UI frameworks like Hotwire and Stimulus.

Built with **ViewComponent**, **Turbo Frames**, **Stimulus**, and **TailwindCSS**, PowerGrid offers a premium, SPA-like experience without the complexity of a Javascript frontend framework.

![PowerGrid UI Mockup](docs/assets/ui_mockup.png)

## Features

- 🏎 **Server-Side Processing**: Efficiently handles huge datasets using Active Record `offset` and `limit`.
- ⚡️ **Hotwire Integration**: Instant sorting, filtering, and pagination updates via Turbo Frames.
- 🔍 **Advanced Search**: 
  - Multi-column search support.
  - Search on **joined tables** via `sql_expression`.
  - Automatic input debouncing.
- 📄 **Smart Pagination**:
  - Numbered pagination window (e.g., `1 2 ... 5 6 7 ... 10`).
  - Dynamic **Per Page** limits.
- 🔒 **Secure Scoping**: Supports `initial_scope` for tenant/user scoping (e.g., `current_user.posts`).
- 🎨 **Visuals**:
  - Professional "Slate" color palette.
  - Fully responsive and Dark Mode compatible.
- 🚀 **Optimization**: Built-in support for `includes` to automatically prevent N+1 queries.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'power_grid'
```

And then execute:

```bash
$ bundle install
```

## Quick Start

### 1. Define your Grid

Create a class that inherits from `PowerGrid::Base`. This class defines your data source and columns.

```ruby
# app/grids/users_grid.rb
class UsersGrid < PowerGrid::Base
  scope { User.all } 

  # Basic columns
  column :name, sortable: true, searchable: true
  column :email, sortable: true, searchable: true
  
  # Column with block formatting (for badges, links, etc.)
  column :status do |user|
    tag.span(user.status.humanize, class: "badge badge-#{user.status}")
  end
end
```

### 2. Instantiate in Controller

Initialize the grid in your controller action. You can pass an initial scope (like `current_user.posts`) to ensure security.

```ruby
# app/controllers/users_controller.rb
def index
  # @grid = UsersGrid.new(params)
  # OR with scoping:
  @grid = UsersGrid.new(params, initial_scope: current_user.posts)
end
```

### 3. Render in View

Render the `PowerGrid::TableComponent`, passing the grid instance.

```erb
<!-- app/views/users/index.html.erb -->
<%= render PowerGrid::TableComponent.new(@grid) %>
```

## detailed API Reference

### `column(name, options = {}, &block)`

Defines a column in the table.

| Option | Type | Description |
| :--- | :--- | :--- |
| `sortable` | `boolean` | If true, the column header will be clickable to sort. |
| `searchable` | `boolean` | If true, the global search input will check this column using `LIKE`. |
| `sql_expression` | `string` | The raw SQL column name to use for sorting/searching. Essential for joined tables (e.g., `"posts.title"`). |
| `includes` | `symbol/array` | Association(s) to eager load when rendering this column to prevent N+1 queries. |

**Example: Joined Column**
```ruby
column :"posts.title", 
       searchable: true, 
       sortable: true, 
       sql_expression: "posts.title",
       includes: :posts
```

### `scope { ... }`

Defines the default Active Record scope. This is used if no `initial_scope` is passed to the initializer.

```ruby
scope { User.active.order(created_at: :desc) }
```

### `initialize(params, initial_scope: nil)`

- `params`: The Rails `params` hash (required for sorting/filtering state).
- `initial_scope`: Use this to pass context-aware relations, such as `current_account.invoices`. If provided, it overrides the class-level `scope`.

## Frontend Configuration

### TailwindCSS

PowerGrid creates HTML with standard Tailwind utility classes (using the `slate` color palette). Ensure your Tailwind configuration scans your gem paths or includes utilities for:
- Colors: `slate-50` to `slate-900`.
- Spacing, Borders, Flexbox, Typography.

### Hotwire & Stimulus

Ensure your application has `turbo-rails` and `stimulus-rails` installed.
The gem includes a Stimulus controller `power_grid--table_controller` which handles search input debouncing and auto-submission.

If using **Importmap** (default in Rails 7+), this is configured automatically.
If using **esbuild/webpack**, manually register the controller if needed, or ensure the gem's assets are in your load path.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bhavinNandani/power_grid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
