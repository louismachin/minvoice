def print_header
    puts "╔══════════════════════════════════════╗"
    puts "║ minvoice                             ║"
    puts "╚══════════════════════════════════════╝"
end

def prompt(message)
    print message
    gets.chomp
end

def prompt_optional(message)
    value = prompt(message)
    value.empty? ? nil : value
end

def clear_screen
    system('clear') || system('cls')
end