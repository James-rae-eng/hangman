class Computer
    attr_reader :word, :empty_word
    def initialize
        @word = []
        @empty_word = []
    end

    def play
        word = ""
        until word.length > 4 && word.length < 13
            word = (File.readlines("google-10000-english-no-swears.txt").sample)
        end
        @word = word.split("")

        (@word.length - 1).times {@empty_word.push("_")}
        puts "The computer has selected the word below:\n"
        puts @empty_word.join(" ")   
    end
end

class User
    def initialize (word, empty_word, number_of_guesses)
        @word = word
        @running_word = empty_word
        @number_of_guesses = number_of_guesses
    end

    def guess
        if @number_of_guesses >= 0 
            puts "\nPlease type a character to guess."
            while guess = gets.chomp 
                case 
                when guess.length == 1 && guess.match(/^[a-zA-Z]+$/)
                    guess_correct?(guess.downcase)
                    break 
                when guess == "#s" || guess == "'#s'"
                    save_game()
                    break
                else 
                    puts "Invalid character, please try again"
                end
            end
        else 
            print "\nGame over, You're all out of guesses. The word was: #{@word.join("")}"
        end
    end

    def add_character(guess)
        @word.each_with_index do |value, index|
            if value == guess
                @running_word[index] = value
            end    
        end 
        puts "Update: #{@running_word.join(" ")}"
    end

    def guess_correct?(guess)
        if @word.include?(guess)
            puts "Correct! Character is in the word"
            add_character(guess)
            if !@running_word.include?("_")
                puts "\nGame over, You Win!"
            else 
                guess()
            end
        else 
            puts "Character not part of the word, you have #{@number_of_guesses} guesses left"
            @number_of_guesses -= 1
            guess()
        end
    end

    def save_game
        puts "Please enter a name for your save (this can be anything)."
        save_name = gets.chomp.to_s.downcase

        Dir.mkdir('saves') unless Dir.exist?('saves')
        filename = "saves/#{save_name}.txt"
        File.open(filename, 'w') do |file|
            file.puts @number_of_guesses 
            file.puts @running_word.join("")
            file.puts @word.join("")
        end
        
        puts "Game state saved, you can close the program or enter 'e' to exit,
        Alternatively press 'r' to resume the game."
        choice = gets.chomp.to_s.downcase
        if choice == "e"
            exit
        elsif choice == "r"
            guess()
        else
            puts "Invalid selection"
        end
    end
end
    
class Game 
puts "\n\e[1m\e[4mWelcome to Hangman\e[0m"
puts "\n\e[4mHow to play\e[0m:
In this game you play against the computer which selects a random 5-12 character word.
You'll have 6 guesses to get the word (1 letter at a time).\n"
puts "You can type '#s' at any point to save current game."
    def initialize
        @computer = Computer.new
    end

    def replay_game
        puts "\nWould you like to play again? Enter y / n"
        choice = gets.chomp.to_s.downcase
        if choice == "y"
            game = Game.new
            game.start
        elsif choice == "n"
            puts "Thanks for playing!"
        else
            puts "Invalid selection"
        end
    end

    def load_save(list_of_saves, save_num)
        save_file = "saves/#{list_of_saves[save_num-1][3..-1]}.txt"

        number_of_guesses = IO.readlines(save_file)[0].to_i
        running_word_unformat = IO.readlines(save_file)[1]
        word_unformat = IO.readlines(save_file)[2]

        running_word = running_word_unformat[0...-1].split("")
        word = word_unformat[0...-1].split("")

        puts "The partial word is: #{running_word.join(" ")}"
        @user= User.new(word, running_word, number_of_guesses)
        @user.guess
    end

    def delete_save(list_of_saves, save_num)
        save_file = "saves/#{list_of_saves[save_num-1][3..-1]}.txt"
        File.delete(save_file)
        puts "Save deleted"
        start()
    end

    def manage_save
        list_of_saves = Dir["saves/**/*.txt"].map.with_index do |name, index|
          clean_name = name.gsub("saves/", "").gsub(".txt", "")
          list_name = "#{index + 1}. #{clean_name}"
        end
        puts list_of_saves
        puts "Please type the number of the save file you wish to load"
        puts "Alternatively type the save number followed by 'd' to delete a file (e.g. 2d would delete the 2nd save)."
        
        while choice = gets.chomp
            case
            when choice.length == 1 && Integer(choice, exception: false)
                load_save(list_of_saves, choice.to_i)
                break
            when choice.length == 2
                delete_save(list_of_saves, choice.chop.to_i)
                break
            else 
                puts "Invalid entry, please try again"
            end
        end
    end

    def new_game
        puts "New game, Press Enter to continue"
        STDIN.getc
        @computer.play
        @user= User.new(@computer.word, @computer.empty_word, 6)
        @user.guess
    end

    def start
        puts "\nWould you like to load or manage a previous game from a save file? Enter y / n"
        choice = gets.chomp.to_s.downcase
        if choice == "y" && Dir["saves/*.txt"].empty?
            puts "No save files found"
            new_game()
        elsif choice == "y" && !Dir["saves/*.txt"].empty?
            manage_save()
        else 
            new_game()   
        end
        replay_game()
    end
end  

game = Game.new
game.start