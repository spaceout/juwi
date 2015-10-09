module TfilesHelper
  def rename_status_tag(tfile)
    if tfile.rename_status == true
      return 'success'
    elsif tfile.rename_status == false
      return 'danger'
    else
      return nil
    end
  end
end
