require 'ruby-progressbar'
progressbar_title = "Hello"
progressbar_total = 100
some = ProgressBar.create(:title => "#{progressbar_title}", :total => progressbar_total, :progress_mark => "*")
20.times {
  some.increment
  sleep 0.1
}
some.title = "Switch Up"
20.times {
  some.increment
  sleep 0.1
}
some.finish

