#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'mechanize'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

DATA_SUBDIR = 'data'
FileUtils.makedirs(DATA_SUBDIR)

class CasaRealSpider
  def initialize
    @agent = Mechanize.new
  end

  def fetch
    # TODO: Fetch http://www.casareal.es/ES/ArchivoMultimedia/Paginas/subhome_archivo_multimedia.aspx

  end
end

CasaRealSpider.new().fetch()
