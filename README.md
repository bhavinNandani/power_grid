# PowerGrid

[![Gem Version](https://badge.fury.io/rb/power_grid.svg)](https://badge.fury.io/rb/power_grid)
[![CI](https://github.com/bhavinNandani/power_grid/actions/workflows/ci.yml/badge.svg)](https://github.com/bhavinNandani/power_grid/actions/workflows/ci.yml)

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
- 🎛 **Advanced Filtering**:
  - Support for **Search**, **Select**, **Checkboxes**, and **Radio Buttons**.
  - Dynamic collections using Lambdas (e.g., `-> { User.all }`).
  - Custom filtering logic via blocks.
- 📄 **Smart Pagination**:
  - Numbered pagination window (e.g., `1 2 ... 5 6 7 ... 10`).
  - Dynamic **Per Page** limits.
- 🔒 **Secure Scoping**: Supports `initial_scope` for tenant/user scoping (e.g., `current_user.posts`).
- 🎨 **Visuals**:
  - Professional "Slate" color palette.
  - Fully responsive and Dark Mode compatible.
  - **Customizable CSS** classes.
- 🛠 **Modular Toolbar**:
  - Render the toolbar (search/filters) separately from the table for flexible layouts.
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

Create a class that inherits from `PowerGrid::Base`. This class defines your data source, columns, and filters.

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

  # Filters
  filter :role, collection: ["Admin", "User"], include_blank: "All Roles"
  
  # Advanced Filter (Checkbox with custom logic)
  filter :department_ids, type: :checkbox, collection: -> { Department.pluck(:name, :id) } do |scope, value|
    scope.where(department_id: value)
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

## Advanced Filtering

PowerGrid supports rich filtering options beyond simple text search.

### Checkboxes (Multi-select)
Use `type: :checkbox` to render a list of checkboxes.

```ruby
filter :category_ids, header: "Categories", type: :checkbox, collection: -> { Category.pluck(:name, :id) }
```

### Radio Buttons (Single-select)
Use `type: :radio` to render radio buttons.

```ruby
filter :active, type: :radio, collection: [["Yes", true], ["No", false]]
```

### Dynamic Collections
Pass a `lambda` or `Proc` to `collection:` to load options dynamically at request time.

```ruby
filter :manager_id, collection: -> { User.where(role: 'manager').pluck(:name, :id) }
```

### Custom Filtering Logic
Pass a block to `filter` to customize how the query is modified.

```ruby
filter :query_date, type: :text do |scope, value|
  # Parse date string and filter range
  date = Date.parse(value) rescue nil
  date ? scope.where(created_at: date.all_day) : scope
end
```

## CSS Customization

PowerGrid uses TailwindCSS by default but allows you to override classes for deep customization. Pass a `css:` hash to the component.

```erb
<%= render PowerGrid::TableComponent.new(@grid, css: {
  table: "min-w-full divide-y divide-gray-200 border border-gray-300",
  th: "px-6 py-3 bg-blue-50 text-left text-xs font-medium text-blue-500 uppercase tracking-wider",
  tr: "bg-white hover:bg-blue-50 transition-colors duration-150"
}) %>
```

Available keys in `DEFAULT_CSS`: `container`, `table`, `thead`, `tbody`, `tr`, `th`, `td`, `pagination`, `page_link`, `page_link_active`, `page_prev`, `page_next`, `page_gap`, `search_input`, `filter_select`, `filter_input`.

## Modular Toolbar

You can render the toolbar (Search, Filters, Per Page) separately from the table. This is useful for placing filters in a sidebar or sticky header.

1. Disable the built-in toolbar in `TableComponent`:
   ```erb
   <%= render PowerGrid::TableComponent.new(@grid, toolbar: false) %>
   ```

2. Render `ToolbarComponent` where you want it:
   ```erb
   <div class="sticky top-0 bg-white z-10 shadow p-4">
     <%= render PowerGrid::ToolbarComponent.new(@grid) %>
   </div>
   ```

## Detailed API Reference

### `column(name, options = {}, &block)`

Defines a column in the table.

| Option | Type | Description |
| :--- | :--- | :--- |
| `sortable` | `boolean` | If true, the column header will be clickable to sort. |
| `searchable` | `boolean` | If true, the global search input will check this column using `LIKE`. |
| `sql_expression` | `string` | The raw SQL column name/expression to use for sorting/searching. Essential for joined tables (e.g., `"posts.title"`). |
| `includes` | `symbol/array` | Association(s) to eager load when rendering this column to prevent N+1 queries. |

### `initialize(params, initial_scope: nil)`

- `params`: The Rails `params` hash (required for sorting/filtering state).
- `initial_scope`: Use this to pass context-aware relations, such as `current_account.invoices`. If provided, it overrides the class-level `scope`.

## Frontend Configuration

### TailwindCSS

PowerGrid creates HTML with standard Tailwind utility classes (using the `slate` color palette). Ensure your Tailwind configuration scans your gem paths.

### Hotwire & Stimulus

Ensure your application has `turbo-rails` and `stimulus-rails` installed.
The gem includes a Stimulus controller `power_grid--table_controller` which handles search input debouncing and auto-submission.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bhavinNandani/power_grid.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
