require 'prawn'
require 'prawn/table'
require 'date'

Prawn::Fonts::AFM.hide_m17n_warning = true

def generate_invoice(invoice_data, filename = 'invoice.pdf')
    Prawn::Document.generate(filename, page_size: 'A4', margin: 50) do |pdf|

        bg_color = 'FFFFFF' # 'EDE8E3'
        text_color = '1a1a1a'

        # Set background color
        pdf.canvas do
            pdf.fill_color bg_color
            pdf.fill_rectangle [pdf.bounds.left - 50, pdf.bounds.top + 50], pdf.bounds.width + 100, pdf.bounds.height + 100
        end
        
        pdf.fill_color text_color

        # Logo and Invoice title on same line
        logo_position = pdf.cursor

        if File.exist?('orb.jpg')
            pdf.image 'orb.jpg', at: [0, logo_position], width: 80, height: 80
        end

        pdf.bounding_box([pdf.bounds.width - 300, logo_position], width: 300) do
            pdf.text "INVOICE", size: 50, style: :bold, align: :right, character_spacing: 2
        end

        pdf.move_down 60

        # Billed to and Invoice details side by side
        bill_info_position = pdf.cursor
        
        pdf.bounding_box([0, bill_info_position], width: 300) do
            pdf.text "BILLED TO:", style: :bold, size: 11
            pdf.move_down 8
            pdf.text invoice_data[:to_name], size: 11
            pdf.move_down 4
            pdf.text invoice_data[:to_address], size: 11
            pdf.move_down 4
            pdf.text invoice_data[:to_phone], size: 11 if invoice_data[:to_phone]
        end
        
        pdf.bounding_box([pdf.bounds.width - 200, bill_info_position], width: 200) do
            pdf.text 'Shukra Software Ltd', align: :right, size: 11, style: :bold
            pdf.text "Invoice: #{invoice_data[:invoice_number]}", align: :right, size: 11
            pdf.text invoice_data[:date], align: :right, size: 11
        end
    
        pdf.move_down 80
    
        # Line items table
        table_data = [['Item', 'Quantity', 'Unit Price', 'Total']]
    
        invoice_data[:items].each do |item|
            table_data << [
                item[:description],
                item[:quantity].to_s,
                "£#{sprintf('%d', item[:price])}",
                "£#{sprintf('%d', item[:quantity] * item[:price])}"
            ]
        end

        # Calculate totals
        subtotal = invoice_data[:items].sum { |item| item[:quantity] * item[:price] }
        tax_rate = invoice_data[:tax_rate] || 0
        tax = subtotal * tax_rate
        total = subtotal + tax

        # Add subtotal and tax rows to table
        table_data << ['', '', 'Subtotal', "£#{sprintf('%d', subtotal)}"]
        table_data << ['', '', "Tax (#{(tax_rate * 100).to_i}%)", "£#{sprintf('%d', tax)}"]

        cell_style = { 
            borders: [:top, :bottom], 
            border_color: text_color,
            border_width: 0.5,
            padding: [6, 0, 6, 0],
            size: 11
        }

        pdf.table(table_data, width: pdf.bounds.width, cell_style: cell_style) do
            # Content rows (all item rows, dynamically based on item count)
            item_count = invoice_data[:items].length
            rows(1..item_count).borders = []
            # Subtotal and tax rows
            row(-2).borders = []
            row(-1).borders = []
            row(0).font_style = :bold
            row(-2).columns(2..3).font_style = :bold
            row(-1).columns(2..3).font_style = :bold
            # Align columns
            columns(1..3).align = :right
        end

        pdf.move_down 2

        # Total row with border
        pdf.stroke_color text_color
        pdf.stroke_horizontal_rule
        pdf.move_down 12
    
        content = [{ text: "Total  £#{sprintf('%d', total)}", styles: [:bold], size: 18 }]
        pdf.formatted_text_box(content, at: [pdf.bounds.width - 150, pdf.cursor], width: 150, align: :right)
    
        pdf.move_down 60
    
        pdf.text "Thank you!", size: 24, style: :bold
    
        pdf.move_down 20
    
        # Payment information and company info side by side
        footer_cursor = pdf.cursor
        
        pdf.bounding_box([0, footer_cursor], width: 300) do
            pdf.text "PAYMENT INFORMATION", style: :bold, size: 11
            pdf.move_down 8
            pdf.text "Name: #{invoice_data[:account_name]}", size: 11 if invoice_data[:account_name]
            pdf.text "Bank Name: #{invoice_data[:account_name]}", size: 11 if invoice_data[:bank_name]
            pdf.text "Account Number: #{invoice_data[:account_number]}", size: 11 if invoice_data[:account_number]
            pdf.text "Sort Code: #{invoice_data[:sort_code]}", size: 11 if invoice_data[:sort_code]
            pdf.text "Pay by: #{invoice_data[:due_date]}", size: 11 if invoice_data[:due_date]
            pdf.move_down 20
            pdf.text "Company Registration Number: #{invoice_data[:company_reg_number]}", size: 11 if invoice_data[:company_reg_number]
        end
    
        pdf.bounding_box([pdf.bounds.width - 280, footer_cursor], width: 280) do
            pdf.text "CONTACT INFORMATION", style: :bold, size: 11, align: :right
            pdf.move_down 4
            pdf.text invoice_data[:from_name], size: 11, align: :right if invoice_data[:from_name]
            pdf.move_down 4
            pdf.text invoice_data[:from_email], size: 11, align: :right if invoice_data[:from_email]
            pdf.move_down 4
            pdf.text invoice_data[:from_address], size: 11, align: :right if invoice_data[:from_address]
        end
  end
  
  filename
end

invoice_data = {
    invoice_number: 'CP001',
    date: '30 September 2025',
    due_date: nil,
    website: 'https://shukra.dev',
    to_name: 'Unreal Pharmacy',
    to_phone: '020 8207 7999',
    to_address: "Unit 1, 23 Temporary St.\nBorehamwood\nAB1 2ZY",
    from_name: 'Louis Machin',
    from_email: 'louis@shukra.dev',
    from_address: "Flat 1, Example Road\nSalisbury, Wiltshire\nSP1 2AB",
    account_name: 'SHUKRA SOFTWARE LTD',
    account_number: '98765432',
    sort_code: '01-02-03',
    company_reg_number: '12345678',
    items: [
        { description: 'Example Item #1', quantity: 4, price: 25 },
        { description: 'Example Item #2', quantity: 3, price: 25 },
        { description: 'Example Item #3', quantity: 2, price: 25 },
    ],
    tax_rate: 0.0
}

generate_invoice(invoice_data, 'invoice_CP001.pdf')
