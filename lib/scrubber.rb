class Scrubber
  def self.clean_show_title(dirty_show_title)
    clean_show_title = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/\(us\)/i, '').gsub("  ", " ").gsub(/\(20\d\d\)/, '').downcase.strip 
    return clean_show_title
  end

  def self.clean_show_title2(dirty_show_title)
    clean_show_title = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/\Wus/i, '').gsub("  ", " ").downcase.strip
    return clean_show_title
  end
end
