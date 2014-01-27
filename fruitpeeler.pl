#!/usr/bin/perl
# fruitpeeler - rar/zip/7z passlist unrarer wrapper gui

use Tk;
use Tk::Adjuster;
use Tk::BrowseEntry;
use Tk::DialogBox;
use Tk::TList;
require Tk::ItemStyle;
use Tk::ProgressBar;
use File::Find;
use File::Path;
use File::Copy;
use Encode; #encode lang
# use utf8;
use MIME::Base64;
# binmode INP, ':encoding(UTF-8)';
# binmode OUTP, ':encoding(UTF-8)';

# Global Variables
$version = "0.36b (20140127)";
$VerboseLevel = 0;  # show verbose output, 0=none, 3=shitload
foreach (@ARGV) {
  $VerboseLevel = $1 if /^(?:--verbose=|-v)(\d+)/ && $1<4;
  if (not /^--verbose=\d|^-v\d+/) {
    print "Error: Unknown parameter! Accepted parameter:\n";
    print " --verbose=# or -v# , where # is one of 0..3\n"; exit 1;
  }
}
print "FruitPeeler $version by BF\n\n";
%bin=undef;
$bin{'rar'}{'path'}=""; # path to rar extracter
$bin{'zip'}{'path'}=""; # path to 7z/zip extracter.
$configfile = "$ENV{HOME}/.fruitpeeler" ;
$s_src = $ENV{HOME}; # default entry variable for source path
$s_dst = $ENV{HOME}; # default entry variable for destination path
#$s_src = "/cygdrive/" if isCygwin();
#$s_dst = "/cygdrive/" if isCygwin();
@cygpaths = undef;
@winpaths = undef;
my $cygwin_basepath = qx/cygpath -w \// if isCygwin();
chomp($cygwin_basepath)                 if isCygwin();

$s_dstchoice = "Source"; # extract to Source or destination
$dstcreatefolders = 1; #checkbox variable
$createfolders = 0; #checkbox variable
$deletearchive = 0; #checkbox variable


# Main Window

my $mw = new MainWindow(title=>"FruitPeeler $version");


# Icons

