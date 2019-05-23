# frozen_string_literal: true

class AutomaticSat::DescriptionGenerator
  MONTHS = %w[Enero Febrero Marzo Abril Mayo Junio Julio Agosto Septiembre Octubre Noviembre Diciembre].freeze

  def initialize(description, options)
    @description = description
    @options = options
  end

  def parse
    @description
  end

  private

  def month_range(time)
    month = month_from_time(time)
    "1 a de #{MONTHS[month['month'] - 1]} de #{month['year']}"
  end

  def month_from_time(time)
    Hash[time.strftime('year:%Y-month:%m').split('-').map { |attribute| attribute.split(':') }]
  end
end
