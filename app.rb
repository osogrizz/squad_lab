require 'sinatra'
require 'pry'
require 'better_errors'
require 'pg'


configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = __dir__
end

configure do
  set :conn, PG.connect(dbname: 'squadlab')
end

before do
  @conn =settings.conn
end

# Root Route
get '/' do
  redirect  '/squads'
end


# INDEX
get '/squads' do
  squads = []
  @conn.exec ("SELECT * FROM squads") do |result|
    result.each do |squad|
      squads << squad   
    end
  end
  @squads = squads
  erb :index
end

# NEW SQUAD
get '/squads/new' do
  erb :new
end

# NEW STUDENTS
get 'squads/:id/students' do
  erb :newstudents
end

# SHOW SINGLE SQUAD
get '/squads/:id' do
  id = params[:id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id = $1", [id])
  count = @conn.exec("SELECT COUNT (*) FROM students WHERE squad_id=$1", [id])
  @squad = squad[0]
  @count = count [0]["count"]
  
  erb :showsquad
end

# SHOW SQUAD STUDENTS LIST
get '/squads/:squad_id/students' do 
  squad_id = params[:squad_id].to_i
  students = []
  @conn.exec("SELECT * FROM students WHERE squad_id=$1", [squad_id]) do |result|
    result.each do |student|
      students << student   
    end
  end
  @students = students
  erb :studentsindex
end

# SHOW INDIVIDUAL STUDENT INFO
get 'squads/:squad_id/students/:id' do
  id = params[:id].to_i
  studentinfo = @conn.exec("SELECT * FROM students WHERE id=$1",[id])
  @student = studentinfo[0]
  
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1",[id])
  @squad = squad
  erb :showstudent
end

# Edit
get '/squads/:squad_id/editsquads' do
 id = params[:squad_id].to_i
  squad = @conn.exec("SELECT * FROM squads WHERE id=$1", [id])
  @squad = squad[0]
  erb :editsquads 
end


# CREATE NEW SQUAD
post '/squads' do
  name = params[:name]
  mascot = params[:mascot]
  @conn.exec("INSERT INTO squads (name,mascot) VALUES($1,$2)",[name,mascot])
  redirect  '/squads'
end
 
# CREATE NEW STUDENT within a SQUAD
post '/squads/:id/students' do
  name = params[:name]
  age = params[:age]
  spirit_animal = [:spirit_animal]
  @conn.exec("INSERT INTO students (name,age,spirit_animal) VALUES ($1,$2,$3)",[name,age,spirit_animal])
  redirect  '/squads/:id/students'
end

# UPDATE
put '/squads/:squad_id' do
  id = params[:id].to_i
  name = params[:name]
  mascot = params[:mascot]
  @conn.exec("UPDATE squads SET name=$1,mascot=$2 WHERE id=$3", [name,mascot,id])
  

  redirect '/squads/ << params[:squad_id]'
end

# DESTROY
delete '/sqauds/:squad_id' do
  id = params[:id].to_i
  @conn.exec("DELETE FROM squads WHERE id=$1", [id])

  redirect '/squads'
end











