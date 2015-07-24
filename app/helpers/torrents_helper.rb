module TorrentsHelper
  def rename_status_tag(torrent)
    if torrent.rename_status == true
      return 'success'
    elsif torrent.rename_status == false
      return 'danger'
    else
      return nil
    end
  end
end
