puts "Creating users..."
100.times do
  User.create!
end
puts "Created #{User.count} users"

puts "Creating segments..."
segments_data = [
  {
    slug: 'MAIL_VOICE_MESSAGES',
    name: 'Голосовые сообщения в почте',
    description: 'Эксперимент с голосовыми сообщениями'
  },
  {
    slug: 'CLOUD_DISCOUNT_30',
    name: 'Скидка 30% на облако',
    description: 'Тестирование скидки на подписку в облаке'
  },
  {
    slug: 'MAIL_GPT',
    name: 'GPT в письмах',
    description: 'Использование GPT для написания писем'
  }
]

segments_data.each do |data|
  Segment.create!(data)
end
puts "Created #{Segment.count} segments"

puts "Assigning segments to random users..."
Segment.all.each do |segment|
  segment.assign_to_random_users(30)
end

puts "Seed data completed!"
puts "Total users: #{User.count}"
puts "Total segments: #{Segment.count}"
puts "Total assignments: #{UserSegment.count}"
