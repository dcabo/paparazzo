#!/usr/bin/env ruby
# encoding: UTF-8

# Gallery with several pictures: http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=119572
# Gallery with only one picture: http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=105971
# The ID seems to start after 100000, haven't seen anything earlier than that

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'fileutils'
require 'csv'

DATA_SUBDIR = 'data'
FileUtils.makedirs(DATA_SUBDIR)

class CasaRealSpider
  def initialize
    @agent = Mechanize.new
  end

  def get_text(node, selector)
    selected_node = node.at(selector)
    return selected_node ? selected_node.text : ''
  end

  def fetch(page_number)
    # Get the page
    puts "Fetching page #{page_number}..."
    page = @agent.get("http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=#{page_number}")
    page_title = page.at('h1').text

    # ...and iterate through the pictures, storing metadata in a CSV file
    CSV.open(File.join(DATA_SUBDIR, page_number, 'metadata.csv'), 'w') do |csv|
      page.links_with(:dom_class => 'highslide').each do |picture|
        puts "  Fetching picture #{File.basename(picture.href)}..."

        # Save the linked picture...
        file = picture.click()
        file.save(File.join(DATA_SUBDIR, page_number, file.filename))

        # ...and get some metadata
        parent = picture.attributes.parent
        who = get_text(parent, 'span.who')
        description = get_text(parent, 'p.desc')
        location = get_text(parent, 'span.date')

        csv << [page_number, page_title, file.filename, who, description, location]
      end
    end
  end
end

page_number = '119572'
unless File.exists? File.join(DATA_SUBDIR, page_number)
  CasaRealSpider.new().fetch(page_number)
end
