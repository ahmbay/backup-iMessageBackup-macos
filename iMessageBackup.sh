# This script takes in input a iMessage account input and backs its conversations up as txt files.
# It also saves its pictures that are cached localy
#Parameter is a iMessage account (email or phone number i.e. +33616.... )
if [ $# -lt 1 ]; then
echo "Enter a iMessage account (email of phone number i.e +33616.....) "
fi
login=$1
#Retrieve the text messages
sqlite3 ~/Library/Messages/chat.db "
select is_from_me,text from message where handle_id=(
select handle_id from chat_handle_join where chat_id=(
select ROWID from chat where guid='iMessage;-;$1')
)" | sed 's/1\|/me: /g;s/0\|/budy: /g' > MessageBackup.txt
#Retrieve the attached stored in the local cache
sqlite3 ~/Library/Messages/chat.db "
select filename from attachment where rowid in (
select attachment_id from message_attachment_join where message_id in (
select rowid from message where cache_has_attachments=1 and handle_id=(
select handle_id from chat_handle_join where chat_id=(
select ROWID from chat where guid='iMessage;-;$1')
)))" | cut -c 2- | awk -v home=$HOME '{print home $0}' | tr '\n' '\0' | xargs -0 -t -I fname cp fname .
