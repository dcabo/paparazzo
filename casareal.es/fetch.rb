#!/usr/bin/env ruby
# encoding: UTF-8

# Some sample galleries:
#  - several pictures: http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=119572
#  - FIXME: only one picture: http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=105971
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
    # Get the page (unless we have it already)
    target_folder = File.join(DATA_SUBDIR, page_number)
    if File.exists? target_folder
      puts "Skipping page #{page_number}..."
      return
    end
    puts "Fetching page #{page_number}..."
    page = @agent.get("http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos-detalle.aspx?data=#{page_number}")

    # And check it's not blank
    page_title = page.at('h1') && page.at('h1').text
    if page_title.nil?
      # Create an empty file to avoid coming back next time. We could create an empty
      # folder, but it's less comfortable for browsing later on
      FileUtils.touch(target_folder)
      return
    end

    # ...and iterate through the pictures, storing metadata in a CSV file
    FileUtils.makedirs(target_folder)
    CSV.open(File.join(target_folder, 'metadata.csv'), 'w') do |csv|
      page.links_with(:dom_class => 'highslide').each do |picture|
        puts "  Fetching picture #{File.basename(picture.href)}..."

        # Save the linked picture...
        file = picture.click()
        file.save(File.join(target_folder, file.filename))

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

# TODO: Should find out the latest available gallery (from main catalogue):
# http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos.aspx
119570.upto(119580) do |page_number|
  CasaRealSpider.new().fetch(page_number.to_s)
end