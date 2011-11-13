package Numpaar::Channel;
use strict;
use Encode;

sub new {
    my ($class) = @_;
    my $self = {
        "title_pattern_list" => {},
    };
    bless $self, $class;
    return $self;
}

sub putEngine {
    my ($self, $prio, $engine) = @_;
    $self->{"title_pattern_list"}->{$prio} = $engine;
}

sub pushEngine {
    my ($self, $engine) = @_;
    my @keylist = sort {$a<=>$b} keys(%{$self->{"title_pattern_list"}});
    if(!@keylist) {
        $self->{'title_pattern_list'}->{0} = $engine;
    }else {
        $self->{'title_pattern_list'}->{$keylist[@keylist-1] + 1} = $engine;
    }
}

sub getActiveEngine {
    my ($self, $win_title) = @_;
    $win_title = decode('utf8', $win_title);
    foreach my $prio (sort {$a<=>$b} keys(%{$self->{"title_pattern_list"}})) {
        my $engine = $self->{"title_pattern_list"}->{$prio};
        my $pattern = decode('utf8', $engine->{"pattern"});
        if($win_title =~ /$pattern/) {
            return $engine;
        }
    }
    return undef;
}

sub getExplanations {
    my ($self, $win_title) = @_;
    my $engine = $self->getActiveEngine($win_title);
    return $engine->getExplanations();
}

sub processCommand {
    my ($self, $connection, $command, $win_title, $status_interface) = @_;
    my $engine = $self->getActiveEngine($win_title);
    if(!defined($engine)) {
        print STDERR "No active Engine found.\n";
        return 0;
    }
    $engine->show($command);
    $engine->processCommand($connection, $command, $status_interface);
    return $engine->getStateString();
}

1;
