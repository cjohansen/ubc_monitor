= ubc_monitor

* http://www.cjohansen.no/projects/ubc_monitor

== DESCRIPTION:

ubc_monitor monitors resource usage in virtual servers run by
OpenVz.

Monitor /proc/user_beancounters and send an email to the systems
administrator if failcnt has increased since last time ubc_monitor
was run.

ubc_monitor uses a file (by default ~/.ubc_monitor) to keep track of
user_beancounter fail counts. When running without this file (such
as the first run) any fail count except 0 will be reported.

== SYNOPSIS:

  ubc_monitor [options]

Options:

-f --file                    Log failcounts to this file, default is ~/.ubc_monitor
-n --no-log                  Don't log fail counts (only print results to STDOUT)
-t --email-recipient [EMAIL] The recipient of report emails. If this is not set, no email is sent
-s --email-subject [SUBJECT]", "Email subject. Default value is 'VPS has increased failcounts'

== INSTALL:

  sudo gem install ubc_monitor

== LICENSE:

(The MIT License)

Copyright (c) 2008 Christian Johansen

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
