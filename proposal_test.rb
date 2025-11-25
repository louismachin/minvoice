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
      pdf.text "PROPOSAL", size: 50, style: :bold, align: :right, character_spacing: 2
    end

    pdf.move_down 60

    info_position = pdf.cursor

    pdf.bounding_box([0, info_position], width: 300) do
      pdf.text "PREPARED FOR:", style: :bold, size: 11
      pdf.move_down 8
      pdf.text proposal_data[:client_name], size: 11
      pdf.move_down 4
      pdf.text proposal_data[:client_address], size: 11
      pdf.move_down 4
      pdf.text proposal_data[:client_phone], size: 11 if proposal_data[:client_phone]
    end

    pdf.bounding_box([pdf.bounds.width - 200, info_position], width: 200) do
      pdf.text 'Shukra Software Ltd', align: :right, size: 11, style: :bold
      pdf.text "Reference: #{proposal_data[:reference]}", align: :right, size: 11
      pdf.text proposal_data[:date], align: :right, size: 11
      pdf.move_down 4
    
    #   pdf.text "Valid until: #{proposal_data[:valid_until]}", align: :right, size: 10 if proposal_data[:valid_until]
    end

    pdf.move_down 80

    # Work items section
    table_data = [['Reference', 'Work Description', 'Projected Cost']]

    total_cost = 0
    proposal_data[:work_items].each do |item|
      cost = item[:hours] * item[:rate]
      total_cost += cost
      
      table_data << [
        item[:reference],
        item[:description],
        "£#{sprintf('%d', cost)}"
      ]
    end

    cell_style = { 
      borders: [:top, :bottom], 
      border_color: text_color,
      border_width: 0.5,
      padding: [6, 8, 6, 8],
      size: 11
    }

    pdf.table(table_data, width: pdf.bounds.width, cell_style: cell_style) do
      item_count = proposal_data[:work_items].length
      rows(1..item_count).borders = []
      row(0).font_style = :bold
      columns(2).align = :right
    end

    pdf.move_down 2
    pdf.stroke_color text_color
    pdf.stroke_horizontal_rule
    pdf.move_down 12

    content = [{ text: "Total Projected Cost  £#{sprintf('%d', total_cost)}", styles: [:bold], size: 18 }]
    pdf.formatted_text_box(content, at: [pdf.bounds.width - 250, pdf.cursor], width: 250, align: :right)

    pdf.move_down 60

    # Notes section if provided
    if proposal_data[:notes] && !proposal_data[:notes].empty?
      pdf.text "NOTES", style: :bold, size: 11
      pdf.move_down 8
      pdf.text proposal_data[:notes], size: 11
      pdf.move_down 30
    end

    footer_cursor = pdf.cursor

    pdf.bounding_box([0, footer_cursor], width: 300) do
      pdf.text "TERMS", style: :bold, size: 11
      pdf.move_down 8
      pdf.text "Payment due: #{proposal_data[:payment_terms]}", size: 11 if proposal_data[:payment_terms]
      pdf.move_down 4
      pdf.text "Estimated timeline: #{proposal_data[:timeline]}", size: 11 if proposal_data[:timeline]
      pdf.move_down 20
      pdf.text "Company Registration Number: #{proposal_data[:company_reg_number]}", size: 10 if proposal_data[:company_reg_number]
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

# Example usage
proposal_data = {
  reference: 'CM-PROP001',
  date: '25 November 2025',
  valid_until: '25 December 2025',
  client_name: 'CareMeds Limited',
  client_phone: '01794 400 100',
  client_address: "Unit 7, Brickfield Lane\nChandlers Ford, Hampshire\nSO53 4DR",
  from_name: 'Louis Machin',
  from_email: 'louis@shukra.dev',
  from_address: "Flat 2, 49 St. Marks Road\nSalisbury, Wiltshire\nSP1 3AY",
  company_reg_number: '15392867',
  work_items: [
    { 
      reference: 'RM #1234', 
      description: 'Seals and lid generation for a patient and care provider',
      hours: 8,
      rate: 35
    },
    { 
      reference: 'RM #3456', 
      description: 'Integration of Tic-Tac API for medication input',
      hours: 35,
      rate: 6
    },
    { 
      reference: 'RM #3457', 
      description: 'Integration of Tic-Tac API for interaction warnings',
      hours: 35,
      rate: 5
    }
  ],
  payment_terms: 'Net 30 upon completion',
  timeline: '2-4 weeks',
  notes: 'Additional rounds of developments, features, or changes beyond the scope described may incur additional costs which will be communicated and agreed upon.'
}

generate_proposal(proposal_data)