#!/usr/bin/perl

use 5.014;
use warnings;

use NetSNMP::agent (':all');
use NetSNMP::ASN qw(ASN_OCTET_STR);

my $value = "hello world";
sub myhandler {
	my ($handler, $registration_info, $request_info, $requests) = @_;
	my $request;

	for($request = $requests; $request; $request = $request->next()) {
		my $oid = $request->getOID();
		if ($request_info->getMode() == MODE_GET) {
			# ... generally, you would calculate value from oid
			if ($oid == new NetSNMP::OID(".1.3.6.1.4.1.8072.9999.9999.7375.1.0")) {
				$request->setValue(ASN_OCTET_STR, $value);
			}
		} elsif ($request_info->getMode() == MODE_GETNEXT) {
			# ... generally, you would calculate value from oid
			if ($oid < new NetSNMP::OID(".1.3.6.1.4.1.8072.9999.9999.7375.1.0")) {
				$request->setOID(".1.3.6.1.4.1.8072.9999.9999.7375.1.0");
				$request->setValue(ASN_OCTET_STR, $value);
			}
		} elsif ($request_info->getMode() == MODE_SET_RESERVE1) {
			if ($oid != new NetSNMP::OID(".1.3.6.1.4.1.8072.9999.9999.7375.1.0")) {  # do error checking here
				$request->setError($request_info, SNMP_ERR_NOSUCHNAME);
			}
		} elsif ($request_info->getMode() == MODE_SET_ACTION) {
			# ... (or use the value)
			$value = $request->getValue();
		}
	}

}

my $agent = new NetSNMP::agent(
						# makes the agent read a my_agent_name.conf file
						'Name' => "my_agent_name",
						'AgentX' => 1
						);
$agent->register("my_agent_name", ".1.3.6.1.4.1.8072.9999.9999.7375",
				 \&myhandler);

my $running = 1;
while($running) {
		$agent->agent_check_and_process(1);
}

$agent->shutdown();
