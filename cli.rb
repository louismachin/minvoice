#!/usr/bin/env ruby

require_relative './invoice'
require_relative './prompt'

require 'yaml'

def main
    clear_screen
    print_header

    invoice_data = YAML.load(File.read('./invoice_data.yml'))
    client_data = File.file?('./client_data.yml') ? YAML.load(File.read('./client_data.yml')) : { 'clients' => [] }

    puts "\n• CLIENT INFORMATION"
    puts "─" * 40
    
    unless client_data['clients'].empty?
        puts client_data['clients'].map.with_index { |client, i| "#{i + 1}: #{client['to_name']}" }
        client_selection = prompt_optional("Select client (or ENTER for new client): ")
        if client_selection
            i = client_selection.to_i - 1
            to_name = client_data[i]['clients']['to_name']
            to_address = client_data[i]['clients']['to_address']
            to_phone = client_data[i]['clients']['to_phone']
        else
            puts
        end
    end

    unless to_name
        to_name = prompt("Client Name: ")
        to_prefix = prompt("Client Invoice Prefix: ")
        to_address = prompt("Client Address (use \\n for new lines): ")
        to_phone = prompt_optional("Client Phone (optional): ")
        client_data['clients'] << {
            'to_name' => to_name, 'to_prefix' => to_prefix, 'to_address' => to_address, 'to_phone' => to_phone,
        }
        File.write('./client_data.yml', client_data.to_yaml)
    end

    puts "\n• INVOICE DETAILS"
    puts "─" * 40
    invoice_number = prompt("Invoice Number: ")
    date = prompt("Invoice Date (or ENTER for today): ")
    date = Date.today.strftime("%d %B %Y") if date.empty?
    due_date = prompt_optional("Due Date (optional): ")


    puts "\n• LINE ITEMS"
    puts "─" * 40
    items = []

    loop do
    puts "\n- Item ##{items.length + 1}"
    description = prompt("  Description (or press Enter to finish): ")
    break if description.empty?

    quantity = prompt("  Quantity: ").to_i
    price = prompt("  Unit Price (£): ").to_f

    items << { description: description, quantity: quantity, price: price }
    puts "  ✓ Added: #{quantity}x #{description} @ £#{price}"
    end

    if items.empty?
        puts "\nNo items added. Exiting."
        return
    end

    puts "\n• TAX & TOTALS"
    puts "─" * 40
    tax_input = prompt("Tax rate (%, or press Enter for 0%): ")
    tax_rate = tax_input.empty? ? 0.0 : tax_input.to_f / 100.0

    subtotal = items.sum { |item| item[:quantity] * item[:price] }
    tax = subtotal * tax_rate
    total = subtotal + tax

    puts "\n• INVOICE SUMMARY"
    puts "─" * 40
    puts "Subtotal: £#{sprintf('%.2f', subtotal)}"
    puts "Tax:      £#{sprintf('%.2f', tax)}"
    puts "Total:    £#{sprintf('%.2f', total)}"

    invoice_data.merge!(
        invoice_number: invoice_number,
        date: date,
        due_date: due_date,
        to_name: to_name,
        to_address: to_address.gsub('\\n', "\n"),
        to_phone: to_phone,
        items: items,
        tax_rate: tax_rate
    )

    filename = "invoice_#{invoice_number}.pdf"

    puts "\nGenerating PDF..."
    generate_invoice(invoice_data, filename)

    puts "Invoice generated successfully!"
    puts "Saved as: #{filename}"
end

main if __FILE__ == $0