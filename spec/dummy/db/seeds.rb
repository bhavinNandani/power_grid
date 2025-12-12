# spec/dummy/db/seeds.rb

puts "Seeding database..."

User.destroy_all

100.times do |i|
  u = User.create!(
    name: "User #{i + 1}",
    email: "user#{i + 1}@example.com",
    status: ["active", "inactive", "pending"].sample
  )
  
  rand(0..3).times do |j|
    u.posts.create!(title: "Post #{j + 1} by #{u.name}")
  end
end

puts "Created 100 users with posts."
