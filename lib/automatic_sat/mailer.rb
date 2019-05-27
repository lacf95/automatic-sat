# frozen_string_literal: true

class AutomaticSat::Mailer
  include SendGrid

  attr_accessor :to

  def initialize(to, attach_path)
    @to = to
    @attach_path = attach_path
    @send_grid = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
  end

  def send_invoice_email(invoice_content, invoice_name)
    response = @send_grid.client.mail._('send').post(request_body: invoice_mail_content(invoice_content, invoice_name))
    response.body
  end

  private

  def invoice_mail_content(invoice_content, invoice_name)
    {
      personalizations: [{ to: @to, subject: invoice_subject }],
      from: { email: ENV['SENDGRID_FROM_EMAIL'] },
      content: [{ type: 'text/plain', value: invoice_content }],
      attachments: invoice_attachments(invoice_name, invoice_content)
    }
  end

  def invoice_attachments(invoice_name, invoice_content)
    [
      {
        content: open_file("#{invoice_name}.xml"),
        type: 'text/xml',
        filename: "#{invoice_name}.xml",
        content_id: "XML: #{invoice_content}",
        disposition: 'attachment'
      },
      {
        content: open_file("#{invoice_name}.pdf"),
        type: 'application/pdf',
        filename: "#{invoice_name}.pdf",
        content_id: "PDF: #{invoice_content}",
        disposition: 'attachment'
      }
    ]
  end

  def invoice_subject
    'Automatic SAT: Tu factura'
  end

  def open_file(file_name)
    file = AutomaticSat::FileSearcher.find_by_name(@attach_path, file_name)
    Base64.strict_encode64(File.open(file, 'rb').read)
  end
end
