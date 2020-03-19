require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions

#funkar ej 
#before do 
#    if (session[:user_id] == nil) && (request.path_info != "/") && (request.path_info != "/login") 
#        redirect ("/")
#    end
#end



get("/") do
    slim(:index)
end

get("/home") do
    slim(:home)
end

post("/register") do
        db = SQLite3::Database.new("db/mat.db")
        username = params["username"]
        password = params["password"]
        confirm_password = params["confirm_password"]
        result = db.execute("SELECT * FROM User WHERE username=?", username)
    
        if result.empty?
            if password == confirm_password
                password_digest = BCrypt::Password.create(password)
                db.execute("INSERT INTO User(username, Password) VALUES (?,?)", [username, password_digest])
                session[:user_id] = db.execute("SELECT user_id FROM User WHERE username=?", [username])
                session[:username] = username
    
                redirect('/stock')
            else
                redirect('/error')
                
            end
        else
            redirect('/error')
        end

    redirect("/stock")
    
end

post('/login') do
    db = SQLite3::Database.new("db/mat.db")
    username = params["username"]
    password = params["password"]
    db.results_as_hash = true
    result = db.execute("SELECT user_id, password FROM User WHERE username=?", [username])
    if result.empty?
        redirect('/error')
    end
    user_id = result.first["user_id"]
    password_digest = result.first["password"]
    if BCrypt::Password.new(password_digest) == password
        session[:username] = username
        session[:user_id] = user_id
        redirect("/stock")
    end
    
end



get("/stock") do
slim(:stock)
end

get("/error") do
    slim(:error) 
end