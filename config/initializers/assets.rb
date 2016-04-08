# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( bootstrap.min.css style.css admin.css demo_page.css demo_table.css )
Rails.application.config.assets.precompile += %w( jquery-ui-1.8.17.custom.css )
Rails.application.config.assets.precompile += %w( jquery-ui-1.8.17.custom.min.js )
Rails.application.config.assets.precompile += %w( DataTables-1.8.2/media/js/jquery.dataTables.min.js )
Rails.application.config.assets.precompile += %w( JQuery-DataTables-ColumnFilter/media/js/jquery.dataTables.columnFilter.js )
