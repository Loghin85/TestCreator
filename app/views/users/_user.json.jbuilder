json.extract! user, :id, :Fname, :Lname, :Email, :Address, :Postcode, :City, :Country, :Phone, :Privilege, :CardRegistered, :password_digest, :created_at, :updated_at
json.url user_url(user, format: :json)
