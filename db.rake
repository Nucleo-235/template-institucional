namespace :db do
  task load_nucleo_admins: :environment do
    Admin.create_admin_if_new("admin@nucleo235.com.br", "Admin Nucleo")
  end
end
