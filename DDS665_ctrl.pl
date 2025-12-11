#!/usr/bin/perl
use POSIX;
use Getopt::Long;
use Device::Modbus::RTU::Client;
use Data::Dumper;





# Init
#################################################################################################
#
# Functions & tools 
###############################################################################################
# ---------- Usage ----------
sub usage {
	$msg = @_[0];
	$cr = @_[1];
	print <<FIN_USAGE;

**********   $0 : $msg	**************
DDS 665 control tool.
** Shows DDS metrics:
      Voltage (V)              Current (A)
      Active Power (W)         Power factor (cos)
      Total energy (kWh)       Total negative energy (kWh)
      Frequency (Hz)           Total positive energy (kWh)
** -s option for DDS w/ remote switch option: turns DDS ON or OFF

Usage:  $0   [-h] [-d] [-s ON|OFF] [-p port] [-i modbus_id] [-b baud_rate]
        -p port      port to use for RS485 (default=/dev/ttyUSB0)
        -b baud      baud rate to use for RS485 (default=9600)
        -i id        modbus id to use (default=1)
        -s ON|OFF    switch DDS665 ON or OFF
        -d           activate debug mode
        -h           display help message
**********   $0 : $msg	**************
	
FIN_USAGE
	exit $cr;
}

# ---------- Float32 decoding ----------
sub decode_float32 {
    my ($hi, $lo) = @_;

    # Combine two 16bit registers into a 32bit
    my $raw = pack('n n', $hi, $lo);   # big-endian (swap if abnormal results)
    my $float = unpack('f>', $raw);    # float big-endian

    return $float;
}



#
# MAIN 
###############################################################################################

# ---------- Init vars ----------
# Comms
my $port     = "/dev/ttyUSB0";
my $baudrate = 9600;
my $slave_id = 1;
my $client, $req, $resp, $mes, $ad;
$DEBUG=0;
$SWITCH="NO";

# Address list to read according to DDS documentation
$addresses{"Voltage (V)"}=0x0000;
$addresses{"Current (A)"}=0x0002;
$addresses{"Active Power (W)"}=0x0004;
$addresses{"Power factor (cos)"}=0x0006;
$addresses{"Total energy (kWh)"}=0x0008;
$addresses{"Total negative energy (kWh)"}=0x000C;
$addresses{"Frequency (Hz)"}=0x000E;
$addresses{"Total positive energy (kWh))"}=0x000A;

# Args options
GetOptions ("help" => \$opt_h,
			"p=s" => \$port,
			"id=i" => \$slave_id,
			"baud=i" => \$baudrate,
			"switch=s" => \$opt_s,
			"debug" => \$DEBUG );

# Help
if ($opt_h) { usage("Help", 0) }

# DDS Switch
if ($opt_s) {
	if($opt_s eq "OFF") { $SWITCH=0xAAAA } 
	elsif ($opt_s eq "ON") { $SWITCH=0x5555 }
	else { usage ("Unexpected value for option -s: should be 'ON' or 'OFF', got '$opt_s'", 1) }
	}

# Init modbus client
$client = Device::Modbus::RTU::Client->new(
    port     => $port,
    baudrate => $baud,
    parity   => 'none',
    stopbits => 1,
    timeout  => 1,
	) or die "Unable to open $port / baud=$baudrate / id=$slave_id\n";



# ---------- Monitor / ctrl ----------
# DDS665 switch (OFF=write 0xAAAA in address 0x10 ; ON=write 0x5555 in address 0x10) 
if($opt_s){
	$req=$client->write_multiple_registers(
		unit     	=> $slave_id,
		address		=>0x0010,
		values		=> [$SWITCH] 
		);
	print "$opt_s (write_multiple_registers(addr=0x0010, vals=$SWITCH))-------------------\n-> " . Dumper $req if($DEBUG);
	$client->send_request($req);
	$resp = $client->receive_response;
	}

# DDS665 metrics read 
else {
	# Read input registers of selected addresses
	foreach $mes (keys(%addresses)) {
		$req = $client->read_input_registers(
							unit     => $slave_id,
							address  => $addresses{$mes},
							quantity => 2,
							);
		print "$mes --- read_input_registers(addr=$addresses{$mes}, quantity=2)---\n-> " . Dumper $req if ($DEBUG);

		$client->send_request($req);
		$resp = $client->receive_response;
		print "<- " . Dumper $resp if($DEBUG);
		@raw_val=@{$resp->values};
		print "Value of $mes = " . decode_float32($raw_val[0],$raw_val[1]) . "\n";
		}
	}
exit;

