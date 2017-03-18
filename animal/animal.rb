require 'yaml'


def start_game
  animal_library = YAML.load_file('animals.yml')
  verb_library = YAML.load_file('verbs.yml')
  adjective_library = YAML.load_file('adjectives.yml')
  puts 'Are you ready to play? Rules answer with y or n'
  animal = { 'name' => nil, 'verbs' => [], 'adjectives' => [] }
  asked_words = []
  5.times do
    answer = ask_question(asked_words, verb_library.split(' '), adjective_library.split(' '))
    word = answer[0]
    asked_words << word
    if answer[1]
      if answer[2] == :verb
        animal['verbs'] << word
      elsif answer[2] == :adjective
        animal['adjectives'] << word
      end
    end
  end
  animal_to_ask = guess_animal(animal, animal_library)
  if animal_to_ask.nil? || animal_to_ask.empty?
    puts "I don't know, you win"
    animal_answer = 'n'
  else
    puts "Is it a #{animal_to_ask['name']}, answer y or n"
    animal_asnwer = gets.chomp.downcase
  end
  if animal_asnwer == 'y'
   puts "Yes I'm awesome"
   #add adjvectives and verbs to animal
  else
    puts "You win"
    puts "Please tell me the animals name you were thinking of."
    animal['name'] = gets.chomp.downcase
    puts "Please describe a #{animal['name']} with a adjective."
    adjective_to_add = gets.chomp.downcase
    puts "What can a #{animal['name']} do?"
    verb_to_add = gets.chomp.downcase
    animal['verbs'] << verb_to_add
    animal['adjectives'] << adjective_to_add
    animal_already_exists = false
    animal_library.each do |_ ,lib_animal|
      puts lib_animal['name']
      if lib_animal['name'] == animal['name']
        animal_already_exists = true
        lib_animal['verbs'] += animal['verbs']
        lib_animal['verbs'] << verb_to_add
        lib_animal['verbs'].uniq!.sort!
        lib_animal['adjectives'] += animal['adjectives']
        lib_animal['adjectives'] << adjective_to_add
        lib_animal['adjectives'].uniq!.sort!
      end
    end
    unless animal_already_exists
      animal_library[animal['name']] = animal
    end
    verb_library << " #{verb_to_add}" unless verb_library.include?(verb_to_add)
    adjective_library << " #{adjective_to_add}" unless adjective_library.include?(adjective_to_add)
    File.open('animals.yml','w') {|f| YAML.dump(animal_library, f)}
    File.open('verbs.yml', 'w'){|f| YAML.dump(verb_library, f)}
    File.open('adjectives.yml', 'w'){|f| YAML.dump(adjective_library, f)}
    puts "Thanks for telling me about #{animal['name']}"
  end
  puts "Do you want to play again? y or n."
  play_again = gets.chomp.downcase == 'y'
  start_game if play_again
end

def ask_question(asked_words, verb_library, adjective_library)
  [0,1].sample == 0 ? ask_verb(asked_words, verb_library) : ask_adjective(asked_words, adjective_library)
end

def ask_verb(asked_words, verb_library)
  word = verb_library.sample
  while asked_words.include?(word) do word = verb_library.sample end
  puts "Can it #{word}"
  answer = gets.chomp.downcase
  if answer == 'y'
    [word, true, :verb]
  else
    [word, false, :verb]
  end
end

def ask_adjective(asked_words, adjective_library)
  word = adjective_library.sample
  while asked_words.include?(word) do word = adjective_library.sample end
  puts "Is it #{word}"
  answer = gets.chomp.downcase
  if answer == 'y'
    [word, true, :adjective]
  else
    [word, false, :adjective]
  end
end

def guess_animal(animal, animal_library)
  exact_animal = nil
  possible_animals = []
  animal_library.each do |_ ,lib_animal|
    verb_matches = true
    animal['verbs'].each do |word|
      possible_animals << lib_animal if !possible_animals.include?(lib_animal) && lib_animal['verbs'] && lib_animal['verbs'].include?(word)
      if verb_matches && (lib_animal['verbs'].nil? || !lib_animal['verbs'].include?(word))
        verb_matches = false
      end
    end
    adjective_matches = true
    animal['adjectives'].each do |word|
      possible_animals << lib_animal if !possible_animals.include?(lib_animal) && lib_animal['adjectives'] && lib_animal['adjectives'].include?(word)
      if adjective_matches && (lib_animal['adjectives'].nil? || !lib_animal['adjectives'].include?(word))
        adjective_matches = false
      end
    end
    exact_animal = lib_animal if verb_matches && adjective_matches
  end
  if exact_animal.nil?
    possible_animals.sample
  else
    exact_animal
  end
end


start_game
