## =============================================================================== ##
## OCSINVENTORY-NG                                                                 ##
## Copyleft Antoine ROBIN 2021                                                     ##
## Web : http://www.ocsinventory-ng.org                                            ##
##                                                                                 ##
## This code is open source and may be copied and modified as long as the source   ##
## code is always made freely available.                                           ##
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt** ##
## =============================================================================== ##

package Ocsinventory::Agent::Modules::Systemdservice;

sub new {
    my $name="systemdservice"; 
    

    my (undef,$context) = @_;
    my $self = {};


    $self->{logger} = new Ocsinventory::Logger ({
        config => $context->{config}
    });

    $self->{logger}->{header}="[$name]";

    $self->{context}=$context;

    $self->{structure}= {
        name => $name,
        start_handler => undef,
        prolog_writer => undef,
        prolog_reader => undef,
        inventory_handler => $name."_inventory_handler",
        end_handler => undef
    };
 
    bless $self;
}

sub systemdservice_inventory_handler {
    my $self = shift;
    my $logger = $self->{logger};
    my $common = $self->{context}->{common};
    $logger->debug("Starting systemdservice inventory plugin");

    my $file = "/tmp/systemdservice.txt";
    my $command = system("systemctl --all --type=service -print > $file");

    open(FH, '<', $file);

    my $cursor = 181;

    seek(FH, 0, 2);
    my $eof = tell(FH) - 310;
    seek(FH, $cursor, 0);

    $cursor = tell(FH);
    while($cursor <= $eof){
        my $string = <FH>;
        my @tab = split(/[[:blank:]]+|\n+/, $string);
        my $tab_size = @tab;
        my $description = "";
        for(my $i = 5; $i <= $tab_size; $i++){
                $description = $description . " " . @tab[$i];
        }
        push @{$common->{xmltags}->{SYSTEMDSERVICE}},
        {
            NAME => [@tab[1]],
            STATE => [@tab[2]],
            ACTIVITY => [@tab[3]],
            DESCRIPTION => [$description],
        };
        @tab = undef;
        $description = undef;
        $cursor = tell(FH);
    }

    close(FH);
}

1;
