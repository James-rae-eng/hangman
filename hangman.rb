class Computer
    attr_reader :word, :empty_word
    def initialize
        @word = []
        @empty_word = []
    end

    def play
        if @word.length <= 4 || @word.length >= 13
            @word = (File.readlines("google-10000-english-no-swears.txt").sample).split("")
        end
        print @word.join

        (@word.length - 1).times {@empty_word.push("_")}
        puts "The computer has selected the word below:\n"
        puts @empty_word.join(" ")   
    end
end

class User
    def initialize
        @number_of_guesses = 6
        @running_word = nil
        @word = nil
    end

    def guess
        if @number_of_guesses >=1 
            puts "\nPlease type a character to guess"
            while guess = gets.chomp 
                case 
                when guess.length == 1 && guess.match(/^[a-zA-Z]+$/)
                    guess_correct?(guess.downcase)
                    break 
                else 
                    puts "Invalid character, please try again"
                end
            end
        else 
            print "You're all out of guesses, game over, better luck next time"
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

    def play(word, empty_word)
        @running_word = empty_word
        @word = word
        guess()
    end
end
    
class Game 
puts "\n\e[1m\e[4mWelcome to Hangman\e[0m"
puts "\n\e[4mHow to play\e[0m:
In this game you play against the computer which selects a random 5-12 character word.
You'll have 6 guesses to get the word (1 letter at a time).
Good luck"
    def initialize
        @computer = Computer.new
        @user= User.new
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

    def start
        puts "Press Enter to continue"
        STDIN.getc
        @computer.play
        @user.play(@computer.word, @computer.empty_word)
        replay_game()
    end
end  

game = Game.new
game.start