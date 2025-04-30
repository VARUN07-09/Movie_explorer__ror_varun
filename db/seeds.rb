AdminUser.create!(
  email: 'varun19thakur@gmail.com',
  password: 'password123',
  password_confirmation: 'password123'
) unless AdminUser.exists?(email: 'varun19thakur@gmail.com')
