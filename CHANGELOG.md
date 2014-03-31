# v0.0.9

* Allow `include_empty_scope` option in filter groups

  ```
    filter_by :status, [:foo, :bar], include_empty_scope: true
  ```

# v0.0.8

* Support a symbol column label. It will use human attribute name:

  ```
    = row.column :truncated_title, :title
  ```

# v0.0.7

* `#scope_params` does not change request params

# v0.0.6

* Moved the filter group params inside of the `:query` hash

# v0.0.5

* Rename Field into SearchField
* Admino::Table::Presenter no longer presents collection by default

# v0.0.4

* Rename Group into FilterGroup
* Rename `FilterGroup#available_scopes` into `#scopes`
* Rename `Sorting#available_scopes` into `#scopes`
* Removed nil scope in `FilterGroup`
* Clicking on an active filter scope link will deactivate it

# v0.0.3

* Fixed bug in `SortingPresenter` with default scope

# v0.0.2

* Support to sortings

# v0.0.1

* First release

