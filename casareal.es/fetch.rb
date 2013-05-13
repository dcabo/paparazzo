#!/usr/bin/env ruby
# encoding: UTF-8

# Will fetch pictures from casareal.es galleries, going backwards in time from given starting point
# Usage:
#   fetch.rb <start_gallery_id>

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
      # Find out whether we have a gallery-type page, or just one picture
      pictures = page.links_with(:dom_class => 'highslide')
      if pictures.empty?
        # Save the picture...
        src = page.at('.detalleFoto img').attributes['src'].to_s
        puts "  Fetching picture #{File.basename(src)}..."
        file = page.image_with(:src => src).fetch
        file.save(File.join(target_folder, file.filename))

        # ...and get some metadata
        footer = page.at('div.pieFoto')
        who = get_text(footer, 'span.autor')
        description = get_text(footer, 'h2.title')
        location = get_text(footer, 'span.date')

        csv << [page_number, page_title, file.uri.to_s, who, description, location]
      else
        pictures.each do |picture|
          puts "  Fetching picture #{File.basename(picture.href)}..."

          # Save the linked picture...
          file = picture.click()
          file.save(File.join(target_folder, file.filename))

          # ...and get some metadata
          parent = picture.attributes.parent
          who = get_text(parent, 'span.who')
          description = get_text(parent, 'p.desc')
          location = get_text(parent, 'span.date')

          csv << [page_number, page_title, file.uri.to_s, who, description, location]
        end
      end
    end
  end
end

# Get starting point from command line
# TODO: Should find out the latest available gallery (from main catalogue):
# http://www.casareal.es/ES/ArchivoMultimedia/Paginas/archivo-multimedia_galerias-de-fotos.aspx
start_gallery_id = ARGV[0]
if start_gallery_id.nil?
  puts "Usage: fetch.rb <start_gallery_id>"
else
  spider = CasaRealSpider.new() 
  Integer(start_gallery_id).downto(1) do |page_number|
    spider.fetch(page_number.to_s)
    sleep(2)
  end
end