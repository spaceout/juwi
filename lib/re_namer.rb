class Renamer
  def self.rename(dirty_name)
    match_data = /^((?:.+?)(?:.20[01][0-9].?)?).s?(\d{1,2})e?x?(\d\d)/i.match(dirty_name)
    dirty_show_title = match_data[1].gsub(/20\d\d/, '')
    season_number = match_data[2].to_i
    episode_number = match_data[3].to_i
    clean_show_name = dirty_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/(\(|\))/,'').gsub(/\Wus/i, '').gsub("  ", " ").downcase.strip
    show_match = false
    episode_match = false
    matched_show_title = nil
    matched_episode_title = nil
    Tvshow.all.each do |tvshow|
      if tvshow.ttdb_show_title.gsub(/[\.\-\_\:]/, ' ').gsub("!", '').gsub("'", '').gsub(/\(us\)/i, '').gsub("  ", " ").gsub(/\(20\d\d\)/, '').downcase.strip == clean_show_name
        show_match = true
        matched_show_title = tvshow.ttdb_show_title
        if tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first == nil
          #No Matched Episode
        else
          episode_match = true
          matched_episode_title = tvshow.episodes.where("ttdb_season_number = ? AND ttdb_episode_number = ?", season_number, episode_number).first.ttdb_episode_title
        end
      end
    end
    if show_match == true && episode_match == true
      rename_to = matched_show_title + " - " '%02d' % season_number + "e" + '%02d' % episode_number + " - " + matched_episode_title
      return rename_to
    elsif show_match == true && episode_match == false
      return "#No Episode Found for: #{matched_show_title} - s#{season_number}e#{episode_number}"
    elsif show_match == false
      return "#No Matched Show Title Found for: #{dirty_show_title} - #{clean_show_name}"
    end
  end
end