require 'prawn'
require 'prawn/table'
require 'date'

Prawn::Fonts::AFM.hide_m17n_warning = true

def generate_proposal(proposal_data, filename = 'proposal.pdf')
    Prawn::Document.generate(filename, page_size: 'A4', margin: 50) do |pdf|
    bg_color = 'FFFFFF'
    text_color = '1a1a1a'

    pdf.canvas do
        pdf.fill_color bg_color
        pdf.fill_rectangle [pdf.bounds.left - 50, pdf.bounds.top + 50], pdf.bounds.width + 100, pdf.bounds.height + 100
    end

    pdf.fill_color text_color

    logo_position = pdf.cursor
    if File.exist?('orb.jpg')
        pdf.image 'orb.jpg', at: [0, logo_position], width: 80, height: 80
    end

    pdf.bounding_box([pdf.bounds.width - 300, logo_position], width: 300) do
        pdf.text "WORK PROPOSAL", size: 32, style: :bold, align: :right, character_spacing: 2
    end

    pdf.move_down 60

    bill_info_position = pdf.cursor

    pdf.bounding_box([0, bill_info_position], width: 300) do
        pdf.text "BILLED TO:", style: :bold, size: 11
        pdf.move_down 8
        pdf.text proposal_data[:to_name], size: 11
        pdf.move_down 4
        pdf.text proposal_data[:to_address], size: 11
        pdf.move_down 4
        pdf.text proposal_data[:to_phone], size: 11 if proposal_data[:to_phone]
    end

    pdf.bounding_box([pdf.bounds.width - 200, bill_info_position], width: 200) do
        pdf.text 'Shukra Software Ltd', align: :right, size: 11, style: :bold
        pdf.text "Proposal: #{proposal_data[:proposal_number]}", align: :right, size: 11
        pdf.text proposal_data[:date], align: :right, size: 11
    end

    pdf.move_down 80

    table_data = [['Reference', 'Item', 'Total']]

    proposal_data[:items].each do |item|
        item[:price] = item[:rate] * item[:est_time]
        table_data << [
        item[:reference],
        item[:description],
        "£#{sprintf('%d', item[:price])}"
        ]
    end

    subtotal = proposal_data[:items].sum { |item| item[:price] }
    tax_rate = proposal_data[:tax_rate] || 0
    tax = subtotal * tax_rate
    total = subtotal + tax

    table_data << ['', 'Subtotal', "£#{sprintf('%d', subtotal)}"]
    table_data << ['', "Tax (#{(tax_rate * 100).to_i}%)", "£#{sprintf('%d', tax)}"]

    cell_style = { 
        borders: [:top, :bottom], 
        border_color: text_color,
        border_width: 0.5,
        padding: [6, 0, 6, 0],
        size: 11
    }

    pdf.table(table_data, width: pdf.bounds.width, cell_style: cell_style) do
        item_count = proposal_data[:items].length
        rows(1..item_count).borders = []
        row(-2).borders = []
        row(-1).borders = []
        row(0).font_style = :bold
        row(-2).columns(1..2).font_style = :bold
        row(-1).columns(1..2).font_style = :bold
        columns(-1).align = :right
    end

    pdf.move_down 2
    pdf.stroke_color text_color
    pdf.stroke_horizontal_rule
    pdf.move_down 12

    content = [{ text: "Total  £#{sprintf('%d', total)}", styles: [:bold], size: 18 }]
    pdf.formatted_text_box(content, at: [pdf.bounds.width - 150, pdf.cursor], width: 150, align: :right)

    pdf.move_down 60
    pdf.text "Thank you!", size: 24, style: :bold
    pdf.move_down 20

    footer_cursor = pdf.cursor

    pdf.bounding_box([0, footer_cursor], width: 300) do
        pdf.text "PAYMENT INFORMATION", style: :bold, size: 11
        pdf.move_down 8
        pdf.text "Name: #{proposal_data[:account_name]}", size: 11 if proposal_data[:account_name]
        pdf.text "Bank Name: #{proposal_data[:bank_name]}", size: 11 if proposal_data[:bank_name]
        pdf.text "Account Number: #{proposal_data[:account_number]}", size: 11 if proposal_data[:account_number]
        pdf.text "Sort Code: #{proposal_data[:sort_code]}", size: 11 if proposal_data[:sort_code]
        pdf.text "Pay by: #{proposal_data[:due_date]}", size: 11 if proposal_data[:due_date]
        pdf.move_down 20
        pdf.text "Company Registration Number: #{proposal_data[:company_reg_number]}", size: 11 if proposal_data[:company_reg_number]
    end

    pdf.bounding_box([pdf.bounds.width - 280, footer_cursor], width: 280) do
        pdf.text "CONTACT INFORMATION", style: :bold, size: 11, align: :right
        pdf.move_down 4
        pdf.text proposal_data[:from_name], size: 11, align: :right if proposal_data[:from_name]
        pdf.move_down 4
        pdf.text proposal_data[:from_email], size: 11, align: :right if proposal_data[:from_email]
        pdf.move_down 4
        pdf.text proposal_data[:from_address], size: 11, align: :right if proposal_data[:from_address]
    end
    end

    filename
end

proposal_data = {
    proposal_number: 'CM001',
    date: '31 October 2025',
    due_date: nil,
    website: 'https://shukra.dev',
    to_name: 'CareMeds Ltd',
    to_phone: '020 8207 7999',
    to_address: "Unit 7, Brickfield Industrial Estate\nChandlers Ford\nSO53 4DR",
    from_name: 'Louis Machin',
    from_email: 'louis@shukra.dev',
    from_address: "Flat 2, 49 St. Marks Road\nSalisbury, Wiltshire\nSP1 3AY",
    account_name: 'SHUKRA SOFTWARE LTD',
    account_number: '57193695',
    sort_code: '04-00-06',
    company_reg_number: '15392867',
    items: [
        { reference: 'RM #1234', description: '\'EasyMAR\' MultiMeds lids and seals generation', rate: 35, est_time: 6 },
        { reference: 'RM #1245', description: '\'EasyMAR\' simple rostering implementation', rate: 35, est_time: 10 },
    ],
    tax_rate: 0.0
}

generate_proposal(proposal_data)