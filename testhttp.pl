my $html = http_get("http://192.168.137.79:8080/hello?version=0.36b");
print "length of html is ".length($html)."\n";
exit 0;

sub http_get {
  my $url = shift;
  eval {
    require LWP::UserAgent;
    my $ua2 = LWP::UserAgent->new(timeout => 60, agent => 'FruitPeeler $version');
	
  };
  unless($@)
  {
    # required module loaded
    my $ua2 = LWP::UserAgent->new(timeout => 60, agent => 'FruitPeeler $version');
    print "we made it\n";
    my $res;
    MAIN: for my $retries (0..2) {
      printf('Fetching %s..', $url);
      $res = $ua2->get($url);
      if ($res->is_success) {
         printf("OK (%.2f KiB)\n", length($res->content) / 1024);
         #updatefruitpeeler($res->content);
         return $res->content;
      } else {
         print color 'yellow';
         printf("FAILED (%s)!\n", $res->status_line);
         print color 'reset';
      }
      last if $res->status_line =~ /^(400|401|403|404|405|406|407|410)/;
      sleep(2) if $retries<4;
    }
    return "";
    #$mw -> messageBox(-type=>"ok", -message=>"Unable to snag the latest FruitPeeler version.");
  }
  else {
    # required module NOT loaded
    print "Error: Unable to use LWP::UserAgent. Looking for other options\n";
    if (-f "/usr/bin/wget") {
      my $html = "";
      print "You have wget\n";
      system("wget -O \"/tmp/fruitpeeler_http_get\" $url");
      open(TMPFILE,"<","/tmp/fruitpeeler_http_get") || die "$!";
      while (<TMPFILE>) { chomp; $html=$html.$_."\n"; }
      close(TMPFILE);
      system("rm /tmp/fruitpeeler_http_get");
      return $html;
    }
    elsif (-f "/usr/bin/curl") {
      my $html = "";
      print "You have curl\n";
      open(PS, "curl $url |");
      while (<PS>) { chomp; $html=$html.$_."\n"; }
      close(PS);
      return $html;
    }
    else {
      print "No tools no means no html. sorry.\n";
      print "You have three options to enable FruitPeeler's html snagging capabilities :\n".
            "1. Install the libwww-perl package,\n".
            "2. Install the wget package, or\n".
            "3. Install the curl package.\n".
            "(4. GTFO RTFM)\n";
      return "";
    }
  }
}

