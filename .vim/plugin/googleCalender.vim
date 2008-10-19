"Calendar起動時にフックさせる関数を指定し、GoogleCalenderを取り込む
let calendar_begin = 'GoogleCalendarImport'

"GoogleCalenderを取り込む（コマンドプロンプトがでないように！）
function! GoogleCalendarImport()
	:python <<EOF
#!/usr/bin/env python
# @see http://www.ac.cyberhome.ne.jp/~mattn/cgi-bin/blosxom.cgi/software/linux/vim/20070801190741.htm

# -*- coding: utf-8 -*-
import os
import sys
import re
import gdata.calendar.service
import gdata.service
import atom.service
import gdata.calendar
import atom
import datetime
from dateutil.relativedelta import relativedelta

schedule_sep = "-- Google Calendar --"
diarydir = os.path.expanduser("~/diary")

def datetime2diary(datetime):
    col = datetime.split("-")
    col[2] = col[2][0:2]
    return "%s/%d/%d/%d.cal" % (diarydir, int(col[0]), int(col[1]), int(col[2]))

def remove_schedule(path):
    if not os.path.isfile(path):
        return
    lines = []
    resep = re.compile("^" + schedule_sep + "$")
    fp = open(path)
    for line in fp.readlines():
        if resep.search(line):
            break
        lines.append(line)
    #print "cleaning schedule of '%s'" % path
    fp = open(path, "w")
    fp.writelines(lines)
    fp.close()

def update_schedule(path, an_event, a_when):
    dir = os.path.dirname(path)
    if not os.path.isdir(dir):
        os.makedirs(dir)
    lines = []
    resep = re.compile("^" + schedule_sep + "$")
    has_data = False
    if os.path.isfile(path):
        fp = open(path)
        for line in fp.readlines():
            if resep.search(line):
                has_data = True
            lines.append(line)
    if not has_data:
        lines.append("%s\n" % schedule_sep)
    #GTK+9される部分を削除
    r = "T([0-9][0-9]:[0-9][0-9]:[0-9][0-9]).*$"
    r2 = "T([0-9][0-9]:[0-9][0-9]):[0-9][0-9].*$"
    a_when.start_time = re.sub(r,r' \1',a_when.start_time)
    a_when.end_time = re.sub(r,r' \1',a_when.end_time)
    a_when.start_time = re.sub(r2,r' \1',a_when.start_time)
    a_when.end_time   = re.sub(r2,r' \1',a_when.end_time)
    lines.append("%s - %s\n" % (
        a_when.start_time.replace("-", "/"),
        a_when.end_time.replace("-", "/")))
    lines.append("\t%s\n" % an_event.title.text.encode("utf-8", "replace"))
    #print "updating schedule of '%s'" % path
    fp = open(path, "w")
    fp.writelines(lines)
    fp.close()

#if len(sys.argv) < 4:
#  raise Exception("invalid argument")
#if len(sys.argv) == 4:
diarydir = os.path.expanduser("C:\Documents and Settings\\asano\diary") #sys.argv[3]

# login to google calendar
cal_client = gdata.calendar.service.CalendarService()
cal_client.email = 'asano.yuki'#sys.argv[1]
cal_client.password = 'landsystem'#sys.argv[2]
cal_client.source = "Google-Calendar_Python_Sample-1.0"
cal_client.ProgrammaticLogin()

# query schedules in 3 months
today = datetime.date.today()
#このパラメータだと、Googleカレンダーのデフォルト（一番上にあるカレンダーグループのみ）取得となる
query = gdata.calendar.service.CalendarEventQuery("default", "private", "full", "")
query.start_min = str(today + relativedelta(day=1))
query.start_max = str(today + relativedelta(months=+3,day=1,days=-1))
print query
feed = cal_client.CalendarQuery(query)

# clean exising schedules
for i, an_event in enumerate(feed.entry):
  for a_when in an_event.when:
    remove_schedule(datetime2diary(a_when.start_time))

# append newer schedules
for i, an_event in enumerate(feed.entry):
  for a_when in an_event.when:
    update_schedule(datetime2diary(a_when.start_time), an_event, a_when)
EOF
":echo "取込完了"
endfunction

