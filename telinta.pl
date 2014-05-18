use Purple;

use strict;
use warnings;

our %PLUGIN_INFO = (
    perl_api_version => 2,
    name => "Telinta Pidgin plugin",
    version => "0.1",
    summary => "Makes engineers' life a little bit easier :)",
    description => "Tracks messages in the messaging window and turns ticket numbers into links.",
    author => "Eugene Glinchuk <eugeneg\@telinta.com>",
    url => "http://telinta.com",
    load => "plugin_load",
    unload => "plugin_unload"
);

sub convert_link {
    # Matches messages which contain ticket number and converts it to a link
    $_[2] =~ s/#(\d{5,})(\s\()/<a href="https:\/\/rt.telinta.com\/Ticket\/Display.html?id=$1">#$1<\/a>$2/;
    my $num = $1;
    # Matches messages with newly created tickets and adds the 'Take' button
    if($_[2] =~ /Ticket created/ && $_[2] !~ /zenoss/)
    {
        $_[2] =~ s/$/ \(<a href="https:\/\/rt.telinta.com\/Ticket\/Display.html?Action=Take&id=$num">Take<\/a>\)/;
    }
    # Highlight warning, erorrs, alerts, recveries
    if($_[2] =~ /\(WARNING: /)
    {
        $_[2] = "<span style='background: #FFF884;'>".$_[2]."<\/span>";
    }
    if($_[2] =~ /\(CRITICAL: /)
    {
        $_[2] = "<span style='background: #FF7676;'>".$_[2]."<\/span>";
    }
    if($_[2] =~ /\(ERROR: /)
    {
        $_[2] = "<span style='background: #FFBA49;'>".$_[2]."<\/span>";
    }
    if($_[2] =~ /\(recovery: /)
    {
        $_[2] = "<span style='background: #CAFFBC;'>".$_[2]."<\/span>";
    }
    return 0;
}

sub plugin_init {
    return %PLUGIN_INFO;
}

sub plugin_load {
    my $plugin = shift;
    my $message_handle = Purple::Conversations::get_handle();
    Purple::Signal::connect($message_handle, "receiving-im-msg",
                                 $plugin, \&convert_link, $plugin);
    Purple::Signal::connect($message_handle, "receiving-chat-msg",
                                 $plugin, \&convert_link, $plugin);
}

sub plugin_unload {
    my $plugin = shift;
    Purple::Debug::info("Telinta Pidgin plugin", "plugin_unload() - Telinta Pidgin plugin is unloaded.\n");
}
