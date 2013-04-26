require 'xmlsimple'

filebot_log = '/home/jemily/.filebot/history.xml'
filebot_history = XmlSimple.xml_in(filebot_log)
filebot_history['sequence'].each do |sequence|
  sequence['rename'].each do |rename|
    puts rename['from']
    match_data = /^(.*?).s?(\d?\d)e?x?(\d\d)/i.match(rename['from'])
    print match_data[1]
    print " "
    print match_data[2]
    print " "
    puts match_data[3]
  end
end
