class Scrubber
  def self.clean_show_title(dirty_show_title)
    clean_show_title = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub(/[\/?!'"]|\(us\)|\(20\d\d\)/i, '').gsub("  ", " ").downcase.strip 
    return clean_show_title
  end

  def self.clean_show_title2(dirty_show_title)
    clean_show_title = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/\Wus/i, '').gsub("  ", " ").downcase.strip
    return clean_show_title
  end

  def self.clean_folder_name(dirty_folder_name)
    clean_folder_name = dirty_folder_name.gsub(/[\/?:"]/,  '')
    return clean_folder_name
  end

  def self.clean_file_name(dirty_file_name)
    return Scrubber.clean_folder_name(dirty_file_name)
  end
end
