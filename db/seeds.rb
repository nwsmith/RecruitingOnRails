# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
User.create([{first_name: 'Chuck', last_name: 'Norris', admin: true, active: true, auth_name: 'chuck.norris', user_name: 'chuck.norris'}])
User.create([{first_name: 'Bruce', last_name: 'Lee', admin: false, active: true, auth_name: 'bruce.lee', user_name: 'bruce.lee'}])