$image_arrow = $mw -> Photo(-format=>"gif", -data =>
"R0lGODlhIAAgAOf/AENEMjFOKzpMMTlPLUdMM0lONTFbL0pUNENXLyZiIR9mJCtnJjtiMUteMERj
LVNfMzNsJEdmLzZrMS1wJ0BrLE9nMUVrM1plM0tqM1JpNENuLyd4Hx17ISF7GFxnNE9sL01sNR58
IjpzKyx4LT1yNwyEFj10JUtvMTx1LUdyMkN0LT12LQSLEkl0NE9zNEl1NVB0NSqCIE13MVd0N4Fm
Tkl6MjiBL4xlUSuGK0d+LmN0P3FwQEh/Lz2DKlJ8NWd2NXBzO2p1QUaDK2x2PD+FLFR+N0eELEGH
LkeGNdNVh2h9Oh6WH1KHME6JKkiLK02KMmODOFmHMtFbiFSJMj2RJ4l3VtJdkBKjFoF+R2uGQlSP
MFuOMFWQMUqUK0+SMliRKnuESk6TOlWSOmeNOBynHFyROkGbKE6XLnWKRx+oHWePQUOdKmiQQo+B
amCVPk2dK2GWPzCoHnmOSpiGTJ2DXoWMTCqtFyatI0+gLVycNFChLiiuJDuoKXCWQYaPVE2lKYeQ
VXCbPrCEareEbD6wHTSzH16lNE6sJj2xKVOqLja0IV+mNUGyID6yKk2tMDe1InWgQ36dSUKzIWuk
PZiWSn+eSlGvKjm3I12rMYibUYWdSjq4JVOxLDu5Jka3JWmqQnmlR021Lke4JlqxNT67KUi5KJed
VZadW4qiT0C8Kkq6KUS9IEG9K1C4MXeqS3WsPnOsRUK+LFS5KUe/I069LVS7NVy5NI+nVE++LlC/
L1i9Ln+wSoitUFHBMLqcapSqUXuzREzEKFXCJ1vAMIOyRa2iamO+Ma2kWVbDKW26QHq3P1fEKlXE
NF3CM3W6QVjFK5KwVFbFNVrGLIe3SVvHLn67Q3G/RG3BPVzIL2LGN2nEN13JMGXHL4G+R2TIOou7
TWfJMmDMM4m+SGHNNGbLPHXHO2LONYXCSmzONmXQN23POMaugGbSOc2te27QOY/FTm/ROnzOQnHS
O3PUPX/RRXTWP4bRTnbYQYPVSaLKXXnaQ4XXS6LQWo3dSYjhS////yH+EUNyZWF0ZWQgd2l0aCBH
SU1QACH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGDCBMqzATnUzKFEA2aAmYNFpuIGAV+qwYq
S8aD6/LRKxdPnDNIdbBEbIfq1i9fBPnpQ4aLGrZUs5CdwyiI2Lt+vAZOSydvnr952ZrJu2kmIp1z
u/CpCfTvFK5c+uZpe+OEyJMzfOJ0gDioUrdAbj4BsiXJm7dQKD4IPEYJSowlIyDeAIMmCA1Hd7Cp
02XEyEBXcqDJCMEhYhIpVooRUiVP3RoTA8Uw2bJA4IaPrxSpk2cMAsEEAg0InPCR0yOif0QQVCCw
yD8cGD6uSiVPXhctBBlI+HfNRoCPfpBRS+etiZeCFQQQ+Cgw0qp06XQRQUI9YZ/X2GS1OcnRHaEO
O+mwSaJCofzBKmSo5cJlxoH7g1dSSct1SMN9gyw8Ip8qPTzx30BtlLBHKqk8gkgj+9gTBgndaTLD
F7SkccUjikjCDC3IMGJGCt1F8YYqtKiiCoOP5EJNNKG0UEN5D4Dwhi7cyDdfNJi4wMN9PwzAxSjg
1FKLJYbAEMGBQCCAQiJ5LJJHEQVMcuA/czSgwhRjlHGABVcO5MEJLWQAgDJhDjQEBgcokSZBO1zw
5oEBAQA7");

$image_browse = $mw -> Photo(-format=>"gif", -data =>
"R0lGODlhIAAgAOMKAAAAALhI/zGWAMZr/wDcANSO/8DAwOKx/3P/SObm5v//////////////////
/////yH+EUNyZWF0ZWQgd2l0aCBHSU1QACH5BAEKAA8ALAAAAAAgACAAAAT98MlJq5UAgcv7BBmx
eeSXIaIIkuBYnSqCih5wFIGLESovy6oLoHAb5FoPgAhI+M10n0JhYLRNAQIBzPejWQBUY2AgrWpB
My4Kihm0wlXbTdlEPYUAhSIBPoLLOXV3Qnp6BiB6fGGBdV6ECnmHhQqHYkp2jl8JiZKQlABHdoN4
BqUgm3uHOUxrLC0BOaWVaDOtHXJlcUMbJ2lsFENSOFREUjlJML/AZDhjxH0uIJkcfc5u1VDKLy1v
sMclX2BwYSvgLwc33rBF3+YYwgHpAYDat1SwuYv1t6Bw6vu3bgzT5e6cQCPpAN4SVmVKu4IYrOWA
pbCGN24QqZXLyNFcBAA7");

$image_refresh = $mw -> Photo(-format=>"gif", -data =>
"R0lGODlhIAAgAOf/AA4jXQQnZgYoZwgpYgwqagAtcgwqcA4rcQAvdBEtZwMwdRItbQcxdxcvcQoz
cgwzeQ80ehsycxE1exI2dh0zdRM2fAg8gRc5eQ49gxA+hB08fRI/hR49fhRAhiA+fxZCgiE/gBhC
iRhDgyRAghlDiiVBgyZChB5FjSlEhiBGjhNKkCBHiCFHjyFIiRdLkiNJiyxHiidMjihNjzFMiSBQ
lx9RkiFRmCtPkTVPjS5RlC5SjydUnB9ZpjNVmCtXnyJaqC1YoCRbqSVcqjBZqC9aoxhgszFbpDBc
nhthtDJcpSlerDNdpipfrSpgqDpdmiFjty1hryNkuDdgqSNlsy9isS5jqzhhqjhkoDtirDFlrShn
uzNltDJmrkJjoSpovDRnrx9sxixpvjVosD1nqi1qvyFtxzdpsi5suj9qpzBswUBrqDJtwkdqojps
tUFsqTNuw0hro0JtqilxzENuqytyzURurEttpT9vuTVyukhxrzF10TtzyDp0wzl1vUlysEJ0t0d0
q0pzsUN1uEt0slFzq0R2uSd81jZ51TZ6z0B5yDh61i193zp90kJ8xVF5uC+A2kp7vlZ6rTt/zjCB
21F8tEN/wTKC3FR8u0SAwzaC5EaBxEiByk6BviuI6VGBxVeBukOF1D2G6V6CtUuGyTuJ3VOFwyOP
9zOM7j+K5UiJ2SaQ+DSO6VeJx1mKyFiMw1qLyWGKwy+V/DGW/j6U8FaRzl6PzTOX/0GU91OR4l2R
yTWY/0KV+DWZ+mSRw2GR0DeZ/0yV61SV3kWX+kaZ9Tqc/WKVzVyX1E2a40ea9miVx0mZ/GOWzkmb
+Eqc+WaZ0lmc31ub5WCb2FSd7V+d1FKf52Od23mZwmmc1Geez3Kcw3SbyGSe3F6g42Wf3XubxGSh
2GWi2WGi5muh02eh32Kj52ii4G6h2XmfzWOk6HOjz2Sl6Wqm3mOo5Wun33Gn2Wer6HOp23mp1W6r
4nKr6niq43Cw4YOt1HKy43ux44Gw3Yex2Hy14IG26YW43om84v///yH+EUNyZWF0ZWQgd2l0aCBH
SU1QACH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGDCBMS9KCwocJsdhxKLOitH5yJGK3t84cG
Y0IQVwZRslfvXr6OHgfqAHROX76X+OTJ5IfSIxtt8eC5c7euXTt2QN/RG4NxhKh04sR9AwfO3Lhy
UMmhm3dtIohI2LBNc8a1mtdu3LiFUxetxkRCyYoVW2asbTFftZw9o8bN14WJOHrlykWrL6w4OGas
uHQMWqsXEzUQctWq1StWgT4QzBPM0wSMKz6VKjVqlB8QBetAKuHRCSdMmDQ5EmGwh4OUbiDJhoQm
gMEFKQ/UKSSoz58cKREeiIPnzh0zIxxmSNLESpYsBw10aWNmihIUDrEAG4YMmTQDBg3kHDFDJYgS
GQ757NKlSxkuhDKq/PihBAgDhRhI2WJPrBFCDUTwMEQRVJSAAEIPZLEee8gQgVADNwhYxBNJZKCA
QRUYgQp77KXCGkIcABHEhFpQcYIEBwhUQAdSoCILh8N8oZAAMPyARBRhgLHGFkkAkcQZjJwSC4e8
bEJAQxHEQAWOa8hBxyGGTNLJKaYMqYswoKggUQMsKBFGGXTQocgimUypyouzSELaRA2EIEQaTyry
SCahnKLKLqvcEUJKAFAQQhJk7IHII5NYkkgWLgAQnEADPGABCzTsQEMKHiSw6KWYYhQQADs=");

$image_extract = $mw -> Photo(-format=>"gif", -data =>
"R0lGODlhIAAgAOf/AP/+y//+mf/+Zf/+M/39AP/L/v/Ly//Lmf/LZf/MM/3LAP+Z/v+Zy/+Zmf+Y
Zf+YM/2YAP9l/v9ly/9lmP9lZf9lM/1lAP8z/v8zy/8zmP8zZf8zM/0yAP0A/f0Ay/0AmP0AZf0A
Mv0AAMv//8v/y8z/mcv/Zcz/M8v9AMvL/8zMzMvLmMzLZsvLMszLAMuZ/8uYy8uYmMyYZsuYMsyZ
AMtl/8xmy8xmmMxmZstlMsxlAMsz/8syy8symMsyZcsyMswyAMsA/cwAy8wAmMwAZcwAMswAAJn/
/5n/y5n/mZj/ZZn/M5j9AJnM/5jLy5jLmJnMZpjLMpnMAJmZ/5iYy5mZmZiYZZmYM5iXAJhl/5hm
zJhlmJhlZZllM5hlAJgz/5gyy5kzmJkzZZkzM5gyAJgA/ZgAzJgAl5gAZZgAMpgAAGX//2X/y2X/
mGX/ZWb/M2X9AGXL/2bMzGbMmGbMZmXLMmbMAGWY/2aZzGWYmGWYZWaZM2WYAGVl/2ZmzGVlmGZm
ZmVlMmZlAGUz/2Uyy2UzmWUyZWUyMmYyAGUA/WUAzGUAmGYAZWYAMmYAADP//zP/zDP/mDP/ZjP/
MzL9ADPM/zLLyzLLmDLLZTLLMjPMADOZ/zKYyzOZmTOZZTOZMzKYADNm/zJlyzNmmTJlZTJlMjNm
ADMz/zIyyzMzmTIyZTMzMzIxADIA/TIAzDIAmDIAZjIAMTIAAAD9/QD9ywD9mAD9ZQD9MgD9AADL
/QDMzADMmQDMZQDMMwDMAACY/QCZzACYmACYZQCYMgCYAABl/QBmzABlmABmZgBmMgBmAAAy/QAz
zAAymAAzZgAyMgAyAAAA/QAAzAAAmAAAZgAAMu4AANwAALoAAKoAAIgAAHYAAFQAAEQAACIAABAA
AADuAADcAAC6AACqAACIAAB2AABUAABEAAAiAAAQAAAA7gAA3AAAugAAqgAAiAAAdgAAVAAARAAA
IgAAEO7u7t3d3bu7u6qqqoiIiHd3d1VVVURERCIiIhEREQAAAP///yH+EUNyZWF0ZWQgd2l0aCBH
SU1QACH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGDCBMqXMiwIUJrEK0JjDgR4kSH/yRmvDhQ
I8eGGkMS9LjRoUiSKDFmpEhxpUiTBVN2xEiy5EebDGu23BmxpsqfGP0J9VdQKNB/QjdYwzYUqT+l
RIM+jejvypWk1vxldYg1qz+mWIXm0xo1YdesVsP6u3dv7FazG+JCFJqW7L58bNuSRfi0HsS4dK8K
zXp3rNa5UfcJHGytHr6/G+gO9rePcU+v/yq7xYat8WNrgP3hI3v5L1WklcF2tobvM9TDl/1CrMeP
stOhXyO2Ll0anz5s/PSVRWr462rW+i7LhYjtt77RihePxs25uu/Y/KqDHY7baPfO1yElBufcvWjT
gdQvP+8+XKG/4pwRlw86fSh53EDZ3zZ6dH///wYFBAA7");


# Path Frame

my $frm_path = $mw -> Frame();
my $lbl_src = $frm_path -> Label(-text=>"Source:     ");
my $ent_src = $frm_path -> BrowseEntry(-label=>"",-variable=>\$s_src,
                                       -browsecmd=>\&setPath_src,
                                       -listcmd=>\&populatelistbox_source,
                                       -width=>73, -listheight=>20);
$ent_src -> Subwidget('arrow') -> configure(-image=>$image_arrow,
                                            -relief=>'flat');
my $but_src = $frm_path -> Button(-text=>"Browse",
                                   -command =>\&browse_src,-relief=>'flat',
                                   -pady=>1, -image=>$image_browse);
my $lbl_choice = $frm_path -> Label(-text=>"Extract to ");
my $rdb_src = $frm_path -> Radiobutton(-text=>"Source", -value=>"Source",
                                       -variable=>\$s_dstchoice,
                                       -command=>\&rdb_change );
my $rdb_dst = $frm_path -> Radiobutton(-text     =>"Destination",
                                       -value    =>"Destination",
                                       -variable =>\$s_dstchoice, 
                                       -command  =>\&rdb_change );
my $chkb_dstcr = $frm_path -> Checkbutton(-text=>"create folders in dest based on selection",
                                            -variable=>\$dstcreatefolders,
                                            -command =>\&save_configuration);
my $lbl_dst  = $frm_path -> Label(-text=>"Destination:");
#my $ent_dst  = $frm_path -> Entry(-textvariable=>\$s_dst,
#                                  -state=>readonly, -width=>70);

my $ent_dst = $frm_path -> BrowseEntry(-label=>"",-variable=>\$s_dst,
                                       -browsecmd=>\&setPath_dst,
                                       -listcmd=>\&populatelistbox_dest,
                                       -width=>73,-listheight=>20);
$ent_dst -> Subwidget('arrow') -> configure(-image=>$image_arrow,
                                            -relief=>'flat');
my $but_dst  = $frm_path -> Button(-text=>"Browse",-relief=>'flat',
                                   -command =>\&browse_dst,
                                   -pady=>1, -image=>$image_browse );


# Passlist Frame

my $frm_plst = $mw -> Frame();
my $lbl_plst = $frm_plst -> Label(-text=>"Passwords");
my $txt_plst = $frm_plst -> Text(-width=>30, -height=>27);
my $srl_y    = $frm_plst -> Scrollbar(-orient=>'v',
                                      -command=>[yview => $txt_plst]);
my $but_plst = $frm_plst -> Button(-text=>"Save passwords",
#                                   -state=>disabled,
                                   -command=>\&save_configuration);


# Action Frame

my $frm_acti  = $mw -> Frame();
# $frm_acti->configure(-background=>'yellow');
my $but_refresh = $frm_acti -> Button(-text=>"Refresh",-image=>$image_refresh,
                                      -relief=>'flat',
                                      -command=>\&refresh_filelist );
my $lbl_acti  = $frm_acti -> Label(-text=>"Source directory");
my $tlst_acti = $frm_acti -> TList(-itemtype=>'text',
                                   -height=>21,-width=>58,-padx=>3,-pady=>0,
                                   -selectbackground=>'yellow',
                                   -selectmode=>'multiple',
                                   -command=>\&tlst_doubleclick);

my $style_dirnoitems = $mw->ItemStyle('text', -foreground => 'dark blue',
   -selectforeground => 'dark blue', -selectbackground=>'light yellow',
   -font=>'TkFixedFont 8'   );
my $style_dirhasitems = $mw->ItemStyle('text', -foreground => 'dark blue',
   -selectforeground => 'dark blue', -selectbackground=>'light yellow',
   -font=>'TkFixedFont 8 bold'   );
my $style_file = $mw->ItemStyle('text', -foreground => 'black',
   -selectforeground => 'black', -selectbackground=>'yellow',
   -font=>'TkFixedFont 8 bold'   );

my $srla_x = $frm_acti -> Scrollbar(-orient=>'horizontal',
                                    -command=>[xview=>$tlst_acti]);
my $chkb_folders = $frm_acti -> Checkbutton(-text=>"CreateFolders",
                                            -variable=>\$createfolders,
                                            -command =>\&save_configuration);
my $chkb_delete  = $frm_acti -> Checkbutton(-text=>"DeleteArchive",
                                            -variable=>\$deletearchive,
                                            -command =>\&save_configuration );
my $but_extract = $frm_acti -> Button(-text=>"Extract",-image=>$image_extract,
                            -relief=>'flat', -command=>\&extract_selected );
$tlst_acti -> bind('<Control-Key-a>', \&tlst_acti_ctrl_a_pressed);
$adj = $mw->Adjuster(-widget=>$frm_acti, -side=>'left');


#Geometry Management

$lbl_src -> grid(-row=>1,-column=>1,-sticky=>"ew");
$ent_src -> grid(-row=>1,-column=>2,-columnspan=>2,-sticky=>"ew");
$but_src -> grid(-row=>1,-column=>4,-sticky=>"ew");
$lbl_choice -> grid(-row=>2,-column=>1,-sticky=>"ew");
$rdb_src -> grid(-row=>2,-column=>2,-sticky=>"w");
$rdb_dst -> grid(-row=>3,-column=>2,-sticky=>"w");
$chkb_dstcr -> grid(-row=>3,-column=>3,-sticky=>"w");
$lbl_dst -> grid(-row=>4,-column=>1,-sticky=>"ew");
$ent_dst -> grid(-row=>4,-column=>2,-columnspan=>2,-sticky=>"ew");
$but_dst -> grid(-row=>4,-column=>4,-sticky=>"ew");
$but_refresh -> grid(-row=>1,-column=>2);
$lbl_acti  -> grid(-row=>1,-column=>1,-sticky=>"s");
$tlst_acti -> grid(-row=>2,-column=>1,-columnspan=>3,-sticky=>"ew");
$srla_x    -> grid(-row=>3,-column=>1,-columnspan=>3,-sticky=>"ew");
$chkb_folders -> grid(-row=>4,-column=>1);
$chkb_delete  -> grid(-row=>4,-column=>2);
$but_extract  -> grid(-row=>4,-column=>3);
$lbl_plst -> grid(-row=>1,-column=>1);
$txt_plst -> grid(-row=>2,-column=>1);
$srl_y    -> grid(-row=>2,-column=>2,-sticky=>"ns");
$but_plst -> grid(-row=>3,-column=>1);
$frm_path -> pack(-side=>'top', -fill=>'both', -expand=>0);
$frm_acti -> pack(-side=>'left', -fill=>'both', -expand=>1);
$adj->packAfter($frm_acti, -side => 'left');
$frm_plst -> pack(-side=>'left', -fill=>'both', -expand=>1);
$mw->minsize(683,575);
$mw->maxsize(1280,2000);


# Bindings

my ( $mw_width, $frm_height, $frm_width, $frm_width2, $ratio );
$mw->bind( $mw, '<ButtonRelease-1>' => sub {
  undef $ratio;
  $mw->update;
  my $width  = $mw->width;
  my $width2 = $frm_acti->width;
  $frm_width2 = $width2 unless $frm_width; # do once this means.
  if ($width2 != $frm_width2) {
    $tlst_acti->configure( -width=>( int(($frm_acti->reqwidth +
                                  $frm_acti->cget(-borderwidth) -13))/7) );
	  if (isCygwin()) {
      $txt_plst-> configure( -width=>( int(($width - $frm_acti->width -
                                         $txt_plst->cget(-borderwidth) -
                                         $txt_plst->cget(-padx) -
                                         $srl_y->width -14  -
                                         $srl_y->cget(-borderwidth) )/7)) );
    }
    else {
      $txt_plst-> configure( -width=>( int(($width - $frm_acti->width -
                                         $txt_plst->cget(-borderwidth) -
                                         $txt_plst->cget(-padx) -
                                         $srl_y->width -21  -
                                         $srl_y->cget(-borderwidth) )/7)) );
    }
    $frm_width2 = $width2;
  }
});
$mw->bind( $mw, '<Configure>' => sub {
  $mw->XEvent;
  my $width = $mw->width;
  my $width2 = $frm_acti->width;
  my $height = $frm_acti->height;
  $mw_width    = $width unless $mw_width;
  $frm_width   = $width2 unless $frm_width; # do once this means.
  $frm_height2 = $height unless $frm_height;
#        if ($ratio) {foreach ( $mw->geometry ) { print "$_ $ratio\n"; } }
  if ( $width == $mw_width ){ $frm_width = $width2; }
  if ( $width != $mw_width ) {
#    print "$width2 - ", $tlst_acti->reqwidth, "\n";
	if (isCygwin()) {
      $frm_acti->configure( -width => int( $width - $txt_plst->width -
                                         $txt_plst->cget(-borderwidth) -
                                         $txt_plst->cget(-padx) -
                                         $srl_y->width -8  -
                                         $srl_y->cget(-borderwidth) ));
    } else {
      $frm_acti->configure( -width => int( $width - $txt_plst->width -
                                         $txt_plst->cget(-borderwidth)*2 -
                                         $txt_plst->cget(-padx)*2 -
                                         $srl_y->width -8  -
                                         $srl_y->cget(-borderwidth)*2 ));
    }
#    $frm_acti->update;
    $tlst_acti->configure( -width=>( int(($frm_acti->reqwidth +
                                   $frm_acti->cget(-borderwidth) -13))/7) );
    $ent_src->configure( -width=>( int(($width - $lbl_src->width -
                                        $but_src->width -55 )/7)) );
#            $txt_plst-> configure( -width=>( int(($width-$frm_acti->width)/8))-3 );
    $mw_width = $width;
    $frm_width = $width2;
  }
  if ($height != $frm_height) {
	if (isCygwin()) {
      $tlst_acti->configure( -height=>( int( ($height - $but_refresh->height - 
                              $but_extract->height -
                              $tlst_acti->cget(-borderwidth)-28 ))/14 ) );
      $txt_plst->configure( -height=>( int( ($height - $lbl_plst->height - 
                             $but_plst->height -10)/15) ));
    } else {
      $tlst_acti->configure( -height=>( int( ($height - $but_refresh->height - 
                              $but_extract->height -
                              $tlst_acti->cget(-borderwidth) -32))/16 ) );
      $txt_plst->configure( -height=>( int( ($height - $lbl_plst->height - 
                              $but_plst->height -10)/15) ));
    }
    $frm_height = $height;
  }
});


# Menu

$menubar = $mw -> Menu(-tearoff=>1);
$mw -> configure(-menu => $menubar);
$mbinfo = $menubar -> cascade(-label=>"Info", -underline=>0,
                                  -tearoff => 0);
$mbupdate = $mbinfo -> command ( -label =>"Update FruitPeeler!", -underline => 0,
  -command => sub { 
	eval {
    require LWP::UserAgent;
    my $ua2 = LWP::UserAgent->new(timeout => 60, agent => 'FruitPeeler $version');
	
  };
  unless($@)
  {
    # required module loaded
    my $verifyhost = $ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME}; # remember it.
    $ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME}=0;
    my $ua2 = LWP::UserAgent->new(timeout => 60, agent => 'FruitPeeler $version');
		my $url = "https://raw.github.com/bitterfruit/fruitpeeler-perltk/master/fruitpeeler.pl";
    print "we made it\n";
    my $res;
    MAIN: for my $retries (0..2) {
      printf('Fetching %s..', $url);
      $res = $ua2->get($url);
      if ($res->is_success) {
         printf("OK (%.2f KiB)\n", length($res->content) / 1024);
         updatefruitpeeler($res->content);
         $ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME} = $verifyhost;
         return;
      } else {
         print color 'yellow';
         printf("FAILED (%s)!\n", $res->status_line);
         print color 'reset';
      }
      last if $res->status_line =~ /^(400|401|403|404|405|406|407|410)/;
      sleep(2) if $retries<4;
    }
    $ENV{ PERL_LWP_SSL_VERIFY_HOSTNAME} = $verifyhost;
    $mw -> messageBox(-type=>"ok", -message=>"Unable to snag the latest FruitPeeler version.");
  }
  else {
    # required module NOT loaded
    print "Error: You need LWP::UserAgent get it with \"cpan LWP::UserAgent\")\n";
  }


} );
                            
sub updatefruitpeeler {
  my $html = shift;
  return if $html eq "";
  my $path = "/usr/bin" if -d "/usr/bin";
  $path = "/usr/local/bin" if -d "/usr/local/bin";
  if (-f "/usr/bin/fruitpeeler" && -d "/usr/local/bin" ) {
    system("rm -v /usr/bin/fruitpeeler")
  }
  print "writing ". $path."/fruitpeeler"."\n";
  open(FILE,">",$path."/fruitpeeler") or die $!;
  binmode(FILE);
  print FILE $html;
  close(FILE);
  chmod(755, $path."/fruitpeeler");
  $mw -> messageBox(-type=>"ok", -message=>"FruitPeeler updated. Press OK to restart FruitPeeler.");
  system("fruitpeeler&"); exit;
#  check_dir("FruitPeelerTEMP");
  #my $isSave=0;
  #my $md5 = "";
  #my $base64data = "";
  #foreach ( split /\n/, $html ) {
  #  $isSave=0 if /---end base64---/;
  #  $base64data = $base64data ."$_\n" if $isSave;
  #  $isSave=1 if /---start base64---/;
  #  $md5=lc($1) if /md5=([a-f0-9]+)/;
  #  #print FILE "$_\n" if /[a-zA-Z0-9\/\=]{50,}/;
  #}
  #$base64data=~tr#A-Za-z0-9+/\.\_##cd; # remove non-bas64 chars
  #$base64data=~tr#A-Za-z0-9+/# -_#; # translate sets
  #open(FILE,">","/usr/bin/fruitpeeler_new") or die $!;
  #binmode(FILE);
  #print FILE unpack("u",pack("C",32+int(length($1)*6/8)) . $1) while($base64data=~s/(.{60}|.+)//);
  #close(FILE);
  #my $md5new ="";
  #open(PS, "md5sum /usr/bin/fruitpeeler_new 2>&1 |") || die "Failed $!\n";
  #while(<PS>) {
  #  lc;
  #  #662a78de940ee83046a3be5562b670e5
  #  $md5new = $1 if /([a-f0-9]+)/;
  #}
  #print "$md5 $md5new\n";
  #if ($md5new eq $md5) {
  #  move("/usr/bin/fruitpeeler_new","/usr/bin/fruitpeeler");
  #  chmod(755, "/usr/bin/fruitpeeler");
  #  
  #  system("fruitpeeler&"); exit;
  #}
  #else {
  #  print "md5 doesn't match. update aborted.";
  #  $mw -> messageBox(-type=>"ok", -message=>"MD5 sums doesn't match. Update fail!");
  #}
  return;
#  chdir("FruitPeelerTEMP");
#  system("7z x fruitpeeler.7z");
#  system("cat fruitpeeler.pl >>/usr/bin/fruitpeeler");
#  chdir("..");
#  system("rm -r FruitPeelerTEMP");
  #print $res->content;

}

#$mbabout = $menubar -> cascade ( -label => "About", -underline=>0, -tearoff=>0,
#                                 -command=>sub { print "bblabas\n"  });


# Initialize

$mw->eventGenerate('<Configure>');
$txt_plst  -> configure(-yscrollcommand=>['set', $srl_y]);
$tlst_acti -> configure(-xscrollcommand=>['set', $srla_x]);
$chkb_folders -> deselect();
$chkb_dstcr -> deselect();
get_depacker_paths();
$mbinfo -> command( -label =>$bin{'rar'}{'path'}." (".$bin{'rar'}{'version'}.")", -underline => 0);
$mbinfo -> command( -label =>$bin{'zip'}{'path'}." (".$bin{'zip'}{'version'}.")", -underline => 0);
$mbinfo -> command(-label =>"Exit", -underline => 1, -command => sub { exit } );
load_configuration();
refresh_filelist();
# my $medialst_mw = $mw -> Listbox( -height=>21,-width=>58,
#                                   -selectbackground=>'yellow',
#                                   -selectmode=>'multiple') -> pack();
# $medialst_mw -> place();
# print "width: ", $tlst_acti->reqwidth, " height: ", $tlst_acti->reqheight,"\n";
MainLoop;


# functions

sub browse_src {
  printdeb(1, "fruitpeeler::browse_src()\n");
  my $dir="";
  if (!isCygwin() && (-f "/usr/bin/zenity") ) {
    open(PS, "/usr/bin/zenity --file-selection --directory --title=\"Select a Source Directory\" --window-icon=/usr/share/pixmaps/ZIP-File-icon_48.png |") || die "Failed $!\n";
    $dir=<PS>;
    chomp $dir;
  }
  else {
    #http://stackoverflow.com/questions/251694/how-can-i-check-if-i-have-a-perl-module-before-using-it
		eval {
      require Win32::GUI;
      $dir = Win32::GUI::BrowseForFolder( -root => 0x0000 , -editbox => 1,
                                           -directory => $s_src, -title => "Select a Source Directory",
                                           -includefiles=>0, -addexstyle => WS_EX_TOPMOST,);
    };
    unless($@)
    {
      $dir = cyg_path($dir);
      printdeb(1, "Gui Loaded successfully $dir\n");
      if ( $dir ne "" ) { # use ne for string, and != for numerics
        $s_src  = encode("windows-1252", $dir);
        setPath_src();
      }
      return;
    }
    $dir = $mw->chooseDirectory(-initialdir=>$s_src,
                                -title=>"Choose a Source Directory");
  }
  if ( $dir ne "" ) { # use ne for string, and != for numerics
    $s_src  = encode("windows-1252", $dir);
    setPath_src();
  }
}

sub setPath_src {
  printdeb("1, fruitpeeler::setPath_src()\n");
  # Put path to top of list, and erase duplicate if any.
  if ($s_src ne "") {
    $ent_src -> insert( 0, $s_src );
#   for $idx (1 .. ($ent_src->index('end')) ) {
    for $idx (1 .. 9)  {
      if ($ent_src->get($idx) eq $s_src) {
        $ent_src->delete($idx); $idx--;
        printdeb(2, "deleted setPath idx $idx\n");
      }
    }
    refresh_filelist();
    save_configuration();
  } else {
    $s_src = $ent_src->get(0);
  }
}


sub browse_dst {
  printdeb("1, fruitpeeler::browse_dst()\n");
  my $dir="";
  if (!isCygwin() && (-f "/usr/bin/zenity") ) {
    open(PS, "/usr/bin/zenity --file-selection --directory --title=\"Select a Destination Directory\" --window-icon=/usr/share/pixmaps/ZIP-File-icon_48.png |") || die "Failed $!\n";
    $dir=<PS>;
    chomp $dir;
  }
  else {
    #http://stackoverflow.com/questions/251694/how-can-i-check-if-i-have-a-perl-module-before-using-it
		eval {
      require Win32::GUI;
      $dir = Win32::GUI::BrowseForFolder( -root => 0x0000 , -editbox => 1,
            -directory => $s_dst, -title => "Select a Destination Directory",
            -includefiles=>0, -addexstyle => WS_EX_TOPMOST,);
    };
    unless($@)
    {
      $dir = cyg_path($dir);
      printdeb(2, "Gui Loaded successfully $dir\n");
      if ( $dir ne "" ) { # use ne for string, and != for numerics
        $s_dst  = encode("windows-1252", $dir);
        setPath_dst();
      }
      return;
    }
    $dir = $mw->chooseDirectory(-initialdir=>$s_dst,
                                -title=>"Choose a Destination Directory");
  }
  if ( $dir ne "" ) { # use ne for string, and != for numerics
    $s_dst  = encode("windows-1252", $dir);
    setPath_dst();
  }
}

sub setPath_dst {
  printdeb(1, "fruitpeeler::setPath_dst() s_src=$s_src\n");
  # Put path to top of list, and erase duplicate if any.
  if ($s_dst ne "") {
    $ent_dst -> insert( 0, $s_dst );
#   for $idx (1 .. ($ent_dst->index('end')) ) {
    for $idx (1 .. 9)  {
      if ($ent_dst->get($idx) eq $s_dst) {
        $ent_dst->delete($idx); last;
        printdeb(2, "deleted setPath idx $idx\n");
      }
    }
    #refresh_filelist();
    save_configuration();
  } else {
    $s_dst = $ent_dst->get(0); # give back original value after "" selected.
  }
}

sub populatelistbox_source {
# Insert removable media items (or cygdrive on cygwin).
  printdeb(1, "fruitpeeler::populatelistbox_source()\n");
  my @devices, $path, $device;
  $path = "/media/";
  $path = "/cygdrive/" if isCygwin();
  opendir(DIR, $path);
  while (defined($device = readdir(DIR))) {
    push @devices, "$path$device" if ($device !~ /\.|\.\.|floppy(.*)/);
  }
  closedir(DIR);
  @devices  = reverse sort @devices;
  my @contents = $ent_src->get('0', 'end');
  if ($#contents > 9 ) {
    for (10 .. $#contents ) { $ent_src->delete(10); }
  }
  foreach $path (@devices) {
    # make sure that load_configuration fills all 10 first entries in ent_src
    $ent_src ->  insert(10, $path );
    $ent_src ->  Subwidget('slistbox') -> itemconfigure(10,
                            -background=>'blue',-foreground=>'white');
  }
  $ent_src ->  insert(10, $ENV{HOME} );
  $ent_src ->  Subwidget('slistbox') -> itemconfigure(10,
                            -background=>'darkgreen',-foreground=>'white');
}

sub populatelistbox_dest {
# Insert removable media items (or cygdrive on cygwin).
  printdeb(1, "fruitpeeler::populatelistbox_dest()\n");
  my @devices, $path, $device;
  if (isCygwin()) { $path = "/cygdrive/"; }
  else                        { $path = "/media/";    }
  opendir(DIR, $path);
  while (defined($device = readdir(DIR))) {
    push @devices, "$path$device" if ($device !~ /\.|\.\.|floppy(.*)/);
  }
  closedir(DIR);
  @devices  = reverse sort @devices;
  my @contents = $ent_dst->get('0', 'end');
  if ( $#contents >9 ) {
    for (10 .. $#contents ) { $ent_dst->delete(10); } # clean media items
  }
  foreach $path (@devices) {
    # make sure that load_configuration fills all 10 first entries in ent_dst
    $ent_dst ->  insert(10, $path );
    $ent_dst ->  Subwidget('slistbox') -> itemconfigure(10,
                                  -background=>'blue',-foreground=>'white');
  }
  $ent_dst ->  insert(10, $ENV{HOME} );
  $ent_dst ->  Subwidget('slistbox') -> itemconfigure(10,
                             -background=>'darkgreen',-foreground=>'white');
}


sub refresh_filelist {
  printdeb(1, "fruitpeeler::refresh_filelist()\n");
  my (@files, @dirs);
  my $enc = find_encoding("utf-8");
  opendir(DIR, $s_src);
  while (defined($file = readdir(DIR))) {
#   print "refr_flst: $file\n";
    if (-d "$s_src/".$enc->decode($file) && $enc->decode($file) !~ /^\.(.*)/ ) {
      push @dirs, $enc->decode($file)."/";
    }
    else {
      if ( $file =~ /\.(7z|7z\.\d\d\d|rar|zip)$/i ) {
        push @files, $enc->decode($file);
      }
    }  
  }
  closedir(DIR);
  @dirs  = sort {uc($a) cmp uc($b)} @dirs;
  @files = sort {uc($a) cmp uc($b)} @files;
  $tlst_acti -> delete(0,'end'); # clear filelist widget entries.
  if (isCygwin()) { # workaround "/" path on cygwin..
    $tlst_acti -> insert('end', -text=>"..", -data=>1 ) if $s_src =~ /\/.+\/.+/;
  }
  else {
    $tlst_acti -> insert('end', -text=>"..", -data=>1 ) if not $s_src eq "/";
  }  
  foreach my $dir ( @dirs  ) {
    my %archives;
    my $hasarchive=0;
    #opendir(DIR, "$s_src/$dir");
    #while (defined($file = readdir(DIR))) {
    #  if (isFirstArchiveFile($file)) { $dirempty=0; last; }
    #}
    #closedir(DIR);
    list_files_recursive("$s_src/$dir", \%archives); # get files
    foreach(keys %archives) { # filter by isFirstArchive
      $hasarchive=1 if isFirstArchiveFile($_);
    }
    $tlst_acti -> insert('end', -text=>$dir, -data=>1, 
      -style=>$style_dirnoitems ) if !$hasarchive ;
    $tlst_acti -> insert('end', -text=>$dir, -data=>1, 
      -style=>$style_dirhasitems ) if $hasarchive ;
    delete @archives{keys %archives};
    %archives = (); # completely empty %HASH
    undef %archives;
  }
  foreach( @files ) { $tlst_acti -> insert('end', -text=>$_, -data=>0,
                                    -style=>$style_file); }
}


sub extract_selected {
  printdeb(1, "fruitpeeler::extract_selected()\n");
  my @passlist = split( /\n/ , $txt_plst -> get('1.0', 'end')); # build passlist
  my @archives;
  my $enc = find_encoding("utf-8");

  foreach ( $tlst_acti->info('selection') ) {
    my $entry = $tlst_acti -> entrycget( $_ , -text);
    my $isDir = $tlst_acti -> entrycget( $_ , -data);
    next if $entry eq "..";
    if ($isDir ) {
      # scan subfolder and creat arhives and destpath list
      $entry =~ s/(\/)$//; #remove last slash in dir-entry if any.
      #list_files_recursive("$s_src/$entry/", \%archives); # get files
      #foreach(keys %archives) { # filter by isFirstArchive
      #  delete($archives{$_}) if !isFirstArchiveFile($_);
      #}
      chdir("$s_src");
      find( { wanted => sub {
        if (isFirstArchiveFile($_)) {
          #printdeb(2, "find_cb: ".$File::Find::name." - "
          # .$File::Find::dir." - ".$_."\n");
          push @archives, { 'filename' => $_ ,
                             'rel_dir'  => $File::Find::dir,
                             'abs_path' => $s_src."/".$File::Find::name,
                             'dst_path' => destfolder($_,$File::Find::dir) };
        }
      }, no_chdir => 0 }, "$entry");

    } else {
      # entry is an archive, not a directory
      #print "entry is an archive: $entry\n";
      if (isFirstArchiveFile($entry)) {
        push @archives, { 'filename' => $entry ,
                           'rel_dir'  => "",
                           'abs_path' => "$s_src/$entry",
                           'dst_path' => destfolder($entry,"") };
      }
    }
  }
  if ($isVerbosa) { 
    print "\@archives:\n";
    foreach (@archives) {
      print $_->{'filename'}."-" ;
      print $_->{'rel_dir'}."-" ;
      print $_->{'abs_path'}."-" ;
      print $_->{'dst_path'}."\n" ;
    }
  }

  # extract files using archives and destpath lists.
  #    print "$entry $isDir\n";
  my $percent_done = 0; 
  my $status = "";
  my $arch = "";
  my $dest = "";
  my $top = $mw->Toplevel(-title=>'progress', -height=>10, -width=>'200', -bd=>5);
  my $progress = 
  $top->ProgressBar(-width => 15, -height => 500, -borderwidth=>2,
                   -from => 0, -to => 100,
                   -blocks => 0,
                   -variable => \$percent_done,
                   ) -> pack();
  $top->Label(-text=>'xxxxxxxxxx', -textvariable=>\$status) -> pack();
  $top->Label(-text=>'xxxxxxxxxx', -textvariable=>\$arch,
              -justify=>'left', -width=>80) -> pack();
  $top->Label(-text=>'xxxxxxxxxx', -textvariable=>\$dest,
              -justify=>'left', -width=>80) -> pack();
  my $return = 1;
  for $idx ( 0 ... $#archives ) {
    $percent_done = 100*$idx/($#archives+1);
    $status = sprintf('%s of %s', $idx+1, $#archives+1);
    my $archpath = $archives[$idx]->{'abs_path'};
    my $destpath = $archives[$idx]->{'dst_path'};
    $arch = "Archive: $archpath";
    $dest = "Dest.  : $destpath";
    if ($isVerbosa) { print "percent_done: $percent_done\n"; } 
    $top->update();
    foreach my $pass ( @passlist ) {
      $arg = "'".$bin{'rar'}{'path'}."'\ x -p\"".escape_pass($pass)."\" -o+ -ierr \"$archpath\" \"$destpath\"" if ($archpath =~ /(\.rar)$/i);
      $arg = "'".$bin{'zip'}{'path'}."' x -aoa -y -p\"$pass\" \"$archpath\" -o\"$destpath\"" if ($archpath =~ /\.(7z|7z\.001|zip)$/i);

      if (isCygwin() && $bin{'rar'}{'path'} !~ /unrar$|unrar\.exe$/) { # overide the above $arg if cygwin is true
        $arg = sprintf("'".$bin{'rar'}{'path'}."' x -o+ -ierr -p\"%s\" -- \"%s\" \"%s\"",
                        escape_pass($pass),
                        escape_path(win_path($archpath)),
                        escape_path(win_path($destpath)))
                           if ( $archpath =~ /(\.rar)$/i );
      } # keep @archives unix/cygpath style path to be usable later in the script.
      $arg = "nice -20 ".$arg; # set task to low priority
      print "$arg\n";

      my $return = system ( $arg );
      printdeb(2, "Return values: $return - ");
      my $return = ($return >> 8);
      printdeb(2, "$return\n");
      printdeb(2, "fruitpeeler::extract_selected() -> child exited with value $return\n");
      if ( $return == 0 or $return == 9 ) { # success (return==9writeerror also success, (linefeedfilename problem))
        if ( $deletearchive ) {
          if ( $archpath !~ /(.*)(\.part)(1|01|001)(\.rar)$/i &&
               $archpath !~ /(.*)(\.7z\.001)$/i ) {
            system ( "rm", "$archpath" );
          }
          if ($archpath =~ /(.*)(\.part)(1|01|001)(\.rar)$/i) {
            my $tmp = $archpath;
            $tmp =~ s/(.*)(\.part)(1|01|001)(\.rar)$/$1$2\*$4/i;
            $tmp =~ s/\ /\\ /gi;
            print "delete \'$tmp\'\n";              
            foreach my $archive (glob( $tmp )) {
              print "del glob => '$archive'\n";
              system ( "rm", "$archive") ; 
            }
          }
          if ($archpath =~ /(.*)(\.7z\.001)$/i) {
            my $tmp = $archpath;
            $tmp =~ s/(.*)(\.7z\.)001$/$1$2\*/i;
            $tmp =~ s/\ /\\ /gi;
            print "delete \'$tmp\'\n";              
            foreach my $archive (glob( $tmp )) { 
              print "del glob => '$archive'\n";
              system ( "rm", "$archive") ; 
            }
          }
        }
        my @tmppasslist = $pass;
        foreach my $tmppass ( @passlist ) {
          if ( $tmppass ne $pass ) { push(@tmppasslist, $tmppass ); }
        }
        @passlist = @tmppasslist;
        $txt_plst -> delete('1.0', 'end');
        foreach my $tmppass ( @tmppasslist ) {
          $txt_plst -> insert('end', "$tmppass\n" );
        }
        last;
      } else {
#       $mw -> messageBox(-message => 'Extract FAILED!', -type=>'Ok');
      }
    }
  } # end for 0..#archives
  
  destroy $top;
  $tlst_acti -> selectionClear();
  save_configuration();
  refresh_filelist();
}



sub isFirstArchiveFile {
# This helper function returns 1 if the file is the first part of a multi-
# part archive or a singular archive file. If a multi-part file is not the first
# part, then the function returns 0.
  my $file = shift;
  printdeb(3, "fruitpeeler::isFirstArchiveFile($file)\n");
  if (($file =~ /(.*)(\.rar)$/i && $file !~ /(.*)(\.part)(\d+)(\.rar)$/i) ||
     ($file =~ /(.*)(\.7z|\.zip)$/i ) ||
     ($file =~ /(.*)(\.part)(1|01|001)(\.rar)$/i) ||
     ($file =~ /(.*)(\.7z\.001)$/i) ) { return 1; } else { return 0; }
}

sub destfolder {
  printdeb(3, "fruitpeeler::destfolder()\n");
  my ($filename,$reldir) = @_;
  $_=$filename;
  my ($file, $ext ) = /(.*)\.(7z|7z\.001|rar|zip)$/i ;
  my $folder = $file;
  $folder =~ s/(\.part(1|01|001))$//;
  my @path;
  if ( $s_dstchoice eq 'Source' ) {
    push @path, $s_src;
    push @path, $reldir if $reldir ne "";
  }
  else {
    push @path, $s_dst;
    push @path, $reldir if $reldir ne "" && $dstcreatefolders == 1;
  }
  push @path, $folder if $createfolders == 1;
  return join( "/", @path )."/";
}

sub get_depacker_paths() {
  printdeb(1, "fruitpeeler::get_depacker_paths()\n");
  my @rarbins=();
  my @zipbins=();
  foreach my $path ( (split (/\:/, $ENV{PATH}), $ENV{HOME},"$ENV{HOME}/rar") ) {
    push @rarbins, "$path/rar" if (-f "$path/rar");
    push @rarbins, "$path/rar.exe" if (-f "$path/rar.exe");
    push @rarbins, "$path/unrar.exe" if (-f "$path/unrar.exe");
    push @rarbins, "$path/unrar"     if (-f "$path/unrar");
    #push @rarbins, "$path/unrar-nonfree" if (-f "$path/unrar-nonfree");
    #$bin{'rar'}{'path'} = "$path/rar" if (-f "$path/rar");
    #$bin{'rar'}{'path'} = "$path/rar.exe" if (-f "$path/rar.exe");
    #$bin{'rar'}{'path'} = "$path/unrar.exe" if (-f "$path/unrar.exe" and isCygwin());
    #$bin{'rar'}{'path'} = "$path/unrar"     if (-f "$path/unrar" and !isCygwin());
    $bin{'zip'}{'path'} = "$path/7z"      if (-f "$path/7z");
    $bin{'zip'}{'path'} = "$path/7z.exe"  if (-f "$path/7z.exe");
    #printdeb(2, "fruitpeeler::get_depacker_paths() -> $path - $bin{'rar'}{'path'} - $bin{'zip'}{'path'}\n");
  }
  #$bin{'rar'}{'path'} = "/usr/local/bin/unrar" if (-f "/usr/local/bin/unrar"); # where rarlinux is installed

  while( scalar(@rarbins)> 0) {
    my $path = pop @rarbins;
    printdeb(2, "found: $path\n" );
    my $version = get_bin_version($path);

    # Only store path to rar if unrar doesn't exist (prefer unrar).
    # Ignore unrar-free.
    if ($path ne "" && $version ne "unrar-free" &&
                        $bin{'rar'}{'path'} !~ /unrar$/i) {
      $bin{'rar'}{'path'} = $path;
    }
    print "Ignoring unrar-free! ($path)\n" if $version eq "unrar-free";
  }

  if (isCygwin() and $bin{'rar'}{'path'} !~ /unrar$|unrar\.exe$/) {
    printdeb(2, "fruitpeeler::get_depacker_paths()->isCygwin true\n");
    if (-e cyg_path("$ENV{PROGRAMFILES}\\WinRAR\\rar.exe")) {
      $bin{'rar'}{'path'} = cyg_path("$ENV{PROGRAMFILES}\\WinRAR\\rar.exe");
    }
    if (-e cyg_path("$ENV{ProgramW6432}\\WinRAR\\rar.exe")) {
      $bin{'rar'}{'path'} = cyg_path("$ENV{ProgramW6432}\\WinRAR\\rar.exe");
    }
  }
  if ($bin{'rar'}{'path'} eq "" || ! -f $bin{'rar'}{'path'}) { print "ERROR: Can't find rar executable.\n"; exit 1; }
  if ($bin{'zip'}{'path'} eq "" || ! -f $bin{'zip'}{'path'}) { print "ERROR: Can't find 7z executable.\n"; exit 1; }
  # finally set versions
  $bin{'rar'}{'version'} = get_bin_version($bin{'rar'}{'path'});
  $bin{'zip'}{'version'} = get_bin_version($bin{'zip'}{'path'});
  print "paths to the exec 7z\&rar was finaly set to:\n";
  print "  - ".$bin{'rar'}{'path'}." (". $bin{'rar'}{'version'}.")\n";
  print "  - ".$bin{'zip'}{'path'}." (". $bin{'zip'}{'version'}.")\n"; 
}

sub get_bin_version {
  my $path = shift;
  printdeb(2, "fruitpeeler::get_bin_version($path)\n");
  return "none" if $path eq "";
  return "winrar" if $path =~ /winrar/i;
  if (!isCygwin() || $path =~ /unrar|7z/ ) {
    my $command = "$path -V";
    $command = $path if $path =~ /7z$/;
    #print "command: $command\n";
    open(PS, "$command 2>&1 |") || die "Failed $!\n";
    while(<PS>) {
      chomp;
      #print $_."\n";
      return "rar $1"   if /^RAR ([\d\.]+) .*Alexander\ Roshal/;
      return "unrar $1" if /^UNRAR ([\d\.]+) .*Alexander\ Roshal/;
      return "p7zip-full $1" if /7\-Zip ([\d\.]+)/;
      return "unrar-free" if /unrar ([\d\.]+)$/;
    }
  }
  return "none";
}

sub load_configuration {
  printdeb(1, "fruitpeeler::load_configuration()\n");
  unless (open(FILE, '<', $configfile)) {
    printdeb(1, "Configfile not found. Creating one.\n");
    my $selecteddir="";
    if (!isCygwin()) {
      if ( (-f "/usr/bin/zenity") ) {
        open(PS, "/usr/bin/zenity --file-selection --directory --title=\"Select a Source Directory\" --window-icon=/usr/share/pixmaps/ZIP-File-icon_48.png |") || die "Failed $!\n";
        $selecteddir=<PS>;
        close(PS);
        chomp $selecteddir;
        $s_src = $selecteddir if $selecteddir ne "";
        $s_dst = $selecteddir if $selecteddir ne "";
        printdeb(1, "User selected $selecteddir as Source Directory.\n");
      }
    }
    else {
      $s_dst = $s_src;
    }
    $ent_src -> insert ('0', $s_src); # insert default source path
    $ent_dst -> insert ('0', $s_dst); # insert default destination path
    save_configuration(); # i'm, crude !
    #return;
  };
  $txt_plst -> delete('1.0','end');
  #my ($label, $data);
  my $enc = find_encoding("utf-8");
  while(<FILE>) {
    my ($label, $data) = /(srce|dste|pass|dstc|dstf|crtf|dela)\=(.*)/;
    $ent_src ->  insert('end', $enc->decode($data)) if $label eq "srce" && (-e $data);
    $ent_dst ->  insert('end', $enc->decode($data)) if $label eq "dste" && (-e $data);
    $data = decode_base64($data)          if $label eq "pass";
    $txt_plst -> insert('end', $enc->decode($data)) if $label eq "pass";
    $txt_plst -> insert('end', "\n")      if $label eq "pass";
    $s_dstchoice   = $data                if $label eq "dstc";
    $dstcreatefolders = $data             if $label eq "dstf";
    $createfolders = $data                if $label eq "crtf";
    $deletearchive = $data                if $label eq "dela";
  }
  $s_src = $ent_src->get('0'); # set browseentry to first element
  $s_dst = $ent_dst->get('0'); # ..
  my @listentries = $ent_src->get('0', 'end');
  if ($#listentries < 9) {
    for ( $#listentries .. 9 ) { $ent_src ->  insert('end', "") }
  }
  my @listentries = $ent_dst->get('0', 'end');
  if ($#listentries < 9) {
    for ( $#listentries .. 9 ) { $ent_dst ->  insert('end', "") }
  }
  close(FILE);
  rdb_change();
}

sub save_configuration {
  printdeb(1, "fruitpeeler::save_configuration()\n");
  my $enc = find_encoding("utf-8");
  open(my $fh, '>', $configfile) or die $!;
  print $fh "fruitpeeler configuration file\n\n";
#  foreach ( 0 .. $ent_src->index('end') ) {
  foreach ( 0 .. 9 ) {
    print ($fh "srce=",$enc->encode($ent_src->get($_)),"\n") if $ent_src->get($_) ne "";
  }
#  foreach ( 0 .. $ent_dst->index('end') ) {
  foreach ( 0 .. 9 ) {
    print ($fh "dste=",$enc->encode($ent_dst->get($_)),"\n") if $ent_dst->get($_) ne "";
  }
  foreach $pass ( split (/\n/, encode('utf8', $txt_plst->get('1.0','end'))) ) {
    print $fh "pass=" . encode_base64($pass,"") . "\n";
  }
  print $fh "dstc=$s_dstchoice\n";
  print $fh "dstf=$dstcreatefolders\n";
  print $fh "crtf=$createfolders\n";
  print $fh "dela=$deletearchive\n";
  close($fh);
}

sub rdb_change {
  printdeb(1, "fruitpeeler::rdb_change()\n");
  if ($s_dstchoice eq "Source" ) {
    $lbl_dst    -> configure(-state=>"disabled");
    $ent_dst    -> configure(-state=>"disabled");
    $but_dst    -> configure(-state=>"disabled");
    $chkb_dstcr -> configure(-state=>"disabled");
  } else {
    $lbl_dst    -> configure(-state=>"normal");
    $ent_dst    -> configure(-state=>"normal");
    $but_dst    -> configure(-state=>"normal");
    $chkb_dstcr -> configure(-state=>"normal");
  }
  save_configuration();
}

sub tlst_doubleclick {
  printdeb(1, "fruitpeeler::tlst_doubleclick()\n");
  $_ = $tlst_acti->info('selection');
  my $entry = $tlst_acti -> entrycget( $_ , -text);
  my $isDir = $tlst_acti -> entrycget( $_ , -data);
  if ($isDir) {
    $entry =~ s/\/$//; # remove slash at end of entry if any.
    my $newpath ="";
    $newpath = "$s_src$entry"  if ($s_src eq "/");
    $newpath = "$s_src/$entry" if !($s_src eq "/");
    if ($entry eq "..") {
      $newpath =~ s/(.*)\/.*\/\.\.$/\1/;
      $newpath = "/" if $newpath eq "";
    }
    if (-d "$newpath") { 
      $s_src = "$newpath";
      setPath_src();
    }
    else {
      refresh_filelist();
    }
  }
}

sub tlst_acti_ctrl_a_pressed {
  printdeb(1, "fruitpeeler::tlst_act_ctrl_a_pressed()\n");
  $tlst_acti -> selectionSet('1','end');
}

sub cyg_path {
  my ($path) = @_;
  printdeb(2, "fruitpeeler::cyg_path($path) -> ");
  $path =~ s/^(\w):\\/\/cygdrive\/\L$1\//;
  $path =~ s/\\/\//g;
  printdeb(2, "$path\n");
  return $path;
}

sub translate_cygpath {
  my($cygpath) = @_;
  my($winpath);
  if(isCygwin()) {
    if (defined(@cygpaths)) {
      for my $idx (0...$#cygpaths) {
        return $winpaths[$idx] if $cygpaths[$idx] eq $cygpath;
      }
    }
    $winpath = qx/cygpath -w \'$cygpath\'/;
    chomp($winpath);
    push @cygpaths, $cygpath;
    push @winpaths, $winpath;
    printdeb(2, "fruitpeeler::translate_cygpath() -> $winpath\n");
    return $winpath;
  }
  printdeb(2, "fruitpeeler::translate_cygpath() -> $cygpath\n");
  return $cygpath;
}

sub win_path {
  printdeb(2, "fruitpeeler::win_path()\n" );
  my ( $path ) = @_;
  if (not $path =~ /cygdrive\/\w/) { 
    $path = $cygwin_basepath . $path;
  };
  $path =~ s/^\/cygdrive\/(\w)$/$1\:\\/;
  $path =~ s/^\/cygdrive\/(\w)\/(.*)/$1\:\\$2/;
  $path =~ s/\//\\/g;
  #$path =~ s/\(/\\\(/g;
  #$path =~ s/\)/\\\)/g;
  #$path =~ s/\'/\\\'\\\'/g;
  return $path;
}

sub escape_path {
  my $string = shift;
  #$string =~ s/\"/\\\"/g;
  #$string =~ s/\'/\\\'/g;
  $string =~ s/\$/\\\$/g;
  $string =~ s/\\/\\\\/g;
  printdeb(2, "fruitpeeler::escape_path() -> $string\n");
  return $string;
}

sub escape_pass {
  my $string = shift;
  $string =~ s/\\/\\\\/g; # must be first.
  $string =~ s/\"/\\\"/g;
  $string =~ s/\'/\\\'/g;
  $string =~ s/\$/\\\$/g;
  printdeb(2, "escape_pass() -> $string\n");
  return $string;
}

sub isCygwin {
  my $cygwin=0;
  if (defined ($ENV{TERM})) {
    $cygwin = 1 if $ENV{TERM} eq "cygwin";
  }
  if (!$cygwin && exists($ENV{WINDIR})) {
    $cygwin = 1 if $ENV{WINDIR} =~ /WINDOWS/i;
  }
  printdeb(2, sprintf ("fruitpeeler::isCygwin() - returns %d\n", $cygwin) );
  return $cygwin;
}

sub list_files_recursive {
  my ($path, $filehash, $level) = @_;
  my $nkeys = keys %{$filehash};
  $level=0 if !defined($level);
  if ($level>0) {
    printdeb (3, "fr..::list_files_recursive() $level $nkeys -> $path\n");
  }
  else {
    printdeb (2, "fr..::list_files_recursive() $level $nkeys -> $path\n");
  }
  return if $level > 6;
  return if $nkeys > 1000;
  my @dirs =();
  opendir(DIR, $path) or print "Error: $!\n";
  while (defined(my $dir = readdir(DIR))) {
    next if $dir =~ /^\.$|^\.\.$/ig;
    if ( -d $path.$dir) {
      push @dirs, $dir;
    }
    elsif (-f $path.$dir ) {
        $filehash->{"$path"."$dir"}='';
    }
  }
  closedir(DIR);
  foreach my $dir (@dirs) {
    list_files_recursive($path.$dir."/", $filehash, $level+1);
  }
}

sub printdeb {
  my ($level,$message) = @_;
  print $message if $level <= $VerboseLevel;
}

sub check_dir {
	my ($dir) = @_;
	mkpath($dir, 0, 0755) if (! -d $dir);
}
