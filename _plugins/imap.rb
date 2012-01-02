=begin

require 'net/imap'

server = "imap.gmail.com"    # change this for your system
port = 993
user = "keith@marran.com"        # change this for your system
pass = "Th3B0ys!"        # change this for your system
folder = "INBOX"

imap = Net::IMAP.new(server, port, true)
imap.login(user, pass)
imap.select('INBOX')

msgs = imap.search(["FROM", "lhorn@pps.k12.or.us", "BODY", "Flash"]) 

msgs.each do |msgID| 
  msg = imap.fetch(msgID, ["ENVELOPE","UID","BODY"] )[0] 
# Only those with 'SOMETEXT' in subject are of our interest 
  if msg.attr["ENVELOPE"].subject.index('SOMETEXT') != nil 
    body = msg.attr["BODY"] 
    i = 1 
    while body.parts[i] != nil 
# additional attachments attributes 
      cType = body.parts[i].media_type 
      cName = body.parts[i].param['NAME'] 
      i+=1 
# fetch attachment. 
      attachment = imap.fetch(msgID, "BODY[#{i}]")[0].attr["BODY[#{i}]"] 
# Save message, BASE64 decoded 
      File.new(cName,'wb+').write(attachment.unpack('m')) 
    end 
  end 
end 

imap.close 
imap.logout

=end


